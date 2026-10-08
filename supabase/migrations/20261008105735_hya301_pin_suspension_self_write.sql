-- HYA-301: pin suspension columns against self-write.
--
-- ## The hole
--
-- `profiles_update_own` pins only role/is_verified/kyc_tier via
-- `private.profile_protected_fields_unchanged` (HYA-280). The suspension
-- columns added later (HYA-262: suspended_at/suspended_reason/suspended_by)
-- were never added to the pin, so a suspended seller with a REST client can
-- clear their own suspension with a direct UPDATE -- the WITH CHECK passes
-- because it only looks at the three old fields. Verified by reading the
-- policy, not by exploiting it.
--
-- ## Fix
--
-- Extend the helper with the three suspension columns (compared with
-- IS NOT DISTINCT FROM so null-to-null counts as unchanged) and re-issue
-- the own-update policy against the new signature. The insert policy gains
-- the matching guard: a fresh row must start unsuspended.
--
-- Untouched: `profiles_update_admin` (is_admin, separate policy) and the
-- suspend/unsuspend RPCs (SECURITY DEFINER, owner bypasses RLS). Admin flows
-- keep working; only self-service loses the new columns.
--
-- ## Rule compliance
--
-- * Rule 1: new file; the applied HYA-280 migration is not edited (function
--   signature change forces drop + recreate, HYA-251 precedent).
-- * Rule 3: policy and helper ship in this same file.
-- * Rules 4/8: no status transitions, no admin mutations, no audit rows.
--
-- ## Replay safety
--
-- Policy drops are `if exists`; the function drop names the old 3-argument
-- signature exactly; grants name the new 6-argument signature exactly.

drop policy if exists "profiles_update_own" on public.profiles;

drop function if exists private.profile_protected_fields_unchanged(
  public.user_role, boolean, text
);

-- The helper compares the caller's existing row to the proposed values,
-- SECURITY DEFINER so the self-lookup does not recurse (HYA-280). Suspension
-- columns join the pinned set: a seller may edit their name, phone and
-- agency, never their suspension state.
create function private.profile_protected_fields_unchanged(
  p_role public.user_role,
  p_is_verified boolean,
  p_kyc_tier text,
  p_suspended_at timestamptz,
  p_suspended_reason text,
  p_suspended_by uuid
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
      and p.suspended_at is not distinct from p_suspended_at
      and p.suspended_reason is not distinct from p_suspended_reason
      and p.suspended_by is not distinct from p_suspended_by
  );
$function$;

revoke execute on function private.profile_protected_fields_unchanged(
  public.user_role, boolean, text, timestamptz, text, uuid
) from public, anon;
grant execute on function private.profile_protected_fields_unchanged(
  public.user_role, boolean, text, timestamptz, text, uuid
) to authenticated;

comment on function private.profile_protected_fields_unchanged(
  public.user_role, boolean, text, timestamptz, text, uuid
) is
  'HYA-280 helper, extended by HYA-301: compare proposed role/verification/'
  'KYC/suspension values with the current user''s existing profile, '
  'bypassing RLS only for this narrow self-lookup. Never expose via PostgREST.';

create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using (id = (select private.current_uid()))
  with check (
    id = (select private.current_uid())
    and private.profile_protected_fields_unchanged(
      role, is_verified, kyc_tier,
      suspended_at, suspended_reason, suspended_by
    )
  );

-- A fresh row starts unsuspended: no one signs up already suspended, and no
-- one signs up having suspended someone else.
drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert to authenticated
  with check (
    id = (select private.current_uid())
    and role = 'buyer'
    and is_verified = false
    and kyc_tier = 'none'
    and suspended_at is null
    and suspended_reason is null
    and suspended_by is null
  );
