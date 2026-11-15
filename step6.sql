-- ============================================================
-- 문학연구소 step6.sql  (6단계: 관리자 매출 통계)
-- schema.sql 이 이미 실행되어 있어야 합니다.
-- Supabase 대시보드 > SQL Editor 에 붙여넣고 Run 하세요. 여러 번 실행해도 안전합니다.
-- ============================================================

-- 관리자 전용 매출 통계 함수.
-- 함수 안에서 is_admin() 을 확인하므로 관리자가 아니면 오류가 납니다.
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
    'paid_count',       (select count(*) from public.purchases where status = 'paid'),
    'paid_amount',      (select coalesce(sum(amount), 0) from public.purchases where status = 'paid'),
    'pending_count',    (select count(*) from public.purchases where status = 'pending'),
    'cancelled_count',  (select count(*) from public.purchases where status = 'cancelled'),
    'refunded_count',   (select count(*) from public.purchases where status = 'refunded'),
    'refunded_amount',  (select coalesce(sum(amount), 0) from public.purchases where status = 'refunded'),
    'by_work', (
      select coalesce(jsonb_agg(x order by x.amount desc, x.title), '[]'::jsonb)
      from (
        select w.title, count(*)::int as cnt, sum(p.amount)::int as amount
        from public.purchases p join public.works w on w.id = p.work_id
        where p.status = 'paid'
        group by w.id, w.title
      ) x
    ),
    'by_month', (
      select coalesce(jsonb_agg(x order by x.month desc), '[]'::jsonb)
      from (
        select to_char(coalesce(p.paid_at, p.created_at) at time zone 'Asia/Seoul', 'YYYY-MM') as month,
               count(*)::int as cnt, sum(p.amount)::int as amount
        from public.purchases p
        where p.status = 'paid'
        group by 1
      ) x
    )
  ) into r;

  return r;
end;
$$;

-- 실행 권한: 로그인한 사용자만 (비회원 차단). 관리자 여부는 함수 안에서 한 번 더 확인합니다.
revoke all on function public.admin_sales_stats() from public, anon;
grant execute on function public.admin_sales_stats() to authenticated;
