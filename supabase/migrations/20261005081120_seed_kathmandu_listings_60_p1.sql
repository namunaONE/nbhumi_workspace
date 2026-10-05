-- HYA-206 — seed 60 realistic Kathmandu Valley listings, part 1 of 2
-- (seller identity + Kathmandu metro, Kirtipur, Tokha: 32 rows)
-- See 20261005081141_seed_kathmandu_listings_60_p2.sql for the rest.
-- Full rationale in that file's header. Purging the seed later is one
-- statement: delete from listings where seller_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'.
--
-- NOTE (recorded drift): the auth-on-signup trigger auto-created this
-- profile with empty defaults BEFORE the INSERT ... ON CONFLICT DO NOTHING
-- could set it, so full_name/phone/role stayed blank until patched
-- separately: UPDATE profiles SET full_name='Demo Homes (seed)',
-- phone='9841111111', role='agent' WHERE id='dddddddd-...' (2026-10-05).
-- seller_name on v1_get_listings now resolves correctly.

-- ---------------------------------------------------------------------------
-- Demo seller
-- ---------------------------------------------------------------------------

insert into auth.users (id, email, raw_user_meta_data)
values (
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  'demo.seed@nbhumi.internal',
  '{"is_seed": true}'::jsonb
)
on conflict (id) do nothing;

