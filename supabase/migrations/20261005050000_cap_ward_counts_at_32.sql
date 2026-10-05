-- HYA-253 (1/2) — cap ward counts at the real national maximum of 32
--
-- Corrects migration 009 (applied as `..._v2`), which shipped both ward
-- ceiling CHECK constraints one too high. Verified live before writing:
--
--   municipalities_ward_count_check: ward_count between 5 and 33
--   wards_ward_no_check:            ward_no     between 1 and 33
--
-- 33 is not a real ward in Nepal. Kathmandu Metropolitan City has 32 and is
-- the largest local body in the country; the Local Government Act 2017 caps
-- ordinary municipalities and rural municipalities at 19. So 32 is the true
-- national maximum and 33 is dead space.
--
-- It is worse than dead space, because it is inconsistently enforced. The
-- `ward_valid` CHECK on `public.listings` already caps at 32:
--
--   check (ward is null or ward ~ '^([1-9]|[12][0-9]|3[0-2])$')
--
-- and `Validators.maxWard` in packages/core matches. So before this migration
-- a ward 33 could be inserted into reference data and then be rejected by
-- every consumer of it: the wizard's field, the listings constraint, and every
-- browse filter. Reference data has to be at least as permissive as nothing
-- and no more permissive than everything.
--
-- ### Why this is a new file
--
-- Rule 1: 009 is applied and immutable, so the CHECKs are dropped and
-- recreated here rather than edited in place.
--
-- ### Why 32 and not 19
--
-- 19 is the ceiling for the 736 ordinary municipalities and rural
-- municipalities. It would be wrong for the 17 metropolises and
-- sub-metropolises, KMC among them at 32. A single flat CHECK cannot express
-- "depends on type", so the ceiling is the maximum over all types and the
-- per-municipality bound lives in `ward_count`, which the wizard will read to
-- size its ward picker.

-- ---------------------------------------------------------------------------
-- Verify before altering
-- ---------------------------------------------------------------------------
-- Both tables are currently empty, so tightening the CHECK cannot fail on
-- existing rows. Asserted rather than assumed: if a seed migration lands
-- first and introduces a 33, this migration stops instead of silently deleting
-- or failing obscurely later.

do $$
declare v_bad integer;
begin
  select count(*) into v_bad
  from public.municipalities
  where ward_count > 32;

  if v_bad > 0 then
    raise exception
      'REFUSING TO MIGRATE: % municipalities have ward_count > 32. '
      'Those rows contradict the listings constraint and must be corrected '
      'first.', v_bad
      using errcode = 'integrity_constraint_violation';
  end if;

  select count(*) into v_bad
  from public.wards
  where ward_no > 32;

  if v_bad > 0 then
    raise exception
      'REFUSING TO MIGRATE: % wards have ward_no > 32. '
      'Those rows contradict the listings constraint and must be corrected '
      'first.', v_bad
      using errcode = 'integrity_constraint_violation';
  end if;

  raise notice 'pre-flight ok: no ward above 32 in reference data';
end;
$$;

-- ---------------------------------------------------------------------------
-- Recreate the CHECKs at the correct ceiling
-- ---------------------------------------------------------------------------

alter table public.municipalities
  drop constraint if exists municipalities_ward_count_check;

alter table public.municipalities
  add constraint municipalities_ward_count_check
  check (ward_count between 5 and 32);

alter table public.wards
  drop constraint if exists wards_ward_no_check;

alter table public.wards
  add constraint wards_ward_no_check
  check (ward_no between 1 and 32);

-- ---------------------------------------------------------------------------
-- Comment on the constraints rather than the tables, so the reason travels
-- with the rule in `pg_constraint` where a reviewer will actually see it.
-- ---------------------------------------------------------------------------

comment on constraint municipalities_ward_count_check on public.municipalities is
  'Ward count per local body. Lower bound 5 is the Local Government Act 2017 '
  'floor. Upper bound 32 is the national maximum, set by Kathmandu '
  'Metropolitan City; metropolises are exempt from the ordinary 19-ward cap. '
  'Must stay aligned with ward_valid on listings and Validators.maxWard in '
  'packages/core, or reference data will accept wards that every consumer '
  'rejects.';

comment on constraint wards_ward_no_check on public.wards is
  'Ward numbers are 1..ward_count for the owning municipality, and never above '
  '32 nationally. Mirrors the ward_valid CHECK on public.listings.';

-- ---------------------------------------------------------------------------
-- Sanity check on ward_count versus actual ward rows, where rows exist.
-- ---------------------------------------------------------------------------
-- Informational only. A municipality with fewer ward rows than its ward_count
-- is legitimate: ward detail is being seeded for the valley first and the rest
-- follows, so a short count is the expected intermediate state rather than
-- corruption. Logged so the seed migration has something to reconcile against.

do $$
declare
  v_mismatch integer;
begin
  select count(*) into v_mismatch
  from public.municipalities m
  join public.wards w on w.municipality_id = m.id
  group by m.id, m.ward_count
  having count(*) <> m.ward_count
  limit 1;

  raise notice 'ward rows present for % municipality group(s)', v_mismatch;
end;
$$;