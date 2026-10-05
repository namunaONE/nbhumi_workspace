/// Environment configuration for nBhumi.
///
/// Values are injected at compile time via `--dart-define`.
/// Example:
/// ```sh
/// flutter run \
///   --dart-define=SUPABASE_URL=https://rerjioibpqvcomdingte.supabase.co \
///   --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
/// ```
///
/// No `service_role` key may ever appear here. That key bypasses RLS and must
/// stay on the server (Rule 2).
library;

/// Compile-time environment configuration.
abstract final class EnvConfig {
  /// Supabase project URL.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://rerjioibpqvcomdingte.supabase.co',
  );

  /// Supabase publishable API key. Safe to ship in a client binary — it is
  /// subject to RLS, unlike `service_role`.
  ///
  /// Named `publishable` rather than `anon` to match the current Supabase
  /// terminology. `Supabase.initialize` deprecated its `anonKey` parameter in
  /// favour of `publishableKey`.
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_DaQ2qWXImnMaQ_TV8Zedvg_xcGvy_v3',
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

  /// Whether this is the development environment.
  static bool get isDev => environment == 'dev';

  /// Public web host that doubles as the deep-link host (HYA-257).
  ///
  /// Universal links (`https://<host>/auth/callback`, `https://<host>/listing/*`)
  /// and the Supabase `emailRedirectTo` are all derived from this, so changing
  /// the production domain is one `--dart-define` plus the native manifests and
  /// the `.well-known` files (see `deep-links/README.md`). Defaults to the
  /// intended production host; nothing is live there until DNS and the
  /// Supabase redirect allowlist are configured.
  static const String deepLinkHost = String.fromEnvironment(
    'DEEP_LINK_HOST',
    defaultValue: 'nbhumi.com',
  );

  /// Custom-scheme fallback for auth callbacks (`nbhumi://auth/callback`).
  ///
  /// Works without DNS, assetlinks, or associated domains, so magic-link
  /// sign-in is testable before the production domain exists. The scheme must
  /// additionally be allowlisted in Supabase Auth → URL Configuration.
  static const String deepLinkScheme = String.fromEnvironment(
    'DEEP_LINK_SCHEME',
    defaultValue: 'nbhumi',
  );

  /// Path Supabase redirects to after a magic-link tap.
  ///
  /// A const, not configuration: the native intent filters, the Apple
  /// association file, and the router's `/auth/callback` route all match this
  /// literally, so changing it means changing all of them together.
  static const String authCallbackPath = '/auth/callback';

  /// Whether magic links redirect to the custom scheme instead of https.
  ///
  /// Pre-domain testing switch: `flutter run
  /// --dart-define=DEEP_LINK_CUSTOM_SCHEME=true` makes [authRedirectUri]
  /// `nbhumi://auth/callback`, which needs no DNS, assetlinks, or associated
  /// domains — only the matching Supabase allowlist entry. Defaults to false
  /// so release builds always use the universal link.
  static const bool useCustomSchemeRedirect =
      bool.fromEnvironment('DEEP_LINK_CUSTOM_SCHEME');

  /// The `emailRedirectTo` passed to `signInWithOtp`.
  static Uri get authRedirectUri => useCustomSchemeRedirect
      ? Uri(scheme: deepLinkScheme, host: 'auth', path: '/callback')
      : Uri(scheme: 'https', host: deepLinkHost, path: authCallbackPath);
}
