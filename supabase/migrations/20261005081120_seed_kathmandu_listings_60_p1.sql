-- HYA-206 — demo seller profile (prerequisite for seed listings)
-- Listing fixtures moved to supabase/seed.sql (HYA-288).
-- This migration now only creates the demo seller profile.

-- ---------------------------------------------------------------------------
-- Demo seller
-- ---------------------------------------------------------------------------

insert into auth.users (id, email, raw_user_meta_data)
values (
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  'demo.seed@nbhumi.internal',
  '{"is_seed": true}'::jsonb
)
on conflict (id) do nothing;

insert into public.profiles (id, email, full_name, phone, role, is_verified, kyc_tier)
values (
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  'demo.seed@nbhumi.internal',
  'Demo Homes (seed)',
  '9841111111',
  'agent',
  false,
  'none'
)
on conflict (id) do nothing;
