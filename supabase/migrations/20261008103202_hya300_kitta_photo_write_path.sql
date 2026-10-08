-- HYA-300: fraud-signal write path -- kitta params on the seller write RPCs
-- plus the listing_photos.storage_path backfill.
--
-- ## Why
--
-- HYA-261 reads columns the write path never populates: `missing_kitta`
-- fires on ~100% of rows because no input or RPC param exists, and
-- `storage_path` stays null because `attachListingPhotos` inserts url-only
-- rows. Signals without producers are dead checks; this migration connects
-- the producers.
--
-- ## Design decisions
--
-- * `p_kitta_number` is appended AFTER the existing parameters on both RPCs.
--   Every parameter carries a default, so old clients keep working, and
--   positional callers are unaffected by an append (unlike an insert).
-- * Normalization is `nullif(btrim(...), '')` with a 60-character cap
--   (22023 past it). Blank means "not provided" and stores NULL, matching
--   the wizard's `_nullIfBlank` convention and the fraud RPC's
--   null/blank-missing rule. Clearing an already-set kitta is impossible --
--   null means "leave alone" under the coalesce convention, exactly like
--   `description` -- because a parcel number is a fact, not a draft.
-- * The backfill derives paths only from app-shaped URLs
--   (`%/listing-photos/%`); anything else keeps its null rather than gaining
--   a garbage path from a blind split. Bucket name is a stable constant
--   (`listing-photos`), so the split is deterministic, not heuristic.
-- * `photo_hash` gets no producer here: perceptual hashing needs a compute
--   step (Edge Function on upload) that is its own issue. The column stays
--   reserved.
--
-- ## Rule compliance
--
-- * Rule 1: new file; reproduces both function bodies verbatim plus kitta.
-- * Rule 4: no status transitions touched. Rule 6: trim + length enforced
--   again server-side. Rule 8: no admin mutations, no audit rows.
-- * Grants: drop removes EXECUTE; re-revoked from public and re-granted to
--   authenticated only, per the HYA-248/HYA-251 precedent.
--
-- ## Replay safety
--
-- Drops are `if exists` with full signatures; creates are plain
-- (drop-then-create); backfill is guarded by `storage_path is null` and the
-- URL pattern, so re-apply changes nothing.

-- ---------------------------------------------------------------------------
-- storage_path backfill (existing rows first: no dependency on the RPCs)
-- ---------------------------------------------------------------------------

update public.listing_photos
  set storage_path = split_part(url, '/listing-photos/', 2)
  where storage_path is null
    and url like '%/listing-photos/%'
    and split_part(url, '/listing-photos/', 2) <> '';

comment on column public.listing_photos.storage_path is
  'HYA-261: storage object path (not the public URL) for exact duplicate '
  'detection across listings. Written by attachListingPhotos for new uploads '
  '(HYA-300); backfilled here for rows whose URL carries the stable '
  'listing-photos bucket prefix. Null means unknown, never a match group.';

-- ---------------------------------------------------------------------------
-- v1_create_listing + p_kitta_number
-- ---------------------------------------------------------------------------
-- CREATE OR REPLACE cannot change a parameter list, so drop and recreate
-- (HYA-251 precedent). The grant dies with the drop and is re-established
-- below for authenticated only.

drop function if exists public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text
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
  p_kitta_number text default null
)
returns json
language plpgsql
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_id uuid;
  v_status public.listing_status;
  v_kitta text := nullif(btrim(p_kitta_number), '');
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
  insert into public.listings (
    seller_id, property_type, listing_purpose, title, description,
    price_npr, area_sqm, area_ropani, area_aana, area_paisa, area_dam,
    area_bigha, area_kattha, area_dhur,
    district, city, ward, road_access_ft, bedrooms, bathrooms, status,
    kitta_number
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
    v_kitta
  )
  returning id, status into v_id, v_status;
  return json_build_object('id', v_id, 'status', v_status);
end;
$function$;

-- ---------------------------------------------------------------------------
-- v1_update_listing + p_kitta_number
-- ---------------------------------------------------------------------------

drop function if exists public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text
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
  p_kitta_number text default null
)
returns json
language plpgsql
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_status public.listing_status;
  v_kitta text := nullif(btrim(p_kitta_number), '');
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
    kitta_number = coalesce(v_kitta, kitta_number)
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
  text, integer, smallint, smallint, text, text
) from public;

revoke execute on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text, text
) from public;

grant execute on function public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text, text
) to authenticated;

grant execute on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text, text
) to authenticated;

comment on column public.listings.kitta_number is
  'HYA-261: land parcel (kitta) number as the seller wrote it, writable via '
  'p_kitta_number on the write RPCs (HYA-300, trimmed, 60 chars). Null/blank '
  'means "not provided" and is itself a review signal; duplicates across '
  'listings are a fraud signal.';
