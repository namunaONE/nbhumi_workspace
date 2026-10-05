-- Migration 009: municipalities + wards (HYA-253) — SUPERSEDED
--
-- ### This file is stale and must not be applied
--
-- The migration recorded in `supabase_migrations.schema_migrations` for this
-- work is `20261005000009_municipalities_wards_v2` (version 20261005041611),
-- not this file. Rule 1 makes an applied migration immutable, so this file is
-- retained verbatim as the historical record of what was authored and has been
-- annotated rather than edited.
--
-- ### Differences between this file and what actually shipped (v2)
--
--   * v2 added `municipalities.slug text not null unique`, which does not
--     appear below. The column is NOT NULL with no default, so any seed must
--     supply it.
--
-- ### Why v2 is itself incomplete
--
-- Verified against the live database:
--
--   municipalities: 0 rows. wards: 0 rows.
--
-- So the seed data this file's header promises ("All 753 local levels across
-- 77 districts; ward detail for Kathmandu/Lalitpur/Bhaktapur", citing
-- hand-verification under G-08) is absent from the database entirely. The
-- tables exist; the reference data does not.
--
-- Both ward ceiling CHECK constraints also shipped one too high, at 33:
--
--   municipalities_ward_count_check: ward_count between 5 and 33
--   wards_ward_no_check:           ward_no     between 1 and 33
--
-- 33 is wrong. Kathmandu Metropolitan City has 32 wards and is the largest
-- local body in Nepal; the Local Government Act 2017 caps ordinary
-- municipalities and rural municipalities at 19. `ward_valid` on `listings`
-- already enforces 1-32, as does `Validators.maxWard` in the Dart client, so
-- a ward 33 row would be storable in reference data yet rejected everywhere it
-- is actually used. Corrected forward in
-- `20261005050000_cap_ward_counts_at_32.sql`.
--
-- The `listings_city_fkey` declared at the bottom of this file did NOT land,
-- and could not have: it references `municipalities(name)`, but the only
-- uniqueness on that table is the composite `unique (district, name)`, and
-- Postgres requires the referenced columns to be unique on their own. The
-- correct form is a composite FK on (district, city), which is deferred to the
-- seed migration because it cannot be added while `listings.city` holds
-- unvalidated free text.
--
-- ### A separate naming issue, not touched here
--
-- `municipalities.name` is not unique on its own, only per district. Several
-- names recur across the country (Baluwatar, Machhapokhari, Rampur and others
-- appear as local body names in more than one district). Any future FK that
-- targets `name` alone will fail for the same reason `listings_city_fkey` did,
-- and any client code that treats a municipality name as an identifier will
-- conflate distinct bodies. Prefer `slug`, which v2 made globally unique, over
-- `name` for anything that needs to reference a municipality.

-- ---------------------------------------------------------------------------
-- Enums / types
-- ---------------------------------------------------------------------------
create type public.municipality_type as enum
  ('metropolitan', 'sub_metropolitan', 'municipality', 'rural_municipality');

-- ---------------------------------------------------------------------------
-- municipalities: all 753 local levels
-- ---------------------------------------------------------------------------
create table public.municipalities (
  id uuid primary key default gen_random_uuid(),
  district text not null references public.districts (name),
  name text not null,
  name_ne text,
  type public.municipality_type not null,
  ward_count smallint not null check (ward_count between 5 and 33),
  unique (district, name),
  created_at timestamptz not null default now()
);

create index municipalities_district_idx on public.municipalities (district);
create index municipalities_type_idx on public.municipalities (type);

-- ---------------------------------------------------------------------------
-- wards: ward rows (valley first; other districts follow up)
-- ---------------------------------------------------------------------------
create table public.wards (
  id uuid primary key default gen_random_uuid(),
  municipality_id uuid not null references public.municipalities (id) on delete cascade,
  ward_no smallint not null check (ward_no between 1 and 33),
  name text,      -- ward names exist in datasets but are NOT official; nullable
  name_ne text,
  unique (municipality_id, ward_no),
  created_at timestamptz not null default now()
);

create index wards_municipality_idx on public.wards (municipality_id);

-- ---------------------------------------------------------------------------
-- RLS: Reference data is readable by everyone (including anonymous guests).
-- ---------------------------------------------------------------------------
alter table public.municipalities enable row level security;
create policy "municipalities_select_public"
  on public.municipalities
  for select
  to anon, authenticated
  using (true);

alter table public.wards enable row level security;
create policy "wards_select_public"
  on public.wards
  for select
  to anon, authenticated
  using (true);

-- ---------------------------------------------------------------------------
-- listings.city FK to municipalities.name (Rule 4: status changes via RPC;
-- city is static reference data, safe to FK)
-- ---------------------------------------------------------------------------
alter table public.listings
  add constraint listings_city_fkey
  foreign key (city) references public.municipalities (name);

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------
grant select on public.municipalities to anon, authenticated;
grant select on public.wards to anon, authenticated;