/// Environment configuration for nBhumi.
///
/// Values are injected at compile time via `--dart-define` (Rule 7). There are
/// intentionally **no default values**: a build that forgets to pass them fails
/// with an obvious empty-string Supabase URL rather than silently pointing at a
/// project nobody chose. Example:
/// ```sh
/// flutter run \
///   --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
///   --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
/// ```
/// For local convenience, `tool/run_web.ps1` sources `.env.local` (gitignored)
/// and forwards the values for you.
///
/// No `service_role` key may ever appear here. That key bypasses RLS and must
/// stay on the server (Rule 2).
library;

/// Compile-time environment configuration.
abstract final class EnvConfig {
  /// Supabase project URL. Empty when not supplied — see the library doc.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase publishable API key. Safe to ship in a client binary — it is
  /// subject to RLS, unlike `service_role`.
  ///
  /// Named `publishable` rather than `anon` to match the current Supabase
  /// terminology. `Supabase.initialize` deprecated its `anonKey` parameter in
  /// favour of `publishableKey`.
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Current environment name: dev, staging, or prod.
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  /// Sentry DSN for crash reporting (prod only).
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Whether this is the production environment.
  static bool get isProd => environment == 'prod';

  /// Whether this is the staging environment.
  static bool get isStaging => environment == 'staging';

  /// Whether this is the development environment.
  static bool get isDev => environment == 'dev';

  /// Public web host that doubles as the deep-link host (HYA-257).
  ///
  /// Empty until the production domain exists. While empty, [authRedirectUri]
  /// uses the custom scheme (see [useCustomSchemeRedirect]) so confirmation
  /// sign-in works with no domain at all — only a Supabase allowlist entry.
  /// When the domain is ready, pass `--dart-define=DEEP_LINK_HOST=...` and
  /// replace the host in the native manifests and `deep-links/.well-known/`
  /// (see `deep-links/README.md`).
  static const String deepLinkHost = String.fromEnvironment(
    'DEEP_LINK_HOST',
  );

  /// Custom scheme for auth callbacks (`nbhumi://auth/callback`).
  ///
  /// The default redirect path while no [deepLinkHost] is configured: needs
  /// no DNS, assetlinks, or associated domains, only the matching Supabase
  /// allowlist entry. Also usable later via `DEEP_LINK_CUSTOM_SCHEME=true`.
  static const String deepLinkScheme = String.fromEnvironment(
    'DEEP_LINK_SCHEME',
    defaultValue: 'nbhumi',
  );

  /// Path Supabase redirects to after a confirmation-link tap.
  ///
  /// A const, not configuration: the native intent filters, the Apple
  /// association file, and the router's `/auth/callback` route all match this
  /// literally, so changing it means changing all of them together.
  static const String authCallbackPath = '/auth/callback';

  /// Whether confirmation links redirect to the custom scheme instead of
  /// https.
  ///
  /// True when no [deepLinkHost] is configured (the normal pre-domain state)
  /// or when explicitly forced for testing. The custom scheme needs no DNS,
  /// assetlinks, or associated domains — only the matching Supabase
  /// allowlist entry. Setting `DEEP_LINK_HOST` flips release builds back to
  /// universal links automatically.
  static bool get useCustomSchemeRedirect =>
      deepLinkHost.isEmpty ||
      const bool.fromEnvironment('DEEP_LINK_CUSTOM_SCHEME');

  /// The `emailRedirectTo` passed to signup and recovery calls.
  static Uri get authRedirectUri => useCustomSchemeRedirect
      ? Uri(scheme: deepLinkScheme, host: 'auth', path: '/callback')
      : Uri(scheme: 'https', host: deepLinkHost, path: authCallbackPath);
}
