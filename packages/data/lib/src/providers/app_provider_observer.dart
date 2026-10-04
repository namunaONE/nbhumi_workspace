import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Routes Riverpod's lifecycle events into [AppLogger] (Rule 37).
///
/// Three things this deliberately does not do:
///
/// * **It does not log rebuilds.** `didUpdateProvider` fires on every value
///   change, so logging there would bury the failures in noise. Only failures
///   and disposals are recorded.
/// * **It does not print.** Rule 21 forbids `print`. Entries go through
///   `dart:developer`'s structured `log()` so Sentry can pick them up.
/// * **It does not log rethrows.** See below.
///
/// ### Why `ProviderException` is skipped
///
/// Riverpod 3.0 wraps a provider failure in `ProviderException` as it
/// propagates. If provider A fails and providers B and C both watch A, all
/// three report a failure while only one real error exists. Logging all three
/// triples the error count for every incident and makes Sentry noise
/// impossible to triage.
///
/// A `ProviderException` therefore means "this provider did not fail, it
/// rethrew someone else's failure", and is skipped. Riverpod's own retry logic
/// performs exactly this check.
///
/// `ProviderException` is `@internal` and not exported from `flutter_riverpod`,
/// so it cannot be named in a `case`. It is detected structurally instead, by
/// matching on the error's own runtime type. This is the only duck-typed check
/// in the codebase and it is confined here rather than repeated at call sites.
///
/// If a future Riverpod release exports the type, replace [isProviderException]
/// with a real `case ProviderException()` match.
final class AppProviderObserver extends ProviderObserver {
  /// Creates an observer that logs through [AppLogger].
  AppProviderObserver();

  /// Provider names whose failures are not logged.
  ///
  /// The Supabase providers touch `Supabase.instance`, which throws in tests
  /// before any real work happens. Logging that records the test environment,
  /// not the app.
  static const Set<String> _silentPrefixes = <String>{
    'supabase',
  };

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (isProviderException(error)) {
      // A rethrow, not a root failure. Already logged at the origin.
      return;
    }

    final provider = _describe(context);
    if (_isSilent(provider)) return;

    final mapped = _map(error);

    AppLogger.error(
      'Provider failed: $provider',
      context: LogContext(
        screen: provider,
        action: 'providerDidFail',
        detail: <String, Object?>{'error': mapped.code},
      ),
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    final provider = _describe(context);
    if (_isSilent(provider)) return;

    AppLogger.debug(
      'Provider disposed: $provider',
      context: LogContext(
        screen: provider,
        action: 'didDisposeProvider',
      ),
    );
  }

  /// Translates a provider failure into a safe exception type.
  ///
  /// A repository that already mapped its failure produces an [AppException],
  /// which is logged as-is. Anything else is a programming error that escaped
  /// mapping, and is reported as such rather than being quietly reclassified as
  /// a server fault.
  static AppException _map(Object error) {
    if (error is AppException) return error;
    return ValidationException(
      code: 'provider.unmappedError',
      messageEn: 'Something went wrong. Please try again.',
      messageNe: 'केही गडबड भयो। कृपया पुनः प्रयास गर्नुहोस्।',
      cause: error,
    );
  }

  /// Whether [error] is Riverpod's internal wrapper rather than a real failure.
  ///
  /// Visible for testing. See the class docs for why this is structural.
  ///
  /// Checks the wrapper's own type, not the type of its payload: reading
  /// `.exception` and inspecting *that* looks like the right test but is not —
  /// the payload is the original error, which by definition is not a
  /// ProviderException, so the check would never fire.
  @visibleForTesting
  static bool isProviderException(Object error) {
    if (error is AppException) return false;

    return error.runtimeType.toString().contains('ProviderException');
  }

  static bool _isSilent(String providerName) =>
      _silentPrefixes.any(providerName.contains);

  /// Human-readable provider identifier.
  ///
  /// `ProviderBase` is not exported from `package:riverpod`, so the provider is
  /// rendered through interpolation rather than by reading `.name` — a
  /// codegen'd provider's `toString()` includes its name, which is what a log
  /// entry needs. `contains` rather than `startsWith` because the rendered form
  /// is wrapped in a type, e.g. `FutureProvider<AuthState>`.
  static String _describe(ProviderObserverContext context) =>
      '${context.provider}';
}
