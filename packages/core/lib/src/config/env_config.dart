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
}
