-- ============================================================
-- 문학연구소 step8.sql  (8단계: 결제 — 테스트 모드)
-- schema.sql, step6.sql, step7.sql 이 이미 실행되어 있어야 합니다.
-- Supabase 대시보드 > SQL Editor 에 붙여넣고 Run 하세요. 여러 번 실행해도 안전합니다.
--
-- ※ 이 단계의 '테스트 결제'는 실제 돈이 오가지 않습니다. PG사 계약·API 키가 없으므로
--   실제 결제(live)는 구현하지 않았고, 결제 모드가 'test' 일 때만 동작합니다.
-- ============================================================

-- 1. 서버 설정 저장소 (브라우저에서 직접 읽기/쓰기 불가)
create table if not exists public.app_settings (
  key   text primary key,
  value text not null
);
alter table public.app_settings enable row level security;          -- 정책이 없으므로 아무도 직접 접근 불가
revoke all on public.app_settings from anon, authenticated;
insert into public.app_settings (key, value) values ('payment_mode', 'off')
  on conflict (key) do nothing;
-- 결제 모드: off(결제 불가, 기본) / test(테스트 결제) / live(실결제: 아직 미구현, 사용 금지)

-- 2. 현재 결제 모드 조회 (화면 표시용)
create or replace function public.payment_mode()
returns text language sql stable security definer set search_path = public as $$
  select coalesce((select value from public.app_settings where key = 'payment_mode'), 'off');
$$;
revoke all on function public.payment_mode() from public;
grant execute on function public.payment_mode() to anon, authenticated;

-- 3. 테스트 결제: 금액은 항상 DB의 작품 가격을 사용(브라우저가 보낸 값은 쓰지 않음)
create or replace function public.test_checkout(p_work uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_w   public.works%rowtype;
begin
  if v_uid is null then return 'login'; end if;
  if public.payment_mode() <> 'test' then return 'mode_off'; end if;
  select * into v_w from public.works where id = p_work and is_published and access = 'premium';
  if not found then return 'no_work'; end if;
  if exists (select 1 from public.purchases where user_id = v_uid and work_id = p_work and status = 'paid') then
    return 'already';
  end if;
  insert into public.purchases (user_id, work_id, amount, status, pg_provider, pg_payment_id, paid_at)
  values (v_uid, p_work, v_w.price, 'paid', 'test', 'test-' || gen_random_uuid()::text, now());
  return 'ok';
end;
$$;
revoke all on function public.test_checkout(uuid) from public, anon;
grant execute on function public.test_checkout(uuid) to authenticated;

-- 4. 매출 통계 갱신: 테스트·수동 지급은 실제 매출에서 제외하고 따로 집계
create or replace function public.admin_sales_stats()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  r jsonb;
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select jsonb_build_object(
    'members',          (select count(*) from public.profiles),
    'paid_count',       (select count(*) from public.purchases where status = 'paid' and coalesce(pg_provider,'') not in ('test','manual')),
    'paid_amount',      (select coalesce(sum(amount), 0) from public.purchases where status = 'paid' and coalesce(pg_provider,'') not in ('test','manual')),
    'pending_count',    (select count(*) from public.purchases where status = 'pending'),
    'cancelled_count',  (select count(*) from public.purchases where status = 'cancelled'),
    'refunded_count',   (select count(*) from public.purchases where status = 'refunded'),
    'refunded_amount',  (select coalesce(sum(amount), 0) from public.purchases where status = 'refunded'),
    'test_count',       (select count(*) from public.purchases where status = 'paid' and pg_provider = 'test'),
    'test_amount',      (select coalesce(sum(amount), 0) from public.purchases where status = 'paid' and pg_provider = 'test'),
    'manual_count',     (select count(*) from public.purchases where status = 'paid' and pg_provider = 'manual'),
    'payment_mode',     public.payment_mode(),
    'by_work', (
      select coalesce(jsonb_agg(x order by x.amount desc, x.title), '[]'::jsonb)
      from (
        select w.title, count(*)::int as cnt, sum(p.amount)::int as amount
        from public.purchases p join public.works w on w.id = p.work_id
        where p.status = 'paid' and coalesce(p.pg_provider,'') not in ('test','manual')
        group by w.id, w.title
      ) x
    ),
    'by_month', (
      select coalesce(jsonb_agg(x order by x.month desc), '[]'::jsonb)
      from (
        select to_char(coalesce(p.paid_at, p.created_at) at time zone 'Asia/Seoul', 'YYYY-MM') as month,
               count(*)::int as cnt, sum(p.amount)::int as amount
        from public.purchases p
        where p.status = 'paid' and coalesce(p.pg_provider,'') not in ('test','manual')
        group by 1
      ) x
    )
  ) into r;

  return r;
end;
$$;
revoke all on function public.admin_sales_stats() from public, anon;
grant execute on function public.admin_sales_stats() to authenticated;
