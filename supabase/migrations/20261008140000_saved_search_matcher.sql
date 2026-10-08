-- HYA-268 (C3) — saved-search alert matcher: notify on new listings.
--
-- WHAT THIS DOES
-- ==============
-- An hourly pg_cron job calls `v1_match_saved_searches()`, which scans
-- alert-enabled saved searches against live listings created since each
-- search's watermark and inserts one `saved_search_match` inbox row per
-- (search, listing) pair. In-app delivery needs no credentials, so unlike
-- push/SMS this half of HYA-268 is implementable now; FCM/APNs remain
-- blocked on server keys (see Linear).
--
-- PRIVACY / CORRECTNESS BOUNDARIES (deliberate)
-- =============================================
-- * A search only ever matches PUBLIC live listings: the predicate requires
--   `status = 'live'`, so drafts and rejected rows can never leak via alerts.
-- * A search only notifies ITS OWNER (`user_id` from the search row). The
--   function takes no caller input at all, so there is no confused-deputy
--   read of another buyer's searches.
-- * Watermarks (`last_notified_at`, else the search's own `created_at`)
--   bound every run: a listing created before the watermark never matches
--   later, so re-runs cannot spam history. Caps (5 per search, 200 per run)
--   bound a pathological first run after a long scheduler outage.
-- * EXECUTE is granted to service_role ONLY (the cron identity). Granting it
--   to authenticated would let any signed-in user run the whole table's
--   matching on demand — harmless in output (rows still go to owners) but a
--   free compute sink, so it stays revoked from public/anon/authenticated.
--
-- VERIFY AT APPLY TIME (HYA-283 owns the apply queue)
-- ===================================================
--   1. `select public.v1_match_saved_searches();` on a staging project with
--      one saved search + one fresh live listing → exactly one inbox row,
--      bilingual, with listing_id set.
--   2. Run it again → zero new rows (watermark held).
--   3. Confirm `cron.job` lists `saved-search-matcher` with schedule
--      `0 * * * *`.

-- ---------------------------------------------------------------------------
-- 1. Watermark + opt-out on saved_searches
-- ---------------------------------------------------------------------------

alter table public.saved_searches
  add column if not exists alert_enabled boolean not null default true;

alter table public.saved_searches
  add column if not exists last_notified_at timestamptz;

comment on column public.saved_searches.alert_enabled is
  'C3: false opts this search out of match alerts; true (default) enrolls it.';
comment on column public.saved_searches.last_notified_at is
  'C3: upper bound of the last matcher run for this search. Null means '
  'never run: the first run falls back to the search''s created_at.';

-- ---------------------------------------------------------------------------
-- 2. notifications: new type + listing link
-- ---------------------------------------------------------------------------
-- The type check is the compiler-generated `notifications_type_check`
-- (column-level CHECK naming). Drop + re-add with the new value.
alter table public.notifications
  drop constraint if exists notifications_type_check;

alter table public.notifications
  add constraint notifications_type_check
  check (type in (
    'listing_approved', 'listing_rejected',
    'kyc_verified', 'kyc_rejected',
    'new_message', 'saved_search_match'
  ));

-- Actionable alerts: tapping the row opens the listing. CASCADE keeps the
-- inbox truthful — a removed listing takes its match rows with it.
alter table public.notifications
  add column if not exists listing_id uuid
    references public.listings (id) on delete cascade;

create index if not exists notifications_listing_idx
  on public.notifications (listing_id)
  where listing_id is not null;

-- The new column joins the frozen set: match rows are a log, and an owner
-- repointing them at another listing would forge history.
create or replace function public.enforce_notification_immutable ()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.user_id is distinct from old.user_id
     or new.type is distinct from old.type
     or new.message_en is distinct from old.message_en
     or new.message_ne is distinct from old.message_ne
     or new.listing_id is distinct from old.listing_id then
    raise exception 'IMMUTABLE: notification content cannot be changed'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. Matcher
-- ---------------------------------------------------------------------------

create or replace function public.v1_match_saved_searches()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_run_at timestamptz := now();
  v_matched integer := 0;
  r_search record;
  r_listing record;
  v_per_search integer;
begin
  -- One transaction for the whole run: either every watermark advances with
  -- its rows, or none does. A crash mid-run re-scans rather than skips.
  for r_search in
    select id, user_id, district, property_type, listing_purpose,
           min_price_npr, max_price_npr, min_area_sqm, max_area_sqm,
           coalesce(last_notified_at, created_at) as watermark
    from public.saved_searches
    where alert_enabled
    order by created_at
  loop
    exit when v_matched >= 200;
    v_per_search := 0;
    for r_listing in
      select l.id, l.title, l.district, l.price_npr
      from public.listings l
      where l.status = 'live'
        and l.created_at > r_search.watermark
        and l.created_at <= v_run_at
        and (r_search.district is null or l.district = r_search.district)
        and (r_search.property_type is null
             or l.property_type::text = r_search.property_type)
        and (r_search.listing_purpose is null
             or l.listing_purpose::text = r_search.listing_purpose)
        and (r_search.min_price_npr is null
             or l.price_npr >= r_search.min_price_npr)
        and (r_search.max_price_npr is null
             or l.price_npr <= r_search.max_price_npr)
        and (r_search.min_area_sqm is null
             or (l.area_sqm is not null
                 and l.area_sqm >= r_search.min_area_sqm))
        and (r_search.max_area_sqm is null
             or (l.area_sqm is not null
                 and l.area_sqm <= r_search.max_area_sqm))
      order by l.created_at
      limit 5
    loop
      insert into public.notifications
        (user_id, type, listing_id, message_en, message_ne)
      values (
        r_search.user_id,
        'saved_search_match',
        r_listing.id,
        'New match: ' || r_listing.title || ' in ' || r_listing.district ||
          ' — NPR ' || r_listing.price_npr::text,
        'नयाँ मिल्दो विज्ञापन: ' || r_listing.title || ', ' ||
          r_listing.district || ' — NPR ' || r_listing.price_npr::text
      );
      v_matched := v_matched + 1;
      v_per_search := v_per_search + 1;
    end loop;
    update public.saved_searches
    set last_notified_at = v_run_at
    where id = r_search.id;
  end loop;
  return v_matched;
end;
$$;

comment on function public.v1_match_saved_searches() is
  'HYA-268 C3: hourly match of alert-enabled saved searches against new live '
  'listings. One bilingual inbox row per (search, listing); watermarks + caps '
  '(5/search, 200/run) bound repeats. EXECUTE: service_role (cron) only.';

revoke execute on function public.v1_match_saved_searches() from public;
revoke execute on function public.v1_match_saved_searches() from anon;
revoke execute on function public.v1_match_saved_searches()
  from authenticated;
grant execute on function public.v1_match_saved_searches() to service_role;

-- ---------------------------------------------------------------------------
-- 4. Schedule
-- ---------------------------------------------------------------------------

create extension if not exists pg_cron;

-- Hourly, top of the hour. Runs as the scheduling role; the function is
-- SECURITY DEFINER so row access does not depend on cron identity.
select cron.schedule(
  'saved-search-matcher',
  '0 * * * *',
  'select public.v1_match_saved_searches();'
);
