-- Migration: districts lookup table (HYA-196)
-- Reference data for all 77 districts of Nepal with area-unit region.
-- Rule 28: never free-text district names in the DB — listings reference
-- this table by name; UI dropdowns are driven from it.

create table if not exists public.districts (
  id smallint generated always as identity primary key,
  name text not null unique,
  province smallint not null check (province between 1 and 7),
  -- hill → ropani-aana-paisa-dam; terai → bigha-kattha-dhur (Rule 25)
  region text not null check (region in ('hill', 'terai')),
  created_at timestamptz not null default now()
);

alter table public.districts enable row level security;

-- Reference data is readable by everyone (including anonymous guests).
create policy "districts_select_public"
  on public.districts
  for select
  to anon, authenticated
  using (true);

-- No insert/update/delete from clients; managed via migrations only.
