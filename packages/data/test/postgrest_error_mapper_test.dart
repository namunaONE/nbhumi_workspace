import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Builds a [PostgrestException] carrying a specific SQLSTATE.
///
/// The mapping contract is "this SQLSTATE becomes that AppException subtype
/// with a safe bilingual message"; nothing else about the error is asserted.
PostgrestException postgrestError(String code, {String message = 'boom'}) =>
    PostgrestException(message: message, code: code);

/// A provider whose build always throws.
final throwingProvider = FutureProvider<int>((ref) async {
  throw postgrestError('22023');
});

/// A container with Riverpod 3.0's automatic retry switched off.
///
/// Riverpod retries a failing provider up to 10 times with exponential backoff
/// (200ms to 6.4s), so reading `provider.future` does not reject until roughly
/// 40 seconds have passed. Any provider expected to fail - a browse request
/// against a dead network, for instance - must therefore pass
/// `retry: (count, error) => null`, or the user watches a spinner for the best
/// part of a minute. Without this, these tests time out at 30s. See HYA-203.
ProviderContainer testContainer() =>
    ProviderContainer.test(retry: (count, error) => null);

/// Reads the throwing provider's failure out of a container.
///
/// Returns the error object rather than asserting, so each test can make its
/// own claim about it.
Future<Object> readFailure() async {
  final container = testContainer()
    ..listen(throwingProvider, (_, _) {});
  try {
    await container.read(throwingProvider.future);
  } on Object catch (e) {
    return e;
  }
  fail('the throwing provider should have failed');
}

/// Recovers a mapped [AppException] from a provider failure.
///
/// Riverpod 3.0 does wrap provider errors in `ProviderException` for
/// `requireValue`, but that type is `@internal` and **not exported** from
/// `flutter_riverpod`, so it cannot be named or pattern-matched. Reading
/// `provider.future` - which is what a ViewModel actually does - hands back the
/// unaltered error (verified below), so a plain type test is enough.
AppException mapProviderFailure(Object error, {required String action}) {
  if (error is PostgrestException) {
    return PostgrestErrorMapper.map(error, action: action);
  }
  throw StateError('unmapped provider failure: $error');
}

