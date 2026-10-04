-- HYA-248 (1/4) — SECURITY DEFINER helpers move to a non-exposed schema
--
-- Gap G-02. Live audit showed `anon_exec = true` for every public function,
-- including the admin pair, because `pg_default_acl` grants `anon = X` on new
-- functions in `public` by default. Not exploitable yet (is_admin() returns
-- false for a NULL uid), but every future function inherits it.
--
-- `private` is not in PostgREST's exposed schemas, so its functions are
-- unreachable via /rest/v1/rpc regardless of privileges. That is what makes it
-- safe to leave private.is_admin() executable by anon: the RLS policies need
-- it, but no client can call it.

create schema if not exists private;
revoke all on schema private from public;
revoke all on schema private from anon;
revoke all on schema private from authenticated;
grant usage on schema private to anon, authenticated;

comment on schema private is
  'Internal helpers. Not exposed via PostgREST — unreachable from /rest/v1/rpc.';

-- Stop granting anon/authenticated EXECUTE on new public functions. Wrapped in
-- a guard: the migration runner may lack the privilege to change defaults, and
-- an explicit REVOKE per function is the fallback.
do $$
begin
  execute 'alter default privileges in schema public revoke execute on functions from public';
  execute 'alter default privileges in schema public revoke execute on functions from anon';
  execute 'alter default privileges in schema public revoke execute on functions from authenticated';
exception when insufficient_privilege then
  raise notice 'default privileges not adjustable by this role; relying on explicit revokes';
end $$;

create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.role = 'admin'
  );
$$;
revoke execute on function private.is_admin() from public;
grant execute on function private.is_admin() to anon, authenticated;

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, coalesce(new.email, ''), coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;
revoke execute on function private.handle_new_user() from public;
grant execute on function private.handle_new_user() to supabase_auth_admin, service_role;

-- Policies must be dropped BEFORE public.is_admin() can be dropped (2BP01).
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;
drop policy if exists "profiles_update_admin" on public.profiles;
drop policy if exists "listings_select_public_live" on public.listings;
drop policy if exists "listings_insert_own" on public.listings;
drop policy if exists "listings_update_own" on public.listings;
drop policy if exists "listings_update_admin" on public.listings;
drop policy if exists "listings_delete_own_draft" on public.listings;
drop policy if exists "listing_photos_select_public" on public.listing_photos;
drop policy if exists "listing_photos_insert_own" on public.listing_photos;
drop policy if exists "listing_photos_delete_own" on public.listing_photos;
drop policy if exists "audit_log_select_admin" on public.audit_log;

drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();
drop function if exists public.is_admin();

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- ---------------------------------------------------------------------------
-- RLS policies — closing gap G-09
--
-- auth.uid() and is_admin() are re-evaluated once per row by Postgres. Wrapping
-- them in (select ...) lets the planner hoist them to once per statement.
-- 23 bare call sites across 001-003 are corrected here.
-- ---------------------------------------------------------------------------
create policy "profiles_select_own_or_admin" on public.profiles for select to authenticated
  using ((select auth.uid()) = id or (select private.is_admin()));

create policy "profiles_insert_own" on public.profiles for insert to authenticated
  with check ((select auth.uid()) = id);

create policy "profiles_update_own" on public.profiles for update to authenticated
  using ((select auth.uid()) = id)
  with check (
    (select auth.uid()) = id
    and role = (select p.role from public.profiles p where p.id = (select auth.uid()))
    and is_verified = (select p.is_verified from public.profiles p where p.id = (select auth.uid()))
    and kyc_tier = (select p.kyc_tier from public.profiles p where p.id = (select auth.uid()))
  );

create policy "profiles_update_admin" on public.profiles for update to authenticated
  using ((select private.is_admin())) with check ((select private.is_admin()));

create policy "listings_select_public_live" on public.listings for select to anon, authenticated
  using (status = 'live' or seller_id = (select auth.uid()) or (select private.is_admin()));

create policy "listings_insert_own" on public.listings for insert to authenticated
  with check (seller_id = (select auth.uid()));

create policy "listings_update_own" on public.listings for update to authenticated
  using (seller_id = (select auth.uid())) with check (seller_id = (select auth.uid()));

create policy "listings_update_admin" on public.listings for update to authenticated
  using ((select private.is_admin())) with check ((select private.is_admin()));

create policy "listings_delete_own_draft" on public.listings for delete to authenticated
  using (seller_id = (select auth.uid()) and status = 'draft');

create policy "listing_photos_select_public" on public.listing_photos for select to anon, authenticated
  using (exists (select 1 from public.listings l where l.id = listing_id
    and (l.status = 'live' or l.seller_id = (select auth.uid()) or (select private.is_admin()))));

create policy "listing_photos_insert_own" on public.listing_photos for insert to authenticated
  with check (exists (select 1 from public.listings l
    where l.id = listing_id and l.seller_id = (select auth.uid())));

create policy "listing_photos_delete_own" on public.listing_photos for delete to authenticated
  using (exists (select 1 from public.listings l
    where l.id = listing_id and l.seller_id = (select auth.uid())));

create policy "audit_log_select_admin" on public.audit_log for select to authenticated
  using ((select private.is_admin()));

-- Indexes for the columns the policies actually filter on. `seller_id` appears
-- in seven policies and had no index at all.
create index if not exists listings_seller_id_idx on public.listings (seller_id);

-- The browse feed is the hottest path: live rows, newest first. A partial index
-- keeps it small by containing only publishable rows.
create index if not exists listings_live_created_at_idx
  on public.listings (created_at desc) where status = 'live';

create index if not exists listings_live_district_created_idx
  on public.listings (district, created_at desc) where status = 'live';

create index if not exists profiles_role_idx on public.profiles (role);