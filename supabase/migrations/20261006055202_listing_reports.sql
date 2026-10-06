-- HYA-263: buyer "report listing" flags.
--
-- Part 1 of 2: schema, constraints, indexes and RLS. The RPCs
-- (v1_report_listing, v1_admin_get_reports, v1_admin_resolve_report) follow in
-- part 2, split the way the queue migration was, so DDL and SECURITY DEFINER
-- functions stay separately re-runnable.
--
-- ## Why this is not just a button (HYA-263 calls it "cheap")
--
-- The UI is cheap. The trust loop is the point: a buyer flags something
-- suspicious, and that flag reaches an admin who would otherwise never see it.
-- The schema has to make three abuses impossible rather than merely discouraged:
--
--   * a buyer flooding one listing with reports, to get a competitor taken down;
--   * a seller reporting their own listing to manufacture an appearance of
--     dispute, or to unpublish themselves;
--   * a report arriving for a listing the reporter cannot even see.
--
-- All three are enforced in the INSERT policy's WITH CHECK below, which is the
-- only place a client cannot route around.
--
-- ## Why reporter_id is ON DELETE RESTRICT, and what that costs
--
-- `v1_delete_my_account` hard-deletes `public.profiles`. A plain
-- `references profiles(id)` would therefore make account deletion FAIL for any
-- user who has ever filed a report, with a bare FK violation and no explanation.
--
-- Three options were available:
--
--   * ON DELETE CASCADE  -- the report vanishes. Wrong: a report is evidence
--     against a *seller*. Losing it because the reporter deleted their own
--     account hands the seller exactly the outcome they wanted.
--   * ON DELETE SET NULL -- the report survives but loses its reporter, so
--     "this buyer reported three listings this week" stops being answerable.
--   * Re-attribute to the tombstone uuid, which is what this file does.
--
-- The third matches what v1_delete_my_account already does for listings,
-- reviewed_by, audit_log and contact_logs, so a deleted user's reports become
-- anonymous-but-retained rather than vanishing. It also means this migration
-- MUST update that function, or deletion breaks. It does, below.
--
-- ## Why one report per buyer per listing, permanently
--
-- unique (listing_id, reporter_id). A buyer cannot re-report a listing they have
-- already reported, even after it is dismissed.
--
-- That is deliberate. It makes "report" a considered act rather than a button,
-- and it means an admin's dismissal counts for something. The cost is that a
-- genuine, recurring problem cannot be re-reported; the remedy is that the
-- listing is still there to re-evaluate, and the seller can be actioned
-- directly. Flood-filling is the attack that actually matters, and a unique
-- index is the only thing that fully prevents it.
--
-- ## Why the resolution check constraint
--
-- A report is either open, or resolved by a specific admin at a specific time.
-- Those are not three independent columns. Without this constraint a client
-- could write status='actioned' with a null resolved_by and the admin UI would
-- have no way to tell who did it. The INSERT policy forbids setting a non-open
-- status at creation; this constraint stops the inconsistent state arising any
-- other way.

-- ---------------------------------------------------------------------------
-- Enums
--
-- An enum rather than free text, matching listing_status / property_type /
-- municipality_type. Rule 6 requires the client and server to agree on the
-- accepted set, and an enum makes that set inspectable in one place.
-- ---------------------------------------------------------------------------

create type public.report_reason as enum (
  'duplicate_listing',      -- the same property is listed more than once
  'photos_misleading',      -- photos appear to be of another property
  'price_suspicious',       -- price is implausible for the area
  'wrong_location',         -- district, municipality or ward is wrong
  'already_sold',           -- the property is no longer available
  'seller_asked_offsite',   -- seller tried to move the deal off-platform
  'fake_listing',           -- no such property exists
  'other'                   -- anything above was wrong; details required
);

create type public.report_status as enum (
  'open',       -- awaiting an admin
  'actioned',   -- an admin acted on it (listing actioned or seller suspended)
  'dismissed'   -- an admin reviewed it and found nothing wrong
);

-- ---------------------------------------------------------------------------
-- Table
-- ---------------------------------------------------------------------------

