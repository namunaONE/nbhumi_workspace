-- HYA-262 (3/3): admin moderation RPCs (Rule 8: every one writes its audit row
-- in the same transaction; Rule 6: reasons trimmed and length-checked
-- server-side; Rule 38: mapped codes, never raw Postgres errors).
--
-- entity_type stays within the existing audit_log CHECK
-- ('listing','user','kyc'): suspend uses 'user', unpublish uses 'listing'.

-- ---------------------------------------------------------------------------
-- v1_admin_suspend_user / v1_admin_unsuspend_user
-- ---------------------------------------------------------------------------

create or replace function public.v1_admin_suspend_user(
  p_user_id uuid,
  p_reason text
)
returns json
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_role public.user_role;
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to suspend users'
      using errcode = '42501';
  end if;

  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  if p_user_id is null then
    raise exception 'VALIDATION_ERROR: user id is required'
      using errcode = '22023';
  end if;

  -- Suspending yourself locks the panel's own operator out mid-shift; that is
  -- never what the button meant. Suspending another admin is a governance
  -- action for the database owner, not a queue decision.
  if p_user_id = v_uid then
    raise exception 'VALIDATION_ERROR: you cannot suspend your own account'
      using errcode = '22023';
  end if;

  select p.role into v_role from public.profiles p where p.id = p_user_id;
  if not found then
    raise exception 'NOT_FOUND: no user with that id'
      using errcode = 'P0002';
  end if;

  if v_role = 'admin' then
    raise exception 'VALIDATION_ERROR: admin accounts cannot be suspended here'
      using errcode = '22023';
  end if;

  if p_user_id = '00000000-0000-0000-0000-000000000000' then
    raise exception 'VALIDATION_ERROR: the deleted-user identity cannot be suspended'
      using errcode = '22023';
  end if;

  if p_reason is null or length(btrim(p_reason)) = 0 then
    raise exception 'VALIDATION_ERROR: a suspension reason is required'
      using errcode = '22023';
  end if;

  if length(p_reason) > 500 then
    raise exception 'VALIDATION_ERROR: reason must be 500 characters or fewer'
      using errcode = '22023';
  end if;

  update public.profiles
     set suspended_at = now(),
         suspended_reason = btrim(p_reason),
         suspended_by = v_uid
   where id = p_user_id
     and suspended_at is null;

  if not found then
    raise exception 'VALIDATION_ERROR: this account is already suspended'
      using errcode = '22023';
  end if;

  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    v_uid,
    'suspend',
    'user',
    p_user_id,
    json_build_object('reason', btrim(p_reason))
  );

  return json_build_object(
    'id', p_user_id,
    'suspended', true,
    'reason', btrim(p_reason)
  );
end;
$function$;

create or replace function public.v1_admin_unsuspend_user(p_user_id uuid)
returns json
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to unsuspend users'
      using errcode = '42501';
  end if;

  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  if p_user_id is null then
    raise exception 'VALIDATION_ERROR: user id is required'
      using errcode = '22023';
  end if;

  update public.profiles
     set suspended_at = null,
         suspended_reason = null,
         suspended_by = null
   where id = p_user_id
     and suspended_at is not null;

  if not found then
    raise exception 'VALIDATION_ERROR: this account is not suspended'
      using errcode = '22023';
  end if;

  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    v_uid,
    'unsuspend',
    'user',
    p_user_id,
    json_build_object()
  );

  return json_build_object('id', p_user_id, 'suspended', false);
end;
$function$;

-- ---------------------------------------------------------------------------
-- v1_admin_unpublish_listing / v1_admin_republish_listing
-- ---------------------------------------------------------------------------

create or replace function public.v1_admin_unpublish_listing(
  p_listing_id uuid,
  p_reason text
)
returns json
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to unpublish listings'
      using errcode = '42501';
  end if;

  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  if p_listing_id is null then
    raise exception 'VALIDATION_ERROR: listing id is required'
      using errcode = '22023';
  end if;

  if p_reason is null or length(btrim(p_reason)) = 0 then
    raise exception 'VALIDATION_ERROR: an unpublish reason is required'
      using errcode = '22023';
  end if;

  if length(p_reason) > 1000 then
    raise exception 'VALIDATION_ERROR: reason must be 1000 characters or fewer'
      using errcode = '22023';
  end if;

  perform set_config('nbhumi.admin_action', 'on', true);

  -- Only a live listing can be unpublished. Anything else is either already
  -- out of the public eye (draft/pending/rejected/unpublished) or missing,
  -- and answering those identically would hide which. NOT_FOUND only when the
  -- row itself is absent.
  update public.listings
     set status = 'unpublished',
         rejection_reason = btrim(p_reason),
         reviewed_by = v_uid,
         reviewed_at = now()
   where id = p_listing_id
     and status = 'live';

  if not found then
    if not exists (select 1 from public.listings where id = p_listing_id) then
      raise exception 'NOT_FOUND: no listing with that id'
        using errcode = 'P0002';
    end if;
    raise exception 'VALIDATION_ERROR: only a live listing can be unpublished'
      using errcode = '22023';
  end if;

  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    v_uid,
    'unpublish',
    'listing',
    p_listing_id,
    json_build_object('to', 'unpublished', 'reason', btrim(p_reason))
  );

  return json_build_object('id', p_listing_id, 'status', 'unpublished');
