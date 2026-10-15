-- HYA-278 follow-up: facing direction + amenities + house/villa floors
--
-- ## Why
--
-- Post-property needs three things the schema could not store:
--
--   1. `facing_direction` (Mohoda/Vastu: which way the plot or main door
--      faces). Nepal buyers filter on this, and without a column it lived
--      only in free-text description, unqueryable and unvalidatable.
--   2. `amenities` (water, electricity, balcony, garden, garage...). Same
--      problem: description-only, no structure, no validation.
--   3. House/villa floors. The `listings_field_applicability` trigger nulled
--      `floor_number`/`total_floors` for house and villa, but Nepali houses
--      are routinely multi-floor. A 3-storey house had nowhere to say so.
--
-- ## Design decisions
--
-- * **facing as text + CHECK, not a Postgres enum.** Matches the existing
--   `furnishing_status` / `pet_policy` / `construction_status` pattern:
--   the column documents its own values, a bad value names the column,
--   and the Dart enum maps 1:1 through fromWire/wireName. Eight compass
--   points: north, north_east, east, south_east, south, south_west, west,
--   north_west.
--
-- * **amenities as `text[]`, not a junction table.** M1 needs capture and
--   display, not amenity-filtered search. An array needs no RLS block
--   (Rule 3: no new table), no join in browse, and one RPC param. Cap:
--   max 20 entries, each 1..40 chars after trim, enforced by CHECK.
--   A junction table (`amenities` + `listing_amenities`) is the follow-up
--   if filtered search is ever required.
--
-- * **Floors for every built type.** The trigger now nulls floors for land
--   only; house, villa, apartment, commercial and business all keep them.
--   Bedrooms stay residential-only (house/apartment/villa); parking stays
--   everything-but-land; age/construction stay everything-but-land.
--
-- * **Trigger nulls, never raises** (existing convention): stray values on
--   inapplicable types are silently nulled so a listing is never
--   un-submittable because of a stale client field.
--
-- ## Rule compliance
--
-- * Rule 1: new file, never edits an applied migration.
-- * Rule 3: no new table, so no RLS block; trigger runs as table owner.
-- * Rule 4: no status transitions touched. Rule 6: ranges enforced
--   server-side ahead of client validators. Rule 8: no admin mutations.
--
-- ## Replay safety
--
-- `add column if not exists`, CHECKs dropped before re-adding, trigger
-- dropped first, functions dropped with full signatures then recreated.
-- Re-applying changes nothing.

-- ---------------------------------------------------------------------------
-- Columns
-- ---------------------------------------------------------------------------

alter table public.listings
  add column if not exists facing_direction text,
  add column if not exists amenities text[] not null default '{}';

comment on column public.listings.facing_direction is
  'Which way the plot or main entrance faces (Mohoda/Vastu). '
  'north | north_east | east | south_east | south | south_west | west | '
  'north_west. Null means "not stated". Applies to every property type.';

comment on column public.listings.amenities is
  'Structured amenity tags (water, electricity, balcony...). Max 20 entries, '
  'each 1..40 chars. Empty array means none stated. M1 capture + display only; '
  'filtered search would need a junction table follow-up.';

-- ---------------------------------------------------------------------------
-- Value constraints
-- ---------------------------------------------------------------------------

alter table public.listings drop constraint if exists listings_facing_valid;
alter table public.listings
  add constraint listings_facing_valid
  check (facing_direction is null
         or facing_direction in (
           'north', 'north_east', 'east', 'south_east',
           'south', 'south_west', 'west', 'north_west'
         ));

alter table public.listings drop constraint if exists listings_amenities_valid;
alter table public.listings
  add constraint listings_amenities_valid
  check (
    coalesce(array_length(amenities, 1), 0) <= 20
    and not exists (
      select 1 from unnest(amenities) as a
      where btrim(a) = '' or length(btrim(a)) > 40
    )
  );

-- ---------------------------------------------------------------------------
-- Applicability trigger: floors now apply to every built type
-- ---------------------------------------------------------------------------

