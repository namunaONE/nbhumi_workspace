-- Purpose- and type-conditioned listing fields
--
-- ## Why
--
-- The schema collects one shape of listing for all six property types and all
-- three purposes. That is already wrong in two visible ways (a plot of land is
-- asked for bedrooms and bathrooms; a lease is asked for nothing that
-- distinguishes it from a sale) and wrong in two invisible ones (there is
-- nowhere to put a lease term or a rental deposit, so data the review notes
-- promise is simply dropped).
--
-- This adds twelve columns and one trigger, grouped by the axis that decides
-- them:
--
--   purpose = lease    : lease_term_months, lease_renewable
--   purpose = rent     : deposit_amount, available_from, furnishing_status,
--                        utilities_included, pet_policy
--   has rooms          : bedrooms/bathrooms (already here) + parking_spaces
--   has floors         : floor_number, total_floors
--   is built (not land): property_age_years, construction_status
--
-- ## Design decisions
--
-- * **text + CHECK, not Postgres enums.** kyc_tier and doc_type already use
--   this pattern: the column documents its own values, a bad value names the
--   column in the error, and the Dart enum maps 1:1 through fromWire/wireName.
--   A Postgres enum would need its own migration every time a furnishing level
--   or pet policy is added.
--
-- * **A trigger nulls out inapplicable fields rather than raising.** Property
--   type and purpose are immutable through `v1_update_listing` (it has no
--   parameter for either), so the only path that sets them is
--   `v1_create_listing`. Nulling makes "only the fields relevant to the chosen
--   type are populated" a server invariant -- the same thing
--   `ListingWizard._toListing()` already does client-side -- instead of a
--   convention that returns the next time someone writes SQL. Raising would be
--   the alternative, but a listing that is otherwise fine should not be
--   un-submittable because a client sent a stray parking count, and there is no
--   client that does.
--
-- * **Range checks are hard CHECKs.** A parking count of zero is meaningless in
--   exactly the way a bedroom count of zero is: absence already means "none",
--   so a stored 0 can only be a mistake. Same for total_floors and building
--   age. floor_number is the one count where zero is a real value (ground
--   floor), so it is >= 0.
--
-- * **The fraud signals are untouched.** `missing_kitta` and the others keep
--   reading the columns they read; nothing here removes one.
--
-- ## Rule compliance
--
-- * Rule 1: new file. Rule 3: no new table, so no RLS block; the trigger runs
--   as the table owner and bypasses RLS by design, exactly like
--   `enforce_listing_status_transition`. Rule 4: no status transitions touched.
--   Rule 6: ranges enforced server-side, ahead of the client validators.
--   Rule 8: no admin mutations, no audit rows.
--
-- ## Replay safety
--
-- `add column if not exists` and `drop ... if exists` with full signatures;
-- CHECKs are dropped before being re-added; the trigger is dropped first.
-- Re-applying changes nothing.

-- ---------------------------------------------------------------------------
-- Columns
-- ---------------------------------------------------------------------------

-- Lease: what the contract says (purpose = lease).
alter table public.listings
  add column if not exists lease_term_months smallint,
  add column if not exists lease_renewable boolean default null;

comment on column public.listings.lease_term_months is
  'Lease length in months. Only meaningful when listing_purpose = ''lease''. '
  'Null for sale and rent, which have no term. CHECK (> 0): 0 months is not a '
  'lease, and absence is the way to say "not applicable".';

comment on column public.listings.lease_renewable is
  'Whether a lease listing can be renewed at the end of the term. Null for '
  'sale and rent. Deliberately nullable: "the listing does not say" is not the '
  'same answer as "no".';

-- Rent: what the tenant needs to know (purpose = rent).
alter table public.listings
  add column if not exists deposit_amount bigint,
  add column if not exists available_from date,
  add column if not exists furnishing_status text,
  add column if not exists utilities_included text,
  add column if not exists pet_policy text;

comment on column public.listings.deposit_amount is
  'Security deposit in NPR, typically one to three months of rent. Only for '
  'purpose = ''rent''. CHECK (>= 0): a zero deposit is a real listing term, '
  'unlike a zero room count.';

