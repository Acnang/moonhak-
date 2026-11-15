-- ============================================================
-- 문학연구소 schema.sql  (4단계)
-- Supabase 대시보드 > SQL Editor 에 붙여넣고 Run 하세요.
-- 여러 번 실행해도 안전하도록 작성되어 있습니다.
-- ============================================================

-- ------------------------------------------------------------
-- 1. 테이블
-- ------------------------------------------------------------

-- 회원 정보 (로그인 정보는 Supabase Auth가 따로 관리, 여기엔 추가 정보만)
create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  email        text,
  display_name text,
  role         text not null default 'member' check (role in ('member', 'admin')),
  created_at   timestamptz not null default now()
);

-- 분류 (고전문학 / 현대문학)
create table if not exists public.categories (
  id    bigint generated always as identity primary key,
  slug  text not null unique,
  name  text not null,
  sort  int  not null default 0
);

-- 작품 (공개 가능한 기본 정보)
create table if not exists public.works (
  id           uuid primary key default gen_random_uuid(),
  slug         text not null unique check (slug ~ '^[A-Za-z0-9_-]+$'),
  title        text not null,
  author       text not null,
  era          text,
  genre        text,
  category_id  bigint references public.categories(id),
  summary      text,
  access       text not null default 'premium' check (access in ('free', 'premium')),
  price        integer not null default 0 check (price >= 0),
  is_exam      boolean not null default false,
  is_published boolean not null default false,
  popularity   integer not null default 0,
  created_at   timestamptz not null default now()
);

-- 분석 본문 (항목별 1행). 유료 본문은 여기에 있고, 아래 RLS로 보호됩니다.
create table if not exists public.analyses (
  id          bigint generated always as identity primary key,
  work_id     uuid not null references public.works(id) on delete cascade,
  section_key text not null check (section_key in (
                'info','author','background','original','modern','analysis','attitude',
                'structure','theme','expression','points','choices','compare','summary')),
  body        jsonb not null,
  is_preview  boolean not null default false,   -- true: 미구매자에게도 보이는 미리보기 항목
  updated_at  timestamptz not null default now(),
  unique (work_id, section_key)
);

-- 작품별 PDF 파일 (실제 파일은 Storage 의 비공개 버킷 work-files 에 저장)
create table if not exists public.work_files (
  id           uuid primary key default gen_random_uuid(),
  work_id      uuid not null references public.works(id) on delete cascade,
  storage_path text not null,        -- 예: <work_id>/성산별곡.pdf
  file_name    text not null,
  created_at   timestamptz not null default now()
);

-- 구매 내역 (결제 확정은 8단계에서 서버만 수행)
create table if not exists public.purchases (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles(id) on delete cascade,
  work_id       uuid not null references public.works(id),
  amount        integer not null check (amount >= 0),
  status        text not null default 'pending' check (status in ('pending', 'paid', 'cancelled', 'refunded')),
  pg_provider   text,
  pg_payment_id text,
  created_at    timestamptz not null default now(),
  paid_at       timestamptz
);
create unique index if not exists purchases_one_paid_per_work
  on public.purchases (user_id, work_id) where status = 'paid';
create index if not exists analyses_work_idx on public.analyses (work_id);
create index if not exists work_files_work_idx on public.work_files (work_id);

-- ------------------------------------------------------------
-- 2. 새 회원가입 시 profiles 행 자동 생성
-- ------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email) values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ------------------------------------------------------------
-- 3. 권한 판별 함수 (RLS 정책에서 사용)
--    security definer: 정책 안에서 다른 테이블을 안전하게 조회하기 위함
-- ------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.has_purchased(p_work uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.purchases
    where user_id = auth.uid() and work_id = p_work and status = 'paid'
  );
$$;

