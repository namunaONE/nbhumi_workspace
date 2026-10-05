-- HYA-253 (4/4) — seed Kathmandu Valley ward rows
--
-- Source: supabase/seeds/009_wards_valley.sql (committed alongside this
-- migration): Kathmandu Metropolitan City 32, Lalitpur Metropolitan City 29,
-- Bhaktapur Municipality 10 — 71 rows total. Ward names are intentionally null:
-- ward names exist in datasets but are not official, and ward_no is the key.
-- Other districts follow in later work; a short ward count is the expected
-- intermediate state, not corruption.
--
-- Idempotent: ON CONFLICT DO NOTHING on (municipality_id, ward_no). No
-- TRUNCATE, for the same reason as the municipalities seed.
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
  ((select id from municipalities where district = 'Kathmandu' and name = 'Kathmandu' and type = 'metropolitan'), 32, null, null, now()) on conflict (municipality_id, ward_no) do nothing;

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
  ((select id from municipalities where district = 'Lalitpur' and name = 'Lalitpur' and type = 'metropolitan'), 29, null, null, now()) on conflict (municipality_id, ward_no) do nothing;

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
  ((select id from municipalities where district = 'Bhaktapur' and name = 'Bhaktapur' and type = 'municipality'), 10, null, null, now()) on conflict (municipality_id, ward_no) do nothing;
-- ---------------------------------------------------------------------------
-- Assertions: each valley body has exactly its ward_count in ward rows
-- ---------------------------------------------------------------------------

do $$
declare
  v_bad integer;
  v_total integer;
begin
  select count(*) into v_bad
  from public.municipalities m
  where m.slug in ('kathmandu-kathmandu', 'lalitpur-lalitpur', 'bhaktapur-bhaktapur')
    and (select count(*) from public.wards w where w.municipality_id = m.id) <> m.ward_count;

  if v_bad > 0 then
    raise exception 'SEED MISMATCH: % valley bodies have incomplete ward rows', v_bad
      using errcode = 'integrity_constraint_violation';
  end if;

  select count(*) into v_total
  from public.wards w
  join public.municipalities m on m.id = w.municipality_id
  where m.slug in ('kathmandu-kathmandu', 'lalitpur-lalitpur', 'bhaktapur-bhaktapur');

  if v_total <> 71 then
    raise exception 'SEED MISMATCH: % valley ward rows, expected 71', v_total
      using errcode = 'integrity_constraint_violation';
  end if;

  raise notice 'valley ward seed ok: 71 rows across 3 bodies';
end;
$$;