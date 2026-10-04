-- HYA-248 (4/4) — Pin search_path on private.current_uid()
--
-- Closes the last `function_search_path_mutable` advisor lint. The function is
-- STABLE INVOKER rather than DEFINER so the risk was low, but leaving one
-- unpinned helper in the schema trains the next reviewer to skip the check.

create or replace function private.current_uid()
returns uuid
language sql
stable
set search_path = ''
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

-- ---------------------------------------------------------------------------
-- ACKNOWLEDGED ADVISORIES
--
-- The security advisor will keep reporting six
-- anon/authenticated_security_definer_function_executable findings. They are
-- intentional and must not be "fixed" by downgrading these functions:
--
--   v1_get_listings, v1_get_listing_detail   SECURITY DEFINER + anon EXECUTE
--     Required. Guest browse is the product's primary use case. Visibility is
--     enforced in SQL (status = 'live' OR own OR is_admin) and only vetted
--     shapes are returned; `profiles` policies are deliberately NOT widened.
--     Reverting to SECURITY INVOKER reintroduces gap G-01, where browse returns
--     zero rows for every guest and every buyer.
--
--   v1_admin_approve_listing, v1_admin_reject_listing
--     SECURITY DEFINER + authenticated EXECUTE. Pre-existing M0 design; anon is
--     revoked. The private.is_admin() gate remains as defence in depth.
--
-- Rule: any change that silences these lints by flipping a function back to
-- SECURITY INVOKER is a regression. Re-run the Phase 0 test suite instead.
-- ---------------------------------------------------------------------------