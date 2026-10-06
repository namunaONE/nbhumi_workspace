-- HYA-242 (B2) — verdict fan-out into notifications
--
-- Every moderation verdict now leaves a bilingual row in the seller's inbox,
-- right beside the audit_log row it already wrote. Five touchpoints, one new
-- statement each; no signature changes, so no Dart changes.
--
--   v1_admin_approve_listing  -> listing_approved
--   v1_admin_reject_listing   -> listing_rejected (+ reason)
--   v1_admin_verify_kyc       -> kyc_verified (doc-check wording)
--   v1_admin_reject_kyc       -> kyc_rejected (+ reason)
--   v1_contact_seller         -> new_message, first reveal only
--
-- RULE 1: applied migrations are restated here with `CREATE OR REPLACE`, not
-- edited in place. Bodies are otherwise byte-identical to their sources:
-- approve/reject from 20261004092021_repair_admin_review_rpcs.sql, KYC from
-- 20261005120000_kyc_documents_tier2_tier3.sql, contact from
-- 20261004070232_allow_rereveal_at_cap.sql.
--
-- BEST-EFFORT BY DESIGN
-- =====================
-- Fan-out goes through `private.notify_user`, which swallows unexpected
-- failures into a Postgres WARNING rather than rolling back the verdict.
-- An approval that fails because a notification insert failed is the worse
-- outcome: the admin retries, the seller sees two verdicts, support gets a
-- ticket. Programmer errors (unknown type, blank message) still raise 22023
-- loudly, so a bad copy deck fails in development, not silently in prod.
-- `private` is not PostgREST-exposed, so the helper is unreachable from any
-- client; the missing grant is the control, not an oversight.

-- ---------------------------------------------------------------------------
-- 0. private.notify_user — the single choke point for server-side fan-out
-- ---------------------------------------------------------------------------

