import 'dart:developer' as developer;

/// Structured logging for nBhumi.
///
/// Uses dart:developer log() for all logging.
/// No print() statements allowed.
class AppLogger {
  AppLogger._();

  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'nBhumi',
      level: 500,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'nBhumi',
      level: 800,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(String message,
      {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'nBhumi',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'nBhumi',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
