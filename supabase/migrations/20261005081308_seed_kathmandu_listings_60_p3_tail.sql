-- HYA-206 tail: the 9 rows (Nagarjun, Dakshinkali, Shankharapur,
-- Kageshwori) that the p2 apply emission dropped. Same idempotency as the
-- parent files. The parent file 20261005081141 on disk already contains
-- these rows verbatim; this tail records them as actually-applied.

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
