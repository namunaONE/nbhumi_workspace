/// Environment configuration for nBhumi.
///
/// Values are injected at compile time via `--dart-define`.
/// Example:
/// ```sh
/// flutter run \
///   --dart-define=SUPABASE_URL=https://rerjioibpqvcomdingte.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=sb_publishable_...
/// ```
library;

/// Compile-time environment configuration.
abstract final class EnvConfig {
  /// Supabase project URL.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://rerjioibpqvcomdingte.supabase.co',
  );

  /// Supabase publishable (anon) API key. Safe for client apps.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_DaQ2qWXImnMaQ_TV8Zedvg_xcGvy_v3',
  );

  /// Current environment name: dev, staging, or prod.
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  /// Sentry DSN for crash reporting (prod only).
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// Whether this is the production environment.
  static bool get isProd => environment == 'prod';

  /// Whether this is the development environment.
  static bool get isDev => environment == 'dev';
}
