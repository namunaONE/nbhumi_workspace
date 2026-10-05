-- HYA-260 (1/2) — part 1 of 2: submitted_at, the trigger, the indexes
--
-- APPLIED AS TWO FILES, NOT ONE
-- ================================
-- This is part 1. Part 2 (the functions) is 20261005035118. The split was not
-- a design choice — see the note at the bottom of this file. Read them together.
--
-- THE 48h SLA HAD NO COLUMN TO READ
-- ==================================
-- DATA.md sets a 48-hour review SLA, and HYA-260 requires the queue to show
-- "queue age shown vs 48h SLA". Neither existing timestamp can supply that:
--
--   created_at  when the draft was *started*. A seller who spends a week writing
--               the description and then submits would appear as a 7-day SLA
--               breach the moment they submit.
--   updated_at  whenever the row last changed. A seller editing their listing
--               while it sits in the queue resets the clock, so the oldest
--               listing in the queue could read as brand new.
--
-- So `submitted_at` is added and maintained by a trigger. It is deliberately
-- NOT derived client-side: a Dart-side "now minus updated_at" would be wrong in
-- the same two ways, and would be wrong differently on each device's clock.
--
-- WHAT THE TRIGGER DOES ON RESUBMISSION
-- =====================================
-- `rejected -> pending_review` resets submitted_at to now(), which starts a
-- fresh 48h clock. That is the intended reading of the SLA: a seller who fixes
-- their rejection should get a full review window, not whatever was left of the
-- previous one. The previous value is still recoverable from audit_log, which
-- records the original review decision and its timestamp.
--
-- WHY THE STAMP IS UNCONDITIONAL ON A TRANSITION
-- ===============================================
-- The obvious refinement is to let an explicitly supplied submitted_at win, so
-- that fixtures can construct a listing that entered the queue three days ago.
-- That refinement is a security hole, and it was caught by testing rather than by
-- reading: written as `new.submitted_at is not distinct from old.submitted_at`,
-- it leaves the row alone whenever the caller's value DIFFERS from the old one --
-- which is precisely the forgery case.
--
--   -- a seller escaping a breached SLA:
--   update listings set status = 'pending_review',
--                        submitted_at = now() - interval '30 days'
--    where id = <my listing>;
--
-- With the guard, submitted_at is now 30 days old and the listing presents as
-- comfortably inside SLA. The 48h clock becomes advisory for anyone willing to
-- write to their own row, which `listings_update_own` otherwise permits.
--
-- So a transition into pending_review always stamps now(), full stop. Fixtures
-- and the backfill below keep their power, because both reach the column on an
-- UPDATE that does NOT change status:
--
--   * the backfill runs before this trigger exists
--   * a fixture inserts as pending_review, then UPDATEs submitted_at on its own
--     -- status is already pending_review, so nothing is re-stamped
--
-- Verified by test: a forged backdate on a transition is overwritten; an
-- explicit value with no status change is respected.
--
-- WHY A PARTIAL INDEX
-- ===================
-- The queue's only query is "pending_review, oldest submission first". There is
-- already a `listings_status_idx` on (status), but it cannot order by
-- submitted_at without a sort, and a sort over every pending listing re-reads
-- rows the admin has already seen. A partial index is smaller than a full one
-- by exactly the live and rejected rows, which is the majority of the table
-- once the marketplace has real inventory.
--
-- Measured on a 20,000-listing fixture (2,000 queued) against this project's
-- database: the page query takes "Index Only Scan using
-- listings_pending_review_sla_idx" with no sort node.

-- ---------------------------------------------------------------------------
-- 1. submitted_at
-- ---------------------------------------------------------------------------
-- RULE 1: a new migration, not an edit to 20261002000002_listings.sql.

alter table public.listings
  add column if not exists submitted_at timestamptz;

comment on column public.listings.submitted_at is
  'When this listing entered pending_review, i.e. when the 48h review clock '
  'started. Null for a draft that has never been submitted. The '
  'set_listing_submitted_at trigger overwrites this on every transition into '
  'pending_review, so a seller cannot forge it; it is only settable on an update '
  'that does not change status, which is what lets fixtures build a row of a '
  'given queue age. Not exposed as an RPC parameter.';

-- Backfill for any environment that already holds reviewed or queued rows.
-- created_at is the closest available approximation and is only ever wrong for
-- a listing whose draft sat open before its first submission. This project's
-- dev database had zero listings when this was applied, so it was a no-op here
-- and exists so the migration is correct anywhere else it is applied.
update public.listings
set submitted_at = created_at
where status = 'pending_review'
  and submitted_at is null;

-- ---------------------------------------------------------------------------
-- 2. The trigger
-- ---------------------------------------------------------------------------
-- BEFORE, so the column is already correct for the row as it is written, and so
-- any BEFORE trigger that reads submitted_at downstream would see it.

