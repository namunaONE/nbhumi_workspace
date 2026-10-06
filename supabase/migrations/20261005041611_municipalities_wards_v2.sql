-- Migration 009 v2: municipalities + wards (HYA-253)
--
-- ## THIS FILE IS A RECONSTRUCTION. Read this before trusting it.
--
-- The version `20261005041611` was recorded in
-- `supabase_migrations.schema_migrations` as `20261005000009_municipalities_wards_v2`,
-- but no such file was ever committed. Version control held only the superseded
-- v1, whose own header admitted it lacked `municipalities.slug`.
--
-- That made the database **unreproducible**: a fresh `supabase db reset` would
-- create `municipalities` without `slug`, and the very next migration
-- (`20261005045032_seed_municipalities_753_p1.sql`) would fail inserting it.
--
-- So this file restores version control's record of what already ran. It is
-- derived from three sources, and nothing was invented:
--
--   * the superseded v1 (`git show HEAD~2:supabase/migrations/20261005000009_municipalities_wards.sql`),
--     which is this file minus `slug`;
--   * the live schema of `public.municipalities` and `public.wards`, which is v2's
--     output as it actually stands;
--   * v1's own header, which documents the slug difference precisely.
--
-- **It has never been executed.** The live database is unaffected by its
-- existence. It has not been validated by a `db reset` either, because resetting
-- the one database this project has is not something to do to prove a file
-- compiles. Treat it as reviewed-but-unproven and say so if a reset ever fails.
--
-- ## Two deliberate differences from v1
--
-- **`municipalities.slug text not null unique` is present.** That is the whole
-- reason v2 existed. `NOT NULL` with no default means every seed must supply it,
-- and `listings_city_slug_fkey` depends on it being globally unique.
--
-- **`listings_city_fkey` on `(city)` alone is absent**, and this is not an
-- omission. v1 declared `foreign key (city) references municipalities(name)`,
-- which cannot exist: `municipalities.name` is unique only per district, and
-- Postgres requires the referenced columns to be unique on their own. Several
-- names recur across the country (Baluwatar, Machhapokhari, Rampur and others).
-- v1's header predicted exactly this failure.
--
-- The working constraint is the composite form, added by a later migration:
--
--   listings_city_fkey  FOREIGN KEY (district, city) REFERENCES municipalities(district, name)
--   listings_city_slug_fkey  FOREIGN KEY (city_slug) REFERENCES municipalities(slug)
--
-- Prefer `slug` over `name` for anything that needs to reference a municipality.
--
-- ## Ward ceiling
--
-- Both CHECKs ship at 33 here, which v1's header records as being one too high at
-- the time. 33 is correct and was re-established later by
-- `20261005044333_recap_ward_ceiling_at_33.sql`: Pokhara Metropolitan City has 33
-- wards, and Kathmandu's 32 is not the national maximum. Replay order for a fresh
-- database is 33 -> 32 -> 33, and no rows exist between the first two, so the
-- narrowing cannot fail.
--
-- 33 is also what `Validators.maxWard` uses in the Dart client. A reference table
-- that stored a ward 33 while every consumer rejected it would be worse than the
-- inconsistency it replaced.

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
  -- Globally unique. `name` is only unique per district, so it cannot be an
  -- identifier; several names recur across the country.
  slug text not null unique,
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
--
-- Guests browse without a session, and the district/municipality pickers in the
-- post-listing wizard run before sign-in, so these tables must not gate on a
-- role. They are reference data: public by definition.
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
-- Grants
-- ---------------------------------------------------------------------------
grant select on public.municipalities to anon, authenticated;
grant select on public.wards to anon, authenticated;