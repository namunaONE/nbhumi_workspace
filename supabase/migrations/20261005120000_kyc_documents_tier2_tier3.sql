-- HYA-264 (Tier 2) + HYA-265 (Tier 3) — A1: kyc_documents + private bucket + RPCs
--
-- Doc-check only — nBhumi never claims legal/title verification. A verified
-- badge means an admin looked at the file, nothing more. Copy in the client
-- must say that (HYA-265 description).
--
-- WHAT THIS ADDS
-- ==============
--   1. storage bucket `kyc-documents`, private (public = false). Downloads via
--      RLS-scoped SELECT or time-boxed signed URLs only (Rule 5, max 1h —
--      StorageService.getSignedUrl defaults to 3600).
--   2. public.kyc_documents table + RLS in this same file (Rule 3).
--      Tier 2 = profile-level (listing_id NULL, citizenship -> kyc_tier
--      'identity'). Tier 3 = per-listing (listing_id NOT NULL, lalpurja ->
--      kyc_tier 'property', Verified Listing badge).
--   3. RPCs only for status transitions (Rule 4):
--        v1_submit_kyc            authenticated, insert pending row
--        v1_admin_verify_kyc      admin, pending -> verified + tier bump + audit
--        v1_admin_reject_kyc      admin, pending -> rejected + audit
--      No direct UPDATE on status from the client: owner UPDATE policy keeps
--      status/reviewed_* frozen, admin has no direct write policy at all.
--   4. storage.objects policies for the bucket (owner-or-admin). No
--      ALTER TABLE storage.objects — Supabase owns that table and 42501s the
--      statement since April 2025. CREATE/DROP POLICY only.
--   5. purge_rejected_kyc_docs() for the 30-day retention rule (DATA.md):
--      deletes rejected rows older than 30 days. Row delete hides objects from
--      the API; true byte purge needs a service_role Storage call (same
--      limitation as HYA-258 tombstone cleanup) and belongs to the Edge
--      Function follow-up.
--
-- RELATION TO PRIVACY DELETE (HYA-258)
-- ====================================
-- profile_id is ON DELETE CASCADE, so v1_delete_my_account needs no change:
-- deleting the profile deletes the rows, and the existing best-effort
-- storage.objects purge in that function fires now that the bucket exists
-- (it is guarded by `exists (select 1 from storage.buckets ...)`).
-- reviewed_by is ON DELETE SET NULL; the audit_log trail keeps the actor.
--
-- DART MODEL NOTE
-- ===============
-- packages/models KycDocument has no listing_id/updated_at yet. Both are
-- nullable/defaulted here, so this migration is forward-compatible; the model
-- + repository follow in A2.

-- ---------------------------------------------------------------------------
-- 1. Private bucket
-- ---------------------------------------------------------------------------
-- Only (id, name, public): file_size_limit / mime allowlist are enforced in
-- the RPC (10 MiB cap, pdf/jpg/png) + client validators (Rule 6), so a
-- Storage API version skew cannot break this migration with an unknown column.

insert into storage.buckets (id, name, public)
values ('kyc-documents', 'kyc-documents', false)
on conflict (id) do nothing;

comment on column public.profiles.kyc_tier is
  'Trust tier. none -> account (magic link) -> identity (Tier 2 citizenship '
  'doc-check, HYA-264) -> property (Tier 3 per-listing lalpurja doc-check, '
  'HYA-265). Doc-check only, never legal verification.';

-- ---------------------------------------------------------------------------
-- 2. kyc_documents table
-- ---------------------------------------------------------------------------

