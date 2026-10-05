-- HYA-253 (2/3) — correct the ward ceiling from 32 to the real maximum of 33
--
-- Corrects 20261005050000_cap_ward_counts_at_32.sql, which capped both ward
-- CHECKs at 32 on the claim that Kathmandu Metropolitan City's 32 wards were
-- the national maximum. That claim was wrong: Pokhara Metropolitan City has 33
-- wards (Wikipedia infobox "No. of Wards: 33", official pokharamun.gov.np lists
-- ward 33, multiple profiles agree). The generated municipalities seed carries
-- Pokhara at ward_count 33, so the 32 cap would refuse real reference data.
--
-- The "ward 34" sightings in older literature are all pre-2017 Kathmandu, from
-- the old 35-ward structure before federal restructuring. Nothing current
-- exceeds 33.
--
-- Three constraints move together, because the whole point of the previous two
-- migrations was that these three must agree with each other:
--
--   municipalities_ward_count_check: 5..32  ->  5..33
--   wards_ward_no_check:            1..32  ->  1..33
--   ward_valid on listings:         1..32  ->  1..33
--
-- Widening cannot fail on existing rows, so no pre-flight refusal block is
-- needed this time: every row that satisfied the narrower CHECK satisfies the
-- wider one.
--
-- Rule 1 throughout: the two earlier migrations are applied and immutable, so
-- everything here is drop-and-recreate in a new file.

alter table public.municipalities
  drop constraint if exists municipalities_ward_count_check;

alter table public.municipalities
  add constraint municipalities_ward_count_check
  check (ward_count between 5 and 33);

alter table public.wards
  drop constraint if exists wards_ward_no_check;

alter table public.wards
  add constraint wards_ward_no_check
  check (ward_no between 1 and 33);

alter table public.listings
  drop constraint if exists ward_valid;

alter table public.listings
  add constraint ward_valid
  check (ward is null or ward ~ '^([1-9]|[12][0-9]|3[0-3])$');

comment on constraint municipalities_ward_count_check on public.municipalities is
  'Ward count per local body. Lower bound 5 is the Local Government Act 2017 '
  'floor. Upper bound 33 is the national maximum, set by Pokhara Metropolitan '
  'City (Kathmandu is second at 32). Must stay aligned with ward_valid on '
  'listings and Validators.maxWard in packages/core.';

comment on constraint wards_ward_no_check on public.wards is
  'Ward numbers are 1..ward_count for the owning municipality, and never above '
  '33 nationally. Mirrors the ward_valid CHECK on public.listings.';

-- ---------------------------------------------------------------------------
-- Sanity: the reference tables are still empty at this point, and listings
-- carries no ward above the old ceiling, so nothing below can surprise.
-- ---------------------------------------------------------------------------

do $$
declare v_bad integer;
begin
  select count(*) into v_bad from public.municipalities where ward_count > 33;
  if v_bad > 0 then
    raise exception 'UNEXPECTED: % municipalities exceed ward_count 33', v_bad
      using errcode = 'integrity_constraint_violation';
  end if;

  select count(*) into v_bad from public.wards where ward_no > 33;
  if v_bad > 0 then
    raise exception 'UNEXPECTED: % wards exceed ward_no 33', v_bad
      using errcode = 'integrity_constraint_violation';
  end if;

  select count(*) into v_bad
  from public.listings
  where ward is not null
    and ward::integer > 33;
  if v_bad > 0 then
    raise exception 'UNEXPECTED: % listings exceed ward 33', v_bad
      using errcode = 'integrity_constraint_violation';
  end if;

  raise notice 'pre-flight ok: nothing above 33 anywhere';
end;
$$;