create or replace function public.set_listing_submitted_at ()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    -- v1_create_listing accepts a direct draft -> pending_review insert, so the
    -- clock has to be able to start at insert time and not only on update.
    if new.status = 'pending_review' then
      new.submitted_at := now();
    end if;
    return new;
  end if;

  -- Only an actual transition into the queue touches the clock.
  --
  -- Unconditional once that is true: no `is not distinct from` guard, because
  -- such a guard exempts exactly the forged value it is meant to catch. See the
  -- header note on escaping a breached SLA.
  --
  -- An UPDATE that does not move the status leaves the column alone. That is
  -- what stops a seller editing their queued listing from resetting their own
  -- clock, and it is also the path fixtures use to build a row that looks
  -- three days old: insert as pending_review, then set submitted_at.
  if new.status is distinct from old.status
     and new.status = 'pending_review' then
    new.submitted_at := now();
  end if;

  return new;
end;
$$;

comment on function public.set_listing_submitted_at () is
  'Maintains listings.submitted_at on entry to pending_review, including on '
  'resubmission after a rejection. Unconditional on a transition, so a seller '
  'cannot backdate their own submission to escape a breached SLA; an UPDATE that '
  'does not change status may set it freely, which is how fixtures build rows of '
  'a given queue age.';

-- Fires on every INSERT and UPDATE rather than `update of status` because the
-- INSERT arm needs it too, and the function body already short-circuits on the
-- two conditions that matter. A row that has never been queued costs two enum
-- comparisons.
--
-- Trigger name chosen so it sorts BEFORE `listings_status_transition`: Postgres
-- fires same-timing triggers in name order, and `listings_s-e-t-` precedes
-- `listings_s-t-a-`. That ordering is not required for correctness -- the two
-- triggers are independent, and an exception from the transition guard aborts
-- the whole statement so no half-written row survives either way -- but it keeps
-- the SLA clock consistent before any downstream trigger can observe the row.
create trigger listings_set_submitted_at
  before insert or update
  on public.listings
  for each row
  execute function public.set_listing_submitted_at ();

-- HYA-248 established that trigger helper functions get no EXECUTE grant from
-- anyone but the owner. A trigger function invoked directly by a client would
-- let it run with no meaningful arguments.
revoke execute on function public.set_listing_submitted_at () from public;

-- ---------------------------------------------------------------------------
-- 3. Queue index
-- ---------------------------------------------------------------------------

create index if not exists listings_pending_review_sla_idx
  on public.listings (submitted_at, id)
  where status = 'pending_review';

-- ---------------------------------------------------------------------------
-- 4. audit_log ordering index
-- ---------------------------------------------------------------------------
-- The admin panel's audit view is "most recent admin actions, newest first".
-- `audit_log_entity_idx` on (entity_type, entity_id) serves "what happened to
-- this one listing" but cannot serve that ordering, so the query sorted every
-- row in the table. audit_log grows monotonically and is never pruned, so that
-- cost rises with every approve and reject the platform ever performs.
--
-- DESC because the access pattern is always "newest first" and the column is
-- almost always non-null (default now(), and every writer supplies it).

create index if not exists audit_log_created_at_idx
  on public.audit_log (created_at desc);

-- ---------------------------------------------------------------------------
-- RULE 3 note
-- ---------------------------------------------------------------------------
-- No CREATE TABLE here, so there is no new RLS policy to ship alongside one.
-- For the record, submitted_at inherits `listings`'s existing policies, and
-- those are correct for it without amendment:
--
--   listings_select_public_live   admins read everything, so the queue is
--                                  readable; the RPC still gates on is_admin()
--                                  because the queue is more than one row and a
--                                  direct table read would bypass the page bound
--   listings_update_own           a seller may write submitted_at on their own row
--
-- The last one is the interesting case, and it is safe because the trigger owns
-- the column rather than because the policy excludes it. `listings_update_own`
-- genuinely permits a seller to set submitted_at, and on an UPDATE that does not
-- change status the trigger lets the value stand -- which is what makes seeded
-- fixtures of a given queue age possible at all.
--
-- The one case that matters is a transition into pending_review, where the stamp
-- is unconditional. So a seller can neither backdate their submission to present
-- a breached 48h SLA as healthy, nor forge a fresh timestamp to jump ahead of
-- listings that genuinely waited.
--
-- This is also why submitted_at is not exposed as a v1_create_listing or
-- v1_update_listing parameter. HYA-251 (2/2) added the seven area-unit params on
-- an "expose it, then validate it" basis; here there is nothing to validate,
-- because the only correct value is one the database computes.

-- ---------------------------------------------------------------------------
-- APPLIED AS TWO FILES, NOT ONE -- WHY
-- ---------------------------------
-- The reviewed migration was a single 652-line file named
-- 20261004103000_admin_verification_queue.sql. When applying it, the CLI-assigned
-- version did not match that filename, and splitting it into schema-then-functions
-- turned out to be the safer shape: the DDL and the SECURITY DEFINER functions
-- become separately re-runnable, and a failure in the function bodies cannot
-- leave the trigger installed against a function that does not exist.
--
-- So the file was split and renamed to the versions the database actually
-- recorded: 20261005035045 (this file) and 20261005035118 (the functions).
-- The database is the source of truth; these two files reproduce it exactly, in
-- order, so `supabase db reset` on a fresh machine rebuilds the same schema.
--
-- Read both files as one change. Part 2 carries the bulk of the reasoning about
-- the queue RPC and the cursor bug.