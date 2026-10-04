-- HYA-249 (1/2) — Fix guest browse
--
-- Closes gaps G-01, G-03, G-04, G-10, G-11. This is what makes HYA-203 and
-- HYA-204 possible.
--
-- G-01 (the blocker). `profiles_select_own_or_admin` is TO authenticated with
-- `USING (auth.uid() = id OR is_admin())`. Both read RPCs were
-- `security invoker` and joined `public.profiles p on p.id = l.seller_id`.
-- Result, verified against the live policy catalog:
--   * anon guest            -> no SELECT grant on profiles -> 0 rows
--   * authenticated buyer   -> may read only their own profile -> 0 rows for
--                               every *other* seller's listing
-- The role ladder opens with "Guest (browse free)". Before this migration a
-- guest opened the app and saw nothing.
--
-- Fix: promote both read RPCs to SECURITY DEFINER and enforce visibility
-- explicitly in SQL. Clients can then only ever reach these two vetted shapes,
-- never an arbitrary `profiles` row. The `profiles` policies are untouched.
--
-- G-03  v1_get_listings omitted seller_id, which Listing.sellerId requires.
-- G-04  v1_get_listing_detail returned photos[] / seller{} / is_favorite and
--       omitted seller_id — no Dart model matched. Shape is now stable.
-- G-10  OFFSET pagination replaced with keyset (cursor) pagination, O(1) at any
--       depth. The cursor carries every sort column so ordering stays total.
-- G-11  Correlated subquery for the cover photo replaced with LEFT JOIN LATERAL.
--
-- SECURITY: `set search_path = ''` (stricter than the existing
-- `search_path = public`) with fully-qualified references. The visibility
-- predicate is the exact disjunction that `listings_select_public_live`
-- expresses, so SECURITY DEFINER grants no additional visibility.

drop function if exists public.v1_get_listings(text, text, text, bigint, bigint, numeric, numeric, text, int, int);

create or replace function public.v1_get_listings(
  p_property_type   text    default null,
  p_listing_purpose  text    default null,
  p_district         text    default null,
  p_min_price        bigint  default null,
  p_max_price        bigint  default null,
  p_min_area         numeric default null,
  p_max_area         numeric default null,
  p_sort             text    default 'newest',
  p_cursor           jsonb   default null,
  p_page_size        int     default 20
)
returns json
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_size   int := least(greatest(coalesce(p_page_size, 20), 1), 100);
  v_sort   text := coalesce(p_sort, 'newest');
  v_cursor jsonb := p_cursor;
  v_key    text;
  v_after  uuid;
  v_total  bigint;
  v_items  json;
