import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/deep_links/deep_link_listener.dart';
import 'package:user_app/router/app_router.dart';

class _AuthService implements AuthService {
  _AuthService({this.recovery = false, this.failure});

  final bool recovery;
  final AppException? failure;
  Uri? exchanged;

  @override
  Future<bool> exchangeSessionFromUrl(Uri uri) async {
    exchanged = uri;
    final error = failure;
    if (error != null) throw error;
    return recovery;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('unused: ${invocation.memberName}');
}

Future<GoRouter> _pump(
  WidgetTester tester, {
  required _AuthService auth,
  required Stream<Uri> links,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Text('HOME')),
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) => AuthCallbackScreen(
          isRecovery: state.uri.queryParameters['type'] == 'recovery',
          error: state.uri.queryParameters['error'],
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('LOGIN')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        appRouterProvider.overrideWithValue(router),
        isSignedInProvider.overrideWithValue(true),
      ],
      child: DeepLinkListener(
        getInitialLinkOverride: () async => null,
        linkStreamOverride: links,
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('warm recovery link reaches the password form without its code',
      (tester) async {
    final stream = StreamController<Uri>();
    addTearDown(stream.close);
    final auth = _AuthService(recovery: true);
    final router = await _pump(tester, auth: auth, links: stream.stream);

    stream.add(Uri.parse('nbhumi://auth/callback?code=one-time-secret'));
    await tester.pumpAndSettle();

    expect(auth.exchanged?.queryParameters['code'], 'one-time-secret');
    expect(find.text('Choose a new password'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.toString(),
        '/auth/callback?type=recovery');
  });

  testWidgets('a mapped callback failure shows a safe screen, not the code',
      (tester) async {
    final stream = StreamController<Uri>();
    addTearDown(stream.close);
    final auth = _AuthService(
      failure: const AuthFailureException(
        code: 'auth.linkExpired',
        messageEn: 'Expired',
        messageNe: 'म्याद सकियो',
      ),
    );
    final router = await _pump(tester, auth: auth, links: stream.stream);

    stream.add(Uri.parse('nbhumi://auth/callback?code=expired-secret'));
    await tester.pumpAndSettle();

    expect(find.text('Sign-in link failed'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.toString(),
        '/auth/callback?error=expired');
  });
}