create or replace function public.enforce_listing_field_applicability()
returns trigger
language plpgsql
as $$
begin
  -- Rooms only exist in residential buildings.
  if new.property_type not in ('house', 'apartment', 'villa') then
    new.bedrooms := null;
    new.bathrooms := null;
  end if;

  -- A flat in a tower has no parcel number and no frontage of its own.
  if new.property_type = 'apartment' then
    new.kitta_number := null;
    new.road_access_ft := null;
  end if;

  -- Parking: land has none to count.
  if new.property_type = 'land' then
    new.parking_spaces := null;
  end if;

  -- Floors exist wherever there is a building. Land is the only type
  -- without floors; house and villa are multi-storey across Nepal, so
  -- they keep their counts (HYA-278 follow-up, previously nulled).
  if new.property_type = 'land' then
    new.floor_number := null;
    new.total_floors := null;
  end if;

  -- Land is not aged and has no construction status.
  if new.property_type = 'land' then
    new.property_age_years := null;
    new.construction_status := null;
  end if;

  -- Lease terms belong to leases.
  if new.listing_purpose <> 'lease' then
    new.lease_term_months := null;
    new.lease_renewable := null;
  end if;

  -- Rental terms belong to rentals.
  if new.listing_purpose <> 'rent' then
    new.deposit_amount := null;
    new.available_from := null;
    new.furnishing_status := null;
    new.utilities_included := null;
    new.pet_policy := null;
  end if;

  return new;
end;
$$;

drop trigger if exists listings_field_applicability on public.listings;
create trigger listings_field_applicability
  before insert or update on public.listings
  for each row execute function public.enforce_listing_field_applicability();

-- ---------------------------------------------------------------------------
-- Write RPCs: append p_facing_direction + p_amenities with defaults
-- ---------------------------------------------------------------------------

drop function if exists public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text
);

create function public.v1_create_listing(
  p_property_type text,
  p_listing_purpose text,
  p_title text,
  p_price_npr bigint,
  p_district text,
  p_city text,
  p_description text default null,
  p_area_sqm numeric default null,
  p_area_ropani integer default null,
  p_area_aana integer default null,
  p_area_paisa integer default null,
  p_area_dam integer default null,
  p_area_bigha integer default null,
  p_area_kattha integer default null,
  p_area_dhur integer default null,
  p_ward text default null,
  p_road_access_ft integer default null,
  p_bedrooms smallint default null,
  p_bathrooms smallint default null,
  p_status text default 'draft',
  p_kitta_number text default null,
  p_lease_term_months smallint default null,
  p_lease_renewable boolean default null,
  p_deposit_amount bigint default null,
  p_available_from date default null,
  p_furnishing_status text default null,
  p_utilities_included text default null,
  p_pet_policy text default null,
  p_parking_spaces smallint default null,
  p_floor_number smallint default null,
  p_total_floors smallint default null,
  p_property_age_years smallint default null,
  p_construction_status text default null,
  p_facing_direction text default null,
  p_amenities text[] default null
)
returns json
language plpgsql
security invoker
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_id uuid;
  v_status public.listing_status;
  v_kitta text := nullif(btrim(p_kitta_number), '');
  v_utilities text := nullif(btrim(p_utilities_included), '');
  v_facing text := nullif(btrim(p_facing_direction), '');
  v_amenities text[] := coalesce(p_amenities, '{}');
