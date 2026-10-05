-- HYA-258 — tombstone identity + v1_delete_my_account
--
-- Privacy Act 2075 gives every user the right to delete their account. Deleting
-- sounds simple until the foreign keys are listed, and every one of them says
-- something about what "delete" must mean here:
--
--   listings.seller_id      NOT NULL, ON DELETE CASCADE
--   contact_logs.buyer_id   NOT NULL, references auth.users, CASCADE
--   audit_log.actor_id      NOT NULL, no cascade at all
--   listings.reviewed_by    nullable, no cascade
--
-- Two requirements pull in opposite directions, and both are explicit:
--
--   * listings are ANONYMIZED, not deleted (HYA-258 description);
--   * contact_logs are RETAINED per policy;
--   * audit rows must survive (Rule 8: every admin action is logged, and a log
--     that evaporates when its actor leaves is not a log).
--
-- CASCADE on listings would delete the seller's properties outright, and the
-- missing cascades on audit_log would make the whole delete fail. So deletion
-- reassigns instead of cascading: every personal reference moves to a permanent
-- tombstone identity, and only then are the profile and auth rows removed. The
-- tombstone is a real auth user + profile that can never sign in (nobody
-- controls its inbox), so all NOT NULL constraints stay satisfied and every
-- historical row keeps its shape with the person scrubbed out of it.
--
-- What each table means after a delete:
--
--   listings.seller_id  -> tombstone. The listing stays live with no seller
--                           identity. A later contact reveal returns a null
--                           phone, which the client renders as unavailable.
--   contact_logs        -> buyer_id becomes tombstone. Reveal history survives
--                           for abuse analysis, de-linked from the person.
--   audit_log.actor_id  -> tombstone. The trail of who approved what keeps its
--                           rows; the actor reads as "Deleted user".
--
-- KYC documents: there is no kyc-documents bucket and no kyc_documents table
-- yet (M3 / HYA-264), so there is nothing to purge today. The function still
-- attempts a best-effort cleanup guarded by the bucket's existence, because a
-- delete path written without it would silently keep whatever HYA-264 starts
-- storing. Limitation, stated: deleting storage.objects rows hides files from
-- the API but leaves bytes orphaned in the backend. True byte-level purge
-- needs a service_role call and belongs to HYA-264, which owns that bucket.

-- ---------------------------------------------------------------------------
-- Tombstone identity
-- ---------------------------------------------------------------------------
-- Fixed uuid, documented everywhere it is referenced. Created once; the
-- ON CONFLICT guard makes re-running safe.

insert into auth.users (id, email, raw_user_meta_data)
values (
  '00000000-0000-0000-0000-000000000000',
  'deleted@nbhumi.internal',
  '{"is_tombstone": true}'::jsonb
)
on conflict (id) do nothing;

insert into public.profiles (id, email, full_name, role, is_verified, kyc_tier)
values (
  '00000000-0000-0000-0000-000000000000',
  'deleted@nbhumi.internal',
  'Deleted user',
  'buyer',
  false,
  'none'
)
on conflict (id) do nothing;

comment on column public.profiles.full_name is
  'Display name. The tombstone identity 00000000-0000-0000-0000-000000000000 '
  'reads "Deleted user"; it owns listings and log rows whose person is gone.';

-- ---------------------------------------------------------------------------
-- v1_delete_my_account
-- ---------------------------------------------------------------------------

create or replace function public.v1_delete_my_account()
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_tombstone uuid := '00000000-0000-0000-0000-000000000000';
  v_listings integer;
  v_reviews integer;
  v_contacts integer;
  v_audits integer;
  v_docs integer := 0;
begin
  -- Defence in depth: authenticated-only grant plus this check, for a JWT that
  -- carries no `sub`.
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to delete your account'
      using errcode = '42501';
  end if;

  -- The tombstone is infrastructure, not a person. Deleting it would orphan
  -- every anonymized row in the database at once.
  if v_uid = v_tombstone then
    raise exception 'FORBIDDEN: the deleted-user identity cannot be deleted'
      using errcode = '42501';
  end if;

  -- No profile means no account to delete. This also makes a second delete a
  -- clean NOT_FOUND instead of a silent success with all-zero counts.
  if not exists (select 1 from public.profiles where id = v_uid) then
    raise exception 'NOT_FOUND: no account for this session'
      using errcode = 'P0002';
  end if;

  -- Reassign first, delete last. Every one of these columns is NOT NULL, so
  -- the reassignment is what makes the deletes below legal at all.

  update public.listings
  set seller_id = v_tombstone
  where seller_id = v_uid;
  get diagnostics v_listings = row_count;

  update public.listings
  set reviewed_by = v_tombstone
  where reviewed_by = v_uid;
  get diagnostics v_reviews = row_count;

  update public.audit_log
  set actor_id = v_tombstone
  where actor_id = v_uid;
  get diagnostics v_audits = row_count;

  update public.contact_logs
  set buyer_id = v_tombstone
  where buyer_id = v_uid;
  get diagnostics v_contacts = row_count;

  -- Best-effort document purge. Fires only if the bucket exists (it does not
  -- yet; M3 / HYA-264 creates it). Row deletion hides objects from the API;
  -- orphaned bytes need a service_role purge, which is HYA-264's job.
  if exists (select 1 from storage.buckets where id = 'kyc-documents') then
    delete from storage.objects
    where bucket_id = 'kyc-documents'
      and (owner = v_uid or name like v_uid::text || '/%');
    get diagnostics v_docs = row_count;
  end if;

  -- The profile FK cascade would delete listings; nothing references the
  -- profile anymore by this point, so both deletes are clean.
  delete from public.profiles where id = v_uid;
  delete from auth.users where id = v_uid;

  return json_build_object(
    'deleted_user_id', v_uid,
    'anonymized_listings', v_listings,
    'reviews_reattributed', v_reviews,
    'audit_rows_kept', v_audits,
    'contact_logs_retained', v_contacts,
    'documents_purged', v_docs
  );
end;
$$;

-- Account deletion is the one write that must never be reachable without a
-- session: it destroys the caller's identity. No anon grant, and none ever.
revoke execute on function public.v1_delete_my_account() from public;
grant execute on function public.v1_delete_my_account() to authenticated;

comment on function public.v1_delete_my_account() is
  'Deletes the caller''s account per Privacy Act 2075: listings anonymized to '
  'the tombstone identity, contact logs retained de-linked, audit trail kept, '
  'profile and auth rows removed.';

-- ---------------------------------------------------------------------------
-- ACKNOWLEDGED ADVISOR FINDINGS
-- ---------------------------------------------------------------------------
-- authenticated_security_definer_function_executable is intentional here, as
-- with every other v1_ RPC. DEFINER is required: the caller must not have
-- DELETE on profiles or auth.users (there is deliberately no DELETE policy),
-- and only the function may rewrite other users' audit rows. The missing anon
-- grant is the control, not an oversight.
--
-- Product note, not enforced: deleting the last admin is allowed and leaves
-- their reviews attributed to the tombstone. Refusing it would need a
-- privileged-role census inside a self-service function, which is a policy
-- decision for the admin panel, not a guard in this RPC.