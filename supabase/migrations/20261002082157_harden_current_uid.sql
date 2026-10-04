-- HYA-249 (2/2) — Harden the uid lookup
--
-- Found by the Phase 0 test suite, not by review. An anonymous request whose
-- JWT carries `"sub": ""` made v1_get_listings raise:
--
--   ERROR: 22P02 invalid input syntax for type uuid: ""
--
-- Cause: auth.uid() nullifs each source individually but not the coalesced
-- result, so coalesce(NULL, '') = '' and ''::uuid throws.
--
--         select coalesce(
--           nullif(current_setting('request.jwt.claim.sub', true), ''),
--           (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
--         )::uuid
--
-- Tokens are signed by GoTrue so a client cannot forge one, but a blank sub is
-- a legitimate shape for some anon tokens, and one bad request would otherwise
-- take down the entire browse feed for every guest.
--
-- private.current_uid() applies nullif to the coalesced value, so anything
-- blank becomes NULL rather than a cast error.

create or replace function private.current_uid()
returns uuid
language sql
stable
as $$
  select nullif(
    coalesce(
      nullif(current_setting('request.jwt.claim.sub', true), ''),
      (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
    ),
    ''
  )::uuid;
$$;
revoke execute on function private.current_uid() from public;
grant execute on function private.current_uid() to anon, authenticated;

create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select private.current_uid()) and p.role = 'admin'
  );
$$;
revoke execute on function private.is_admin() from public;
grant execute on function private.is_admin() to anon, authenticated;

-- Repoint every policy at the hardened lookup.
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin" on public.profiles for select to authenticated
  using ((select private.current_uid()) = id or (select private.is_admin()));

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles for insert to authenticated
  with check ((select private.current_uid()) = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update to authenticated
  using ((select private.current_uid()) = id)
  with check (
    (select private.current_uid()) = id
    and role = (select p.role from public.profiles p where p.id = (select private.current_uid()))
    and is_verified = (select p.is_verified from public.profiles p where p.id = (select private.current_uid()))
    and kyc_tier = (select p.kyc_tier from public.profiles p where p.id = (select private.current_uid()))
  );

drop policy if exists "profiles_update_admin" on public.profiles;
create policy "profiles_update_admin" on public.profiles for update to authenticated
  using ((select private.is_admin())) with check ((select private.is_admin()));

drop policy if exists "listings_select_public_live" on public.listings;
create policy "listings_select_public_live" on public.listings for select to anon, authenticated
  using (status = 'live' or seller_id = (select private.current_uid()) or (select private.is_admin()));

drop policy if exists "listings_insert_own" on public.listings;
create policy "listings_insert_own" on public.listings for insert to authenticated
  with check (seller_id = (select private.current_uid()));

drop policy if exists "listings_update_own" on public.listings;
create policy "listings_update_own" on public.listings for update to authenticated
  using (seller_id = (select private.current_uid())) with check (seller_id = (select private.current_uid()));

drop policy if exists "listings_update_admin" on public.listings;
create policy "listings_update_admin" on public.listings for update to authenticated
  using ((select private.is_admin())) with check ((select private.is_admin()));

drop policy if exists "listings_delete_own_draft" on public.listings;
create policy "listings_delete_own_draft" on public.listings for delete to authenticated
  using (seller_id = (select private.current_uid()) and status = 'draft');

drop policy if exists "listing_photos_select_public" on public.listing_photos;
create policy "listing_photos_select_public" on public.listing_photos for select to anon, authenticated
  using (exists (select 1 from public.listings l where l.id = listing_id
    and (l.status = 'live' or l.seller_id = (select private.current_uid()) or (select private.is_admin()))));

drop policy if exists "listing_photos_insert_own" on public.listing_photos;
create policy "listing_photos_insert_own" on public.listing_photos for insert to authenticated
  with check (exists (select 1 from public.listings l
    where l.id = listing_id and l.seller_id = (select private.current_uid())));

drop policy if exists "listing_photos_delete_own" on public.listing_photos;
create policy "listing_photos_delete_own" on public.listing_photos for delete to authenticated
  using (exists (select 1 from public.listings l
    where l.id = listing_id and l.seller_id = (select private.current_uid())));

drop policy if exists "audit_log_select_admin" on public.audit_log;
create policy "audit_log_select_admin" on public.audit_log for select to authenticated
  using ((select private.is_admin()));