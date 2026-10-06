-- HYA-268 (C2b) — saved searches: table + RLS
--
-- A saved search is a named filter a buyer stores and re-runs. Flat columns
-- mirror `ListingFilter` field-for-field (district, type, purpose, price and
-- area bounds) rather than a jsonb blob, for one reason: the C3 matcher that
-- alerts on new listings is a SQL predicate, and comparing columns beats
-- extracting jsonb paths in every way that matters (indexes, readability,
-- EXPLAIN output an admin can actually read).
--
-- A null bound is a wildcard. The client validates ranges (min <= max) before
-- sending (Rule 6); the database does not re-check them, because a lopsided
-- range is merely useless (matches nothing), never dangerous.
--
-- WHAT THIS DOES NOT DO (C3)
-- ==========================
-- Matching new listings against these rows and notifying needs a writer on a
-- schedule (pg_cron or Edge) plus a new notification type: the
-- `notifications.type` check has no saved-search value, and extending it is a
-- constraint change that belongs with the matcher, not here.
--
-- RULE 3: RLS lives in the same migration as the table. Owner-only throughout:
-- searches are private to the account, support has no read path, and the
-- admin queue never shows them.

-- ---------------------------------------------------------------------------
-- 1. Table
-- ---------------------------------------------------------------------------

create table if not exists public.saved_searches (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  -- Display name. Client-generated from the filter ("Houses in Kathmandu");
  -- renaming is a later affordance, not a schema question.
  name text not null check (name <> ''),
  district text,
  property_type text
    check (property_type is null
      -- Mirrors public.property_type (20261002073751_listings.sql).
      or property_type in (
        'land', 'house', 'apartment', 'villa', 'commercial', 'business'
      )),
  listing_purpose text
    check (listing_purpose is null
      or listing_purpose in ('sale', 'rent', 'lease')),
  min_price_npr integer check (min_price_npr is null or min_price_npr > 0),
  max_price_npr integer check (max_price_npr is null or max_price_npr > 0),
  min_area_sqm double precision
    check (min_area_sqm is null or min_area_sqm > 0),
  max_area_sqm double precision
    check (max_area_sqm is null or max_area_sqm > 0),
  created_at timestamptz not null default now()
);

comment on table public.saved_searches is
  'Buyer-stored browse filters (HYA-268 C2b). Null bound = wildcard. '
  'Matching against new listings is C3 with a scheduler.';

-- The account's searches, newest first, is the only read order.
create index if not exists saved_searches_user_idx
  on public.saved_searches (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- 2. RLS (same file as the table — Rule 3)
-- ---------------------------------------------------------------------------
-- Full owner CRUD: unlike notifications (a server-written log), a saved
-- search is an ordinary user document — rename and adjust are legitimate, so
-- UPDATE is granted rather than trigger-frozen.

alter table public.saved_searches enable row level security;

drop policy if exists "saved_searches_select_own" on public.saved_searches;
create policy "saved_searches_select_own"
  on public.saved_searches for select
  to authenticated
  using (user_id = (select private.current_uid()));

drop policy if exists "saved_searches_insert_own" on public.saved_searches;
create policy "saved_searches_insert_own"
  on public.saved_searches for insert
  to authenticated
  with check (user_id = (select private.current_uid()));

drop policy if exists "saved_searches_update_own" on public.saved_searches;
create policy "saved_searches_update_own"
  on public.saved_searches for update
  to authenticated
  using (user_id = (select private.current_uid()))
  with check (user_id = (select private.current_uid()));

drop policy if exists "saved_searches_delete_own" on public.saved_searches;
create policy "saved_searches_delete_own"
  on public.saved_searches for delete
  to authenticated
  using (user_id = (select private.current_uid()));

-- HYA-248: restate the anon-execution default so future functions inherit it.
alter default privileges in schema public
  revoke execute on functions from anon;
