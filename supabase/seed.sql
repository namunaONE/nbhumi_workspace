-- nBhumi — Dev Seed Data
-- Consolidated fixture data for local development and testing.
-- This file is NOT a migration — run it manually after `supabase db reset`.
--
-- Contents:
--   1. 60 live Kathmandu listings (browse fixtures)
--   2. 54 pending_review listings (admin queue fixtures)
--   3. Photos for pending_review listings
--
-- Usage:
--   supabase db reset && supabase db push && psql -f supabase/seed.sql

-- ---------------------------------------------------------------------------
-- 1. Live listings (60 rows)
-- ---------------------------------------------------------------------------
-- These are browse fixtures: they populate the home feed and search results.
-- They are NOT real properties. Titles are clearly marked as fixtures.

insert into public.listings (
  id, seller_id, property_type, listing_purpose, title, description,
  price_npr, area_sqm, area_aana, area_paisa, district, city, ward,
  road_access_ft, bedrooms, bathrooms, status, created_at
)
select
  md5('fixture-live-' || n::text)::uuid,
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  (array['land','house','apartment','villa','commercial'])[1 + (n % 5)],
  (array['sale','sale','rent','lease'])[1 + (n % 4)],
  'Browse fixture ' || lpad(n::text, 2, '0'),
  'Fixture row for browse/search testing. Not a real property.',
  5000000 + (n * 350000),
  200 + (n * 11),
  case when n % 3 = 0 then 2 + (n % 4) else null end,
  case when n % 4 = 0 then 1 + (n % 3) else null end,
  'Kathmandu',
  'Kathmandu',
  case when (n % 5) in (0, 3) then 2 + (n % 4) else null end,
  case when n % 3 = 0 then 10 + n else null end,
  case when (n % 5) in (0, 3) then 1 + (n % 3) else null end,
  'live',
  now() - interval '10 days'
from generate_series(1, 60) as n
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- 2. Pending review listings (54 rows)
-- ---------------------------------------------------------------------------
-- These are admin queue fixtures: they populate the verification queue.
-- They walk through the legal state transition (draft → pending_review).

-- Insert as draft
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

-- Walk through legal transition (draft → pending_review)
update public.listings
   set status = 'pending_review'
 where id in (select md5('fixture-pending-' || n::text)::uuid
                from generate_series(1, 54) n)
   and status = 'draft';

-- Backdate submitted_at to spread across SLA buckets
update public.listings l
   set submitted_at = case n % 3
                        when 0 then now() - interval '6 hours'
                        when 1 then now() - interval '41 hours'
                        else        now() - interval '73 hours'
                      end
  from generate_series(1, 54) g(n)
 where l.id = md5('fixture-pending-' || g.n::text)::uuid
   and l.status = 'pending_review';

-- ---------------------------------------------------------------------------
-- 3. Photos for pending_review listings
-- ---------------------------------------------------------------------------
-- Two per listing except every 7th gets one (below the wizard floor of 3).

delete from public.listing_photos
 where listing_id in (select md5('fixture-pending-' || n::text)::uuid
                         from generate_series(1, 54) n);

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
  select generate_series(1, case when g.n % 7 = 0 then 1 else 2 end) as n
) p
where l.status = 'pending_review';

-- ---------------------------------------------------------------------------
-- 4. Verification
-- ---------------------------------------------------------------------------

do $$
declare
  v_live     int;
  v_pending  int;
  v_photos   int;
begin
  select count(*) into v_live from public.listings where status = 'live';
  select count(*) into v_pending from public.listings where status = 'pending_review';
  select count(*) into v_photos from public.listing_photos;

  if v_live < 50 then
    raise exception 'Seed: expected at least 50 live listings, got %', v_live;
  end if;

  if v_pending < 50 then
    raise exception 'Seed: expected at least 50 pending listings, got %', v_pending;
  end if;

  raise notice 'Seed: % live, % pending, % photos', v_live, v_pending, v_photos;
end;
$$;
