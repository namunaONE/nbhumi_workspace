-- HYA-262 (2/3): suspension guards on the seller write RPCs.
--
-- Bodies preserved verbatim apart from the added guards (Rule 1: applied
-- migrations are never edited, so the whole functions are replaced here).
--
-- * Suspension is checked in the RPC (readable 42501) AND in the RLS policy
--   (part 1, unbypassable). Either alone leaves a hole.
-- * v1_update_listing additionally validates seller-set statuses. Previously
--   anything else fell through to the trigger and escaped as a raw
--   check_violation (Rule 38: never leak raw Postgres errors); only admin
--   RPCs may set live/rejected/unpublished, via the GUC bypass.

-- ---------------------------------------------------------------------------
-- v1_create_listing: refuse suspended sellers (Rule 6: readable 42501)
-- ---------------------------------------------------------------------------

create or replace function public.v1_create_listing(
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
  p_status text default 'draft'
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
begin
  if v_uid is null then
    raise exception 'UNAUTHORIZED: sign in to create a listing'
      using errcode = '42501';
  end if;

  -- HYA-262: suspension is checked here (readable error) AND in the RLS
  -- policy (unbypassable). Either alone would leave a hole: the policy alone
  -- fails opaquely, the RPC alone is routable-around via direct REST.
  if (select private.is_suspended()) then
    raise exception 'FORBIDDEN: account suspended'
      using errcode = '42501';
  end if;

  if p_status not in ('draft', 'pending_review') then
    raise exception 'VALIDATION_ERROR: status must be draft or pending_review'
      using errcode = '22023';
  end if;

  insert into public.listings (
    seller_id, property_type, listing_purpose, title, description,
    price_npr, area_sqm, area_ropani, area_aana, area_paisa, area_dam,
    area_bigha, area_kattha, area_dhur,
    district, city, ward, road_access_ft, bedrooms, bathrooms, status
  )
  values (
    v_uid,
    p_property_type::public.property_type,
    p_listing_purpose::public.listing_purpose,
    p_title,
    p_description,
    p_price_npr,
    p_area_sqm, p_area_ropani, p_area_aana, p_area_paisa, p_area_dam,
    p_area_bigha, p_area_kattha, p_area_dhur,
    p_district, p_city, p_ward, p_road_access_ft,
    p_bedrooms, p_bathrooms,
    p_status::public.listing_status
  )
  returning id, status into v_id, v_status;

  return json_build_object('id', v_id, 'status', v_status);
end;
$function$;

-- ---------------------------------------------------------------------------
-- v1_update_listing: refuse suspended sellers + validate seller-set statuses
-- ---------------------------------------------------------------------------

create or replace function public.v1_update_listing(
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
  p_status text default null
)
returns json
language plpgsql
security invoker
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_status public.listing_status;
begin
  if v_uid is null then
    raise exception 'UNAUTHORIZED: sign in to update a listing'
      using errcode = '42501';
  end if;

  -- HYA-262: same dual enforcement as v1_create_listing.
  if (select private.is_suspended()) then
    raise exception 'FORBIDDEN: account suspended'
      using errcode = '42501';
  end if;

  -- Sellers may only ever request draft/pending_review. Previously an
  -- anything-else value fell through to the trigger and escaped as a raw
  -- check_violation (Rule 38: never leak raw Postgres errors); only admin
  -- RPCs may set live/rejected/unpublished, via the GUC bypass.
  if p_status is not null and p_status not in ('draft', 'pending_review') then
    raise exception 'VALIDATION_ERROR: status must be draft or pending_review'
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
    status = coalesce(p_status::public.listing_status, status)
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