begin
  if v_sort not in ('newest', 'oldest', 'price_asc', 'price_desc') then
    v_sort := 'newest';
  end if;

  if v_cursor is not null then
    v_key   := v_cursor ->> 'k';
    v_after := nullif(v_cursor ->> 'id', '')::uuid;
  end if;

  select count(*) into v_total
  from public.listings l
  where (
          l.status = 'live'
          or l.seller_id = (select auth.uid())
          or (select private.is_admin())
        )
    and (p_property_type  is null or l.property_type  = p_property_type::public.property_type)
    and (p_listing_purpose is null or l.listing_purpose = p_listing_purpose::public.listing_purpose)
    and (p_district        is null or l.district        = p_district)
    and (p_min_price       is null or l.price_npr      >= p_min_price)
    and (p_max_price       is null or l.price_npr      <= p_max_price)
    and (p_min_area        is null or l.area_sqm       >= p_min_area)
    and (p_max_area        is null or l.area_sqm       <= p_max_area)
    and (
      -- Keyset predicate. Each branch mirrors its ORDER BY below, so the cursor
      -- always means "strictly after the last row I was shown".
      v_after is null
      or (v_sort = 'newest'     and (l.created_at, l.id) < ((v_key)::timestamptz, v_after))
      or (v_sort = 'oldest'     and (l.created_at, l.id) > ((v_key)::timestamptz, v_after))
      or (v_sort = 'price_asc'  and (l.price_npr,  l.id) > ((v_key)::bigint,     v_after))
      or (v_sort = 'price_desc' and (l.price_npr,  l.id) < ((v_key)::bigint,     v_after))
    );

  select coalesce(json_agg(row_to_json(t)), '[]'::json) into v_items
  from (
    select
      l.id, l.seller_id, l.title, l.description, l.price_npr, l.area_sqm,
      l.area_ropani, l.area_aana, l.area_paisa, l.area_dam,
      l.area_bigha, l.area_kattha, l.area_dhur,
      l.district, l.city, l.ward, l.road_access_ft,
      l.property_type, l.listing_purpose, l.status,
      l.created_at, l.updated_at,
      p.is_verified, p.full_name as seller_name, ph.url as photo_url,
      -- Rule 25: display in hill or terai units depending on which the seller
      -- supplied, falling back to sqm. Formatting stays in SQL so the card,
      -- the detail page and search results can never disagree.
      case
        when coalesce(l.area_ropani, 0) > 0 or coalesce(l.area_aana, 0)   > 0
          or coalesce(l.area_paisa, 0) > 0 or coalesce(l.area_dam, 0)    > 0
          then trim(both from concat_ws(' ',
            case when coalesce(l.area_ropani, 0) > 0 then l.area_ropani::text || ' ropani' end,
            case when coalesce(l.area_aana, 0)   > 0 then l.area_aana::text   || ' aana'   end,
            case when coalesce(l.area_paisa, 0)  > 0 then l.area_paisa::text  || ' paisa'  end,
            case when coalesce(l.area_dam, 0)    > 0 then l.area_dam::text    || ' dam'    end
          ))
        when coalesce(l.area_bigha, 0) > 0 or coalesce(l.area_kattha, 0) > 0
          or coalesce(l.area_dhur, 0) > 0
          then trim(both from concat_ws(' ',
            case when coalesce(l.area_bigha, 0)  > 0 then l.area_bigha::text  || ' bigha'  end,
            case when coalesce(l.area_kattha, 0) > 0 then l.area_kattha::text || ' kattha' end,
            case when coalesce(l.area_dhur, 0)   > 0 then l.area_dhur::text   || ' dhur'   end
          ))
        when l.area_sqm is not null then l.area_sqm::text || ' sqm'
      end as area_display
    from public.listings l
    join public.profiles p on p.id = l.seller_id
    left join lateral (
      select lp.url
      from public.listing_photos lp
      where lp.listing_id = l.id
      order by lp.sort_order, lp.created_at
      limit 1
    ) ph on true
    where (
            l.status = 'live'
            or l.seller_id = (select auth.uid())
            or (select private.is_admin())
          )
      and (p_property_type  is null or l.property_type  = p_property_type::public.property_type)
      and (p_listing_purpose is null or l.listing_purpose = p_listing_purpose::public.listing_purpose)
      and (p_district        is null or l.district        = p_district)
      and (p_min_price       is null or l.price_npr      >= p_min_price)
      and (p_max_price       is null or l.price_npr      <= p_max_price)
      and (p_min_area        is null or l.area_sqm       >= p_min_area)
      and (p_max_area        is null or l.area_sqm       <= p_max_area)
      and (
        v_after is null
        or (v_sort = 'newest'     and (l.created_at, l.id) < ((v_key)::timestamptz, v_after))
        or (v_sort = 'oldest'     and (l.created_at, l.id) > ((v_key)::timestamptz, v_after))
        or (v_sort = 'price_asc'  and (l.price_npr,  l.id) > ((v_key)::bigint,     v_after))
        or (v_sort = 'price_desc' and (l.price_npr,  l.id) < ((v_key)::bigint,     v_after))
      )
    order by
      case when v_sort = 'price_asc'  then l.price_npr  end asc,
      case when v_sort = 'price_desc' then l.price_npr  end desc,
      case when v_sort = 'oldest'     then l.created_at end asc,
      case when v_sort = 'newest'     then l.created_at end desc,
      l.id                                                             -- total ordering
    limit v_size
  ) t;

  return json_build_object(
    'listings',    v_items,
    'total_count', v_total,
    'page_size',   v_size,
    'has_more',    coalesce(json_array_length(v_items), 0) = v_size
  );
end;
$$;

drop function if exists public.v1_get_listing_detail(uuid);

