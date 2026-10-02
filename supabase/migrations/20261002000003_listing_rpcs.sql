-- Migration 003: listing RPC endpoints (HYA-198, API.md)
-- Core read/write surface used by the data layer, plus admin-only publish
-- transitions (Rule 4: status changes via RPC only).
-- Read RPCs are SECURITY INVOKER (RLS applies). Admin RPCs are
-- SECURITY DEFINER with explicit is_admin() checks + audit rows (Rule 8).

-- ---------------------------------------------------------------------------
-- v1_create_listing — seller creates a draft or submits for review
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
  p_area_ropani int default null,
  p_area_aana int default null,
  p_area_paisa int default null,
  p_area_dam int default null,
  p_area_bigha int default null,
  p_area_kattha int default null,
  p_area_dhur int default null,
  p_ward text default null,
  p_road_access_ft int default null,
  p_status text default 'draft'
)
returns json
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_id uuid;
  v_status public.listing_status;
begin
  if auth.uid() is null then
    raise exception 'UNAUTHORIZED' using errcode = '42501';
  end if;

  if p_status not in ('draft', 'pending_review') then
    raise exception 'VALIDATION_ERROR: status must be draft or pending_review'
      using errcode = '22023';
  end if;

  insert into public.listings (
    seller_id, property_type, listing_purpose, title, description,
    price_npr, area_sqm, area_ropani, area_aana, area_paisa, area_dam,
    area_bigha, area_kattha, area_dhur, district, city, ward,
    road_access_ft, status
  ) values (
    auth.uid(), p_property_type::public.property_type,
    p_listing_purpose::public.listing_purpose, p_title, p_description,
    p_price_npr, p_area_sqm, p_area_ropani, p_area_aana, p_area_paisa,
    p_area_dam, p_area_bigha, p_area_kattha, p_area_dhur, p_district,
    p_city, p_ward, p_road_access_ft, p_status::public.listing_status
  )
  returning id, status into v_id, v_status;

  return json_build_object('id', v_id, 'status', v_status);
end;
$$;

-- ---------------------------------------------------------------------------
-- v1_update_listing — owner updates own listing (seller transitions only)
-- ---------------------------------------------------------------------------
create or replace function public.v1_update_listing(
  p_listing_id uuid,
  p_title text default null,
  p_description text default null,
  p_price_npr bigint default null,
  p_area_sqm numeric default null,
  p_district text default null,
  p_city text default null,
  p_ward text default null,
  p_road_access_ft int default null,
  p_status text default null
)
returns json
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_status public.listing_status;
begin
  if auth.uid() is null then
    raise exception 'UNAUTHORIZED' using errcode = '42501';
  end if;

  update public.listings set
    title = coalesce(p_title, title),
    description = coalesce(p_description, description),
    price_npr = coalesce(p_price_npr, price_npr),
    area_sqm = coalesce(p_area_sqm, area_sqm),
    district = coalesce(p_district, district),
    city = coalesce(p_city, city),
    ward = coalesce(p_ward, ward),
    road_access_ft = coalesce(p_road_access_ft, road_access_ft),
    status = coalesce(p_status::public.listing_status, status)
  where id = p_listing_id
    and seller_id = auth.uid()
  returning status into v_status;

  if not found then
    raise exception 'NOT_FOUND: listing not found or not owned by caller'
      using errcode = 'P0002';
  end if;

  return json_build_object('id', p_listing_id, 'status', v_status);
end;
$$;

-- ---------------------------------------------------------------------------
-- v1_get_listings — public browse with filters + pagination
-- ---------------------------------------------------------------------------
create or replace function public.v1_get_listings(
  p_property_type text default null,
  p_listing_purpose text default null,
  p_district text default null,
  p_min_price bigint default null,
  p_max_price bigint default null,
  p_min_area numeric default null,
  p_max_area numeric default null,
  p_sort text default 'newest',
  p_page int default 1,
  p_page_size int default 20
)
returns json
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_total bigint;
  v_items json;
  v_page int := greatest(p_page, 1);
  v_size int := least(greatest(p_page_size, 1), 100);
