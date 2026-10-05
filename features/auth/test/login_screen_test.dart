import 'package:auth/auth.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SpyAuthService implements AuthService {
  String? sentTo;
  int calls = 0;

  @override
  Future<void> sendMagicLink(String email) async {
    calls++;
    sentTo = email;
  }

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
}
