import 'dart:developer' as developer;

/// Structured logging for nBhumi (Rule 21, Rule 37).
///
/// Every entry carries enough context to answer "which user, on which screen,
/// doing what" without a debugger attached, because that is the only
/// information available when a crash reaches Sentry from a user's device.
///
/// Attach a `LogContext` to every call site.
///
/// The optional `context` parameter carries that detail. Keep it populated: a
/// bare `AppLogger.error('failed')` is close to useless in a log aggregator.
abstract final class AppLogger {
  const AppLogger._();

  /// The `name` shown in `dart:developer` and picked up by Sentry.
  static const String source = 'nBhumi';

  /// Verbose developer diagnostics. Not shipped to error reporting.
  static void debug(
    String message, {
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(
        500,
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
      );

  /// Normal lifecycle events worth recording.
  static void info(
    String message, {
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(
        800,
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
      );

  /// Recoverable problems: a failed request, a rejected upload.
  static void warning(
    String message, {
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(
        900,
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
      );

  /// Unrecoverable failures. These are the entries that must reach Sentry.
  static void error(
    String message, {
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(
        1000,
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
      );

  static void _log(
    int level,
    String message, {
    LogContext? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      context == null ? message : '$message | $context',
      name: source,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Who, where and what, attached to every log entry (Rule 37).
///
/// Rendered as `user=<id> screen=<name> action=<name>`. A null [userId] means
/// the caller is a guest, which is a valid and common state here — browsing is
/// anonymous by design.
class LogContext {
  /// Creates a log context.
  const LogContext({
    required this.screen,
    required this.action,
    this.userId,
    this.detail,
  });

  /// Authenticated user, or null for a guest.
  final String? userId;

  /// Route or widget name, e.g. `ListingDetailScreen`.
  final String screen;

  /// Operation being attempted, e.g. `getListings`.
  final String action;

  /// Optional extra key/value detail.
  final Map<String, Object?>? detail;

  @override
  String toString() {
    final buffer = StringBuffer('user=${userId ?? 'guest'} screen=$screen')
      ..write(' action=$action');
    if (detail != null && detail!.isNotEmpty) {
      buffer.write(' $detail');
    }
    return buffer.toString();
  }
}
