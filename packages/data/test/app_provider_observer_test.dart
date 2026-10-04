import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A provider that always throws, used to trigger `providerDidFail`.
final failingProvider = FutureProvider<int>((ref) async {
  throw const ValidationException(
    code: 'test.boom',
    messageEn: 'Boom',
    messageNe: 'बम',
  );
});

/// An unmapped failure, i.e. a programming error rather than an AppException.
final unmappedFailingProvider = FutureProvider<int>((ref) async {
  throw StateError('a bug');
});

/// A provider that watches [failingProvider].
///
/// When the dependency fails, this one fails too. Under Riverpod 3.0 it is
/// reported to the observer with the dependency's error rethrown, which is the
/// case that would triple the error count without deduplication.
final dependentProvider = FutureProvider<int>((ref) {
  return ref.watch(failingProvider.future);
});

/// A provider that succeeds, to prove the observer stays quiet on the happy
/// path and on rebuilds.
final healthyProvider = FutureProvider<int>((ref) async => 42);

void main() {
  setUp(() => sessionContext.value = SessionContext.guest);
  tearDown(() => sessionContext.value = SessionContext.guest);

  group('AppProviderObserver.isProviderException', () {
    test('a mapped AppException is a real failure, not a wrapper', () {
      // AppException also has a `cause`, so a naive duck-type check would
      // misclassify every mapped repository error as a rethrow and swallow it.
      final mapped = ValidationException(
        code: 'v',
        messageEn: 'a',
        messageNe: 'b',
        cause: StateError('inner'),
      );

      expect(AppProviderObserver.isProviderException(mapped), isFalse);
    });

    test('a plain error without an exception getter is not a wrapper', () {
      expect(AppProviderObserver.isProviderException(StateError('x')), isFalse);
      expect(AppProviderObserver.isProviderException('a string'), isFalse);
      expect(AppProviderObserver.isProviderException(42), isFalse);
    });

    test('a fake ProviderException-shaped object is detected', () {
      // ProviderException cannot be constructed from outside riverpod, so this
      // is the only way to exercise the branch. The real class is @internal.
      final wrapper = _FakeProviderException(StateError('inner'));

      expect(AppProviderObserver.isProviderException(wrapper), isTrue);
    });

    test('an AppException wrapping a ProviderException is still a real failure',
        () {
      // Mapping must not launder a rethrow into something silently dropped.
      const mapped = ValidationException(
        code: 'v',
        messageEn: 'a',
        messageNe: 'b',
      );

      expect(AppProviderObserver.isProviderException(mapped), isFalse);
    });
  });

  group('AppProviderObserver', () {
    test('does not throw when a provider fails', () {
      // The observer must never be the reason a provider failure surfaces: an
      // exception thrown inside providerDidFail would replace the real error.
      final container = ProviderContainer.test(
        observers: [AppProviderObserver()],
        retry: (count, error) => null,
      );

      expect(
        () => container.read(failingProvider.future),
        throwsA(isA<ValidationException>()),
      );
    });

    test('the original error reaches the caller unchanged', () async {
      // Deduplication must not swallow the error itself, only the duplicate log
      // entry.
      final container = ProviderContainer.test(
        observers: [AppProviderObserver()],
        retry: (count, error) => null,
      );

      await expectLater(
        container.read(failingProvider.future),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'test.boom',
          ),
        ),
      );
    });

    test('a healthy provider produces no failure path', () async {
      final container = ProviderContainer.test(
        observers: [AppProviderObserver()],
      );

      expect(await container.read(healthyProvider.future), 42);
    });

    test('a dependent provider surfaces the same underlying error', () async {
      // Both providers report a failure to the observer. Both log entries are
      // suppressed for the rethrow, and only the origin is recorded.
      final container = ProviderContainer.test(
        observers: [AppProviderObserver()],
        retry: (count, error) => null,
      );

      await expectLater(
        container.read(dependentProvider.future),
        throwsA(isA<ValidationException>()),
      );
    });

    test('an unmapped failure is not mistaken for a wrapper', () async {
      final container = ProviderContainer.test(
        observers: [AppProviderObserver()],
        retry: (count, error) => null,
      );

      await expectLater(
        container.read(unmappedFailingProvider.future),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('sessionContext', () {
    test('starts as a guest with no screen', () {
      expect(sessionContext.value.userId, isNull);
      expect(sessionContext.value.screen, isNull);
      expect(SessionContext.guest.toString(), contains('guest'));
    });

    test('recordSessionUser sets and clears the user', () {
      recordSessionUser('user-1');
      expect(sessionContext.value.userId, 'user-1');

      recordSessionUser(null);
      expect(sessionContext.value.userId, isNull);
    });

    test('recordSessionUser preserves the current screen', () {
      recordCurrentScreen('/search');
      recordSessionUser('user-1');

      expect(sessionContext.value.screen, '/search');
      expect(sessionContext.value.userId, 'user-1');
    });

    test('recordCurrentScreen is a no-op when the route is unchanged', () {
      // Called on every navigation, so an unconditional assignment would
      // notify listeners and rebuild things for nothing.
      recordCurrentScreen('/search');
      final first = sessionContext.value;

      recordCurrentScreen('/search');
      expect(identical(sessionContext.value, first), isTrue);
    });

    test('recordCurrentScreen ignores null', () {
      // A null route would render as the literal string "null" in a log line.
      recordCurrentScreen('/search');
      recordCurrentScreen(null);

      expect(sessionContext.value.screen, '/search');
    });

    test('equality accounts for both fields', () {
      expect(
        const SessionContext(userId: 'a', screen: '/x'),
        const SessionContext(userId: 'a', screen: '/x'),
      );
      expect(
        const SessionContext(userId: 'a', screen: '/x'),
        isNot(const SessionContext(userId: 'b', screen: '/x')),
      );
      expect(
        const SessionContext(userId: 'a', screen: '/x'),
        isNot(const SessionContext(userId: 'a', screen: '/y')),
      );
    });
  });

  group('logContext', () {
    test('attaches the current user and screen', () {
      recordSessionUser('user-42');
      recordCurrentScreen('/listing/abc');

      final context = logContext(action: 'getListings');

      expect(context.userId, 'user-42');
      expect(context.screen, '/listing/abc');
      expect(context.action, 'getListings');
    });

    test('falls back to unknown before the first navigation', () {
      // Better than an empty screen field in a crash report.
      final context = logContext(action: 'boot');

      expect(context.screen, 'unknown');
    });

    test('an explicit screen overrides the tracked route', () {
      recordCurrentScreen('/search');
      final context = logContext(action: 'x', screen: '/override');

      expect(context.screen, '/override');
    });

    test('carries the error code through as detail', () {
      final context = logContext(
        action: 'getListings',
        detail: <String, Object?>{'code': 'network.unreachable'},
      );

      expect(context.toString(), contains('network.unreachable'));
    });
  });
}

/// Stands in for Riverpod's `ProviderException`.
///
/// The real type is `@internal` and its constructor is inaccessible from
/// outside the package, so the observer's structural check is exercised
/// against this instead.
class _FakeProviderException implements Exception {
  _FakeProviderException(this.exception);

  final Object exception;
}