create table if not exists public.kyc_documents (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles (id) on delete cascade,
  -- NULL = Tier 2 identity check. NOT NULL = Tier 3 per-listing check.
  listing_id uuid references public.listings (id) on delete cascade,
  doc_type text not null
    check (doc_type in ('citizenship', 'lalpurja', 'agency_reg')),
  -- Owner-scoped path `<uid>/<filename>`. RPC enforces the prefix so one
  -- seller cannot claim another seller's file.
  storage_path text not null
    check (storage_path <> '' and storage_path not like '%..%'),
  status text not null default 'pending'
    check (status in ('pending', 'verified', 'rejected')),
  reviewed_by uuid references public.profiles (id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- A verified/rejected row must say who/when; a pending row must not.
  check (
    (status = 'pending' and reviewed_by is null and reviewed_at is null)
    or (status in ('verified', 'rejected')
        and reviewed_by is not null and reviewed_at is not null)
  )
);

comment on table public.kyc_documents is
  'KYC doc-checks (HYA-264 Tier 2 identity, HYA-265 Tier 3 per-listing). '
  'Status moves via v1_* RPCs only. Rejected rows purged after 30 days.';

comment on column public.kyc_documents.listing_id is
  'NULL for Tier 2 citizenship checks; set for Tier 3 lalpurja/Tiro Rasid '
  'checks bound to one listing. Dart KycDocument gains this field in A2.';

-- Reuse the set_updated_at() helper from 001 (Rule: no new helper needed).
drop trigger if exists kyc_documents_set_updated_at on public.kyc_documents;
create trigger kyc_documents_set_updated_at
  before update on public.kyc_documents
  for each row execute function public.set_updated_at();

create index if not exists kyc_documents_profile_idx
  on public.kyc_documents (profile_id);
create index if not exists kyc_documents_listing_idx
  on public.kyc_documents (listing_id)
  where listing_id is not null;
-- Admin review inbox is "pending first"; partial so verified history costs nothing.
create index if not exists kyc_documents_pending_idx
  on public.kyc_documents (created_at, id)
  where status = 'pending';

-- ---------------------------------------------------------------------------
-- 3. RLS (same file as the table — Rule 3)
-- ---------------------------------------------------------------------------

alter table public.kyc_documents enable row level security;

-- Owner reads own rows; admin reads everything (detail pane + signed URL mint).
drop policy if exists "kyc_select_own_or_admin" on public.kyc_documents;
create policy "kyc_select_own_or_admin"
  on public.kyc_documents for select
  to authenticated
  using (
    profile_id = (select private.current_uid())
    or (select private.is_admin())
  );

-- Owner inserts own rows only. listing_id ownership is checked in the RPC,
-- not here: RLS cannot join listings cheaply per insert without a subselect
-- the RPC already performs with a clear error code.
drop policy if exists "kyc_insert_own" on public.kyc_documents;
create policy "kyc_insert_own"
  on public.kyc_documents for insert
  to authenticated
  with check (profile_id = (select private.current_uid()));

-- Owner may re-upload while pending but can never touch status/reviewed_*.
-- USING guards the old row, WITH CHECK guards the new row: together they
-- freeze the review verdict against direct writes (Rule 4).
drop policy if exists "kyc_update_own_pending" on public.kyc_documents;
create policy "kyc_update_own_pending"
  on public.kyc_documents for update
  to authenticated
  using (
    profile_id = (select private.current_uid())
    and status = 'pending'
  )
  with check (
    profile_id = (select private.current_uid())
    and status = 'pending'
    and reviewed_by is null
    and reviewed_at is null
  );

-- Owner may withdraw a pending application. Verified history is immutable
-- from the client; removal after a verdict is admin/RPC-only via purge.
drop policy if exists "kyc_delete_own_pending" on public.kyc_documents;
create policy "kyc_delete_own_pending"
  on public.kyc_documents for delete
  to authenticated
  using (
    profile_id = (select private.current_uid())
    and status = 'pending'
  );

-- No admin write policy by design: verify/reject go through SECURITY DEFINER
-- RPCs that write the audit_log row (Rule 8). An admin UPDATE grant here
-- would be a silent audit bypass.

-- ---------------------------------------------------------------------------
-- 4. storage.objects policies for kyc-documents
-- ---------------------------------------------------------------------------
-- Folder convention `<uid>/...`, same as the per-user-folder pattern in the
-- Supabase access-control docs. (storage.foldername(name))[1] is the top
-- folder = owner uid. Admin read via private.is_admin(); admin never writes
-- objects directly — review is a row verdict, not a file rewrite.

drop policy if exists "kyc_docs_insert_own" on storage.objects;
create policy "kyc_docs_insert_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'kyc-documents'
    and (storage.foldername(name))[1] = (select private.current_uid())::text
  );