begin
  select count(*) into v_total
  from public.listings l
  where l.status = 'live'
    and (p_property_type is null or l.property_type = p_property_type::public.property_type)
    and (p_listing_purpose is null or l.listing_purpose = p_listing_purpose::public.listing_purpose)
    and (p_district is null or l.district = p_district)
    and (p_min_price is null or l.price_npr >= p_min_price)
    and (p_max_price is null or l.price_npr <= p_max_price)
    and (p_min_area is null or l.area_sqm >= p_min_area)
    and (p_max_area is null or l.area_sqm <= p_max_area);

  select coalesce(json_agg(row_to_json(t)), '[]'::json) into v_items
  from (
    select
      l.id, l.title, l.price_npr, l.area_sqm, l.district, l.city,
      l.property_type, l.listing_purpose, l.created_at,
      p.is_verified,
      (select lp.url from public.listing_photos lp
        where lp.listing_id = l.id order by lp.sort_order limit 1) as photo_url
    from public.listings l
    join public.profiles p on p.id = l.seller_id
    where l.status = 'live'
      and (p_property_type is null or l.property_type = p_property_type::public.property_type)
      and (p_listing_purpose is null or l.listing_purpose = p_listing_purpose::public.listing_purpose)
      and (p_district is null or l.district = p_district)
      and (p_min_price is null or l.price_npr >= p_min_price)
      and (p_max_price is null or l.price_npr <= p_max_price)
      and (p_min_area is null or l.area_sqm >= p_min_area)
      and (p_max_area is null or l.area_sqm <= p_max_area)
    order by
      case when p_sort = 'price_asc' then l.price_npr end asc,
      case when p_sort = 'price_desc' then l.price_npr end desc,
      case when p_sort = 'oldest' then l.created_at end asc,
      case when p_sort is null or p_sort = 'newest' then l.created_at end desc
    limit v_size offset (v_page - 1) * v_size
  ) t;

  return json_build_object(
    'listings', v_items,
    'total_count', v_total,
    'page', v_page,
    'page_size', v_size
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- v1_get_listing_detail — single listing + photos + seller card
-- RLS decides visibility (live for public; own rows for owner; all for admin).
-- ---------------------------------------------------------------------------
create or replace function public.v1_get_listing_detail(p_listing_id uuid)
returns json
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_result json;
begin
  select json_build_object(
    'id', l.id,
    'title', l.title,
    'description', l.description,
    'price_npr', l.price_npr,
    'area_sqm', l.area_sqm,
    'area_ropani', l.area_ropani,
    'area_aana', l.area_aana,
    'area_paisa', l.area_paisa,
    'area_dam', l.area_dam,
    'area_bigha', l.area_bigha,
    'area_kattha', l.area_kattha,
    'area_dhur', l.area_dhur,
    'district', l.district,
    'city', l.city,
    'ward', l.ward,
    'road_access_ft', l.road_access_ft,
    'property_type', l.property_type,
    'listing_purpose', l.listing_purpose,
    'status', l.status,
    'created_at', l.created_at,
    'photos', coalesce((
      select json_agg(lp.url order by lp.sort_order)
      from public.listing_photos lp where lp.listing_id = l.id
    ), '[]'::json),
    'seller', json_build_object(
      'full_name', p.full_name,
      'is_verified', p.is_verified,
      'agency_name', p.agency_name
    ),
    'is_favorite', false
  ) into v_result
  from public.listings l
  join public.profiles p on p.id = l.seller_id
  where l.id = p_listing_id;

  if v_result is null then
    raise exception 'NOT_FOUND: listing not found' using errcode = 'P0002';
  end if;

  return v_result;
end;
$$;

-- ---------------------------------------------------------------------------
-- v1_admin_approve_listing — pending_review → live (admin only, audited)
-- ---------------------------------------------------------------------------
create or replace function public.v1_admin_approve_listing(p_listing_id uuid)
returns json
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  -- Permit the definer-side transition past the state-machine trigger.
  perform set_config('nbhumi.admin_action', 'on', true);

  update public.listings
  set status = 'live',
      reviewed_by = auth.uid(),
      reviewed_at = now(),
      rejection_reason = null
  where id = p_listing_id
    and status = 'pending_review';

  if not found then
    raise exception 'VALIDATION_ERROR: listing not in pending_review'
      using errcode = '22023';
  end if;

  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (auth.uid(), 'approve', 'listing', p_listing_id, json_build_object('to', 'live'));

  return json_build_object('id', p_listing_id, 'status', 'live');
end;
$$;

-- ---------------------------------------------------------------------------
-- v1_admin_reject_listing — pending_review → rejected (admin only, audited)
-- ---------------------------------------------------------------------------
create or replace function public.v1_admin_reject_listing(
  p_listing_id uuid,
  p_reason text
)
returns json
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  if p_reason is null or length(trim(p_reason)) = 0 then
    raise exception 'VALIDATION_ERROR: reason required' using errcode = '22023';
  end if;

  perform set_config('nbhumi.admin_action', 'on', true);

  update public.listings
  set status = 'rejected',
      rejection_reason = p_reason,
      reviewed_by = auth.uid(),
      reviewed_at = now()
  where id = p_listing_id
    and status = 'pending_review';

  if not found then
    raise exception 'VALIDATION_ERROR: listing not in pending_review'
      using errcode = '22023';
  end if;

  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    auth.uid(), 'reject', 'listing', p_listing_id,
    json_build_object('to', 'rejected', 'reason', p_reason)
  );

  return json_build_object('id', p_listing_id, 'status', 'rejected');
end;
$$;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------
grant execute on function public.v1_get_listings(text, text, text, bigint, bigint, numeric, numeric, text, int, int)
  to anon, authenticated;
grant execute on function public.v1_get_listing_detail(uuid)
  to anon, authenticated;
grant execute on function public.v1_create_listing(text, text, text, bigint, text, text, text, numeric, int, int, int, int, int, int, int, text, int, text)
  to authenticated;
grant execute on function public.v1_update_listing(uuid, text, text, bigint, numeric, text, text, text, int, text)
  to authenticated;
grant execute on function public.v1_admin_approve_listing(uuid)
  to authenticated;
grant execute on function public.v1_admin_reject_listing(uuid, text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- Storage: public bucket for listing photos
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('listing-photos', 'listing-photos', true)
on conflict (id) do nothing;

-- Owners manage their listing photos; everyone reads them.
create policy "listing_photos_storage_select"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'listing-photos');

create policy "listing_photos_storage_insert"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'listing-photos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "listing_photos_storage_delete"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'listing-photos' and (storage.foldername(name))[1] = auth.uid()::text);