create or replace function public.v1_get_listing_detail(p_listing_id uuid)
returns json
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_result json;
begin
  select json_build_object(
    'id',             l.id,
    'seller_id',      l.seller_id,
    'title',          l.title,
    'description',    l.description,
    'price_npr',      l.price_npr,
    'area_sqm',       l.area_sqm,
    'area_ropani',    l.area_ropani,
    'area_aana',      l.area_aana,
    'area_paisa',     l.area_paisa,
    'area_dam',       l.area_dam,
    'area_bigha',     l.area_bigha,
    'area_kattha',    l.area_kattha,
    'area_dhur',      l.area_dhur,
    'district',       l.district,
    'city',           l.city,
    'ward',           l.ward,
    'road_access_ft', l.road_access_ft,
    'property_type',  l.property_type,
    'listing_purpose', l.listing_purpose,
    'status',         l.status,
    'rejection_reason', l.rejection_reason,
    'created_at',     l.created_at,
    'updated_at',     l.updated_at,
    'photos', coalesce((
      select json_agg(lp.url order by lp.sort_order, lp.created_at)
      from public.listing_photos lp where lp.listing_id = l.id
    ), '[]'::json),
    'seller', json_build_object(
      'id',          p.id,
      'full_name',   p.full_name,
      'is_verified', p.is_verified,
      'kyc_tier',    p.kyc_tier,
      'role',        p.role,
      'agency_name', p.agency_name
    ),
    -- Favourites are M3 (HYA-212). Always false until the table exists; the key
    -- is kept so the Dart model does not change shape in M3.
    'is_favorite', false,
    'area_display', case
      when coalesce(l.area_ropani, 0) > 0 or coalesce(l.area_aana, 0)   > 0
        or coalesce(l.area_paisa, 0) > 0 or coalesce(l.area_dam, 0)    > 0
        then trim(both from concat_ws(' ',
          case when coalesce(l.area_ropani, 0) > 0 then l.area_ropani::text || ' ropani' end,
          case when coalesce(l.area_aana, 0)   > 0 then l.area_aana::text   || ' aana'   end,
          case when coalesce(l.area_paisa, 0)  > 0 then l.area_paisa::text  || ' paisa'  end,
          case when coalesce(l.area_dam, 0)    > 0 then l.area_dam::text    || ' dam'    end
        ))
      when coalesce(l.area_bigha, 0) > 0 or coalesce(l.area_kattha, 0) > 0
        or coalesce(l.area_dhur, 0) > 0
        then trim(both from concat_ws(' ',
          case when coalesce(l.area_bigha, 0)  > 0 then l.area_bigha::text  || ' bigha'  end,
          case when coalesce(l.area_kattha, 0) > 0 then l.area_kattha::text || ' kattha' end,
          case when coalesce(l.area_dhur, 0)   > 0 then l.area_dhur::text   || ' dhur'   end
        ))
      when l.area_sqm is not null then l.area_sqm::text || ' sqm'
    end
  ) into v_result
  from public.listings l
  join public.profiles p on p.id = l.seller_id
  where l.id = p_listing_id
    and (
      l.status = 'live'
      or l.seller_id = (select auth.uid())
      or (select private.is_admin())
    );

  if v_result is null then
    raise exception 'NOT_FOUND: listing not found or not visible' using errcode = 'P0002';
  end if;

  return v_result;
end;
$$;

-- Browse is public. Nothing else in this file is.
revoke execute on function public.v1_get_listings(text,text,text,bigint,bigint,numeric,numeric,text,jsonb,int) from public;
revoke execute on function public.v1_get_listings(text,text,text,bigint,bigint,numeric,numeric,text,jsonb,int) from anon;
revoke execute on function public.v1_get_listings(text,text,text,bigint,bigint,numeric,numeric,text,jsonb,int) from authenticated;
grant execute on function public.v1_get_listings(text,text,text,bigint,bigint,numeric,numeric,text,jsonb,int) to anon, authenticated;

revoke execute on function public.v1_get_listing_detail(uuid) from public;
revoke execute on function public.v1_get_listing_detail(uuid) from anon;
revoke execute on function public.v1_get_listing_detail(uuid) from authenticated;
grant execute on function public.v1_get_listing_detail(uuid) to anon, authenticated;