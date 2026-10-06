-- HYA-263 part 1b: teach v1_delete_my_account about listing_reports.
--
-- ## Why this is a separate file
--
-- `20261006055202_listing_reports.sql` adds `listing_reports.reporter_id` with
-- `references public.profiles (id)` and deliberately no ON DELETE clause. That
-- choice breaks the Privacy Act self-service delete, because
-- `v1_delete_my_account` hard-deletes `public.profiles`.
--
-- This is not hypothetical. Measured against the live database, immediately
-- after the table was created:
--
--   delete from public.profiles where id = <a user who had filed a report>
--   ERROR: 23503: update or delete on table "profiles" violates foreign key
--          constraint "profiles_reporter_fkey"
--
-- So the two files belong together in one change. They are split only because
-- the schema and the SECURITY DEFINER function are separately re-runnable, which
-- is the same split migration 010 used for the verification queue.
--
-- ## Why reports are re-attributed rather than cascaded
--
-- A report is evidence against the *seller*. Cascading it away means a
-- fraudulent seller gets exactly what they wanted the moment a buyer deletes
-- their own account, which is the easiest possible thing for them to ask for.
--
-- Re-attributing to the tombstone uuid keeps the report, drops the identity,
-- and matches what this function already does for listings, reviewed_by,
-- audit_log and contact_logs. The consequence is stated plainly in the response:
-- `reports_anonymized`.
--
-- ## Why resolved_by is nulled rather than re-attributed
--
-- `resolved_by` records which *admin* made a decision. Pointing it at the
-- tombstone would assert that a nonexistent user resolved it, and the admin UI
-- would render that as a name. Clearing it loses the attribution, but the
-- `audit_log` row written at resolution time still holds the real actor, so
-- nothing is actually lost.

create or replace function public.v1_delete_my_account()
returns json
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_tombstone uuid := '00000000-0000-0000-0000-000000000000';
  v_listings integer;
  v_reviews integer;
  v_contacts integer;
  v_audits integer;
  v_reports integer;
  v_docs integer := 0;
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to delete your account'
      using errcode = '42501';
  end if;

  if v_uid = v_tombstone then
    raise exception 'FORBIDDEN: the deleted-user identity cannot be deleted'
      using errcode = '42501';
  end if;

  if not exists (select 1 from public.profiles where id = v_uid) then
    raise exception 'NOT_FOUND: no account for this session'
      using errcode = 'P0002';
  end if;

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

  -- HYA-263: keep the report, drop the reporter's identity.
  update public.listing_reports
  set reporter_id = v_tombstone
  where reporter_id = v_uid;
  get diagnostics v_reports = row_count;

  -- An admin can be deleted too; clear the reference rather than block on it.
  update public.listing_reports
  set resolved_by = null
  where resolved_by = v_uid;

  if exists (select 1 from storage.buckets where id = 'kyc-documents') then
    delete from storage.objects
    where bucket_id = 'kyc-documents'
      and (owner = v_uid or name like v_uid::text || '/%');
    get diagnostics v_docs = row_count;
  end if;

  delete from public.profiles where id = v_uid;
  delete from auth.users where id = v_uid;

  return json_build_object(
    'deleted_user_id', v_uid,
    'anonymized_listings', v_listings,
    'reviews_reattributed', v_reviews,
    'audit_rows_kept', v_audits,
    'contact_logs_retained', v_contacts,
    'reports_anonymized', v_reports,
    'documents_purged', v_docs
  );
end;
$function$;

comment on function public.v1_delete_my_account() is
  'Privacy Act self-service deletion (HYA-258). Since HYA-263 the response also '
  'carries reports_anonymized: listing_reports rows are re-attributed to the '
  'tombstone uuid rather than deleted, so a report survives the reporter '
  'leaving while losing their identity.';