void main() {
  group('PostgrestErrorMapper - SQLSTATE mapping', () {
    test('42501 insufficient_privilege becomes AuthFailureException', () {
      // Covers both RLS denial and an admin-only RPC called by a non-admin.
      final mapped = PostgrestErrorMapper.map(
        postgrestError('42501'),
        action: 'approveListing',
      );

      expect(mapped, isA<AuthFailureException>());
      expect(mapped.code, 'auth.forbidden');
    });

    test('22023 invalid_parameter_value becomes ValidationException', () {
      // Also what the listings status-transition guard raises.
      final mapped = PostgrestErrorMapper.map(
        postgrestError('22023'),
        action: 'createListing',
      );

      expect(mapped, isA<ValidationException>());
      expect(mapped.code, 'validation.rejected');
    });

    test('P0002 and PGRST116 both become a not-found ServerException', () {
      // v1_get_listing_detail raises P0002 for "missing" and "not visible"
      // alike, so both must read identically to a client.
      final viaPlpgsql = PostgrestErrorMapper.map(
        postgrestError('P0002'),
        action: 'getListingById',
      );
      final viaPostgrest = PostgrestErrorMapper.map(
        postgrestError('PGRST116'),
        action: 'getListingById',
      );

      expect(viaPlpgsql.code, 'server.notFound');
      expect(viaPostgrest.code, 'server.notFound');
      expect(viaPlpgsql.messageEn, viaPostgrest.messageEn);
    });

    test('constraint violations become ValidationException', () {
      // 23505 duplicate, 23503 bad FK, 23514 check (ward 1-32, status trigger).
      for (final code in ['23505', '23503', '23514']) {
        expect(
          PostgrestErrorMapper.map(postgrestError(code), action: 'x'),
          isA<ValidationException>(),
          reason: '$code must map to ValidationException',
        );
      }
    });

    test('57014 statement_timeout becomes ServerException', () {
      final mapped = PostgrestErrorMapper.map(
        postgrestError('57014'),
        action: 'getListings',
      );

      expect(mapped, isA<ServerException>());
      expect(mapped.code, 'server.timeout');
    });

    test('unrecognised codes become ServerException, no raw message', () {
      final mapped = PostgrestErrorMapper.map(
        postgrestError(
          'XX000',
          message: 'relation "secret_table" does not exist',
        ),
        action: 'getListings',
      );

      expect(mapped, isA<ServerException>());
      expect(mapped.code, 'server.unexpected');
      // Rule 38: Postgres text must never reach the user...
      expect(mapped.messageEn, isNot(contains('secret_table')));
      expect(mapped.messageNe, isNot(contains('secret_table')));
      // ...but it is preserved for logging.
      expect(mapped.cause, isA<PostgrestException>());
    });

    test('connectivity failures become a retryable NetworkException', () {
      // PostgREST reports transport problems with no SQLSTATE, so message text
      // is the only available signal.
      for (final message in [
        'TypeError: Failed to fetch',
        'Connection closed',
        'socket hang up',
        'network timeout',
      ]) {
        final mapped = PostgrestErrorMapper.map(
          postgrestError('PGRST000', message: message),
          action: 'getListings',
        );

        expect(
          mapped,
          isA<NetworkException>(),
          reason: '"$message" should be treated as connectivity',
        );
        expect(mapped.isRetryable, isTrue);
      }
    });

    test('PN001 maps to a non-retryable contact rate limit', () {
      // v1_contact_seller raises this once ten first-time reveals are spent.
      final mapped = PostgrestErrorMapper.map(
        postgrestError('PN001', message: 'RATE_LIMITED: contact reveal limit'),
        action: 'contactSeller',
      );

      expect(mapped.code, 'contact.rateLimited');
      // Waiting is the only remedy, so offering a retry button would produce a
      // second guaranteed failure.
      expect(mapped.isRetryable, isFalse);
      // Must not leak the raw Postgres text.
      expect(mapped.messageEn, isNot(contains('RATE_LIMITED')));
      expect(mapped.messageNe, isNot(contains('RATE_LIMITED')));
    });

    test('42501 from v1_contact_seller reads as a sign-in prompt', () {
      // Reached when a guest or the listing's own seller calls it. The generic
      // 'permission' wording is accurate for the seller case and vague for the
      // guest case, which is the safer of the two.
      final mapped = PostgrestErrorMapper.map(
        postgrestError('42501', message: 'permission denied'),
        action: 'contactSeller',
      );

      expect(mapped, isA<AuthFailureException>());
      expect(mapped.isRetryable, isFalse);
    });
  });

  group('AppException contract', () {
    test('every mapped error carries English and Nepali messages', () {
      // Rule 36: user-facing errors are bilingual, and Nepali is the primary
      // language for this market, so neither may be empty or transliterated.
      const codes = [
        '42501',
        '22023',
        '23505',
        '23503',
        '23514',
        'P0002',
        'PGRST116',
        '57014',
        'XX000',
      ];

      for (final code in codes) {
        final mapped = PostgrestErrorMapper.map(
          postgrestError(code),
          action: 'getListings',
        );

        expect(mapped.messageEn, isNotEmpty, reason: '$code needs messageEn');
        expect(mapped.messageNe, isNotEmpty, reason: '$code needs messageNe');
        expect(
          RegExp('[\u0900-\u097F]').hasMatch(mapped.messageNe),
          isTrue,
          reason: '$code Nepali message should be in Devanagari',
        );
      }
    });

    test('message() prefers Nepali by default', () {
      const e = ValidationException(
        code: 'v',
        messageEn: 'English',
        messageNe: 'नेपाली',
      );

      expect(e.message(), 'नेपाली');
      expect(e.message(preferNepali: false), 'English');
    });

    test('only NetworkException is retryable', () {
      // Drives whether the snackbar offers a retry action (Rule 36).
      const network =
          NetworkException(code: 'n', messageEn: 'a', messageNe: 'b');
      const validation =
          ValidationException(code: 'v', messageEn: 'a', messageNe: 'b');
      const server = ServerException(code: 's', messageEn: 'a', messageNe: 'b');
      const auth =
          AuthFailureException(code: 'a', messageEn: 'a', messageNe: 'b');

      expect(network.isRetryable, isTrue);
      expect(validation.isRetryable, isFalse);
      expect(server.isRetryable, isFalse);
      expect(auth.isRetryable, isFalse);
    });

    test('toString does not depend on runtimeType', () {
      // runtimeType is mangled by minification in release builds, which would
      // break grouping errors by type in logs.
      const e = ServerException(
        code: 'server.unexpected',
        messageEn: 'Oops',
        messageNe: 'ओहो',
      );

      expect(e.toString(), 'ServerException(server.unexpected): Oops');
      expect(e.toString(), isNot(contains('Instance of')));
    });

    test('every subtype stays catchable as an Exception', () {
      // The hierarchy must remain catchable through Exception so existing
      // catch blocks keep working (Rule 35).
      const e = ValidationException(code: 'v', messageEn: 'a', messageNe: 'b');
      expect(e, isA<Exception>());
    });
  });

  group('AuthExceptionMapper', () {
    test('an expired magic link is reported as a link failure', () {
      final mapped = AuthExceptionMapper.map(
        const AuthException('Email link is expired'),
        action: 'signIn',
      );

      expect(mapped.code, 'auth.linkExpired');
      expect(mapped.messageNe, isNotEmpty);
    });

    test('an invalid JWT tells the user to sign in again', () {
      final mapped = AuthExceptionMapper.map(
        const AuthException('invalid JWT'),
        action: 'getListings',
      );

      expect(mapped.code, 'auth.sessionExpired');
    });

    test('rate limiting maps to a ServerException', () {
      final mapped = AuthExceptionMapper.map(
        const AuthException('Too many requests, rate limit exceeded'),
        action: 'sendMagicLink',
      );

      expect(mapped, isA<ServerException>());
      expect(mapped.code, 'server.rateLimited');
    });

    test('anything else is generic, with no internals leaked', () {
      final mapped = AuthExceptionMapper.map(
        const AuthException(
          'User with email a@b.com failed to sign in (provider=smtp)',
        ),
        action: 'sendMagicLink',
      );

      expect(mapped.code, 'auth.failed');
      expect(mapped.messageEn, isNot(contains('a@b.com')));
      expect(mapped.messageNe, isNot(contains('smtp')));
    });
  });

  group('provider failure handling', () {
    test('reading provider.future surfaces the unaltered error', () async {
      // The first version of this test asserted the opposite and failed:
      // Riverpod 3.0's ProviderException wrapping applies to requireValue, but
      // provider.future and AsyncValue.error receive the original error. That
      // is what makes a plain `is PostgrestException` check sufficient.
      final error = await readFailure();

      expect(error, isA<PostgrestException>());
      expect((error as PostgrestException).code, '22023');
    });

    test('mapProviderFailure recovers the mapped AppException', () async {
      // This is the call every ViewModel will make. If it cannot see the
      // underlying error, every failure in the UI renders as unknown.
      final error = await readFailure();
      final mapped = mapProviderFailure(error, action: 'getListings');

      expect(mapped, isA<ValidationException>());
      expect(mapped.code, 'validation.rejected');
    });

    test('mapProviderFailure accepts an already-unmapped error', () {
      expect(
        mapProviderFailure(postgrestError('42501'), action: 'getListings'),
        isA<AuthFailureException>(),
      );
    });

    test('a mapped error is not itself a raw transport error', () {
      // A second provider depending on the first must not try to map it again.
      expect(
        PostgrestErrorMapper.map(postgrestError('42501'), action: 'a'),
        isNot(isA<PostgrestException>()),
      );
    });
  });
}
