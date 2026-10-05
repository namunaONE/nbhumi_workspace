import 'package:auth/auth.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SpyAuthService implements AuthService {
  String? sentTo;
  int calls = 0;
  String? signedInEmail;
  String? signedUpEmail;
  String? resetEmail;

  @override
  Future<void> sendMagicLink(String email) async {
    calls++;
    sentTo = email;
  }

  @override
  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    signedUpEmail = email;
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
  Future<void> updatePassword(String password) async {}

  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('unused: ${invocation.memberName}');
}

/// Pumps the screen in an English locale so localized messages render English.
Widget _app(_SpyAuthService spy) {
  return ProviderScope(
    overrides: [
      isSignedInProvider.overrideWithValue(false),
      authServiceProvider.overrideWithValue(spy),
    ],
    child: const MaterialApp(
      locale: Locale('en'),
      home: LoginScreen(),
    ),
  );
}

void main() {
  testWidgets('invalid email blocks the send and shows a bilingual error',
      (tester) async {
    final spy = _SpyAuthService();
    await tester.pumpWidget(_app(spy));

    await tester.enterText(find.byType(TextFormField), 'nope');
    await tester.tap(find.widgetWithText(FilledButton, 'Send sign-in link'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(spy.calls, 0);
  });

  testWidgets('valid email sends and shows the inbox state', (tester) async {
    final spy = _SpyAuthService();
    await tester.pumpWidget(_app(spy));

    await tester.enterText(
      find.byType(TextFormField),
      'seller@example.com',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Send sign-in link'));
    await tester.pump();
    await tester.pump();

    expect(spy.sentTo, 'seller@example.com');
    expect(find.textContaining('seller@example.com'), findsWidgets);
    expect(find.textContaining('Resend in'), findsOneWidget);
  });

  testWidgets('password pane signs in with email and password',
      (tester) async {
    final spy = _SpyAuthService();
    await tester.pumpWidget(_app(spy));

    await tester.tap(find.text('Password'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 's@s.com');
    await tester.enterText(find.byType(TextFormField).last, 'long enough');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(spy.signedInEmail, 's@s.com');
  });

  testWidgets('short signup password is rejected inline', (tester) async {
    final spy = _SpyAuthService();
    await tester.pumpWidget(_app(spy));

    await tester.tap(find.text('Password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 's@s.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'short');
    await tester.enterText(find.byType(TextFormField).last, 'short');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(find.textContaining('At least'), findsOneWidget);
    expect(spy.signedUpEmail, isNull);
  });

  testWidgets('mismatched confirmation blocks signup', (tester) async {
    final spy = _SpyAuthService();
    await tester.pumpWidget(_app(spy));

    await tester.tap(find.text('Password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 's@s.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'long enough');
    await tester.enterText(find.byType(TextFormField).last, 'different!!');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(spy.signedUpEmail, isNull);
  });

  testWidgets('forgot password sends a reset link', (tester) async {
    final spy = _SpyAuthService();
    await tester.pumpWidget(_app(spy));

    await tester.tap(find.text('Password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot your password?'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 's@s.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Send reset link'));
    await tester.pump();
    await tester.pump();

    expect(spy.resetEmail, 's@s.com');
    expect(find.textContaining('reset link to'), findsOneWidget);
  });
}
