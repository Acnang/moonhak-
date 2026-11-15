-- ============================================================
-- 문학연구소 step7.sql  (7단계: 유료 콘텐츠 권한 - 관리자 수동 지급/회수)
-- schema.sql, step6.sql 이 이미 실행되어 있어야 합니다.
-- Supabase 대시보드 > SQL Editor 에 붙여넣고 Run 하세요. 여러 번 실행해도 안전합니다.
-- ============================================================

-- 관리자가 특정 회원에게 작품 열람 권한을 직접 지급 (결제 시스템 연결 전 테스트/이벤트/오류 보상용)
-- 결제 내역으로 오해되지 않도록 pg_provider='manual', 금액 0 으로 기록합니다.
create or replace function public.admin_grant_access(p_email text, p_work uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid;
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select id into v_user from public.profiles where lower(email) = lower(trim(p_email));
  if v_user is null then return 'no_user'; end if;
  if not exists (select 1 from public.works where id = p_work) then return 'no_work'; end if;
  if exists (select 1 from public.purchases where user_id = v_user and work_id = p_work and status = 'paid') then
    return 'already';
  end if;
  insert into public.purchases (user_id, work_id, amount, status, pg_provider, paid_at)
  values (v_user, p_work, 0, 'paid', 'manual', now());
  return 'granted';
end;
$$;

-- 수동 지급 회수: 'manual' 로 지급한 것만 회수 가능 (실제 결제 건은 8단계의 환불 절차로만 처리)
create or replace function public.admin_revoke_manual(p_purchase uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  update public.purchases set status = 'cancelled'
   where id = p_purchase and pg_provider = 'manual' and status = 'paid';
  if not found then return 'not_manual'; end if;
  return 'revoked';
end;
$$;

revoke all on function public.admin_grant_access(text, uuid), public.admin_revoke_manual(uuid) from public, anon;
grant execute on function public.admin_grant_access(text, uuid), public.admin_revoke_manual(uuid) to authenticated;
