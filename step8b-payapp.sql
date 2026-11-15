-- ============================================================
-- 문학연구소 step8b-payapp.sql  (8단계 후속: 페이앱 결제 연동용 DB 함수)
-- schema.sql, step6~8.sql 이 이미 실행되어 있어야 합니다. 여러 번 실행해도 안전합니다.
-- 아래 함수들은 '서버(Edge Function, service_role)'만 호출할 수 있습니다.
-- 브라우저(anon/authenticated)는 호출 권한이 없습니다. → 구매를 위조할 수 없습니다.
-- ============================================================

-- 1. 주문 생성: 금액은 항상 DB의 작품 가격. 결제 모드가 'payapp' 일 때만.
create or replace function public.payapp_create_order(p_user uuid, p_work uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_w public.works%rowtype;
  v_id uuid;
begin
  if public.payment_mode() <> 'payapp' then return jsonb_build_object('error', 'mode_off'); end if;
  select * into v_w from public.works where id = p_work and is_published and access = 'premium';
  if not found then return jsonb_build_object('error', 'no_work'); end if;
  if v_w.price < 1000 then return jsonb_build_object('error', 'min_price'); end if;   -- 페이앱 최소 결제금액 1,000원
  if exists (select 1 from public.purchases where user_id = p_user and work_id = p_work and status = 'paid') then
    return jsonb_build_object('error', 'already');
  end if;
  if (select count(*) from public.purchases
       where user_id = p_user and status = 'pending' and pg_provider = 'payapp' and created_at > now() - interval '1 hour') >= 5 then
    return jsonb_build_object('error', 'too_many');
  end if;
  insert into public.purchases (user_id, work_id, amount, status, pg_provider)
  values (p_user, p_work, v_w.price, 'pending', 'payapp')
  returning id into v_id;
  return jsonb_build_object('id', v_id, 'amount', v_w.price, 'title', v_w.title);
end;
$$;

-- 2. 결제요청번호(mul_no) 기록
create or replace function public.payapp_set_request(p_purchase uuid, p_mul_no text)
returns void
language sql
security definer
set search_path = public
as $$
  update public.purchases set pg_payment_id = p_mul_no
   where id = p_purchase and pg_provider = 'payapp' and status = 'pending';
$$;

-- 3. 결제 완료 확정 (feedbackurl 검증을 통과한 뒤에만 서버가 호출)
create or replace function public.payapp_confirm(p_purchase uuid, p_mul_no text, p_price integer)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  p public.purchases%rowtype;
begin
  select * into p from public.purchases where id = p_purchase and pg_provider = 'payapp' for update;
  if not found then return 'no_order'; end if;
  if p.amount <> p_price then return 'price_mismatch'; end if;
  if p.pg_payment_id is not null and p.pg_payment_id <> p_mul_no then return 'mul_mismatch'; end if;
  if p.status = 'paid' then return 'already'; end if;
  if p.status <> 'pending' then return 'bad_state'; end if;
  begin
    update public.purchases set status = 'paid', paid_at = now(), pg_payment_id = p_mul_no where id = p.id;
  exception when unique_violation then
    return 'duplicate_paid';   -- 이미 같은 작품을 결제한 회원이 또 결제함: 관리자 확인(환불) 필요
  end;
  return 'ok';
end;
$$;

-- 4. 결제 취소/환불 반영 (페이앱 취소 통보를 받았을 때)
create or replace function public.payapp_cancel(p_purchase uuid, p_mul_no text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  p public.purchases%rowtype;
begin
  select * into p from public.purchases where id = p_purchase and pg_provider = 'payapp' for update;
  if not found then return 'no_order'; end if;
  if p.pg_payment_id is not null and p.pg_payment_id <> p_mul_no then return 'mul_mismatch'; end if;
  if p.status = 'paid' then update public.purchases set status = 'refunded' where id = p.id; return 'refunded'; end if;
  if p.status = 'pending' then update public.purchases set status = 'cancelled' where id = p.id; return 'cancelled'; end if;
  return 'noop';
end;
$$;

-- 권한: service_role(서버) 전용
revoke all on function public.payapp_create_order(uuid, uuid), public.payapp_set_request(uuid, text),
  public.payapp_confirm(uuid, text, integer), public.payapp_cancel(uuid, text) from public, anon, authenticated;
grant execute on function public.payapp_create_order(uuid, uuid), public.payapp_set_request(uuid, text),
  public.payapp_confirm(uuid, text, integer), public.payapp_cancel(uuid, text) to service_role;
