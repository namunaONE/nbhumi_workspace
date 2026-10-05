-- HYA-253 (5/5) — enforce the per-body ward bound server-side
--
-- Closes the last gap in the ward story. Until this migration, the
-- municipality's own ward_count bound lived only in the wizard: the database
-- accepted ward 11 in 10-ward Kirtipur without complaint (verified live before
-- writing — a probe insert succeeded and was rolled back). The global
-- ward_valid CHECK caps at 33, so anything at or below that passed no matter
-- which body it named.
--
-- That is the wrong layer for the rule. Client validation is defence in depth
-- for states assembled any other way; the database is the owner. A seller
-- calling the RPC directly, a future import script, or an admin-panel edit
-- would all bypass the wizard, and the wizard is the only writer path that
-- should exist but not the only one that can.
--
-- Follows the existing enforce_listing_status_transition() precedent: a BEFORE
-- trigger on listings, SECURITY INVOKER (no privilege needed — municipalities
-- is publicly readable), with search_path pinned to '' and every reference
-- schema-qualified, unlike the older function it sits beside.
--
-- Two deliberate differences from that precedent:
--
-- 1. No nbhumi.admin_action bypass. The status trigger lets admin RPCs through
--    because admins legitimately move statuses sellers cannot. There is no
--    legitimate ward above a body's count for anyone, admin included, so the
--    rule applies to every writer uniformly.
--
-- 2. Non-numeric wards are left alone. BEFORE triggers fire before CHECK
--    constraints, so casting garbage here would raise a raw 22P02 and steal
--    ward_valid's clean 23514. The guard only reads rows whose ward is already
--    digits; anything else falls through to ward_valid, which owns that error.

create or replace function private.validate_listing_ward()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_ward_count smallint;
begin
  -- Null ward is legitimate (Rule 28: ward is optional).
  if new.ward is null then
    return new;
  end if;

  -- Not digits: ward_valid's CHECK owns this error, not this trigger.
  if new.ward !~ '^[0-9]+$' then
    return new;
  end if;

  select m.ward_count into v_ward_count
  from public.municipalities m
  where m.district = new.district
    and m.name = new.city;

  -- No matching body: the composite city FK owns that error. Raising here as
  -- well would replace its message with a more confusing one.
  if v_ward_count is null then
    return new;
  end if;

  if new.ward::integer > v_ward_count then
    raise exception
      'WARD_OUT_OF_RANGE: ward % exceeds % ward(s) in %, %',
      new.ward, v_ward_count, new.city, new.district
      using errcode = 'check_violation';
  end if;

  return new;
end;
$$;

drop trigger if exists listings_ward_within_body on public.listings;

create trigger listings_ward_within_body
  before insert or update of ward, district, city on public.listings
  for each row
  execute function private.validate_listing_ward();

comment on function private.validate_listing_ward() is
  'BEFORE trigger helper: refuses a ward above its municipality''s ward_count. '
  'The wizard enforces the same bound client-side; this owns it server-side.';

-- ---------------------------------------------------------------------------
-- Pre-flight: no existing row may violate the rule this trigger enforces.
-- ---------------------------------------------------------------------------

do $$
declare v_bad integer;
begin
  select count(*) into v_bad
  from public.listings l
  where l.ward is not null
    and l.ward ~ '^[0-9]+$'
    and l.ward::integer > (
      select m.ward_count
      from public.municipalities m
      where m.district = l.district
        and m.name = l.city
    );

  if v_bad > 0 then
    raise exception
      'REFUSING TO MIGRATE: % listings name a ward above their body''s count.',
      v_bad
      using errcode = 'integrity_constraint_violation';
  end if;

  raise notice 'pre-flight ok: no listing exceeds its body''s ward count';
end;
$$;