-- HYA-280: keep profiles.role authoritative without an RLS recursion.
--
-- Two failures proved on the dev database with rolled-back probe users:
--
-- 1. profiles_update_own queried public.profiles inside its own WITH CHECK.
--    Any authenticated UPDATE (even changing only full_name) raised 42P17:
--    "infinite recursion detected in policy for relation profiles".
-- 2. profiles_insert_own checked only id = current_uid(). If an auth user had
--    no profile row, they could insert their own row with role='admin' and
--    private.is_admin() immediately returned true. The signup trigger normally
--    creates the buyer row, but RLS must remain safe if the row is missing.
--
-- Do not edit earlier applied migrations. Both replacements are atomic here.
-- No JWT app-role claim or Auth hook: PostgREST JWT role stays authenticated;
-- profiles.role is the server-owned application role.

-- The helper compares *only the caller's existing row* to the proposed values.
-- SECURITY DEFINER is necessary here: reading profiles as the invoker from a
-- profiles policy recurses. Keep it outside the exposed API schema, pin its
-- search_path, and grant execution only to authenticated users for the policy.
create or replace function private.profile_protected_fields_unchanged(
  p_role public.user_role,
  p_is_verified boolean,
  p_kyc_tier text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select private.current_uid())
      and p.role = p_role
      and p.is_verified = p_is_verified
      and p.kyc_tier = p_kyc_tier
  );
$function$;

revoke execute on function private.profile_protected_fields_unchanged(
  public.user_role, boolean, text
) from public, anon;
grant execute on function private.profile_protected_fields_unchanged(
  public.user_role, boolean, text
) to authenticated;

comment on function private.profile_protected_fields_unchanged(
  public.user_role, boolean, text
) is
  'HYA-280: compare proposed role/verification/KYC values with the current '
  'user''s existing profile, bypassing RLS only for this narrow self-lookup. '
  'Never expose this helper via PostgREST.';

-- A missing profile must not be an opportunity to self-select an app role or
-- claim KYC. The auth trigger creates a buyer with precisely these defaults.
drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert to authenticated
  with check (
    id = (select private.current_uid())
    and role = 'buyer'
    and is_verified = false
    and kyc_tier = 'none'
  );

-- Both USING and WITH CHECK are required: only the owner can target the row,
-- and the new row must retain its server-owned protected fields. The other
-- permissive policy, profiles_update_admin, still allows actual admins to
-- update other users' profiles. The helper's owner bypasses RLS during its
-- read; authenticated callers cannot update protected values themselves.
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using (id = (select private.current_uid()))
  with check (
    id = (select private.current_uid())
    and private.profile_protected_fields_unchanged(
      role, is_verified, kyc_tier
    )
  );