begin
  if v_uid is null then
    raise exception 'UNAUTHORIZED: sign in to create a listing'
      using errcode = '42501';
  end if;
  if (select private.is_suspended()) then
    raise exception 'FORBIDDEN: account suspended'
      using errcode = '42501';
  end if;
  if p_status not in ('draft', 'pending_review') then
    raise exception 'VALIDATION_ERROR: status must be draft or pending_review'
      using errcode = '22023';
  end if;
  if v_kitta is not null and length(v_kitta) > 60 then
    raise exception 'VALIDATION_ERROR: kitta number must be 60 characters or fewer'
      using errcode = '22023';
  end if;
  if v_utilities is not null and length(v_utilities) > 200 then
    raise exception 'VALIDATION_ERROR: utilities note must be 200 characters or fewer'
      using errcode = '22023';
  end if;
  if v_facing is not null and v_facing not in (
    'north', 'north_east', 'east', 'south_east',
    'south', 'south_west', 'west', 'north_west'
  ) then
    raise exception 'VALIDATION_ERROR: invalid facing direction'
      using errcode = '22023';
  end if;
  if coalesce(array_length(v_amenities, 1), 0) > 20 then
    raise exception 'VALIDATION_ERROR: at most 20 amenities'
      using errcode = '22023';
  end if;

  insert into public.listings (
    seller_id, property_type, listing_purpose, title, description,
    price_npr, area_sqm, area_ropani, area_aana, area_paisa, area_dam,
    area_bigha, area_kattha, area_dhur,
    district, city, ward, road_access_ft, bedrooms, bathrooms, status,
    kitta_number,
    lease_term_months, lease_renewable,
    deposit_amount, available_from, furnishing_status, utilities_included,
    pet_policy, parking_spaces,
    floor_number, total_floors,
    property_age_years, construction_status,
    facing_direction, amenities
  )
  values (
    v_uid,
    p_property_type::public.property_type,
    p_listing_purpose::public.listing_purpose,
    p_title, p_description, p_price_npr,
    p_area_sqm, p_area_ropani, p_area_aana, p_area_paisa, p_area_dam,
    p_area_bigha, p_area_kattha, p_area_dhur,
    p_district, p_city, p_ward, p_road_access_ft,
    p_bedrooms, p_bathrooms,
    p_status::public.listing_status,
    v_kitta,
    p_lease_term_months, p_lease_renewable,
    p_deposit_amount, p_available_from, p_furnishing_status, v_utilities,
    p_pet_policy, p_parking_spaces,
    p_floor_number, p_total_floors,
    p_property_age_years, p_construction_status,
    v_facing, v_amenities
  )
  returning id, status into v_id, v_status;

  return json_build_object('id', v_id, 'status', v_status);
end;
$function$;

drop function if exists public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text
);

create function public.v1_update_listing(
  p_listing_id uuid,
  p_title text default null,
  p_description text default null,
  p_price_npr bigint default null,
  p_area_sqm numeric default null,
  p_area_ropani integer default null,
  p_area_aana integer default null,
  p_area_paisa integer default null,
  p_area_dam integer default null,
  p_area_bigha integer default null,
  p_area_kattha integer default null,
  p_area_dhur integer default null,
  p_district text default null,
  p_city text default null,
  p_ward text default null,
  p_road_access_ft integer default null,
  p_bedrooms smallint default null,
  p_bathrooms smallint default null,
  p_status text default null,
  p_kitta_number text default null,
  p_lease_term_months smallint default null,
  p_lease_renewable boolean default null,
  p_deposit_amount bigint default null,
  p_available_from date default null,
  p_furnishing_status text default null,
  p_utilities_included text default null,
  p_pet_policy text default null,
  p_parking_spaces smallint default null,
  p_floor_number smallint default null,
  p_total_floors smallint default null,
  p_property_age_years smallint default null,
  p_construction_status text default null,
  p_facing_direction text default null,
  p_amenities text[] default null
)
returns json
language plpgsql
security invoker
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_status public.listing_status;
  v_kitta text := nullif(btrim(p_kitta_number), '');
  v_utilities text := nullif(btrim(p_utilities_included), '');
  v_facing text := nullif(btrim(p_facing_direction), '');
