-- Migration 002: listings + listing_photos + audit_log + status state
-- machine + RLS (HYA-198)
-- Publish transitions (pending_review → live/rejected) happen only through
-- admin-only RPCs (see migration 003); enforced here by trigger.
-- Rule 3: RLS lives in the same migration as the table.
-- Rule 8: admin actions are audit-logged — audit_log ships in this migration.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.property_type as enum
  ('land', 'house', 'apartment', 'villa', 'commercial', 'business');

create type public.listing_purpose as enum ('sale', 'rent', 'lease');

create type public.listing_status as enum
  ('draft', 'pending_review', 'live', 'rejected');

-- ---------------------------------------------------------------------------
-- listings
-- ---------------------------------------------------------------------------
create table public.listings (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.profiles (id) on delete cascade,
  property_type public.property_type not null,
  listing_purpose public.listing_purpose not null,
  title text not null,
  description text,
  price_npr bigint not null check (price_npr > 0),
  -- Area: sqm is the canonical store (Rule 25); local units denormalized.
  area_sqm numeric,
  area_ropani int,
  area_aana int,
  area_paisa int,
  area_dam int,
  area_bigha int,
  area_kattha int,
  area_dhur int,
  district text not null references public.districts (name),
  city text not null,
  ward text,
  road_access_ft int,
  status public.listing_status not null default 'draft',
  rejection_reason text,
  reviewed_by uuid references public.profiles (id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ward_valid check (ward is null or ward ~ '^([1-9]|[12][0-9]|3[0-2])$')
);

create trigger listings_set_updated_at
  before update on public.listings
  for each row execute function public.set_updated_at();

-- Indexes (SCHEMA.md)
create index listings_status_idx on public.listings (status);
create index listings_district_idx on public.listings (district);
create index listings_property_type_idx on public.listings (property_type);
create index listings_listing_purpose_idx on public.listings (listing_purpose);
create index listings_price_npr_idx on public.listings (price_npr);
create index listings_created_at_idx on public.listings (created_at desc);
create index listings_filter_combo_idx
  on public.listings (district, property_type, listing_purpose);

-- ---------------------------------------------------------------------------
-- Status state machine
-- draft → pending_review → live
--                      ↘ rejected
-- Sellers may only move draft ↔ pending_review. live/rejected are set by
-- admin RPCs running as definer (which sets nbhumi.admin_action).
-- ---------------------------------------------------------------------------
create or replace function public.enforce_listing_status_transition()
returns trigger
language plpgsql
as $$
begin
  -- Admin RPC path: the RPC sets this GUC before transitioning.
  if current_setting('nbhumi.admin_action', true) = 'on' then
    return new;
  end if;

  -- Unchanged status is always fine.
  if old.status = new.status then
    return new;
  end if;

  -- Seller-permitted transitions only.
  if (old.status = 'draft' and new.status = 'pending_review')
     or (old.status = 'pending_review' and new.status = 'draft')
     or (old.status = 'rejected' and new.status = 'pending_review') then
    return new;
  end if;

  raise exception 'Invalid listing status transition: % → %', old.status, new.status
    using errcode = 'check_violation';
end;
$$;

create trigger listings_status_transition
  before update of status on public.listings
  for each row execute function public.enforce_listing_status_transition();

-- ---------------------------------------------------------------------------
-- listing_photos
-- ---------------------------------------------------------------------------
create table public.listing_photos (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings (id) on delete cascade,
  url text not null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create index listing_photos_listing_id_idx
  on public.listing_photos (listing_id);

-- ---------------------------------------------------------------------------
-- audit_log (Rule 8: every admin approve/reject/suspend is recorded)
-- ---------------------------------------------------------------------------
create table public.audit_log (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid not null references public.profiles (id),
  action text not null,
  entity_type text not null check (entity_type in ('listing', 'user', 'kyc')),
  entity_id uuid not null,
  details jsonb,
  created_at timestamptz not null default now()
);

create index audit_log_entity_idx
  on public.audit_log (entity_type, entity_id);

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.listings enable row level security;

-- Guests + users can browse live listings; owners see all their own;
-- admins see everything.
create policy "listings_select_public_live"
  on public.listings for select
  to anon, authenticated
  using (status = 'live' or auth.uid() = seller_id or public.is_admin());

create policy "listings_insert_own"
  on public.listings for insert
  to authenticated
  with check (auth.uid() = seller_id);

create policy "listings_update_own"
  on public.listings for update
  to authenticated
  using (auth.uid() = seller_id)
  with check (auth.uid() = seller_id);

create policy "listings_update_admin"
  on public.listings for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Owners may delete only their own drafts.
create policy "listings_delete_own_draft"
  on public.listings for delete
  to authenticated
  using (auth.uid() = seller_id and status = 'draft');

alter table public.listing_photos enable row level security;

create policy "listing_photos_select_public"
  on public.listing_photos for select
  to anon, authenticated
  using (
    exists (
      select 1 from public.listings l
      where l.id = listing_id
        and (l.status = 'live' or l.seller_id = auth.uid() or public.is_admin())
    )
  );

create policy "listing_photos_insert_own"
  on public.listing_photos for insert
  to authenticated
  with check (
    exists (
      select 1 from public.listings l
      where l.id = listing_id and l.seller_id = auth.uid()
    )
  );

create policy "listing_photos_delete_own"
  on public.listing_photos for delete
  to authenticated
  using (
    exists (
      select 1 from public.listings l
      where l.id = listing_id and l.seller_id = auth.uid()
    )
  );

alter table public.audit_log enable row level security;

create policy "audit_log_select_admin"
  on public.audit_log for select
  to authenticated
  using (public.is_admin());

-- No client-side insert: audit rows are written by definer RPCs only.
