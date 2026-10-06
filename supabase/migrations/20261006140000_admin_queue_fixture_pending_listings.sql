-- HYA-260 dev fixture: listings in `pending_review`, so the admin verification
-- queue has something to review.
--
-- WHY THIS FILE EXISTS
--
-- The HYA-206 seed inserted 60 listings **directly as `live`**. That is not a
-- transition into `pending_review`, so `set_listing_submitted_at` correctly
-- stamped nothing and all 60 rows have `submitted_at IS NULL`. The result:
--
--   pending_review  0
--   live           60
--   submitted_at    0
--
-- The queue would render empty for any admin, including a real one. Those 60 rows
-- are browse fixtures, not moderation fixtures.
--
-- WHY IT INSERTS AS `draft` AND THEN UPDATES
--
-- `enforce_listing_status_transition` allows only
--   draft -> pending_review, pending_review -> draft, rejected -> pending_review
-- so this file walks each row through the legal path. That is deliberate: it
-- means the fixture also *proves* the state machine still works, because an
-- illegal jump would abort the migration rather than silently insert.
--
-- It also means `submitted_at` is stamped by the trigger rather than written by
-- hand, so the column the queue sorts by is populated by the same code that runs
-- in production.
--
-- `submitted_at` is THEN backdated below. The trigger can only stamp `now()`, and
-- a queue where every row is two seconds old exercises none of the SLA buckets.
-- Backdating happens after the legal transition so the trigger is never bypassed.
--
-- The ages are spread across all three buckets on purpose:
--   < 36h   fresh      (on time)
--   36-48h  atRisk     (due soon)
--   > 48h   breached   (overdue, past the 48h SLA)
--
-- WHY 54 ROWS
--
-- `v1_admin_get_queue` defaults to a page size of 50, so a queue of 50 or fewer
-- never returns a cursor and the pagination path in `AdminQueue.loadMore` is never
-- reached. 54 puts four rows on the second page, which is the smallest number
-- that makes load-more real.
--
-- CLEANING UP
--
--   delete from public.listing_photos
--    where listing_id in (select md5('fixture-pending-' || n::text)::uuid
--                           from generate_series(1, 54) n);
--   delete from public.listings
--    where id in (select md5('fixture-pending-' || n::text)::uuid
--                   from generate_series(1, 54) n);
--
-- `id` is a uuid column, so the sentinel cannot be a readable string; it has to be
-- md5(). The `'fixture-pending-'` prefix is what makes cleanup exact rather than a
-- `title LIKE` that could match a real listing.

-- ---------------------------------------------------------------------------
-- 1. Insert as draft. `seller_id` reuses HYA-206's seed seller, which already
--    exists with role `agent`, so the FK holds without inventing a profile.
-- ---------------------------------------------------------------------------

insert into public.listings (
  id, seller_id, property_type, listing_purpose, title, description,
  price_npr, area_sqm, district, city, bedrooms, bathrooms, road_access_ft,
  status, created_at
)
select
  md5('fixture-pending-' || n::text)::uuid,
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  (array['land','house','apartment','villa','commercial'])[1 + (n % 5)],
  (array['sale','sale','rent','lease'])[1 + (n % 4)],
  'Verification fixture ' || lpad(n::text, 2, '0'),
  'Fixture row used to exercise the admin verification queue. Not a real property.',
  5000000 + (n * 350000),
  200 + (n * 11),
  'Kathmandu',
  'Kathmandu',
  case when (n % 5) in (0, 3) then 2 + (n % 4) else null end,
  case when (n % 5) in (0, 3) then 1 + (n % 3) else null end,
  case when n % 3 = 0 then 10 + n else null end,
  'draft',
  now() - interval '10 days'
from generate_series(1, 54) as n
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- 2. Walk them through the legal transition. This is the line that stamps
--    `submitted_at` via the trigger.
-- ---------------------------------------------------------------------------

update public.listings
   set status = 'pending_review'
 where id in (select md5('fixture-pending-' || n::text)::uuid
               from generate_series(1, 54) n)
   and status = 'draft';

-- ---------------------------------------------------------------------------
-- 3. Backdate `submitted_at` to spread the queue across the SLA buckets.
--
--    36h is `atRiskAfter` and 48h is `breachAfter` in QueueSlaThresholds. A row
--    sitting exactly on a boundary is placed on the *other* side of it, so no
--    fixture depends on `>=` behaving as the Dart tests assume.
--
--    n % 3 spreads the three buckets evenly across 54 rows: 18 each.
-- ---------------------------------------------------------------------------

update public.listings l
   set submitted_at = case n % 3
                        when 0 then now() - interval '6 hours'    -- fresh
                        when 1 then now() - interval '41 hours'   -- at risk
                        else        now() - interval '73 hours'    -- overdue
                      end
  from generate_series(1, 54) g(n)
 where l.id = md5('fixture-pending-' || g.n::text)::uuid
   and l.status = 'pending_review';

-- ---------------------------------------------------------------------------
-- 4. Photos, so `photo_count` and `photo_url` are exercised rather than always
--    zero.
--
--    Two per listing except where the fixture deliberately falls below the
--    wizard's floor of 3 — those are what the queue row's photo warning is for,
--    and a fixture where every listing has enough photos never exercises it.
--
--    The URLs point at the public `listing-photos` bucket but resolve to nothing:
--    there are no objects behind them. That is intentional. `Image.network`'s
--    `errorBuilder` renders a broken-image placeholder, and a fixture that made
--    real network calls would make verification depend on Supabase Storage
--    being reachable.
-- ---------------------------------------------------------------------------

insert into public.listing_photos (listing_id, url, sort_order)
select
  l.id,
  'https://project.supabase.co/storage/v1/object/public/listing-photos/'
    || l.id::text || '-' || p.n || '.jpg',
  p.n
from public.listings l
join generate_series(1, 54) g(n)
  on l.id = md5('fixture-pending-' || g.n::text)::uuid
cross join lateral (
  -- every 7th fixture gets a single photo, below the floor of 3
  select generate_series(1, case when g.n % 7 = 0 then 1 else 2 end) as n
) p
where l.status = 'pending_review'
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- 5. Assert the fixture produced what the queue needs.
--
--    A migration that silently inserted zero rows would leave the queue empty and
--    then look like an application bug. This turns that into a failed migration.
-- ---------------------------------------------------------------------------

do $$
declare
  v_total   int;
  v_stamped int;
begin
  select count(*), count(submitted_at)
    into v_total, v_stamped
    from public.listings
   where id in (select md5('fixture-pending-' || n::text)::uuid
                 from generate_series(1, 54) n)
     and status = 'pending_review';

  if v_total < 51 then
    raise exception
      'HYA-260 fixture: expected at least 51 pending rows for pagination to '
      'engage past the page size of 50, got %', v_total;
  end if;

  if v_stamped <> v_total then
    raise exception
      'HYA-260 fixture: % of % pending rows have no submitted_at. The trigger '
      'did not fire, so the queue would have nothing to sort by.',
      v_stamped, v_total;
  end if;

  raise notice 'HYA-260 fixture: % pending rows, all stamped', v_total;
end;
$$;