-- wards seed for Kathmandu Valley (HYA-253)
-- Kathmandu: 32 wards, Lalitpur: 29 wards, Bhaktapur: 10 wards
-- Ward names from skkdev0/official sources; ward_no is the key (not names)
-- Generated 2026-10-05

truncate public.wards restart identity cascade;

-- Kathmandu Metropolitan City (32 wards)
insert into public.wards (municipality_id, ward_no, name, name_ne, created_at) values
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 1, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 2, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 3, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 4, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 5, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 6, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 7, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 8, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 9, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 10, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 11, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 12, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 13, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 14, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 15, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 16, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 17, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 18, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 19, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 20, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 21, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 22, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 23, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 24, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 25, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 26, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 27, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 28, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 29, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 30, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 31, null, null, now()),
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 32, null, null, now());

-- Lalitpur Metropolitan City (29 wards)
insert into public.wards (municipality_id, ward_no, name, name_ne, created_at) values
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 1, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 2, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 3, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 4, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 5, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 6, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 7, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 8, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 9, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 10, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 11, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 12, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 13, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 14, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 15, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 16, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 17, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 18, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 19, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 20, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 21, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 22, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 23, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 24, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 25, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 26, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 27, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 28, null, null, now()),
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 29, null, null, now());

-- Bhaktapur Municipality (10 wards)
insert into public.wards (municipality_id, ward_no, name, name_ne, created_at) values
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 1, null, null, now()),
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 2, null, null, now()),
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 3, null, null, now()),
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 4, null, null, now()),
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 5, null, null, now()),
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 6, null, null, now()),
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 7, null, null, now()),
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 8, null, null, now()),
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 9, null, null, now()),
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 10, null, null, now());