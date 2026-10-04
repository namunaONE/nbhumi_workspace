-- HYA-251 (3/3) — expose bedrooms/bathrooms on the read RPCs
--
-- The previous migration added the columns and made them writable, but
-- v1_get_listing_detail builds its response with an explicit json_build_object
-- list, so the new columns were invisible to the app. Without this the detail
-- page could not show "Bedrooms: 3", which is what WIREFRAMES.md Screen 2 asks
-- for and the whole reason the columns exist.
--
-- Only the detail RPC is changed. v1_get_listings is left alone deliberately:
-- the browse card shows title, location, price, purpose and area, and adding
-- two more fields per row to a 20-row grid response to populate a card that
-- never renders them is a cost with no benefit.

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
    'is_favorite', false,
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

-- Guest browse is the product's primary use case, so anon is granted here
-- deliberately. Visibility is enforced in the WHERE clause above: only `live`
-- listings, or the caller's own, or anything when the caller is an admin.
grant execute on function public.v1_get_listing_detail (uuid)
  to anon, authenticated;

comment on function public.v1_get_listing_detail (uuid) is
  'Full detail for one listing, including photos, seller card and '
  'bedrooms/bathrooms. Guest-readable for live listings only.';

-- ---------------------------------------------------------------------------
-- ACKNOWLEDGED ADVISOR FINDINGS
-- ---------------------------------------------------------------------------
-- SECURITY DEFINER + anon EXECUTE is intentional here. The function must reach
-- public.profiles to build the seller card, and profiles is readable only by its
-- owner and by admins, so an INVOKER version would return no seller data at all
-- for a guest. The response shape is fixed by this function, so widening
-- profiles SELECT policies is not needed and would leak far more.
-- See also the note in 20261002082624_pin_current_uid_search_path.sql.