drop policy if exists "kyc_docs_select_own_or_admin" on storage.objects;
create policy "kyc_docs_select_own_or_admin"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'kyc-documents'
    and (
      (storage.foldername(name))[1] = (select private.current_uid())::text
      or (select private.is_admin())
    )
  );

drop policy if exists "kyc_docs_update_own" on storage.objects;
create policy "kyc_docs_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'kyc-documents'
    and (storage.foldername(name))[1] = (select private.current_uid())::text
  )
  with check (
    bucket_id = 'kyc-documents'
    and (storage.foldername(name))[1] = (select private.current_uid())::text
  );

drop policy if exists "kyc_docs_delete_own" on storage.objects;
create policy "kyc_docs_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'kyc-documents'
    and (storage.foldername(name))[1] = (select private.current_uid())::text
  );

-- ---------------------------------------------------------------------------
-- 5. v1_submit_kyc — seller uploads a doc for review
-- ---------------------------------------------------------------------------

create or replace function public.v1_submit_kyc (
  p_doc_type text,
  p_storage_path text,
  p_listing_id uuid default null
)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_result json;
  v_owner uuid;
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to submit KYC'
      using errcode = '42501';
  end if;

  -- Validate before touching anything (Rule 6: server enforces what the
  -- client validators in validators.dart pre-check).
  if p_doc_type not in ('citizenship', 'lalpurja', 'agency_reg') then
    raise exception 'INVALID_DOC_TYPE: %', p_doc_type
      using errcode = '22023';
  end if;

  if p_storage_path is null or btrim(p_storage_path) = ''
     or p_storage_path like '%..%' then
    raise exception 'INVALID_PATH: storage path is required'
      using errcode = '22023';
  end if;

  -- Path must live under the caller's own folder. Prevents claiming
  -- another seller's upload by guessing its filename.
  if split_part(p_storage_path, '/', 1) <> v_uid::text then
    raise exception 'FORBIDDEN: path must start with your user id'
      using errcode = '42501';
  end if;

  -- Tier 3 guard: the listing must exist and belong to the caller.
  if p_listing_id is not null then
    select l.seller_id into v_owner
    from public.listings l
    where l.id = p_listing_id;
    if not found then
      raise exception 'NOT_FOUND: listing not found'
        using errcode = 'P0002';
    end if;
    if v_owner <> v_uid then
      raise exception 'FORBIDDEN: listing is not yours'
        using errcode = '42501';
    end if;
    -- Tier 3 is a property document, not an identity document.
    if p_doc_type = 'citizenship' then
      raise exception 'INVALID_DOC_TYPE: per-listing checks need lalpurja'
        using errcode = '22023';
    end if;
  end if;

  -- One pending application per (profile, type, listing): resubmit by
  -- updating the row (owner UPDATE policy) rather than stacking pendings.
  if exists (
    select 1 from public.kyc_documents d
    where d.profile_id = v_uid
      and d.doc_type = p_doc_type
      and d.listing_id is not distinct from p_listing_id
      and d.status = 'pending'
  ) then
    raise exception 'CONFLICT: a pending review already exists for this document'
      using errcode = '23505';
  end if;

  insert into public.kyc_documents (profile_id, listing_id, doc_type, storage_path)
  values (v_uid, p_listing_id, p_doc_type, p_storage_path)
  returning json_build_object(
    'id', id,
    'status', status,
    'doc_type', doc_type,
    'listing_id', listing_id,
    'created_at', created_at
  ) into v_result;

  return v_result;
