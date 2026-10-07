-- HYA-280: verify that profiles.role, not a JWT role claim, authorizes admins.
--
-- Run against a migrated disposable/local database with:
--   psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/admin_role_rls.sql
--
-- Every fixture and moderation action is rolled back. ON_ERROR_STOP is important:
-- if an assertion fails, psql closes the aborted transaction and rolls it back.
-- Never run this through a migration runner, and never put admin credentials in
-- this file. These probe accounts have no password and cannot sign in.
--
-- PostgREST verifies JWT signatures before setting request.jwt.claim.*. Here
-- set_config simulates those verified claims inside SQL; it does NOT test token
-- signature validation, Auth login, or the Flutter redirect. Those require an
-- actual admin account and the HYA-275 end-to-end pass.

begin;

-- auth.users' trigger creates each public.profiles row as a buyer. Promote only
-- the probe admin, as the database owner, before switching to API roles.
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data
) values
  (
    '00000000-0000-0000-0000-000000000000',
    'd2800000-0000-4000-8000-000000000001',
    'authenticated', 'authenticated', 'hya280-probe-buyer@invalid.local',
    null, now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"HYA-280 Probe Buyer"}'
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    'd2800000-0000-4000-8000-000000000002',
    'authenticated', 'authenticated', 'hya280-probe-admin@invalid.local',
    null, now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"HYA-280 Probe Admin"}'
  );

update public.profiles set role = 'admin'
where id = 'd2800000-0000-4000-8000-000000000002';

-- The buyer does not own this pending listing, so an owner SELECT policy cannot
-- accidentally make the RLS assertion pass. No photos or real users are used.
insert into public.listings (
  id, seller_id, property_type, listing_purpose, title, price_npr,
  area_sqm, district, city, status
) values (
  'd2800000-0000-4000-8000-000000000003',
  'd2800000-0000-4000-8000-000000000002',
  'house', 'sale', 'HYA-280 role probe', 25000000,
  300, 'Kathmandu', 'Kathmandu', 'pending_review'
);

-- No signed-in subject: anon may see live listings, never a pending listing,
-- profiles, or the admin queue. A role-only claim without a sub is not an admin.
set local role anon;
select set_config('request.jwt.claim.sub', '', true);
select set_config('request.jwt.claim.role', 'anon', true);
select set_config('request.jwt.claims', '{"role":"anon"}', true);
do $test$
begin
  if (select private.current_uid()) is not null
     or (select private.is_admin())
     or exists (select 1 from public.profiles
                where id = 'd2800000-0000-4000-8000-000000000002')
     or exists (select 1 from public.listings
                where id = 'd2800000-0000-4000-8000-000000000003') then
    raise exception 'HYA-280: anon gained admin/hidden-row access';
  end if;

  if has_function_privilege(
    'anon',
    'public.v1_admin_get_queue(text,timestamptz,uuid,integer)',
    'execute'
  ) then
    raise exception 'HYA-280: anon can execute the admin queue RPC';
  end if;
end;
$test$;

-- A buyer may not become an admin just by putting "admin" in the JWT *role*
-- field. In production this is a signed GoTrue claim, but the authorization
-- helper must still read the server-owned profiles.role, not the claim.
set local role authenticated;
select set_config(
  'request.jwt.claim.sub', 'd2800000-0000-4000-8000-000000000001', true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"d2800000-0000-4000-8000-000000000001","role":"admin"}',
  true
);
do $test$
begin
  if (select private.current_uid()) <>
       'd2800000-0000-4000-8000-000000000001'::uuid
     or (select private.is_admin())
     or not exists (select 1 from public.profiles
                    where id = 'd2800000-0000-4000-8000-000000000001')
     or exists (select 1 from public.profiles
                where id = 'd2800000-0000-4000-8000-000000000002')
     or exists (select 1 from public.listings
                where id = 'd2800000-0000-4000-8000-000000000003') then
    raise exception 'HYA-280: buyer JWT role bypassed profiles.role/RLS';
  end if;

  -- An authenticated buyer must not be able to promote their own profile.
  -- RLS may reject the UPDATE with 42501 or filter it to zero changed rows;
  -- either is safe, but a successful update is a privilege escalation.
  begin
    update public.profiles set role = 'admin'
    where id = 'd2800000-0000-4000-8000-000000000001';
    if found then
      raise exception 'HYA-280: buyer changed their own role';
    end if;
  exception when sqlstate '42501' then
    null;
  end;

  if (select private.is_admin()) then
    raise exception 'HYA-280: buyer self-promotion took effect';
  end if;

  begin
    perform public.v1_admin_get_queue(null, null, null, 1);
    raise exception 'HYA-280: buyer called the admin queue RPC';
  exception when sqlstate '42501' then
    -- The RPC is executable by authenticated users; its *internal* admin
    -- check must deny the buyer. This is the expected result.
    null;
  end;
end;
$test$;

-- A genuine admin has a normal "authenticated" JWT role; the application role
-- lives in profiles. This must admit the admin through both RLS and the RPC.
select set_config(
  'request.jwt.claim.sub', 'd2800000-0000-4000-8000-000000000002', true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"d2800000-0000-4000-8000-000000000002","role":"authenticated"}',
  true
);
do $test$
begin
  if not (select private.is_admin())
     or not exists (select 1 from public.profiles
                    where id = 'd2800000-0000-4000-8000-000000000001')
     or not exists (select 1 from public.listings
                    where id = 'd2800000-0000-4000-8000-000000000003') then
    raise exception 'HYA-280: genuine admin denied by role/RLS';
  end if;

  if not exists (
    select 1 from json_array_elements(
      public.v1_admin_get_queue('pending_review', null, null, 100)->'entries'
    ) as e
    where e->>'id' = 'd2800000-0000-4000-8000-000000000003'
  ) then
    raise exception 'HYA-280: admin queue RPC hid pending fixture';
  end if;
end;
$test$;

-- A real admin decision must still be auditable. Both rows disappear at the
-- final ROLLBACK, which also restores the probe profile roles.
select public.v1_admin_approve_listing(
  'd2800000-0000-4000-8000-000000000003'
);
do $test$
begin
  if not exists (
    select 1 from public.listings
    where id = 'd2800000-0000-4000-8000-000000000003'
      and status = 'live'
  ) or not exists (
    select 1 from public.audit_log
    where entity_type = 'listing'
      and entity_id = 'd2800000-0000-4000-8000-000000000003'
      and actor_id = 'd2800000-0000-4000-8000-000000000002'
  ) then
    raise exception 'HYA-280: admin approval or audit trail failed';
  end if;
end;
$test$;

-- Revocation is immediate even with the same subject and unchanged JWT. This
-- is why profiles.role is authoritative rather than a custom claim cached until
-- token refresh. The admin still owns the now-live fixture, but can no longer
-- see the *other* buyer's profile or any admin audit rows.
set local role postgres;
update public.profiles set role = 'buyer'
where id = 'd2800000-0000-4000-8000-000000000002';
set local role authenticated;
do $test$
begin
  if (select private.is_admin())
     or exists (select 1 from public.profiles
                where id = 'd2800000-0000-4000-8000-000000000001')
     or exists (select 1 from public.audit_log
                where entity_id = 'd2800000-0000-4000-8000-000000000003') then
    raise exception 'HYA-280: revoked admin retained admin access';
  end if;

  begin
    perform public.v1_admin_get_queue(null, null, null, 1);
    raise exception 'HYA-280: revoked admin called the queue RPC';
  exception when sqlstate '42501' then
    null;
  end;
end;
$test$;

rollback;
