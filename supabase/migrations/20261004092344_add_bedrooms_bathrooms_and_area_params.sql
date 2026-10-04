-- HYA-251 (2/2) — bedrooms/bathrooms, and area units on v1_update_listing
--
-- Closes G-12 and G-13.
--
-- G-12: `listings` has no bedrooms or bathrooms. WIREFRAMES.md Screen 2 and the
-- detail page both call for them ("Bedrooms: 3", "Bathrooms: 2"). Adding them
-- now, before the post-listing wizard (HYA-205) exists, means the wizard captures
-- them on the first submission rather than needing a second migration and a
-- second form afterwards.
--
-- G-13: `v1_update_listing` had no parameters for the seven local area units.
--
-- A correction to the issue text: it described this as "editing a listing
-- silently zeroes all of them", which would be data loss. It does not. The
-- function uses the coalesce(p_x, x) convention, so untouched columns are left
-- exactly as they are. Verified by reading the function body. The real defect is
-- the reverse and milder: a seller who entered 5 aana 4 paisa at creation can
-- never correct or clear those values afterwards. Rule 25 is a Nepal-specific
-- feature, so being unable to edit it is a genuine gap rather than a cosmetic
-- one, but nothing has been destroyed.
--
-- This migration also hardens both write RPCs, which HYA-248 missed:
--
--   * `search_path` was `public` and unpinned. Both are SECURITY INVOKER, so
--     there is no privilege-escalation path today, but pinning costs nothing and
--     keeps the next reader from assuming they are all pinned.
--   * anon held EXECUTE. RLS has no INSERT/UPDATE policy for anon and both
--     functions reject a null current_uid(), so a guest cannot write. But HYA-248
--     established the rule that write RPCs are never granted to anon, and
--     leaving them granted means one careless policy change from an open write
--     endpoint. Defence in depth, not a live hole.
--   * Both called bare auth.uid() instead of private.current_uid(), which is
--     what every function hardened in HYA-248 now uses.

-- ---------------------------------------------------------------------------
-- G-12: bedrooms / bathrooms
-- ---------------------------------------------------------------------------

alter table public.listings
  add column if not exists bedrooms smallint,
  add column if not exists bathrooms smallint;

-- CHECK rather than a domain, so the constraint names itself in an error.
--
-- Null is allowed on purpose: land and commercial premises have neither, and
-- forcing a value would mean storing a fake 0. Zero is rejected because "no
-- bedrooms" is expressed by leaving the column null, so a stored 0 can only
-- ever be a mistake.
--
-- NOT VALID is deliberately not used: `listings` is empty in every environment
-- this project has, so validating now is free and means the constraint is
-- enforced for every future row rather than only new ones.
alter table public.listings
  drop constraint if exists listings_bedrooms_positive;
alter table public.listings
  add constraint listings_bedrooms_positive check (bedrooms is null or bedrooms > 0);

alter table public.listings
  drop constraint if exists listings_bathrooms_positive;
alter table public.listings
  add constraint listings_bathrooms_positive
    check (bathrooms is null or bathrooms > 0);

comment on column public.listings.bedrooms is
  'Bedroom count. Null for land and commercial, which have none.';
comment on column public.listings.bathrooms is
  'Bathroom count. Null for land and commercial, which have none.';

-- ---------------------------------------------------------------------------
-- Write RPCs
-- ---------------------------------------------------------------------------
-- CREATE OR REPLACE cannot change a parameter list, so these are dropped and
-- recreated. Dropping briefly removes the EXECUTE grant; the recreate below
-- re-establishes it for authenticated only.

drop function if exists public.v1_update_listing (
  uuid, text, text, bigint, numeric, text, text, text, integer, text
);
drop function if exists public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer, text, integer, text
);

create function public.v1_create_listing (
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
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_id uuid;
begin
  if v_uid is null then
    raise exception 'UNAUTHORIZED: sign in to create a listing'
      using errcode = '42501';
  end if;

  -- RULE 4: the client may only ask for a draft or submit for review. Only an
  -- admin can make a listing live, through v1_admin_approve_listing.
  --
  -- Carried over unchanged from the function this replaces. It is genuinely
  -- needed here, unlike on the update path: enforce_listing_status_transition
  -- is a BEFORE UPDATE trigger reading old.status, so it never sees an INSERT.
  -- Confirmed by trying to create a listing directly as live against the
  -- current function, which refused it.
  if p_status not in ('draft', 'pending_review') then
    raise exception 'VALIDATION_ERROR: status must be draft or pending_review'
      using errcode = '22023';
  end if;

  insert into public.listings (
    seller_id, property_type, listing_purpose, title, description, price_npr,
    area_sqm, area_ropani, area_aana, area_paisa, area_dam,
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
  returning id into v_id;

  return json_build_object('id', v_id, 'status', p_status);
end;
$$;

create function public.v1_update_listing (
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
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_status public.listing_status;
begin
  if v_uid is null then
    raise exception 'UNAUTHORIZED: sign in to update a listing'
      using errcode = '42501';
  end if;

  -- The status state machine is NOT re-checked here.
  --
  -- enforce_listing_status_transition() already owns it: it permits
  -- draft -> pending_review, pending_review -> draft and
  -- rejected -> pending_review, returns early when the status is unchanged, and
  -- lets the admin RPCs through via the nbhumi.admin_action setting.
  --
  -- An earlier draft of this migration also refused p_status outside
  -- (draft, pending_review). That was wrong: because the trigger treats an
  -- unchanged status as a no-op, a seller editing the title of their own live
  -- listing legitimately passes p_status = 'live'. The extra check would have
  -- broken editing a live listing, a working path. One owner for the rule, not
  -- two that can drift apart.

  update public.listings set
    title = coalesce(p_title, title),
    description = coalesce(p_description, description),
    price_npr = coalesce(p_price_npr, price_npr),
    area_sqm = coalesce(p_area_sqm, area_sqm),
    -- G-13: the seven local units were previously unreachable from an update.
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
$$;

-- HYA-248's rule: write RPCs are never granted to anon. Both are SECURITY
-- INVOKER and RLS already blocks a guest, so this is defence in depth.
revoke execute on function public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text
) from public;

revoke execute on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text
) from public;

grant execute on function public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text
) to authenticated;

grant execute on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text
) to authenticated;

-- ---------------------------------------------------------------------------
-- Known limitation, stated rather than hidden
-- ---------------------------------------------------------------------------
-- Every optional parameter follows coalesce(p_x, x): passing null means "leave
-- alone". That makes it impossible to CLEAR a value once set — a seller who
-- entered 5 aana 4 paisa and then changed their mind cannot unset it through
-- this RPC. This is pre-existing behaviour for all optional fields, not new
-- here, and changing the convention to a sentinel would alter the contract for
-- ten fields to fix one edge case. Flagged for a follow-up rather than silently
-- half-solved.

comment on function public.v1_create_listing (
  text, text, text, bigint, text, text, text, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, integer, smallint, smallint, text
) is 'Creates a draft or pending_review listing owned by the caller.';

comment on function public.v1_update_listing (
  uuid, text, text, bigint, numeric,
  integer, integer, integer, integer, integer, integer, integer,
  text, text, text, integer, smallint, smallint, text
) is
  'Updates a listing owned by the caller. Null parameters mean "leave alone", '
  'so fields cannot be cleared. Adds the seven local area units (G-13) and '
  'bedrooms/bathrooms (G-12).';