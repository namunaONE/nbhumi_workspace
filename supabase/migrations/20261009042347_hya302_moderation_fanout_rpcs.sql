-- HYA-302 (2/2): fan out suspend/unpublish verdicts to the seller inbox.
--
-- Each HYA-262 RPC restates its body byte-identically (Rule 1: applied
-- migrations are never edited; B2 restatement pattern) plus one
-- `perform private.notify_user(...)` after its audit insert:
--
-- * suspend -> account_suspended (copy matches auth.accountSuspended, HYA-301)
-- * unsuspend -> account_reinstated
-- * unpublish -> listing_unpublished (seller-visible reason rides along)
-- * republish -> listing_republished
--
-- Best-effort preserved: notify failures warn, verdicts stand. No signature
-- changes, so no drops and no grant churn. Rule 36: every message EN + NE.

-- ---------------------------------------------------------------------------
-- v1_admin_suspend_user + inbox fan-out
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
  -- HYA-302: the seller learns from their inbox, not from a missing account.
  -- Copy matches the auth.accountSuspended mapper message (HYA-301).
  perform private.notify_user(
    p_user_id,
    'account_suspended',
    'Your account has been suspended. You cannot post or edit listings right now.',
    'तपाईंको खाता निलम्बनमा छ। तपाईं अहिले लिस्टिङ पोस्ट वा सम्पादन गर्न सक्नुहुन्न।'
  );
  return json_build_object(
    'id', p_user_id,
    'suspended', true,
    'reason', btrim(p_reason)
  );
end;
$function$;

-- ---------------------------------------------------------------------------
-- v1_admin_unsuspend_user + inbox fan-out
-- ---------------------------------------------------------------------------

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
     set suspended_at = null, suspended_reason = null, suspended_by = null
   where id = p_user_id and suspended_at is not null;
  if not found then
    raise exception 'VALIDATION_ERROR: this account is not suspended'
      using errcode = '22023';
  end if;
  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (v_uid, 'unsuspend', 'user', p_user_id, json_build_object());
  -- HYA-302: lifting is news the seller should not have to discover.
  perform private.notify_user(
    p_user_id,
    'account_reinstated',
    'Your suspension has been lifted. You can post and edit listings again.',
    'तपाईंको निलम्बन हटाइएको छ। तपाईं फेरि लिस्टिङ पोस्ट र सम्पादन गर्न सक्नुहुन्छ।'
  );
  return json_build_object('id', p_user_id, 'suspended', false);
end;
$function$;

-- ---------------------------------------------------------------------------
-- v1_admin_unpublish_listing + inbox fan-out
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
  v_seller uuid;
  v_title text;
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
  values (v_uid, 'unpublish', 'listing', p_listing_id, json_build_object('to', 'unpublished', 'reason', btrim(p_reason)));
  -- HYA-302: the reason is seller-visible by design, so it rides along.
  select l.seller_id, l.title into v_seller, v_title
    from public.listings l where l.id = p_listing_id;
  perform private.notify_user(
    v_seller,
    'listing_unpublished',
    'Your listing "' || v_title || '" was unpublished. Reason: ' || btrim(p_reason),
    '"' || v_title || '" शीर्षकको तपाईंको लिस्टिङ हटाइयो। कारण: ' || btrim(p_reason)
  );
  return json_build_object('id', p_listing_id, 'status', 'unpublished');
end;
$function$;

-- ---------------------------------------------------------------------------
-- v1_admin_republish_listing + inbox fan-out
-- ---------------------------------------------------------------------------

create or replace function public.v1_admin_republish_listing(p_listing_id uuid)
returns json
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_seller uuid;
  v_title text;
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
  values (v_uid, 'republish', 'listing', p_listing_id, json_build_object('to', 'live'));
  -- HYA-302: a pulled listing coming back deserves its own line.
  select l.seller_id, l.title into v_seller, v_title
    from public.listings l where l.id = p_listing_id;
  perform private.notify_user(
    v_seller,
    'listing_republished',
    'Your listing "' || v_title || '" is live again.',
    '"' || v_title || '" शीर्षकको तपाईंको लिस्टिङ फेरि लाइभ भयो।'
  );
  return json_build_object('id', p_listing_id, 'status', 'live');
end;
$function$;

comment on function public.v1_admin_suspend_user(uuid, text) is
  'HYA-262: suspends an account (sets suspended_at/reason/by + audit). '
  'HYA-302: also fans an account_suspended row into the seller inbox. '
  'Suspended sellers cannot insert or update listings, via both the write RPCs '
  'and the RLS backstop. Existing live listings stay live until explicitly '
  'unpublished -- suspending never hides inventory by itself.';
comment on function public.v1_admin_unpublish_listing(uuid, text) is
  'HYA-262: pulls a live listing (status unpublished + audit). HYA-302: also '
  'fans a listing_unpublished row (with the seller-visible reason) into the '
  'seller inbox. Distinct from rejected: the seller sees an unpublish reason, '
  'not a failed review.';
