# nBhumi security decisions

This file records the authorization design actually implemented in the
migrations. The full security rules are in [AGENTS.md](AGENTS.md); this is not a
replacement for a deployment security review.

## Pattern 3 — admin identity

**The source of truth for application roles is `public.profiles.role`, not the
JWT `role` claim.** GoTrue-issued JWTs use `role = authenticated` for signed-in
users, including admins. That value selects the Postgres API role; it does not
say whether someone may moderate listings. A separate custom JWT admin claim
would be stale until token refresh after promotion or revocation, and would add
an Auth hook and a second role store to keep synchronized.

The server checks admin rights through `private.is_admin()`, a
`SECURITY DEFINER` helper with `search_path = ''`. It looks up
`private.current_uid()` in `public.profiles` and requires `role = 'admin'`.
`private.current_uid()` reads the subject PostgREST supplies from a **verified**
JWT; the client cannot self-promote via `profiles_update_own`. The `private`
schema is not exposed through the Data API. Do not use
`auth.jwt()->>'role' = 'admin'` in a policy or an RPC; it confuses the Postgres
role with the application role. Do not trust the Flutter role guard as a security
boundary: it only determines which screen to show.

Admin RPCs are executable by `authenticated` but check `private.is_admin()`
*inside* the function. They are not executable by `anon`. Table policies use the
same helper for admin reads. The admin client reads its own profile to decide
whether to show `/queue`; the RPC and RLS checks remain authoritative even if
someone bypasses the router.

### Regression check

`supabase/tests/admin_role_rls.sql` runs in one transaction and rolls back its
two passwordless probe accounts, pending listing, decision, and audit row. It
checks:

- anon sees neither the pending listing nor profiles and cannot execute the
  admin queue RPC;
- a buyer cannot see the admin's profile or pending listing or call that RPC,
  even if the simulated JWT *claim* says `"role":"admin"`;
- an admin with the normal `"role":"authenticated"` claim sees the pending
  listing and buyer profile, can read the queue, and can approve with an audit
  row;
- revoking `profiles.role = 'admin'` takes effect immediately with the same
  subject and unchanged JWT: the former admin loses admin profile/audit reads
  and the queue RPC rejects the call.

Run it only against an already-migrated disposable/local database, with
`psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/admin_role_rls.sql`.
Never add it to `supabase/migrations`. The transaction rolls back even if psql
exits on a failed assertion. This tests the database authorization boundary,
**not** the JWT signature, the GoTrue password sign-in, or the Flutter router.
Those require the separate HYA-275 real-admin end-to-end pass. Never put an
admin password, service key, or production token in this repository.

### Operational hardening

The admin bootstrap procedure is `supabase/admin_bootstrap.example.sql`. A
human must replace its placeholders privately, provision the account, sign in
with a password, and then enable MFA. The Supabase security advisor currently
also flags leaked-password protection as disabled; address that in the Auth
dashboard before relying on an admin password in production:
[password protection](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection).