insert into public.profiles (id, email, full_name, phone, role, is_verified, kyc_tier)
values (
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  'demo.seed@nbhumi.internal',
  'Demo Homes (seed)',
  '9841111111',
  'agent',
  false,
  'none'
)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Kathmandu Metropolitan City (20)
-- ---------------------------------------------------------------------------

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-baneshwor-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Modern 4BHK House in Baneshwor', 'Earthquake-resistant RCC frame, modular kitchen, parking for two cars, south-facing.', 38500000, 1369.0, 4, 0, 'Kathmandu', 'Kathmandu', '10', 13, 4, 3, 'live', now() - interval '2 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-lazimpat-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Newly Built House near Lazimpat', 'Premium finishes near the diplomatic enclave, servant quarter, landscaped garden.', 52000000, 1882.4, 5, 2, 'Kathmandu', 'Kathmandu', '2', 15, 5, 4, 'live', now() - interval '5 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-ktm-kapan-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Residential Land in Kapan', 'East-facing plotted land, blacktopped access, ready to build.', 30400000, 2738.0, 8, 'Kathmandu', 'Kathmandu', '12', 12, 'live', now() - interval '9 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-chabahil-apt-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'apartment', 'sale', '2BHK Apartment in Chabahil', 'Second-floor flat with balcony, lift and backup power.', 9500000, 78.5, 'Kathmandu', 'Kathmandu', '7', 2, 2, 'live', now() - interval '12 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-ktm-newroad-commercial-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'commercial', 'sale', 'Commercial Building in New Road', 'High-footfall retail building, three shutters plus office floors.', 125000000, 2053.5, 6, 'Kathmandu', 'Kathmandu', '22', 20, 'live', now() - interval '15 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-maharajgunj-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'House with Garden in Maharajgunj', 'Quiet residential lane, mature garden, borewell plus municipal water.', 48000000, 1711.2, 5, 'Kathmandu', 'Kathmandu', '3', 14, 4, 3, 'live', now() - interval '18 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-gongabu-apt-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'apartment', 'sale', 'Budget Flat in Gongabu', 'Compact flat minutes from the bus park, ideal first home.', 7800000, 65.0, 'Kathmandu', 'Kathmandu', '26', 2, 1, 'live', now() - interval '21 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-ktm-jorpati-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Plotted Land in Jorpati', 'Gated colony plots with drainage and street lights.', 16000000, 1711.2, 5, 'Kathmandu', 'Kathmandu', '14', 10, 'live', now() - interval '24 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-koteshwor-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'rent', '3BHK House in Koteshwor for Rent', 'Independent house, monthly rent, two months deposit.', 55000, 1197.9, 3, 2, 'Kathmandu', 'Kathmandu', '32', 12, 3, 2, 'live', now() - interval '3 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-lazimpat-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'apartment', 'rent', 'Furnished Apartment in Lazimpat', 'Fully furnished with appliances, expat-preferred location.', 65000, 95.0, 'Kathmandu', 'Kathmandu', '2', 3, 2, 'live', now() - interval '6 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, status, created_at) values
  (md5('seed-ktm-asan-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'commercial', 'rent', 'Shop Shutter in Asan', 'Ground-floor shutter in the old bazaar, heavy footfall.', 45000, 28.0, 'Kathmandu', 'Kathmandu', '20', 'live', now() - interval '8 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-sitapaila-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Family House in Sitapaila', 'Sunny plot with mountain glimpse, walking distance to ring road.', 26500000, 1112.3, 3, 1, 'Kathmandu', 'Kathmandu', '15', 11, 3, 2, 'live', now() - interval '27 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-baluwatar-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Baluwatar Diplomatic Residence', 'High-security zone residence with lawn and guest house.', 68000000, 2310.2, 6, 3, 'Kathmandu', 'Kathmandu', '4', 16, 5, 5, 'live', now() - interval '30 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-thamel-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'apartment', 'rent', 'Studio Apartment in Thamel', 'Compact studio for a single professional, all bills shared.', 35000, 42.0, 'Kathmandu', 'Kathmandu', '16', 1, 1, 'live', now() - interval '4 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, status, created_at) values
  (md5('seed-ktm-baneshwor-office-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'commercial', 'rent', 'Office Space in Baneshwor', 'Open-plan office floor with meeting room and parking.', 120000, 180.0, 'Kathmandu', 'Kathmandu', '10', 'live', now() - interval '7 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-kilagal-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Traditional Newari House in Kilagal', 'Heritage brick-and-timber home, renovated interior.', 19500000, 855.6, 2, 2, 'Kathmandu', 'Kathmandu', '18', 8, 3, 2, 'live', now() - interval '33 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-ktm-dhapasi-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Residential Plot in Dhapasi', 'Level plot near the ring road, clear lalpurja title.', 18000000, 2053.5, 6, 'Kathmandu', 'Kathmandu', '24', 12, 'live', now() - interval '36 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-balkhu-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'apartment', 'rent', '3BHK Flat in Balkhu', 'Spacious flat near Kalimati market, water 24/7.', 32000, 85.0, 'Kathmandu', 'Kathmandu', '13', 3, 2, 'live', now() - interval '10 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-ktm-chandol-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Bungalow in Chandol', 'Corner bungalow with terrace garden and rainwater harvesting.', 43000000, 1625.7, 4, 3, 'Kathmandu', 'Kathmandu', '7', 14, 4, 4, 'live', now() - interval '39 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, status, created_at) values
  (md5('seed-ktm-teku-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'commercial', 'rent', 'Godown Space in Teku', 'High-ceiling warehouse with loading access near Kalimati.', 80000, 250.0, 'Kathmandu', 'Kathmandu', '12', 'live', now() - interval '14 days')
  on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Kirtipur (6, wards 1-10)
-- ---------------------------------------------------------------------------

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-kirtipur-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'New House in Kirtipur', 'Vastu-compliant new build near TU gate.', 18500000, 1026.8, 3, 'Kathmandu', 'Kirtipur', '5', 11, 3, 2, 'live', now() - interval '11 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-kirtipur-tu-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Land near Tribhuvan University', 'Walking distance to campus, ideal for rental blocks.', 6400000, 1369.0, 4, 'Kathmandu', 'Kirtipur', '10', 10, 'live', now() - interval '19 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-kirtipur-panga-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'rent', 'Rental House in Panga', 'Quiet family house, monthly rent with one month deposit.', 28000, 684.5, 2, 'Kathmandu', 'Kirtipur', '7', 9, 2, 1, 'live', now() - interval '16 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-kirtipur-commercial-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Commercial Plot in Kirtipur', 'Main-road frontage plot for showroom or bank branch.', 8400000, 2053.5, 6, 'Kathmandu', 'Kirtipur', '3', 14, 'live', now() - interval '28 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-kirtipur-tyangla-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Family Home in Tyangla', 'Three-storey home with rooftop terrace and valley view.', 15800000, 941.2, 2, 3, 'Kathmandu', 'Kirtipur', '9', 10, 3, 2, 'live', now() - interval '31 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, status, created_at) values
  (md5('seed-kirtipur-nayabazar-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'commercial', 'rent', 'Office Shutter in Nayabazar', 'Street-level shutter suitable for clinic or consultancy.', 25000, 30.0, 'Kathmandu', 'Kirtipur', '1', 'live', now() - interval '22 days')
  on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Tokha (6, wards 1-11)
-- ---------------------------------------------------------------------------

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, area_paisa, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-tokha-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Modern House in Tokha', 'Duplex-style home with parking and solar backup.', 24000000, 1197.9, 3, 2, 'Kathmandu', 'Tokha', '8', 12, 4, 3, 'live', now() - interval '13 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-tokha-saraswati-land-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Land in Tokha Saraswati', 'Residential pocket near the Saraswati temple area.', 11000000, 1711.2, 5, 'Kathmandu', 'Tokha', '5', 10, 'live', now() - interval '25 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-tokha-grande-house-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'sale', 'Duplex House in Grande', 'Gated-community duplex with common park access.', 27500000, 1026.8, 3, 'Kathmandu', 'Tokha', '11', 12, 4, 3, 'live', now() - interval '17 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, district, city, ward, bedrooms, bathrooms, status, created_at) values
  (md5('seed-tokha-apt-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'apartment', 'sale', 'Apartment in Tokha', 'Ready-to-move flat with lift and generator backup.', 8900000, 72.0, 'Kathmandu', 'Tokha', '2', 2, 2, 'live', now() - interval '29 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, bedrooms, bathrooms, status, created_at) values
  (md5('seed-tokha-rent-1')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'house', 'rent', 'Rental Floor in Tokha', 'Ground floor with separate entrance, monthly rent.', 22000, 684.5, 2, 'Kathmandu', 'Tokha', '6', 9, 2, 1, 'live', now() - interval '9 days')
  on conflict (id) do nothing;

insert into public.listings (id, seller_id, property_type, listing_purpose, title, description, price_npr, area_sqm, area_aana, district, city, ward, road_access_ft, status, created_at) values
  (md5('seed-tokha-land-2')::uuid, 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'land', 'sale', 'Land in Tokha', 'South-facing land with motorable access on two sides.', 14000000, 2395.8, 7, 'Kathmandu', 'Tokha', '9', 11, 'live', now() - interval '34 days')
  on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