begin
  if v_uid is null then
    raise exception 'UNAUTHORIZED: sign in to update a listing'
      using errcode = '42501';
  end if;
  if (select private.is_suspended()) then
    raise exception 'FORBIDDEN: account suspended'
      using errcode = '42501';
  end if;
  if p_status is not null and p_status not in ('draft', 'pending_review') then
    raise exception 'VALIDATION_ERROR: status must be draft or pending_review'
      using errcode = '22023';
  end if;
  if v_kitta is not null and length(v_kitta) > 60 then
    raise exception 'VALIDATION_ERROR: kitta number must be 60 characters or fewer'
      using errcode = '22023';
  end if;
  if v_utilities is not null and length(v_utilities) > 200 then
    raise exception 'VALIDATION_ERROR: utilities note must be 200 characters or fewer'
      using errcode = '22023';
  end if;
  if v_facing is not null and v_facing not in (
    'north', 'north_east', 'east', 'south_east',
    'south', 'south_west', 'west', 'north_west'
  ) then
    raise exception 'VALIDATION_ERROR: invalid facing direction'
      using errcode = '22023';
  end if;
  if p_amenities is not null and coalesce(array_length(p_amenities, 1), 0) > 20 then
    raise exception 'VALIDATION_ERROR: at most 20 amenities'
      using errcode = '22023';
  end if;

  update public.listings set
    title = coalesce(p_title, title),
    description = coalesce(p_description, description),
    price_npr = coalesce(p_price_npr, price_npr),
    area_sqm = coalesce(p_area_sqm, area_sqm),
    area_ropani = coalesce(p_area_ropani, area_ropani),
    area_aana = coalesce(p_area_aana, area_aana),
    area_paisa = coalesce(p_area_paisa, area_paisa),
    area_dam = coalesce(p_area_dam, area_dam),
    area_bigha = coalesce(p_area_bigha, area_bigha),
    area_kattha = coalesce(p_area_kattha, area_kattha),
    area_dhur = coalesce(p_area_dhur, area_dhur),
    district = coalesce(p_district, district),
    city = coalesce(p_city, city),
    ward = coalesce(p_ward, ward),
    road_access_ft = coalesce(p_road_access_ft, road_access_ft),
    bedrooms = coalesce(p_bedrooms, bedrooms),
    bathrooms = coalesce(p_bathrooms, bathrooms),
    status = coalesce(p_status::public.listing_status, status),
    kitta_number = coalesce(v_kitta, kitta_number),
    lease_term_months = coalesce(p_lease_term_months, lease_term_months),
    lease_renewable = coalesce(p_lease_renewable, lease_renewable),
    deposit_amount = coalesce(p_deposit_amount, deposit_amount),
    available_from = coalesce(p_available_from, available_from),
    furnishing_status = coalesce(p_furnishing_status, furnishing_status),
    utilities_included = coalesce(v_utilities, utilities_included),
    pet_policy = coalesce(p_pet_policy, pet_policy),
    parking_spaces = coalesce(p_parking_spaces, parking_spaces),
    floor_number = coalesce(p_floor_number, floor_number),
    total_floors = coalesce(p_total_floors, total_floors),
    property_age_years = coalesce(p_property_age_years, property_age_years),
    construction_status = coalesce(p_construction_status, construction_status),
    facing_direction = coalesce(v_facing, facing_direction),
    amenities = coalesce(p_amenities, amenities)
  where id = p_listing_id
    and seller_id = v_uid
  returning status into v_status;

  if not found then
    raise exception 'NOT_FOUND: listing not found or not owned by caller'
      using errcode = 'P0002';
  end if;

  return json_build_object('id', p_listing_id, 'status', v_status);
end;
$function$;

-- ---------------------------------------------------------------------------
-- Grants (drop removed them; authenticated only, never anon/public)
-- ---------------------------------------------------------------------------

revoke execute on function public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text, text, text[]
) from public;

revoke execute on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text, text, text[]
) from public;

grant execute on function public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text, text, text[]
) to authenticated;

grant execute on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text, text, text[]
) to authenticated;

comment on function public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text, text, text[]
) is
  'Creates a draft or pending_review listing owned by the caller. Adds '
  'facing_direction + amenities; floors now apply to every built type.';

comment on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text, text, text[]
) is
  'Updates a listing owned by the caller. Null means "leave alone". Adds '
  'facing_direction + amenities.';

-- ---------------------------------------------------------------------------
-- v1_get_listing_detail: expose the new fields (CREATE OR REPLACE, no sig change)
-- ---------------------------------------------------------------------------

