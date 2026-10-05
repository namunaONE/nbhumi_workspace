-- HYA-206 — seed 60 realistic Kathmandu Valley listings, part 2 of 2
-- (Tarakeshwor, Budhanilakantha, Chandragiri, Gokarneshwor, Nagarjun,
-- Dakshinkali, Shankharapur, Kageshwori: 28 rows + assertions)
--
-- NOTE: the recorded SQL of this applied migration accidentally included
-- one extra row, `insert into public.municipalities (...) values
-- ('placeholder-should-never-exist', ...)`, which was removed immediately
-- via an explicit DELETE (now 0 rows). The file on disk is authoritative
-- and does NOT contain that statement. Rows for Nagarjun/Dakshinkali/
-- Shankharapur/Kageshwori (9 of the 28) landed in the follow-on tail
-- migration 20261005081308, whose file repeats them verbatim.
--
-- Solo-dev content bootstrap: the marketplace needs supply for browse/search
-- to be testable. These are realistic SYNTHETIC rows, not scraped broker
-- data — prices track 2026 Kathmandu market levels (houses 1.3–6.8 Cr by
-- area, land priced per aana by locality, rents monthly), areas carry matching
-- sqm + local units, and wards respect each body's ward_count (the trigger
-- from HYA-253 would refuse anything else).
--
-- No photos: cover images come from sellers at post time, and hotlinking
-- stock URLs would lie about the properties. ListingCard renders its
-- placeholder for photo-less rows (covered by widget tests).
--
-- Idempotent: fixed ids from md5(title) with ON CONFLICT DO NOTHING, so
-- re-running converges. created_at is spread over the past 50 days so the
-- newest-first feed orders realistically.
-- Tarakeshwor (5, wards 1-11)
-- ---------------------------------------------------------------------------

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-tarakeshwor-manamaiju-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'House in Manamaiju', 'Family home near the main road with shop frontage.', 19800000, 1026.8, 3, 'Kathmandu', 'Tarakeshwor', '4', 11, 3, 2, 'live', now() - interval '20 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-tarakeshwor-kavresthali-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Land in Kavresthali', 'Terraced land with valley view, suitable for farmhouse.', 7200000, 1369.0, 4, 'Kathmandu', 'Tarakeshwor', '2', 9, 'live', now() - interval '26 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-tarakeshwor-sitapaila-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'New Villa in Sitapaila Height', 'Panoramic-view villa with double garage.', 31000000, 1369.0, 4, 'Kathmandu', 'Tarakeshwor', '9', 13, 4, 3, 'live', now() - interval '23 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, bedrooms, bathrooms, status, created_at) values
  (md5('seed-tarakeshwor-greenhill-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'apartment', 'rent', 'Flat in Greenhill City', 'Colony flat with playground access for children.', 27000, 80.0, 'Kathmandu', 'Tarakeshwor', '6', 2, 2, 'live', now() - interval '15 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, status, created_at) values
  (md5('seed-tarakeshwor-machhapokhari-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'commercial', 'rent', 'Shop Space in Machhapokhari', 'Corner shop space on the ring-road stretch.', 35000, 35.0, 'Kathmandu', 'Tarakeshwor', '3', 'live', now() - interval '18 days')
  on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Budhanilakantha (5, wards 1-9)
-- ---------------------------------------------------------------------------

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-budhanilakantha-luxury-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Luxury House in Budhanilakantha', 'Designer home near the Narayanthan temple area.', 45000000, 1711.2, 5, 'Kathmandu', 'Budhanilakantha', '3', 14, 4, 4, 'live', now() - interval '32 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-budhanilakantha-hattigauda-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Land in Hattigauda', 'Premium residential strip, galli with drainage.', 21000000, 2053.5, 6, 'Kathmandu', 'Budhanilakantha', '5', 12, 'live', now() - interval '35 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, bedrooms, bathrooms, status, created_at) values
  (md5('seed-budhanilakantha-bansbari-apt-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'apartment', 'sale', 'Apartment in Bansbari', 'Top-floor flat with Shivapuri views.', 12500000, 88.0, 'Kathmandu', 'Budhanilakantha', '4', 3, 2, 'live', now() - interval '38 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-budhanilakantha-chapali-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'rent', 'House in Chapali', 'Independent house with kitchen garden space.', 48000, 1026.8, 3, 'Kathmandu', 'Budhanilakantha', '8', 11, 3, 2, 'live', now() - interval '12 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-budhanilakantha-deuba-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Residential Land in Deuba Chowk', 'Plotted land in a developing pocket.', 9500000, 1197.9, 3, 2, 'Kathmandu', 'Budhanilakantha', '7', 10, 'live', now() - interval '41 days')
  on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Chandragiri (5, wards 1-15)
-- ---------------------------------------------------------------------------

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-chandragiri-thankot-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'House in Thankot', 'Highway-access home with commercial ground floor.', 17500000, 1026.8, 3, 'Kathmandu', 'Chandragiri', '4', 12, 3, 2, 'live', now() - interval '29 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-chandragiri-hills-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Land in Chandragiri Hills', 'Sloped land with cable-car views, resort potential.', 6000000, 1711.2, 5, 'Kathmandu', 'Chandragiri', '8', 8, 'live', now() - interval '37 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-chandragiri-naikap-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'New House in Naikap', 'Earthquake-safe pillar system, vastu-friendly layout.', 21000000, 1112.3, 3, 1, 'Kathmandu', 'Chandragiri', '12', 11, 4, 3, 'live', now() - interval '26 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, bedrooms, bathrooms, status, created_at) values
  (md5('seed-chandragiri-thankot-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'apartment', 'rent', 'Flat in Thankot', 'Budget flat for highway commuters.', 20000, 70.0, 'Kathmandu', 'Chandragiri', '5', 2, 1, 'live', now() - interval '17 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-chandragiri-highway-commercial-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'commercial', 'sale', 'Commercial Land on Highway', 'Tribhuvan Highway frontage for showroom or motel.', 32000000, 2738.0, 8, 'Kathmandu', 'Chandragiri', '2', 20, 'live', now() - interval '44 days')
  on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Gokarneshwor (4, wards 1-9)
-- ---------------------------------------------------------------------------

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-gokarna-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'House in Gokarna', 'Near the forest gate, cool and quiet by city standards.', 23000000, 1026.8, 3, 'Kathmandu', 'Gokarneshwor', '4', 11, 3, 2, 'live', now() - interval '31 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-gokarna-forest-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Land near Gokarna Forest', 'Green-belt adjacent plot, morning-walk territory.', 8000000, 1369.0, 4, 'Kathmandu', 'Gokarneshwor', '6', 9, 'live', now() - interval '40 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-gokarna-narayanthan-villa-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Villa in Narayanthan', 'Modern villa with rooftop sit-out facing the hills.', 29500000, 1369.0, 4, 'Kathmandu', 'Gokarneshwor', '9', 12, 4, 3, 'live', now() - interval '34 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-gokarna-boudha-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'rent', 'Rental House in Boudha Gate', 'Family house a short walk from the stupa circuit.', 30000, 684.5, 2, 'Kathmandu', 'Gokarneshwor', '5', 9, 2, 1, 'live', now() - interval '20 days')
  on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Nagarjun (4, wards 1-10)
-- ---------------------------------------------------------------------------

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-nagarjun-ramkot-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'House in Ramkot', 'Hillside home with city lights view from the terrace.', 19000000, 1026.8, 3, 'Kathmandu', 'Nagarjun', '6', 11, 3, 2, 'live', now() - interval '28 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-nagarjun-bafal-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Land in Bafal', 'Inner-city plot in an established neighborhood.', 8800000, 1369.0, 4, 'Kathmandu', 'Nagarjun', '10', 10, 'live', now() - interval '42 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, bedrooms, bathrooms, status, created_at) values
  (md5('seed-nagarjun-kalanki-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'apartment', 'rent', 'Rental Flat in Kalanki', 'Transit-friendly flat near the Kalanki underpass.', 24000, 75.0, 'Kathmandu', 'Nagarjun', '5', 2, 2, 'live', now() - interval '11 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-nagarjun-syuchatar-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'House in Syuchatar', 'Corner house with extra side yard for kitchen garden.', 22500000, 1197.9, 3, 2, 'Kathmandu', 'Nagarjun', '9', 12, 4, 2, 'live', now() - interval '45 days')
  on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Dakshinkali (2, wards 1-9), Shankharapur (2, wards 1-9), Kageshwori (1)
-- ---------------------------------------------------------------------------

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-dakshinkali-farm-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Farmhouse Land in Dakshinkali', 'Terraced farmland with seasonal stream, weekend-home potential.', 6000000, 3422.5, 10, 'Kathmandu', 'Dakshinkali', '4', 8, 'live', now() - interval '47 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-dakshinkali-pharping-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'House in Pharping', 'Pilgrim-town home with monastery views.', 13500000, 1026.8, 3, 'Kathmandu', 'Dakshinkali', '6', 10, 3, 2, 'live', now() - interval '49 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-sankhu-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Land in Sankhu', 'Ancient-town fringe land, quiet Newari settlement.', 4800000, 2053.5, 6, 'Kathmandu', 'Shankharapur', '3', 8, 'live', now() - interval '46 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-sankhu-bazaar-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'New House in Sankhu Bazaar', 'Market-adjacent new build with shop space below.', 14800000, 941.2, 2, 3, 'Kathmandu', 'Shankharapur', '7', 10, 3, 2, 'live', now() - interval '50 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-kageshwori-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'House in Kageshwori', 'Ridge-line home with sunrise views over Bhaktapur.', 16500000, 1026.8, 3, 'Kathmandu', 'Kageshwori Manahora', '5', 10, 3, 2, 'live', now() - interval '48 days')
  on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Assertions
-- ---------------------------------------------------------------------------

do $$
declare
  v_total integer;
  v_live integer;
  v_bad_fk integer;
  v_bad_ward integer;
begin
  select count(*) into v_total
  from public.listings
  where seller_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd';
  if v_total <> 60 then
    raise exception 'SEED MISMATCH: % seed listings, expected 60', v_total
      using errcode = 'integrity_constraint_violation';
  end if;

  select count(*) into v_live
  from public.listings
  where seller_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'
    and status = 'live';
  if v_live <> 60 then
    raise exception 'SEED MISMATCH: % live seed listings, expected 60', v_live
      using errcode = 'integrity_constraint_violation';
  end if;

  -- Every (district, city) pair resolves (the FK guarantees it, this names it).
  select count(*) into v_bad_fk
  from public.listings l
  where l.seller_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'
    and not exists (
      select 1 from public.municipalities m
      where m.district = l.district and m.name = l.city
    );
  if v_bad_fk > 0 then
    raise exception 'SEED MISMATCH: % listings with unresolvable city', v_bad_fk
      using errcode = 'integrity_constraint_violation';
  end if;

  -- Every ward fits its own body's count (the trigger guarantees it).
  select count(*) into v_bad_ward
  from public.listings l
  join public.municipalities m
    on m.district = l.district and m.name = l.city
  where l.seller_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'
    and l.ward is not null
    and l.ward::integer > m.ward_count;
  if v_bad_ward > 0 then
    raise exception 'SEED MISMATCH: % listings exceed their body ward count',
      v_bad_ward
      using errcode = 'integrity_constraint_violation';
  end if;

  raise notice 'listing seed ok: 60 live rows, all FK + ward bounds hold';
end;
$$;