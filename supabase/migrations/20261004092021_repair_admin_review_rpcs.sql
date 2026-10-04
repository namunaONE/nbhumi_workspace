-- HYA-251 (1/2) — repair v1_admin_approve_listing / v1_admin_reject_listing
--
-- URGENT: both functions have been non-functional since HYA-248.
--
-- HYA-248 moved is_admin() out of the exposed `public` schema into `private` and
-- repointed the RLS policies and the browse RPCs at `private.is_admin()`. It did
-- not repoint these two admin RPCs, which still called `public.is_admin()`.
--
-- Verified against the live database before writing this file:
--
--   select public.v1_admin_approve_listing(<a pending_review id>);
--   ERROR: 42883: function public.is_admin() does not exist
--
-- So *every* admin approve and reject has failed since that migration landed.
-- The admin panel could not review a single listing. Nothing in the Dart layer
-- caught it because the failure is a Postgres error at call time, not a type or
-- signature mismatch, and no test exercised the admin path against the database.
--
-- This migration also pins `search_path` on both. They are SECURITY DEFINER with
-- `search_path = public`, which is the mutable-search_path pattern HYA-248 set
-- out to eliminate. It is not currently exploitable: the escalation requires the
-- caller to be able to CREATE in a schema on the path, and neither anon nor
-- authenticated has CREATE on public. But the advisor keeps flagging it, and a
-- latent escalation path is worth closing while the function is being rewritten
-- regardless.
--
-- `set_config('nbhumi.admin_action', ...)` is retained even though nothing reads
-- it any more: no policy and no trigger in public references it, so it looks
-- vestigial after HYA-248 replaced its original consumer with private.is_admin().
-- It is left in place because removing it would drop behaviour this file cannot
-- fully account for, and a no-op set_config costs nothing.

create or replace function public.v1_admin_approve_listing (p_listing_id uuid)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
begin
  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  perform set_config('nbhumi.admin_action', 'on', true);

  update public.listings
  set status = 'live',
      reviewed_by = v_uid,
      reviewed_at = now(),
      rejection_reason = null
  where id = p_listing_id
    and status = 'pending_review';

  if not found then
    raise exception 'VALIDATION_ERROR: listing not in pending_review'
      using errcode = '22023';
  end if;

  -- RULE 8: every admin transition is audit-logged. This insert is the reason
  -- the function exists rather than a bare UPDATE.
  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    v_uid,
    'approve',
    'listing',
    p_listing_id,
    json_build_object('to', 'live')
  );

  return json_build_object('id', p_listing_id, 'status', 'live');
end;
$$;

create or replace function public.v1_admin_reject_listing (
  p_listing_id uuid,
  p_reason text
)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
begin
  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  if p_reason is null or length(trim(p_reason)) = 0 then
    raise exception 'VALIDATION_ERROR: reason required'
      using errcode = '22023';
  end if;

  perform set_config('nbhumi.admin_action', 'on', true);

  update public.listings
  set status = 'rejected',
      rejection_reason = p_reason,
      reviewed_by = v_uid,
      reviewed_at = now()
  where id = p_listing_id
    and status = 'pending_review';

  if not found then
    raise exception 'VALIDATION_ERROR: listing not in pending_review'
      using errcode = '22023';
  end if;

  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    v_uid,
    'reject',
    'listing',
    p_listing_id,
    json_build_object('to', 'rejected', 'reason', p_reason)
  );

  return json_build_object('id', p_listing_id, 'status', 'rejected');
end;
$$;

-- anon was already revoked by HYA-248; restated so this file stands alone.
revoke execute on function public.v1_admin_approve_listing (uuid) from public;
revoke execute on function public.v1_admin_reject_listing (uuid, text)
  from public;

grant execute on function public.v1_admin_approve_listing (uuid)
  to authenticated;
grant execute on function public.v1_admin_reject_listing (uuid, text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- ACKNOWLEDGED ADVISITOR FINDINGS
-- ---------------------------------------------------------------------------
-- These two will still be reported as
-- authenticated_security_definer_function_executable findings. That is
-- intentional and must not be "fixed":
--
--   SECURITY DEFINER is required because the admin update touches
--   listings.status, which RLS otherwise confines to the owner. An invoker
--   function could not perform the transition at all.
--
--   `search_path = ''` is what makes DEFINER safe here: every reference in the
--   body is schema-qualified, so there is nothing for a caller to hijack.

comment on function public.v1_admin_approve_listing (uuid) is
  'Admin-only: moves a pending_review listing to live and audit-logs it. '
  'Repaired in this migration after HYA-248 left it calling public.is_admin(), '
  'which no longer exists.';
comment on function public.v1_admin_reject_listing (uuid, text) is
  'Admin-only: moves a pending_review listing to rejected with a reason and '
  'audit-logs it. Repaired in this migration alongside v1_admin_approve_listing.';