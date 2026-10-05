# Deep links (HYA-257) — setup checklist

App-side wiring is done and committed. What remains is all server-side /
store-side configuration, which needs the real production domain and the
release signing credentials. Nothing here blocks building or testing: the
custom `nbhumi://` scheme works today.

## What the app already handles

- `features/auth`: `classifyDeepLink` (pure, tested) + `AuthLinkHandler`
  (cold start via `getInitialLink`, warm via `uriLinkStream`, never throws).
- `apps/user_app`: `DeepLinkListener` starts the handler at launch; auth
  callbacks exchange via `AuthService.exchangeSessionFromUrl`; `/listing/<id>`
  links route in-app; `/auth/callback` is a public route with a status screen.
- Android: `autoVerify` intent filter for `https://nbhumi.com/auth/callback`
  and `https://nbhumi.com/listing/*`, plus the `nbhumi://` scheme fallback.
- iOS: `nbhumi://` URL scheme in `Info.plist`; associated-domains
  entitlement bound in all three Runner configs.

All hosts/schemes derive from `EnvConfig.deepLinkHost` /
`EnvConfig.deepLinkScheme` (`--dart-define=DEEP_LINK_HOST=...`). If the real
domain is not `nbhumi.com`, replace it in: `EnvConfig` default,
`AndroidManifest.xml`, `Runner.entitlements`, and the two files below.

## Go-live steps (domain owner)

1. **DNS + hosting**: serve this directory's `.well-known/` files from the
   domain root over HTTPS with no redirects:
   - `https://<domain>/.well-known/assetlinks.json`
     (`application/json`)
   - `https://<domain>/.well-known/apple-app-site-association`
     (no `.json` extension; `application/json`)
2. **Android**: replace `__PASTE_RELEASE_SHA256_HERE__` with the release
   keystore fingerprint:
   `keytool -list -v -keystore <release.keystore> | grep SHA256`.
   Verify with `adb shell pm verify-app-links --re-verify com.nbhumi.user_app`.
3. **Apple**: replace `__TEAM_ID__` with the 10-character Team ID
   (developer.apple.com → Membership). No portal upload needed; iOS fetches
   the file on install.
4. **Supabase Dashboard → Authentication → URL Configuration**, add to
   Redirect URLs:
   - `https://<domain>/auth/callback`
   - `nbhumi://auth/callback` (custom-scheme fallback; also usable *now* for
     pre-domain testing — run with
     `--dart-define=DEEP_LINK_CUSTOM_SCHEME=true` so links redirect to the
     scheme, tap a link on-device, confirm a session)
5. **Email template**: set the magic-link template's redirect to
   `https://<domain>/auth/callback` (Supabase substitutes the PKCE `?code=`).
6. **Test**: kill the app, tap a real magic link (cold start), then tap one
   with the app open (warm). Confirm session + home redirect. Then tap a
   shared `https://<domain>/listing/<id>` link and confirm in-app routing.

## Files

- `.well-known/assetlinks.json` — Android Digital Asset Links (see step 2).
- `.well-known/apple-app-site-association` — Apple applinks (see step 3).
  Paths covered: `/auth/callback*` (magic-link sign-in), `/listing/*`
  (shared listings open in-app).