create or replace function public.v1_get_listing_detail (p_listing_id uuid)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare v_result json;
begin
  select json_build_object(
    'id', l.id, 'seller_id', l.seller_id, 'title', l.title,
    'description', l.description,
    'price_npr', l.price_npr, 'area_sqm', l.area_sqm,
    'area_ropani', l.area_ropani, 'area_aana', l.area_aana,
    'area_paisa', l.area_paisa, 'area_dam', l.area_dam,
    'area_bigha', l.area_bigha, 'area_kattha', l.area_kattha,
    'area_dhur', l.area_dhur,
    'district', l.district, 'city', l.city, 'ward', l.ward,
    'road_access_ft', l.road_access_ft,
    'bedrooms', l.bedrooms, 'bathrooms', l.bathrooms,
    'property_type', l.property_type, 'listing_purpose', l.listing_purpose,
    'status', l.status, 'rejection_reason', l.rejection_reason,
    'submitted_at', l.submitted_at,
    'lease_term_months', l.lease_term_months,
    'lease_renewable', l.lease_renewable,
    'deposit_amount', l.deposit_amount,
    'available_from', l.available_from,
    'furnishing_status', l.furnishing_status,
    'utilities_included', l.utilities_included,
    'pet_policy', l.pet_policy,
    'parking_spaces', l.parking_spaces,
    'floor_number', l.floor_number,
    'total_floors', l.total_floors,
    'property_age_years', l.property_age_years,
    'construction_status', l.construction_status,
    'facing_direction', l.facing_direction,
    'amenities', coalesce(l.amenities, '{}'),
    'created_at', l.created_at, 'updated_at', l.updated_at,
    'photos', coalesce((
      select json_agg(lp.url order by lp.sort_order, lp.created_at)
      from public.listing_photos lp where lp.listing_id = l.id
    ), '[]'::json),
    'seller', json_build_object(
      'id', p.id, 'full_name', p.full_name,
      'is_verified', p.is_verified, 'kyc_tier', p.kyc_tier,
      'role', p.role, 'agency_name', p.agency_name
    ),
    'is_favorite', exists(
      select 1 from public.favorites f
      where f.user_id = (select private.current_uid())
        and f.listing_id = l.id
    ),
    'area_display', case
      when coalesce(l.area_ropani,0)>0 or coalesce(l.area_aana,0)>0
        or coalesce(l.area_paisa,0)>0 or coalesce(l.area_dam,0)>0
        then trim(both from concat_ws(' ',
          case when coalesce(l.area_ropani,0)>0 then l.area_ropani::text||' ropani' end,
          case when coalesce(l.area_aana,0)>0   then l.area_aana::text||' aana' end,
          case when coalesce(l.area_paisa,0)>0  then l.area_paisa::text||' paisa' end,
          case when coalesce(l.area_dam,0)>0    then l.area_dam::text||' dam' end))
      when coalesce(l.area_bigha,0)>0 or coalesce(l.area_kattha,0)>0
        or coalesce(l.area_dhur,0)>0
        then trim(both from concat_ws(' ',
          case when coalesce(l.area_bigha,0)>0  then l.area_bigha::text||' bigha' end,
          case when coalesce(l.area_kattha,0)>0 then l.area_kattha::text||' kattha' end,
          case when coalesce(l.area_dhur,0)>0   then l.area_dhur::text||' dhur' end))
      when l.area_sqm is not null then l.area_sqm::text||' sqm'
    end
  ) into v_result
  from public.listings l
  join public.profiles p on p.id = l.seller_id
  where l.id = p_listing_id
    and (
      l.status = 'live'
      or l.seller_id = (select private.current_uid())
      or (select private.is_admin())
    );

  if v_result is null then
    raise exception 'NOT_FOUND: listing not found or not visible'
      using errcode = 'P0002';
  end if;

  return v_result;
end;
$$;

revoke execute on function public.v1_get_listing_detail (uuid) from public;
grant execute on function public.v1_get_listing_detail (uuid)
  to anon, authenticated;