-- 작품 전체(분석 본문 전체, PDF)를 볼 수 있는가: 관리자 / 공개된 무료 작품 / 구매자
create or replace function public.can_read_work(p_work uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select public.is_admin() or exists (
    select 1 from public.works w
    where w.id = p_work and w.is_published
      and (w.access = 'free' or public.has_purchased(w.id))
  );
$$;

-- 분석 항목 1개를 볼 수 있는가: 위 조건 + 공개된 작품의 미리보기 항목
create or replace function public.can_read_analysis(p_work uuid, p_preview boolean)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select public.is_admin() or exists (
    select 1 from public.works w
    where w.id = p_work and w.is_published
      and (w.access = 'free' or p_preview or public.has_purchased(w.id))
  );
$$;

-- Storage 파일 경로(<work_id>/파일명)에서 작품을 찾아 열람 가능 여부 확인
create or replace function public.can_read_work_file(p_name text)
returns boolean
language plpgsql stable security definer
set search_path = public
as $$
declare
  v_work uuid;
begin
  if public.is_admin() then
    return true;   -- 관리자는 경로와 상관없이 모든 파일을 볼 수 있음
  end if;
  begin
    v_work := split_part(p_name, '/', 1)::uuid;
  exception when others then
    return false;
  end;
  return public.can_read_work(v_work);
end;
$$;

-- ------------------------------------------------------------
-- 4. RLS (행 단위 보안) 켜기
-- ------------------------------------------------------------
alter table public.profiles   enable row level security;
alter table public.categories enable row level security;
alter table public.works      enable row level security;
alter table public.analyses   enable row level security;
alter table public.work_files enable row level security;
alter table public.purchases  enable row level security;

-- 접근 권한(GRANT): Supabase 기본값에 기대지 않고 필요한 것만 명시합니다.
-- (실제로 어떤 행을 읽고 쓸 수 있는지는 아래 RLS 정책이 최종 결정합니다)
grant usage on schema public to anon, authenticated;
grant select on public.categories, public.works, public.analyses, public.work_files to anon, authenticated;
grant insert, update, delete on public.categories, public.works, public.analyses, public.work_files to authenticated;
grant select on public.profiles, public.purchases to authenticated;
grant execute on function public.is_admin(), public.has_purchased(uuid),
  public.can_read_work(uuid), public.can_read_analysis(uuid, boolean),
  public.can_read_work_file(text) to anon, authenticated;

-- profiles: 본인 것만 조회/수정(이름만). 관리자는 전체 조회.
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles for select
  using (id = auth.uid() or public.is_admin());

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles for update
  using (id = auth.uid()) with check (id = auth.uid());

-- 클라이언트는 profiles 의 role 을 바꿀 수 없음 (display_name 만 수정 가능)
revoke insert, update, delete on public.profiles from anon, authenticated;
grant update (display_name) on public.profiles to authenticated;

-- categories: 누구나 조회, 관리자만 변경
drop policy if exists categories_select on public.categories;
create policy categories_select on public.categories for select using (true);
drop policy if exists categories_admin on public.categories;
create policy categories_admin on public.categories for all
  using (public.is_admin()) with check (public.is_admin());

-- works: 공개된 작품만 누구나 조회, 관리자는 전체 조회/변경
drop policy if exists works_select on public.works;
create policy works_select on public.works for select
  using (is_published or public.is_admin());
drop policy if exists works_admin on public.works;
create policy works_admin on public.works for all
  using (public.is_admin()) with check (public.is_admin());

-- analyses: 열람 권한이 있는 항목만 조회 (핵심 보안 정책)
drop policy if exists analyses_select on public.analyses;
create policy analyses_select on public.analyses for select
  using (public.can_read_analysis(work_id, is_preview));
drop policy if exists analyses_admin on public.analyses;
create policy analyses_admin on public.analyses for all
  using (public.is_admin()) with check (public.is_admin());

-- work_files: 열람 권한이 있는 작품의 파일 목록만 조회
drop policy if exists work_files_select on public.work_files;
create policy work_files_select on public.work_files for select
  using (public.can_read_work(work_id));
drop policy if exists work_files_admin on public.work_files;
create policy work_files_admin on public.work_files for all
  using (public.is_admin()) with check (public.is_admin());

-- purchases: 본인 구매만 조회(관리자는 전체). 클라이언트의 쓰기는 모두 금지.
drop policy if exists purchases_select on public.purchases;
create policy purchases_select on public.purchases for select
  using (user_id = auth.uid() or public.is_admin());
revoke insert, update, delete on public.purchases from anon, authenticated;

-- ------------------------------------------------------------
-- 5. Storage: 비공개 버킷 work-files (PDF)
--    열람 권한이 있는 파일만 임시 링크(서명 URL)를 만들 수 있음
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('work-files', 'work-files', false)
on conflict (id) do nothing;

drop policy if exists work_files_read on storage.objects;
create policy work_files_read on storage.objects for select
  using (bucket_id = 'work-files' and public.can_read_work_file(name));

drop policy if exists work_files_admin_insert on storage.objects;
create policy work_files_admin_insert on storage.objects for insert
  with check (bucket_id = 'work-files' and public.is_admin());

drop policy if exists work_files_admin_update on storage.objects;
create policy work_files_admin_update on storage.objects for update
  using (bucket_id = 'work-files' and public.is_admin())
  with check (bucket_id = 'work-files' and public.is_admin());

drop policy if exists work_files_admin_delete on storage.objects;
create policy work_files_admin_delete on storage.objects for delete
  using (bucket_id = 'work-files' and public.is_admin());

-- ------------------------------------------------------------
-- 6. 분류 기본 데이터
-- ------------------------------------------------------------
insert into public.categories (slug, name, sort) values
  ('classic', '고전문학', 1),
  ('modern',  '현대문학', 2)
on conflict (slug) do nothing;
