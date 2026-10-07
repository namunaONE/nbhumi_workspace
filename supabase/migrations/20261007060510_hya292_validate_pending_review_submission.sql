-- HYA-292: validate submissions to pending_review server-side.
--
-- The wizard now creates a draft, attaches photos, then submits. This trigger
-- is the backstop that makes that ordering a guarantee rather than a client
-- habit: any path that puts a row into pending_review (RPC, direct UPDATE,
-- future client) must carry a usable submission. Drafts stay freely
-- incomplete, and existing rows are never re-checked retroactively — the
-- trigger only fires on writes whose NEW status is pending_review.
--
-- Checks (all VALIDATION_ERROR/22023 so the client maps them, Rule 38):
--   title present and non-blank, price positive, area present (sqm > 0 or any
--   local unit) with no negative units, land carries no bedroom/bathroom
--   counts, at least one attached photo.
-- District/city/ward are left to their FKs and the existing ward triggers;
-- bedrooms/bathrooms positivity to their column CHECKs. Admin RPCs bypass via
-- the nbhumi.admin_action GUC, following the status-transition precedent.
--
-- Rehearsed on main in a rolled-back transaction (11 scenarios: draft-ok,
-- no-photo/photo-missing/land-rooms/price/area/title/negative-unit refusals,
-- price-edit pass, ward-trigger coexistence, admin bypass, submitted_at
-- stamping) with zero residue before applying.

create or replace function private.validate_listing_submission()
returns trigger
language plpgsql
set search_path to ''
as $$
declare
  v_has_area boolean;
  v_has_photo boolean;
begin
  if current_setting('nbhumi.admin_action', true) = 'on' then
    return new;
  end if;

  if new.status <> 'pending_review' then
    return new;
  end if;

  if nullif(trim(new.title), '') is null then
    raise exception
      'VALIDATION_ERROR: title is required to submit for review'
      using errcode = '22023';
  end if;

  if new.price_npr is null or new.price_npr <= 0 then
    raise exception
      'VALIDATION_ERROR: price must be positive to submit for review'
      using errcode = '22023';
  end if;

  v_has_area :=
    (new.area_sqm is not null and new.area_sqm > 0)
    or new.area_ropani is not null
    or new.area_aana is not null
    or new.area_paisa is not null
    or new.area_dam is not null
    or new.area_bigha is not null
    or new.area_kattha is not null
    or new.area_dhur is not null;
  if not v_has_area then
    raise exception
      'VALIDATION_ERROR: area is required to submit for review'
      using errcode = '22023';
  end if;

  if coalesce(new.area_sqm, 0) < 0
    or coalesce(new.area_ropani, 0) < 0
    or coalesce(new.area_aana, 0) < 0
    or coalesce(new.area_paisa, 0) < 0
    or coalesce(new.area_dam, 0) < 0
    or coalesce(new.area_bigha, 0) < 0
    or coalesce(new.area_kattha, 0) < 0
    or coalesce(new.area_dhur, 0) < 0
  then
    raise exception
      'VALIDATION_ERROR: area units cannot be negative'
      using errcode = '22023';
  end if;

  if new.property_type = 'land'
    and (new.bedrooms is not null or new.bathrooms is not null)
  then
    raise exception
      'VALIDATION_ERROR: land listings cannot carry bedroom/bathroom counts'
      using errcode = '22023';
  end if;

  select exists (
    select 1 from public.listing_photos where listing_id = new.id
  ) into v_has_photo;
  if not v_has_photo then
    raise exception
      'VALIDATION_ERROR: at least one photo is required to submit for review'
      using errcode = '22023';
  end if;

  return new;
end;
$$;

create trigger listings_validate_submission
before insert or update on public.listings
for each row execute function private.validate_listing_submission();

do $$
declare
  v_fn boolean;
  v_tg boolean;
begin
  select exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'private' and p.proname = 'validate_listing_submission'
  ) into v_fn;
  select exists (
    select 1 from pg_trigger
    where tgrelid = 'public.listings'::regclass
      and tgname = 'listings_validate_submission'
  ) into v_tg;
  if not v_fn or not v_tg then
    raise exception 'SUBMISSION TRIGGER MISSING: fn=% tg=%', v_fn, v_tg
      using errcode = 'integrity_constraint_violation';
  end if;
  raise notice 'submission validation ok: trigger installed';
end;
$$;