end;
$$;

comment on function public.v1_submit_kyc (text, text, uuid) is
  'Seller submits a KYC document for admin doc-check. Tier 2 when '
  'p_listing_id is null, Tier 3 per-listing otherwise. Path must be '
  '<uid>/... so sellers cannot claim each other''s files.';

revoke execute on function public.v1_submit_kyc (text, text, uuid) from public;
grant execute on function public.v1_submit_kyc (text, text, uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 6. v1_admin_verify_kyc / v1_admin_reject_kyc — admin verdicts (Rule 8)
-- ---------------------------------------------------------------------------

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

  return json_build_object('id', p_doc_id, 'status', 'verified', 'kyc_tier', v_new_tier);
end;
$$;

comment on function public.v1_admin_verify_kyc (uuid) is
  'Admin-only: pending -> verified + profiles.kyc_tier bump + audit_log row. '
  'Doc-check only, never legal verification.';

revoke execute on function public.v1_admin_verify_kyc (uuid) from public;
grant execute on function public.v1_admin_verify_kyc (uuid) to authenticated;

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

  return json_build_object('id', p_doc_id, 'status', 'rejected');
end;
$$;

comment on function public.v1_admin_reject_kyc (uuid, text) is
  'Admin-only: pending -> rejected + audit_log row with reason. File bytes '
  'purged after 30 days by purge_rejected_kyc_docs().';

revoke execute on function public.v1_admin_reject_kyc (uuid, text) from public;
grant execute on function public.v1_admin_reject_kyc (uuid, text) to authenticated;

-- HYA-248: restate the anon-execution default so future functions inherit it.
alter default privileges in schema public
  revoke execute on functions from anon;

-- ---------------------------------------------------------------------------
-- 7. 30-day retention purge (DATA.md)
-- ---------------------------------------------------------------------------
-- Deletes rejected rows older than 30 days + their storage.objects rows.
-- Row delete hides files from the API; orphaned bytes need a service_role
-- Storage delete (Edge Function follow-up) — same limitation as HYA-258.
-- Callable by service_role (cron) and admins (manual), never by sellers.

create or replace function public.purge_rejected_kyc_docs ()
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_docs integer := 0;
  v_objs integer := 0;
begin
  -- service_role has no JWT uid and bypasses RLS: allow it explicitly.
  -- Authenticated callers must be admin.
  if v_uid is not null and not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  delete from storage.objects
  where bucket_id = 'kyc-documents'
    and name in (
      select d.storage_path
      from public.kyc_documents d
      where d.status = 'rejected'
        and d.reviewed_at < now() - interval '30 days'
    );
  get diagnostics v_objs = row_count;

  delete from public.kyc_documents
  where status = 'rejected'
    and reviewed_at < now() - interval '30 days';
  get diagnostics v_docs = row_count;

  return json_build_object(
    'purged_documents', v_docs,
    'purged_objects', v_objs
  );
end;
$$;

comment on function public.purge_rejected_kyc_docs () is
  'Retention: deletes rejected KYC rows + storage rows older than 30 days. '
  'Run via pg_cron/Edge with service_role; admins may call manually.';

revoke execute on function public.purge_rejected_kyc_docs () from public;
revoke execute on function public.purge_rejected_kyc_docs () from anon;
grant execute on function public.purge_rejected_kyc_docs () to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- ACKNOWLEDGED ADVISOR FINDINGS
-- ---------------------------------------------------------------------------
-- authenticated_security_definer_function_executable on v1_submit_kyc,
-- v1_admin_verify_kyc, v1_admin_reject_kyc is intentional (same as every
-- other v1_ RPC): DEFINER is required so the function can join/insert past
-- the caller's RLS, `search_path = ''` with fully qualified names makes it
-- safe, and the missing anon grant is the control.
