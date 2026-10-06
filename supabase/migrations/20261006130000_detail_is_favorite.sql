-- HYA-268 (C2a) — real is_favorite on v1_get_listing_detail
--
-- Replaces the hardcoded `'is_favorite', false` with an existence check
-- against the C1 `favorites` table, scoped to the caller's own rows:
--
--   exists (select 1 from public.favorites f
--           where f.user_id = (select private.current_uid())
--             and f.listing_id = l.id)
--
-- Guests (`current_uid()` null) compare `= null`, which is never true, so
-- they read false exactly as before. A caller learns nothing about other
-- users' shelves: the predicate fixes `user_id` to their own id.
--
-- RULE 1: the function is restated here with `CREATE OR REPLACE`, not edited
-- in the M2 file 20261005035118_admin_verification_queue_part2_functions.sql.
-- The body is otherwise byte-identical to that source (submitted_at,
-- bedrooms/bathrooms, area_display and all). The browse RPC
-- (`v1_get_listings`) never emitted `is_favorite` — only detail carries it —
-- so there is exactly one function to restate.
--
-- CLIENT NOTE: screens keep reading `favoriteIdsProvider` (HYA-268 C1) as the
-- canonical source. The wire value and the provider read the same table, so
-- they agree wherever the applied migrations include both C1 and this file;
-- on an environment with C1 but not C2a, the provider is still right.

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
    -- New: the 48h clock. Null for a draft, which is correct -- a draft has not
    -- been submitted and has no SLA running against it.
    'submitted_at', l.submitted_at,
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
    -- C2a: real favorite state (HYA-268). Guests read false, as before.
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

-- Restated so this file stands alone. Guest browse is the product's primary use
-- case, so the anon grant is deliberate here (see the M2 acknowledged-findings
-- note on this function).
revoke execute on function public.v1_get_listing_detail (uuid) from public;
grant execute on function public.v1_get_listing_detail (uuid)
  to anon, authenticated;

comment on function public.v1_get_listing_detail (uuid) is
  'Full detail for one listing, including photos, seller card, bedrooms and '
  'bathrooms, submitted_at for the admin SLA clock, and real is_favorite from '
  'the favorites shelf (HYA-268). Guest-readable for live listings only.';

-- HYA-248: restate the anon-execution default so future functions inherit it.
alter default privileges in schema public
  revoke execute on functions from anon;

-- ---------------------------------------------------------------------------
-- ACKNOWLEDGED ADVISOR FINDINGS
-- ---------------------------------------------------------------------------
-- authenticated_security_definer_function_executable (plus the anon-executable
-- variant for guests) is intentional here, as with every other v1_ RPC:
-- DEFINER is required for the seller join past RLS, `search_path = ''` with
-- fully qualified names makes it safe, and the grants are the product's
-- browse model, not an oversight.
