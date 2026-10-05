-- nBhumi — create the first admin account
--
-- WHY THIS FILE EXISTS
-- ===================
-- There is no migration that seeds an admin, and there must not be one: an
-- admin row in a committed migration is a standing credential in git, which
-- Rule 7 forbids outright. So the first admin is provisioned by hand, once, out
-- of band — and this file is the documented procedure plus a runnable template.
--
-- `profiles.role` is `user_role` with values buyer | agent | admin. Nothing in
-- the app ever promotes a user: `profiles_update_own` explicitly forbids
-- changing `role`, `is_verified` and `kyc_tier`, so there is no privilege
-- escalation path from the client. This script is the only way in.
--
-- HOW TO RUN
-- ==========
-- 1. Edit the three REPLACE_ME values below. Use a password you type from
--    memory, not one you paste from a password manager into a shared screen.
-- 2. Supabase dashboard -> SQL Editor -> New query -> paste -> Run. Or:
--      supabase db execute --file supabase/admin_bootstrap.example.sql
--    (never `supabase db reset` — see the note at the bottom)
-- 3. Verify with the SELECT at the end. Expect exactly one row, role 'admin'.
-- 4. Sign in at the admin panel. The panel uses password auth, not a magic
--    link, so no redirect-allowlist entry is needed for this account.
--
-- WHY extensions.crypt() AND NOT A PLAIN PASSWORD
-- ===============================================
-- gotrue stores `encrypted_password = crypt(password, gen_salt('bf'))`. Writing
-- anything else produces an account that authenticates against nothing, which
-- fails as a generic "Invalid login credentials" and looks like a wrong
-- password rather than a malformed hash.
--
-- The `extensions.` schema qualifier is REQUIRED and verified on this project:
-- pgcrypto lives there, not in `public` (checked: `crypt` resolves in
-- `extensions` only). Bare `crypt(...)` fails with
-- `function crypt(unknown, unknown) does not exist`.
--
-- WHY email_confirmed_at IS SET
-- =============================
-- `config.toml` sets `enable_confirmations = false` locally, but the hosted dev
-- project has confirmations on. An unconfirmed email cannot sign in with a
-- password, and the failure is indistinguishable from bad credentials. Setting
-- it here avoids that whole class of confusion.
--
-- SECURITY NOTES
-- ==============
-- * Change this password after first sign-in, and never reuse it elsewhere.
-- * Supabase MFA is available (`[auth.mfa]` in config.toml). Enabling TOTP for
--   the admin account is the single highest-value hardening step available
--   before M2 ships: this one account can approve, and from M2 onward suspend,
--   every listing on the platform.
-- * Run the sign-in against the real project only over a trusted connection.
--   The SQL Editor runs server-side, so the password never crosses the wire,
--   but do not paste it into a shell you are logging.

-- ---------------------------------------------------------------------------
-- 1. Create the auth user (only if it does not already exist)
-- ---------------------------------------------------------------------------
insert into auth.users (
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
select
  'REPLACE_ME@example.com',
  extensions.crypt('REPLACE_ME_password', extensions.gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"full_name":"REPLACE_ME Admin"}'::jsonb,
  now(),
  now()
where not exists (
  select 1 from auth.users where email = 'REPLACE_ME@example.com'
);

-- ---------------------------------------------------------------------------
-- 2. Grant the admin role
-- ---------------------------------------------------------------------------
-- `on_auth_user_created` fires on the insert above and creates a `profiles` row
-- with role 'buyer'. That trigger is correct behaviour for the public signup
-- path, so it stays; we just promote the row afterwards. This is why step 1 and
-- step 2 cannot be merged.
--
-- Safe to re-run: it only ever writes the three admin-owned columns, and never
-- touches `is_verified` or `kyc_tier`, which belong to the KYC flow (M3 /
-- HYA-264) and must not be conflated with administrative access.
update public.profiles
set role = 'admin',
    full_name = 'REPLACE_ME Admin'
where email = 'REPLACE_ME@example.com'
  and role <> 'admin';

-- ---------------------------------------------------------------------------
-- 3. Verify
-- ---------------------------------------------------------------------------
select
  p.id,
  p.email,
  p.full_name,
  p.role,
  p.is_verified,
  p.kyc_tier,
  u.email_confirmed_at is not null as confirmed
from public.profiles p
join auth.users u on u.id = p.id
where p.email = 'REPLACE_ME@example.com';

-- ---------------------------------------------------------------------------
-- DO NOT put this in supabase/migrations/
-- ======================================
-- Migrations run on every `supabase db reset` and in CI against a throwaway
-- database. A migration that creates an admin would therefore create one in
-- each developer's local database too, with whatever password was committed
-- alongside it. Keep this out of `migrations/` and run it by hand.
--
-- Adding a SECOND admin later: repeat the same two statements with a different
-- email. `private.is_admin()` reads `profiles.role`, so there is no separate
-- grant step and no admin_roles table to keep in sync.