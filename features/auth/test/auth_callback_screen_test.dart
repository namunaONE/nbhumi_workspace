import 'package:auth/auth.dart';
import 'package:auth/l10n/output/auth_localizations.dart' as auth_strings;
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _PasswordService implements AuthService {
  String? savedPassword;

  @override
  Future<void> updatePassword(String password) async {
    savedPassword = password;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('unused: ${invocation.memberName}');
}

void main() {
  testWidgets('a failed callback shows a safe error and retry path',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/auth/callback?error=expired',
      routes: [
        GoRoute(
          path: '/auth/callback',
          builder: (context, state) => const AuthCallbackScreen(
            error: 'expired',
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('SIGN-IN SCREEN')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [isSignedInProvider.overrideWithValue(false)],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            auth_strings.AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('link has expired'), findsOneWidget);
    await tester.tap(find.text('Request a new link'));
    await tester.pumpAndSettle();
    expect(find.text('SIGN-IN SCREEN'), findsOneWidget);
  });

  testWidgets('recovery session gets a password form, not an automatic home',
      (tester) async {
    final service = _PasswordService();
    final router = GoRouter(
      initialLocation: '/auth/callback?type=recovery',
      routes: [
        GoRoute(
          path: '/auth/callback',
          builder: (context, state) => const AuthCallbackScreen(
            isRecovery: true,
          ),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('HOME')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          authServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            auth_strings.AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsNothing);
    expect(find.text('Choose a new password'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'New password'),
      'correct horse battery',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm new password'),
      'correct horse battery',
    );
    await tester.tap(find.text('Save new password'));
    await tester.pumpAndSettle();

    expect(service.savedPassword, 'correct horse battery');
    expect(find.text('HOME'), findsOneWidget);
  });
}
