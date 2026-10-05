import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records calls; the unused surface throws so a test failure says exactly
/// which method fired that should not have.
class _SpyAuthService implements AuthService {
  String? sentTo;
  int signOutCalls = 0;
  AppException? sendMagicLinkFailure;

  String? signedUpEmail;
  String? signedUpPassword;
  String? signedInEmail;
  String? resetEmail;
  String? updatedPassword;

  @override
  Future<void> sendMagicLink(String email) async {
    if (sendMagicLinkFailure != null) throw sendMagicLinkFailure!;
    sentTo = email;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }

  @override
  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    signedUpEmail = email;
    signedUpPassword = password;
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    signedInEmail = email;
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    resetEmail = email;
  }

  @override
  Future<void> updatePassword(String password) async {
    updatedPassword = password;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('unused: ${invocation.memberName}');
}

ProviderContainer _container(_SpyAuthService spy) {
  return ProviderContainer(
    overrides: [
      isSignedInProvider.overrideWithValue(false),
      authServiceProvider.overrideWithValue(spy),
    ],
  );
}

void main() {
  group('Auth.sendMagicLink', () {
    test('rejects malformed email before touching the service', () async {
      final spy = _SpyAuthService();
      final container = _container(spy);
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(authProvider.notifier)
            .sendMagicLink('not-an-email'),
        throwsA(isA<ValidationException>()),
      );
      expect(spy.sentTo, isNull);
    });

    test('trims and forwards a valid email', () async {
      final spy = _SpyAuthService();
      final container = _container(spy);
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .sendMagicLink('  ramesh@example.com ');
      expect(spy.sentTo, 'ramesh@example.com');
    });

    test('propagates a mapped service failure', () async {
      const failure = ServerException(
        code: 'server.rateLimited',
        messageEn: 'Too many attempts.',
        messageNe: 'धेरै प्रयास भयो।',
      );
      final spy = _SpyAuthService()..sendMagicLinkFailure = failure;
      final container = _container(spy);
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(authProvider.notifier)
            .sendMagicLink('ramesh@example.com'),
        throwsA(isA<ServerException>()),
      );
      expect(spy.sentTo, isNull);
    });
  });

  test('Auth.build mirrors isSignedInProvider', () {
    final container = ProviderContainer(
      overrides: [isSignedInProvider.overrideWithValue(true)],
    );
    addTearDown(container.dispose);
    expect(container.read(authProvider), isTrue);
  });

  group('Auth passwords', () {
    test('short passwords are rejected before touching the service',
        () async {
      final spy = _SpyAuthService();
      final container = _container(spy);
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(authProvider.notifier)
            .signUpWithPassword(email: 'ramesh@example.com', password: 'short'),
        throwsA(isA<ValidationException>()),
      );
      expect(spy.signedUpEmail, isNull);

      await expectLater(
        container
            .read(authProvider.notifier)
            .updatePassword('short'),
        throwsA(isA<ValidationException>()),
      );
      expect(spy.updatedPassword, isNull);
    });

    test('sign-up trims the email and forwards both fields', () async {
      final spy = _SpyAuthService();
      final container = _container(spy);
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).signUpWithPassword(
            email: '  ramesh@example.com ',
            password: 'correct horse staple',
          );

      expect(spy.signedUpEmail, 'ramesh@example.com');
      expect(spy.signedUpPassword, 'correct horse staple');
    });

    test('sign-in validates the email but passes the password through',
        () async {
      final spy = _SpyAuthService();
      final container = _container(spy);
      addTearDown(container.dispose);

      // A wrong-but-long password must reach the server: length is not
      // verifiable client-side, and swallowing it would mask real failures.
      await container.read(authProvider.notifier).signInWithPassword(
            email: 'ramesh@example.com',
            password: 'wrong but long enough',
          );
      expect(spy.signedInEmail, 'ramesh@example.com');

      await expectLater(
        container.read(authProvider.notifier).signInWithPassword(
              email: 'not-an-email',
              password: 'long enough anyway',
            ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('reset validates the email before requesting', () async {
      final spy = _SpyAuthService();
      final container = _container(spy);
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .resetPassword('ramesh@example.com');
      expect(spy.resetEmail, 'ramesh@example.com');

      await expectLater(
        container.read(authProvider.notifier).resetPassword('nope'),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