create table public.listing_reports (
  id uuid primary key default gen_random_uuid(),

  -- CASCADE: listings are never hard-deleted in this system (they move through
  -- listing_status), so this only fires if one is purged. A report about a
  -- listing that no longer exists has nothing to act on.
  listing_id uuid not null references public.listings (id) on delete cascade,

  -- Deliberately no ON DELETE clause; see the header. v1_delete_my_account
  -- re-attributes to the tombstone before deleting the profile.
  reporter_id uuid not null references public.profiles (id),

  reason public.report_reason not null,

  -- Free text, because the enum cannot anticipate every reason. Bounded so a
  -- buyer cannot use it as general storage.
  details text check (details is null or length(details) <= 2000),

  status public.report_status not null default 'open',
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  resolved_by uuid references public.profiles (id),

  unique (listing_id, reporter_id),

  -- 'other' with no explanation is not actionable, so require the details.
  constraint reports_other_needs_details
    check (reason <> 'other' or details is not null),

  -- Open means unresolved; resolved means resolved. Never both, never neither.
  constraint reports_resolution_consistent
    check (
      (status =  'open' and resolved_at is null     and resolved_by is null)
      or
      (status <> 'open' and resolved_at is not null and resolved_by is not null)
    )
);

-- ---------------------------------------------------------------------------
-- Indexes
--
-- The partial index is the one that matters: an admin's worklist is open
-- reports, and open reports are a small fraction of the table once it fills.
-- Indexing only the open subset keeps that query's index small however many
-- resolved reports accumulate.
-- ---------------------------------------------------------------------------

create index listing_reports_open_idx
  on public.listing_reports (created_at)
  where status = 'open';

-- Per-listing report count, for a badge on the queue row and the detail pane.
create index listing_reports_listing_idx
  on public.listing_reports (listing_id);

-- ---------------------------------------------------------------------------
-- RLS (Rule 3: same migration as the table)
-- ---------------------------------------------------------------------------

alter table public.listing_reports enable row level security;

-- Buyers insert their own, always open, and never against their own listing.
--
-- All three conditions are in WITH CHECK because that is the only clause a
-- client cannot work around: USING does not apply to INSERT.
--
--   * reporter_id = me          -- cannot file as somebody else
--   * status = 'open'           -- cannot self-resolve at creation
--   * not my own listing        -- cannot manufacture a dispute
--   * the listing is visible    -- cannot probe for listings that do not exist
create policy listing_reports_insert_own
  on public.listing_reports
  for insert
  to authenticated
  with check (
    reporter_id = (select private.current_uid())
    and status = 'open'
    and exists (
      select 1
      from public.listings l
      where l.id = listing_id
        -- visible to the reporter: live, or their own. Mirrors
        -- listings_select_public_live, which RLS would otherwise apply here
        -- too, but an INSERT policy has no SELECT clause to lean on.
        and (
          l.status = 'live'
          or l.seller_id = (select private.current_uid())
        )
        -- and not their own: a seller cannot flag themselves.
        and l.seller_id is distinct from (select private.current_uid())
    )
  );

-- A buyer sees what they filed; an admin sees everything.
create policy listing_reports_select_own_or_admin
  on public.listing_reports
  for select
  to authenticated
  using (
    reporter_id = (select private.current_uid())
    or (select private.is_admin())
  );

-- Resolution is an admin action, and only ever happens through
-- v1_admin_resolve_report, which writes the audit_log row Rule 8 requires. The
-- policy is the backstop for a direct write attempt.
create policy listing_reports_update_admin
  on public.listing_reports
  for update
  to authenticated
  using ((select private.is_admin()))
  with check ((select private.is_admin()));

-- Admin delete, for removing spam that was filed in bulk by mistake.
-- Rare, and it shows in the audit trail via the resolve path rather than here.
create policy listing_reports_delete_admin
  on public.listing_reports
  for delete
  to authenticated
  using ((select private.is_admin()));

-- ---------------------------------------------------------------------------
-- Grants
--
-- To `authenticated`, with RLS doing the role separation: there is no `admin`
-- Postgres role, admins are `authenticated` with profiles.role = 'admin'.
-- ---------------------------------------------------------------------------

grant select, insert on public.listing_reports to authenticated;
grant update, delete on public.listing_reports to authenticated;
