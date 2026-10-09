import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records calls; the unused surface throws so a test failure says exactly
/// which method fired that should not have.
class _SpyAuthService implements AuthService {
  int signOutCalls = 0;

  String? signedUpEmail;
  String? signedUpPassword;
  String? signedInEmail;
  String? resetEmail;
  String? updatedPassword;
  AppException? signUpFailure;

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }

  @override
  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    final error = signUpFailure;
    if (error != null) throw error;
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

    test('sign-up marks the install for post-signup onboarding', () async {
      final spy = _SpyAuthService();
      final container = _container(spy);
      addTearDown(container.dispose);

      expect(container.read<bool>(freshSignupProvider), isFalse);

      await container.read(authProvider.notifier).signUpWithPassword(
            email: 'ramesh@example.com',
            password: 'correct horse staple',
          );

      expect(container.read<bool>(freshSignupProvider), isTrue);
    });

    test('sign-up propagates a mapped service failure', () async {
      const failure = ServerException(
        code: 'server.rateLimited',
        messageEn: 'Too many attempts.',
        messageNe: 'धेरै प्रयास भयो।',
      );
      final spy = _SpyAuthService()..signUpFailure = failure;
      final container = _container(spy);
      addTearDown(container.dispose);

      await expectLater(
        container.read(authProvider.notifier).signUpWithPassword(
              email: 'ramesh@example.com',
              password: 'correct horse staple',
            ),
        throwsA(isA<ServerException>()),
      );
      expect(spy.signedUpEmail, isNull);
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
