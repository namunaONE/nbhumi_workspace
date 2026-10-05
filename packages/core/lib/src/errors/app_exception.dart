import 'package:flutter/foundation.dart';

/// Base class for every error nBhumi surfaces to the UI (Rule 35).
///
/// Never throw a raw `Exception`, `PostgrestException` or `SocketException`
/// from a repository or service. Repositories map transport-level failures onto
/// this hierarchy so widgets only ever match on a type they know how to render,
/// and so no Postgres text can leak to a user (Rule 38).
///
/// Every instance carries both an English and a Nepali message (Rule 36).
/// Nepali is the primary language for the target market, so it is not an
/// afterthought bolted on by a translation layer later.
@immutable
sealed class AppException implements Exception {
  /// Creates an exception with its bilingual message pair.
  const AppException({
    required this.code,
    required this.messageEn,
    required this.messageNe,
    this.context,
    this.cause,
    this.stackTrace,
  });

  /// Stable machine-readable identifier, e.g. `network.timeout`.
  ///
  /// Use this for analytics and retry decisions, never for user-facing text.
  final String code;

  /// English message, safe to show directly to a user.
  final String messageEn;

  /// Nepali (Devanagari) message, safe to show directly to a user.
  final String messageNe;

  /// Optional structured detail — the filter or field that caused the failure.
  final Object? context;

  /// The underlying error, kept for logging only. Never rendered.
  final Object? cause;

  /// Stack trace captured at the throw site, for Sentry (Rule 37).
  final StackTrace? stackTrace;

  /// Whether retrying the same call could plausibly succeed.
  ///
  /// Drives whether the snackbar offers a retry action (Rule 36).
  bool get isRetryable => false;

  /// The message to show, preferring Nepali.
  String message({bool preferNepali = true}) =>
      preferNepali ? messageNe : messageEn;

  /// Wraps [error] when it is not already an [AppException].
  ///
  /// Repositories map every failure before throwing, so anything else reaching
  /// a widget is a bug escaping that mapping rather than a known condition.
  /// Reporting it as an unmapped error keeps the diagnosis honest instead of
  /// dressing it up as a server fault, and the original is kept as [cause] for
  /// the log (Rule 37).
  static AppException unmapped(Object error) {
    if (error is AppException) return error;
    return ValidationException(
      code: 'provider.unmappedError',
      messageEn: 'Something went wrong. Please try again.',
      messageNe: 'केही गडबड भयो। कृपया पुनः प्रयास गर्नुहोस्।',
      cause: error,
    );
  }

  @override
  String toString() {
    // Deliberately not runtimeType: minification would mangle it in release
    // builds and break log-based grouping. The code is stable instead.
    final kind = switch (this) {
      ValidationException() => 'ValidationException',
      AuthFailureException() => 'AuthFailureException',
      NetworkException() => 'NetworkException',
      ServerException() => 'ServerException',
    };
    return '$kind($code): $messageEn';
  }
}

/// Input failed validation, either client-side or in an RPC (Rule 6).
///
/// Examples: blank title, non-positive price, ward outside 1-33, illegal status
/// transition. Retrying without changing the input will fail identically.
final class ValidationException extends AppException {
  /// Creates a validation failure.
  const ValidationException({
    required super.code,
    required super.messageEn,
    required super.messageNe,
    super.context,
    super.cause,
    super.stackTrace,
  });
}

/// The caller is not signed in, or lacks permission for this action.
///
/// Covers both 401 and 403. The UI decides whether to prompt for sign-in or to
/// explain that the account lacks the required role.
final class AuthFailureException extends AppException {
  /// Creates an authentication or authorisation failure.
  const AuthFailureException({
    required super.code,
    required super.messageEn,
    required super.messageNe,
    super.context,
    super.cause,
    super.stackTrace,
  });
}

/// The request never reached the server, or the connection dropped.
///
/// Retryable by default: the same call may well succeed on a second attempt,
/// which matters on the poor and intermittent mobile connections this app
/// targets.
final class NetworkException extends AppException {
  /// Creates a transport-level failure.
  const NetworkException({
    required super.code,
    required super.messageEn,
    required super.messageNe,
    super.context,
    super.cause,
    super.stackTrace,
  });

  @override
  bool get isRetryable => true;
}

/// The server was reached but failed: RPC raised, RLS denied, or 5xx.
///
/// The Postgres message is deliberately *not* exposed. It is available on
/// [AppException.cause] for logging.
final class ServerException extends AppException {
  /// Creates a server-side failure.
  const ServerException({
    required super.code,
    required super.messageEn,
    required super.messageNe,
    super.context,
    super.cause,
    super.stackTrace,
  });
}