comment on column public.listings.available_from is
  'First date the property can be occupied. Only for purpose = ''rent''. date '
  'rather than timestamptz: it has no timezone meaning, and a tenancy starting '
  '"on" a day should not shift with the viewer''s offset.';

comment on column public.listings.furnishing_status is
  'Rental furnishing level: unfurnished | semi_furnished | furnished. Only for '
  'purpose = ''rent''. Sale listings carry this in the description if it '
  'matters, because "sold furnished" is a negotiation, not a listing term.';

comment on column public.listings.utilities_included is
  'Free-text note on which utilities the rent covers. Only for purpose = '
  '''rent''. Capped at 200 characters; longer belongs in the description.';

comment on column public.listings.pet_policy is
  'Rental pet policy: not_allowed | cats_ok | dogs_ok | all_pets | '
  'negotiable. Only for purpose = ''rent''. Null means "not stated".';

-- Rooms: applies wherever people sleep or park.
alter table public.listings
  add column if not exists parking_spaces smallint;

comment on column public.listings.parking_spaces is
  'Covered or off-street parking spaces. For house/apartment/villa/commercial/'
  'business; null for land, which has none to count. CHECK (> 0): 0 spaces '
  'reads as "none", which absence already says, so a stored 0 is a mistake.';

-- Building position: applies where a floor number is meaningful.
alter table public.listings
  add column if not exists floor_number smallint,
  add column if not exists total_floors smallint;

comment on column public.listings.floor_number is
  'Which floor this unit is on. For apartment/commercial/business. Zero is the '
  'ground floor and is a real value, so this is >= 0 rather than > 0.';

comment on column public.listings.total_floors is
  'How many floors the building has. For apartment/commercial/business. '
  'CHECK (> 0).';

-- Built fabric: applies wherever there is a building.
alter table public.listings
  add column if not exists property_age_years smallint,
  add column if not exists construction_status text;

comment on column public.listings.property_age_years is
  'Age of the building in years, at listing time. Null for land, which is not '
  'aged. CHECK (>= 0): a brand-new building is 0.';

comment on column public.listings.construction_status is
  'new | under_construction | resale. Null for land. Drives whether the '
  'handover date and the price per unit are credible.';

-- ---------------------------------------------------------------------------
-- Range and value constraints (each names itself in an error)
-- ---------------------------------------------------------------------------

alter table public.listings drop constraint if exists listings_lease_term_positive;
alter table public.listings
  add constraint listings_lease_term_positive
  check (lease_term_months is null or lease_term_months > 0);

alter table public.listings drop constraint if exists listings_deposit_not_negative;
alter table public.listings
  add constraint listings_deposit_not_negative
  check (deposit_amount is null or deposit_amount >= 0);

alter table public.listings drop constraint if exists listings_parking_positive;
alter table public.listings
  add constraint listings_parking_positive
  check (parking_spaces is null or parking_spaces > 0);

alter table public.listings drop constraint if exists listings_floor_not_negative;
alter table public.listings
  add constraint listings_floor_not_negative
  check (floor_number is null or floor_number >= 0);

alter table public.listings drop constraint if exists listings_total_floors_positive;
alter table public.listings
  add constraint listings_total_floors_positive
  check (total_floors is null or total_floors > 0);

alter table public.listings drop constraint if exists listings_age_not_negative;
alter table public.listings
  add constraint listings_age_not_negative
  check (property_age_years is null or property_age_years >= 0);

alter table public.listings drop constraint if exists listings_furnishing_status_valid;
alter table public.listings
  add constraint listings_furnishing_status_valid
  check (furnishing_status is null
         or furnishing_status in ('unfurnished', 'semi_furnished', 'furnished'));

alter table public.listings drop constraint if exists listings_pet_policy_valid;
alter table public.listings
  add constraint listings_pet_policy_valid
  check (pet_policy is null
         or pet_policy in (
           'not_allowed', 'cats_ok', 'dogs_ok', 'all_pets', 'negotiable'
         ));

alter table public.listings drop constraint if exists listings_construction_status_valid;
alter table public.listings
  add constraint listings_construction_status_valid
  check (construction_status is null
         or construction_status in ('new', 'under_construction', 'resale'));

-- ---------------------------------------------------------------------------
-- Applicability trigger
-- ---------------------------------------------------------------------------
-- One owner for "which fields may be non-null", read by every writer. Runs
-- BEFORE INSERT OR UPDATE so both the RPC path and a hand-run UPDATE are held
-- to the same rule, and nulls rather than raises: a stray inapplicable value
-- is the client's problem to fix silently, not a listing the seller cannot
-- publish.

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

  -- A floor number means something only inside a taller building.
  if new.property_type not in ('apartment', 'commercial', 'business') then
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
-- Write RPCs
-- ---------------------------------------------------------------------------
-- Every new parameter is appended after `p_kitta_number` with a default, so
-- positional callers are unaffected and old clients keep working. CREATE OR
-- REPLACE cannot change a parameter list, so both functions are dropped with
-- their current signatures and recreated verbatim plus the new parameters
-- (the HYA-251/HYA-300 precedent).

drop function if exists public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text, text
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
  p_construction_status text default null
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
    property_age_years, construction_status
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
    p_property_age_years, p_construction_status
  )
  returning id, status into v_id, v_status;

  return json_build_object('id', v_id, 'status', v_status);
end;
$function$;

drop function if exists public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text, text
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
  p_construction_status text default null
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
    construction_status = coalesce(p_construction_status, construction_status)
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
  smallint, smallint, smallint, text
) from public;

revoke execute on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text
) from public;

grant execute on function public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text
) to authenticated;

grant execute on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text
) to authenticated;

comment on function public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text
) is
  'Creates a draft or pending_review listing owned by the caller. The '
  'purpose- and type-conditioned parameters are accepted but nulled by the '
  'listings_field_applicability trigger when they do not apply, so a client '
  'cannot park a lease term on a sale.';

comment on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text, text,
  smallint, boolean, bigint, date, text, text, text, smallint,
  smallint, smallint, smallint, text
) is
  'Updates a listing owned by the caller. Null parameters mean "leave alone", '
  'so fields cannot be cleared. Adds the lease, rental and building fields; '
  'inapplicable values are nulled by the trigger.';

-- ---------------------------------------------------------------------------
-- v1_get_listing_detail -- expose the new fields
-- ---------------------------------------------------------------------------
-- Without this the columns are write-only: the detail page could not render a
-- lease term, a deposit or a furnishing level, which is the whole reason the
-- columns exist. The body is the HYA-268 C2a version plus the new keys, in the
-- same order the model declares them.
--
-- v1_get_listings is deliberately left alone, exactly as in HYA-251: the
-- browse card renders title, location, price, purpose and area, so a lease term
-- per row would be a cost with no benefit.

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
    -- Purpose-conditioned fields. The trigger guarantees a value is non-null
    -- only when it applies, so the client needs no second check.
    'lease_term_months', l.lease_term_months,
    'lease_renewable', l.lease_renewable,
    'deposit_amount', l.deposit_amount,
    'available_from', l.available_from,
    'furnishing_status', l.furnishing_status,
    'utilities_included', l.utilities_included,
    'pet_policy', l.pet_policy,
    -- Type-conditioned fields.
    'parking_spaces', l.parking_spaces,
    'floor_number', l.floor_number,
    'total_floors', l.total_floors,
    'property_age_years', l.property_age_years,
    'construction_status', l.construction_status,
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

comment on function public.v1_get_listing_detail (uuid) is
  'Full detail for one listing: photos, seller card, bedrooms/bathrooms, '
  'submitted_at for the admin SLA clock, real is_favorite, and the lease, '
  'rental and building fields. The listings_field_applicability trigger '
  'guarantees a value is non-null only when it applies to the listing''s '
  'purpose and property type, so the client renders on null alone.';
