-- HYA-242 (B1) — notifications inbox table + RLS + Realtime + guards
--
-- WHAT THIS ADDS
-- ==============
--   1. public.notifications: one row per user-facing event
--      (listing_approved/rejected, kyc_verified/rejected, new_message).
--      Bilingual content (message_en/message_ne): Rule 36 applies to
--      notifications as much as to errors — a Nepali seller must not receive
--      an English-only verdict.
--   2. RLS in this same file (Rule 3). Reads and is_read flips are
--      owner-scoped; INSERT has deliberately NO policy for authenticated:
--      rows are written server-side only (SECURITY DEFINER verdict RPCs in B2
--      and service_role Edge Functions), so a client can neither forge a
--      "verified" notice nor spam another seller's inbox.
--   3. Immutability trigger: content columns (user_id, type, message_en,
--      message_ne) are frozen after insert. The inbox is a log, not a draft;
--      without the trigger the owner UPDATE policy would let a seller rewrite
--      a rejection into an approval on their own screen.
--   4. First table on the `supabase_realtime` publication: the in-app center
--      subscribes with a `user_id=eq.<uid>` filter (HYA-242 Realtime).
--
-- WHAT THIS DOES NOT DO (B2/B3)
-- ==============================
--   * Fan-out: no existing RPC inserts here yet. B2 extends the verdict RPCs
--     (listing approve/reject, KYC verify/reject) to notify, in NEW
--     statements — applied migrations are never edited (Rule 1).
--   * Push/SMS/Edge delivery (HYA-242 Edge Functions + FCM + Infobip).
--
-- PRIVACY DELETE (HYA-258)
-- ========================
-- user_id is ON DELETE CASCADE: a deleted account's inbox goes with it. That
-- is correct here, unlike listings/audit/contact_logs — notifications carry
-- no marketplace history worth anonymizing, and keeping them would retain
-- personal data past a deletion request (Privacy Act 2075).

-- ---------------------------------------------------------------------------
-- 1. Table
-- ---------------------------------------------------------------------------

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null
    check (type in (
      'listing_approved', 'listing_rejected',
      'kyc_verified', 'kyc_rejected',
      'new_message'
    )),
  -- Bilingual by schema, not by translation layer (Rule 36).
  message_en text not null check (message_en <> ''),
  message_ne text not null check (message_ne <> ''),
  is_read boolean not null default false,
  created_at timestamptz not null default now(),
  -- Content is frozen by the trigger below; only is_read may change.
  check (created_at is not null)
);

comment on table public.notifications is
  'Per-user inbox for HYA-242 (listing/KYC verdicts, messages). '
  'Server-written only; owners may flip is_read and delete. '
  'Content columns are trigger-frozen after insert.';

comment on column public.notifications.message_ne is
  'Nepali (Devanagari) content, required like message_en (Rule 36). '
  'A Nepali seller must never receive an English-only verdict.';

-- Newest first is the only read order (inbox + badge), oldest never scanned.
create index if not exists notifications_user_idx
  on public.notifications (user_id, created_at desc);

-- Unread badge without scanning read history.
create index if not exists notifications_unread_idx
  on public.notifications (user_id)
  where is_read = false;

-- ---------------------------------------------------------------------------
-- 2. Immutability trigger (owns the invariant RLS cannot express)
-- ---------------------------------------------------------------------------
-- RLS WITH CHECK sees only the new row; proving "type/message did not change"
-- needs the old row, which only a trigger has. Same philosophy as the
-- submitted_at trigger: the database owns the invariant, the policy owns the
-- access.

create or replace function public.enforce_notification_immutable ()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.user_id is distinct from old.user_id
     or new.type is distinct from old.type
     or new.message_en is distinct from old.message_en
     or new.message_ne is distinct from old.message_ne then
    raise exception 'IMMUTABLE: notification content cannot be changed'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

comment on function public.enforce_notification_immutable () is
  'Freezes notifications content columns after insert; only is_read may '
  'change via the owner UPDATE policy. A rewritten verdict surfaces as '
  '23514, mapped client-side to validation.constraint.';

drop trigger if exists notifications_immutable
  on public.notifications;
create trigger notifications_immutable
  before update on public.notifications
  for each row execute function public.enforce_notification_immutable ();

revoke execute on function public.enforce_notification_immutable ()
  from public;

-- ---------------------------------------------------------------------------
-- 3. RLS (same file as the table — Rule 3)
-- ---------------------------------------------------------------------------

alter table public.notifications enable row level security;

-- Owners read their own inbox. No admin SELECT: support reads no inboxes,
-- and an admin grant here would let a compromised admin session enumerate
-- every seller's verdicts. Admins act through RPCs, which bypass RLS.
drop policy if exists "notifications_select_own" on public.notifications;
create policy "notifications_select_own"
  on public.notifications for select
  to authenticated
  using (user_id = (select private.current_uid()));

-- No INSERT policy by design (see header): verdict RPCs (SECURITY DEFINER)
-- and service_role Edge Functions bypass RLS. An insert grant here would let
-- any signed-in user forge a "verified" notice into their own inbox — or, if
-- mis-scoped, into anyone's.

-- Owners flip is_read on their own rows. Content changes are rejected by the
-- trigger above, so this policy stays simple and the guarantee stays in one
-- place even if a second update path is added later.
drop policy if exists "notifications_update_own" on public.notifications;
create policy "notifications_update_own"
  on public.notifications for update
  to authenticated
  using (user_id = (select private.current_uid()))
  with check (user_id = (select private.current_uid()));

-- Owners may clear their own inbox. Verified history the platform needs is
-- in audit_log (Rule 8), not here.
drop policy if exists "notifications_delete_own" on public.notifications;
create policy "notifications_delete_own"
  on public.notifications for delete
  to authenticated
  using (user_id = (select private.current_uid()));

-- ---------------------------------------------------------------------------
-- 4. Realtime (first table on the publication)
-- ---------------------------------------------------------------------------
-- The in-app center subscribes with filter `user_id=eq.<uid>`. RLS still
-- applies over Realtime: the filter selects rows, the policy admits only the
-- caller's own, so one seller never sees another's events.

alter publication supabase_realtime add table public.notifications;

-- HYA-248: restate the anon-execution default so future functions inherit it.
alter default privileges in schema public
  revoke execute on functions from anon;

-- ---------------------------------------------------------------------------
-- ACKNOWLEDGED ADVISOR FINDINGS
-- ---------------------------------------------------------------------------
-- No SECURITY DEFINER function is created here, so there is nothing to flag.
-- The `supabase_realtime` publication add may be reported as an
-- informational schema note only.