end;
$function$;

create or replace function public.v1_admin_republish_listing(p_listing_id uuid)
returns json
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to republish listings'
      using errcode = '42501';
  end if;

  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  if p_listing_id is null then
    raise exception 'VALIDATION_ERROR: listing id is required'
      using errcode = '22023';
  end if;

  perform set_config('nbhumi.admin_action', 'on', true);

  update public.listings
     set status = 'live',
         rejection_reason = null,
         reviewed_by = v_uid,
         reviewed_at = now()
   where id = p_listing_id
     and status = 'unpublished';

  if not found then
    if not exists (select 1 from public.listings where id = p_listing_id) then
      raise exception 'NOT_FOUND: no listing with that id'
        using errcode = 'P0002';
    end if;
    raise exception 'VALIDATION_ERROR: only an unpublished listing can be republished'
      using errcode = '22023';
  end if;

  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    v_uid,
    'republish',
    'listing',
    p_listing_id,
    json_build_object('to', 'live')
  );

  return json_build_object('id', p_listing_id, 'status', 'live');
end;
$function$;

-- ---------------------------------------------------------------------------
-- v1_admin_get_user: the admin's read view of one account.
--
-- Bundles what a suspension decision needs -- identity, suspension state,
-- per-status listing counts, open reports against the seller -- in one call.
-- Reads only; the RLS backstop (profiles_select_own_or_admin) would admit the
-- admin anyway, so this bundles rather than bypasses.
-- ---------------------------------------------------------------------------

create or replace function public.v1_admin_get_user(p_user_id uuid)
returns json
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_out json;
begin
  if (select private.current_uid()) is null then
    raise exception 'AUTH_REQUIRED: sign in to inspect users'
      using errcode = '42501';
  end if;

  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  if p_user_id is null then
    raise exception 'VALIDATION_ERROR: user id is required'
      using errcode = '22023';
  end if;

  select json_build_object(
    'id', p.id,
    'email', p.email,
    'full_name', p.full_name,
    'phone', p.phone,
    'role', p.role,
    'is_verified', p.is_verified,
    'kyc_tier', p.kyc_tier,
    'suspended_at', p.suspended_at,
    'suspended_reason', p.suspended_reason,
    'suspended', p.suspended_at is not null,
    'created_at', p.created_at,
    'listings', (
      select coalesce(json_object_agg(l.status::text, l.n), '{}'::json)
      from (
        select status, count(*) as n
        from public.listings
        where seller_id = p_user_id
        group by status
      ) l
    ),
    'open_reports_against', (
      select count(*)
      from public.listing_reports r
      join public.listings l on l.id = r.listing_id
      where l.seller_id = p_user_id
        and r.status = 'open'
    )
  ) into v_out
  from public.profiles p
  where p.id = p_user_id;

  if v_out is null then
    raise exception 'NOT_FOUND: no user with that id'
      using errcode = 'P0002';
  end if;

  return v_out;
end;
$function$;

-- ---------------------------------------------------------------------------
-- Grants (HYA-248: revoke from anon/public first; admin RPCs to authenticated,
-- with the is_admin() check inside each function body)
-- ---------------------------------------------------------------------------

revoke execute on function public.v1_admin_suspend_user (uuid, text) from public;
revoke execute on function public.v1_admin_unsuspend_user (uuid) from public;
revoke execute on function public.v1_admin_unpublish_listing (uuid, text) from public;
revoke execute on function public.v1_admin_republish_listing (uuid) from public;
revoke execute on function public.v1_admin_get_user (uuid) from public;

grant execute on function public.v1_admin_suspend_user (uuid, text) to authenticated;
grant execute on function public.v1_admin_unsuspend_user (uuid) to authenticated;
grant execute on function public.v1_admin_unpublish_listing (uuid, text) to authenticated;
grant execute on function public.v1_admin_republish_listing (uuid) to authenticated;
grant execute on function public.v1_admin_get_user (uuid) to authenticated;

comment on function public.v1_admin_suspend_user(uuid, text) is
  'HYA-262: suspends an account (sets suspended_at/reason/by + audit). '
  'Suspended sellers cannot insert or update listings, via both the write RPCs '
  'and the RLS backstop. Existing live listings stay live until explicitly '
  'unpublished -- suspending never hides inventory by itself.';
comment on function public.v1_admin_unpublish_listing(uuid, text) is
  'HYA-262: pulls a live listing (status unpublished + audit). Distinct from '
  'rejected: the seller sees an unpublish reason, not a failed review.';