create or replace function private.notify_user (
  p_user_id uuid,
  p_type text,
  p_message_en text,
  p_message_ne text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Fail fast on programmer error: these mean the caller built the copy
  -- wrong, and that must surface in development, not as a silent skip.
  if p_user_id is null then
    raise exception 'INVALID_USER: notification needs a recipient'
      using errcode = '22023';
  end if;
  if p_type not in (
    'listing_approved', 'listing_rejected',
    'kyc_verified', 'kyc_rejected',
    'new_message'
  ) then
    raise exception 'INVALID_TYPE: %', p_type
      using errcode = '22023';
  end if;
  if btrim(coalesce(p_message_en, '')) = ''
     or btrim(coalesce(p_message_ne, '')) = '' then
    raise exception 'INVALID_MESSAGE: bilingual content is required (Rule 36)'
      using errcode = '22023';
  end if;

  begin
    insert into public.notifications (user_id, type, message_en, message_ne)
    values (p_user_id, p_type, p_message_en, p_message_ne);
  exception when others then
    -- Best-effort: the verdict already committed around this call must stand.
    -- WARNING lands in the Postgres log with the recipient attached.
    raise warning 'notify_user failed for % (%): %', p_user_id, p_type, sqlerrm;
  end;
end;
$$;

comment on function private.notify_user (uuid, text, text, text) is
  'Server-side fan-out into notifications (HYA-242 B2). Unreachable via '
  'PostgREST (private schema); bypasses RLS as SECURITY DEFINER because '
  'there is deliberately no client INSERT policy. Unexpected failures warn '
  'instead of rolling back the surrounding verdict.';

revoke execute on function private.notify_user (uuid, text, text, text)
  from public;

-- English / Nepali labels for KYC doc types, shared by both KYC verdicts.
-- A SQL function rather than four duplicated CASEs, so the copy has one
-- definition. IMMUTABLE: pure mapping, safe to inline anywhere.
create or replace function private.kyc_doc_label (p_doc_type text)
returns text
language sql
immutable
set search_path = ''
as $$
  select case p_doc_type
    when 'citizenship' then 'citizenship'
    when 'lalpurja' then 'lalpurja'
    when 'agency_reg' then 'agency registration'
    else p_doc_type
  end;
$$;

create or replace function private.kyc_doc_label_ne (p_doc_type text)
returns text
language sql
immutable
set search_path = ''
as $$
  select case p_doc_type
    when 'citizenship' then 'नागरिकता'
    when 'lalpurja' then 'लालपुर्जा'
    when 'agency_reg' then 'एजेन्सी दर्ता'
    else p_doc_type
  end;
$$;

revoke execute on function private.kyc_doc_label (text) from public;
revoke execute on function private.kyc_doc_label_ne (text) from public;

comment on function private.kyc_doc_label (text) is
  'English label for a kyc_documents.doc_type, for notification copy.';
comment on function private.kyc_doc_label_ne (text) is
  'Nepali label for a kyc_documents.doc_type, for notification copy.';

-- ---------------------------------------------------------------------------
-- 1. v1_admin_approve_listing + listing_approved
-- ---------------------------------------------------------------------------
-- Source: 20261004092021_repair_admin_review_rpcs.sql (HYA-251 1/2).
-- Unchanged except the notify block before the return.

create or replace function public.v1_admin_approve_listing (p_listing_id uuid)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_seller_id uuid;
  v_title text;
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

  -- B2 fan-out: the seller's inbox row. Best-effort (see header).
  select l.seller_id, l.title into v_seller_id, v_title
  from public.listings l
  where l.id = p_listing_id;

  perform private.notify_user(
    v_seller_id,
    'listing_approved',
    'Your listing ''' || v_title || ''' is live.',
    'तपाईंको विज्ञापन ''' || v_title || ''' प्रकाशित भयो।'
  );

  return json_build_object('id', p_listing_id, 'status', 'live');
end;
$$;

revoke execute on function public.v1_admin_approve_listing (uuid) from public;
grant execute on function public.v1_admin_approve_listing (uuid)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 2. v1_admin_reject_listing + listing_rejected
-- ---------------------------------------------------------------------------
-- Source: 20261004092021_repair_admin_review_rpcs.sql (HYA-251 1/2).
-- Unchanged except the notify block before the return.

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
  v_seller_id uuid;
  v_title text;
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

  -- B2 fan-out. The reason travels in the message: a rejection without one
  -- leaves the seller with nothing to fix.
  select l.seller_id, l.title into v_seller_id, v_title
  from public.listings l
  where l.id = p_listing_id;

  perform private.notify_user(
    v_seller_id,
    'listing_rejected',
    'Your listing ''' || v_title || ''' needs changes: ' || trim(p_reason),
    'तपाईंको विज्ञापन ''' || v_title || ''' मा सुधार आवश्यक छ: '
      || trim(p_reason)
  );

  return json_build_object('id', p_listing_id, 'status', 'rejected');
end;
$$;

revoke execute on function public.v1_admin_reject_listing (uuid, text)
  from public;
grant execute on function public.v1_admin_reject_listing (uuid, text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 3. v1_admin_verify_kyc + kyc_verified
-- ---------------------------------------------------------------------------
-- Source: 20261005120000_kyc_documents_tier2_tier3.sql (HYA-264 A1).
-- Unchanged except the notify block before the return. Copy stays doc-check:
-- "checked and verified", never legal/title language.

create or replace function public.v1_admin_verify_kyc (p_doc_id uuid)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_doc public.kyc_documents%rowtype;
  v_new_tier text;
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to review KYC'
      using errcode = '42501';
  end if;
  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  select * into v_doc
  from public.kyc_documents
  where id = p_doc_id
  for update;

  if not found then
    raise exception 'NOT_FOUND: KYC document not found'
      using errcode = 'P0002';
  end if;
  if v_doc.status <> 'pending' then
    raise exception 'CONFLICT: document is already reviewed (%)', v_doc.status
      using errcode = '23505';
  end if;

  update public.kyc_documents
  set status = 'verified',
      reviewed_by = v_uid,
      reviewed_at = now()
  where id = p_doc_id;

  -- Tier bump: citizenship -> identity; per-listing lalpurja -> property.
  -- Doc-check only: no claim about legal validity, enforced by copy review.
  v_new_tier := case
    when v_doc.listing_id is not null then 'property'
    else 'identity'
  end;

  update public.profiles
  set kyc_tier = v_new_tier
  where id = v_doc.profile_id
    and (
      (v_new_tier = 'identity' and kyc_tier in ('none', 'account'))
      or (v_new_tier = 'property' and kyc_tier <> 'property')
    );

  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    v_uid, 'kyc.verified', 'kyc', p_doc_id,
    jsonb_build_object(
      'doc_type', v_doc.doc_type,
      'profile_id', v_doc.profile_id,
      'listing_id', v_doc.listing_id
    )
  );

  -- B2 fan-out.
  perform private.notify_user(
    v_doc.profile_id,
    'kyc_verified',
    'Your ' || private.kyc_doc_label(v_doc.doc_type)
      || ' document was checked and verified. Identity check only.',
    'तपाईंको ' || private.kyc_doc_label_ne(v_doc.doc_type)
      || ' कागजात जाँच भयो। पहिचान जाँच मात्र।'
  );

  return json_build_object('id', p_doc_id, 'status', 'verified', 'kyc_tier', v_new_tier);
end;
$$;

comment on function public.v1_admin_verify_kyc (uuid) is
  'Admin-only: pending -> verified + profiles.kyc_tier bump + audit_log row. '
  'Doc-check only, never legal verification. Notifies the seller (HYA-242).';

revoke execute on function public.v1_admin_verify_kyc (uuid) from public;
grant execute on function public.v1_admin_verify_kyc (uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 4. v1_admin_reject_kyc + kyc_rejected
-- ---------------------------------------------------------------------------
-- Source: 20261005120000_kyc_documents_tier2_tier3.sql (HYA-264 A1).
-- Unchanged except the notify block before the return.

create or replace function public.v1_admin_reject_kyc (
  p_doc_id uuid,
  p_reason text
)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_doc public.kyc_documents%rowtype;
  v_reason text := btrim(coalesce(p_reason, ''));
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to review KYC'
      using errcode = '42501';
  end if;
  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;
  -- Blank reasons leave the seller with nothing to fix (same rule as
  -- v1_admin_reject_listing 22023).
  if v_reason = '' then
    raise exception 'INVALID_REASON: rejection reason is required'
      using errcode = '22023';
  end if;

  select * into v_doc
  from public.kyc_documents
  where id = p_doc_id
  for update;

  if not found then
    raise exception 'NOT_FOUND: KYC document not found'
      using errcode = 'P0002';
  end if;
  if v_doc.status <> 'pending' then
    raise exception 'CONFLICT: document is already reviewed (%)', v_doc.status
      using errcode = '23505';
  end if;

  update public.kyc_documents
  set status = 'rejected',
      reviewed_by = v_uid,
      reviewed_at = now()
  where id = p_doc_id;

  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    v_uid, 'kyc.rejected', 'kyc', p_doc_id,
    jsonb_build_object(
      'doc_type', v_doc.doc_type,
      'profile_id', v_doc.profile_id,
      'listing_id', v_doc.listing_id,
      'reason', v_reason
    )
  );

  -- B2 fan-out.
  perform private.notify_user(
    v_doc.profile_id,
    'kyc_rejected',
    'Your ' || private.kyc_doc_label(v_doc.doc_type)
      || ' document was rejected: ' || v_reason
      || ' You can submit a clearer photo.',
    'तपाईंको ' || private.kyc_doc_label_ne(v_doc.doc_type)
      || ' कागजात अस्वीकृत भयो: ' || v_reason
      || ' स्पष्ट फोटो पेस गर्न सक्नुहुन्छ।'
  );

  return json_build_object('id', p_doc_id, 'status', 'rejected');
end;
$$;

comment on function public.v1_admin_reject_kyc (uuid, text) is
  'Admin-only: pending -> rejected + audit_log row with reason. File bytes '
  'purged after 30 days by purge_rejected_kyc_docs(). Notifies the seller.';

revoke execute on function public.v1_admin_reject_kyc (uuid, text) from public;
grant execute on function public.v1_admin_reject_kyc (uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 5. v1_contact_seller + new_message (first reveal only)
-- ---------------------------------------------------------------------------
-- Source: 20261004070232_allow_rereveal_at_cap.sql.
-- Unchanged except the title lookup and the notify block before the return.
-- Only a first-time reveal notifies: re-reveals hand back contact the buyer
-- already holds, and notifying on those would let one buyer buzz a seller
-- indefinitely. No buyer identity travels in the message.

create or replace function public.v1_contact_seller (p_listing_id uuid)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_seller_id uuid;
  v_status public.listing_status;
  v_title text;
  v_reveals_today integer;
  v_revealed_at timestamptz;
  v_expires_at timestamptz;
  v_inserted boolean;
  v_result json;
begin
  -- Defence in depth. anon has no EXECUTE grant, so this is unreachable from a
  -- guest; it catches a JWT that carries no `sub`.
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to contact a seller'
      using errcode = '42501';
  end if;

  select l.seller_id, l.status, l.title
    into v_seller_id, v_status, v_title
  from public.listings l
  where l.id = p_listing_id;

  -- Missing, unpublished and not-yours all answer identically so a client
  -- cannot probe for the existence of a listing it may not see.
  if v_status is distinct from 'live' then
    raise exception 'NOT_FOUND: listing not found or not available'
      using errcode = 'P0002';
  end if;

  -- A seller has their own phone number already. Denying this also stops the
  -- daily cap being burned on self-reveals.
  if v_seller_id = v_uid then
    raise exception 'FORBIDDEN: cannot reveal your own contact'
      using errcode = '42501';
  end if;

  v_expires_at := now() + interval '24 hours';

  insert into public.contact_logs as cl (buyer_id, listing_id, expires_at)
  values (v_uid, p_listing_id, v_expires_at)
  on conflict (buyer_id, listing_id) do update
    set revealed_at = now(),
        expires_at = excluded.expires_at
  returning cl.revealed_at,
            cl.expires_at,
            (cl.xmax = 0)
    into v_revealed_at, v_expires_at, v_inserted;

  -- Only a first-time reveal is capped. Re-revealing hands back nothing the
  -- buyer does not already hold.
  if v_inserted then
    select count(*) into v_reveals_today
    from public.contact_logs cl
    where cl.buyer_id = v_uid
      and cl.revealed_at > now() - interval '1 day';

    if v_reveals_today > 10 then
      raise exception 'RATE_LIMITED: contact reveal limit reached'
        using errcode = 'PN001';
    end if;

    -- B2 fan-out: first reveal only (see header).
    perform private.notify_user(
      v_seller_id,
      'new_message',
      'Someone viewed your contact details for ''' || v_title || '''.',
      'कसैले तपाईंको ''' || v_title || ''' को सम्पर्क विवरण हेर्नुभयो।'
    );
  end if;

  select json_build_object(
    'listing_id', p_listing_id,
    'seller_id', v_seller_id,
    'seller_name', p.full_name,
    'seller_phone', p.phone,
    'seller_email', p.email,
    'agency_name', p.agency_name,
    'is_verified', p.is_verified,
    'revealed_at', v_revealed_at,
    'expires_at', v_expires_at
  ) into v_result
  from public.profiles p
  where p.id = v_seller_id;

  if v_result is null then
    raise exception 'NOT_FOUND: seller profile missing'
      using errcode = 'P0002';
  end if;

  return v_result;
end;
$$;

revoke execute on function public.v1_contact_seller (uuid) from public;
grant execute on function public.v1_contact_seller (uuid) to authenticated;

comment on function public.v1_contact_seller (uuid) is
  'Reveals a live listing''s seller contact to a signed-in buyer, at most 10 '
  'first-time reveals per rolling 24 hours, and records the reveal. '
  'Re-revealing a contact already held is always allowed. First reveals '
  'notify the seller (HYA-242).';

-- HYA-248: restate the anon-execution default so future functions inherit it.
alter default privileges in schema public
  revoke execute on functions from anon;

-- ---------------------------------------------------------------------------
-- ACKNOWLEDGED ADVISOR FINDINGS
-- ---------------------------------------------------------------------------
-- v1_admin_approve_listing, v1_admin_reject_listing, v1_admin_verify_kyc,
-- v1_admin_reject_kyc and v1_contact_seller remain
-- authenticated_security_definer_function_executable findings. Intentional,
-- as with every other v1_ RPC: DEFINER is required (writes past the
-- caller's RLS plus the audit row), `search_path = ''` with fully qualified
-- names makes it safe, and the missing anon grant is the control.
-- private.notify_user and the label helpers may be flagged as
-- security_definer without grants: also intentional — unreachable via
-- PostgREST (private schema), callable only from server-side SQL.
