-- Migration 001: profiles table + role enum + RLS (HYA-197)
-- profiles keyed on auth.users.id; role buyer/agent/admin; is_verified flag;
-- only owner or admin can read/update own row.
-- Rule 3: RLS lives in the same migration as the table.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.user_role as enum ('buyer', 'agent', 'admin');

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------

-- Keeps updated_at fresh on every UPDATE. Reused by later migrations.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- True when the current JWT belongs to an admin. SECURITY DEFINER so it can
-- read profiles without tripping RLS recursion.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ---------------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  full_name text not null,
  phone text,
  role public.user_role not null default 'buyer',
  is_verified boolean not null default false,
  -- Matches Dart KycTier enum values (text, self-documenting).
  kyc_tier text not null default 'none'
    check (kyc_tier in ('none', 'account', 'identity', 'property')),
  agency_name text,
  agency_reg_no text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Auto-create a profile row when a user signs up via Supabase Auth.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;

create policy "profiles_select_own_or_admin"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id or public.is_admin());

create policy "profiles_insert_own"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

-- Owners update their own row but may never escalate role/kyc/is_verified;
-- admins may update everything.
create policy "profiles_update_own"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (
    auth.uid() = id
    and role = (select p.role from public.profiles p where p.id = auth.uid())
    and is_verified = (select p.is_verified from public.profiles p where p.id = auth.uid())
    and kyc_tier = (select p.kyc_tier from public.profiles p where p.id = auth.uid())
  );

create policy "profiles_update_admin"
  on public.profiles for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());
