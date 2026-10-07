import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

const _failure = AuthFailureException(
  code: 'auth.linkExpired',
  messageEn: 'That sign-in link has expired. Request a new one.',
  messageNe: 'messageNe',
);

AuthLinkHandler _handler({
  required Stream<Uri> stream,
  Uri? initial,
  List<Uri>? exchanged,
  List<String>? routed,
  List<AppException>? failures,
  AppException? exchangeFailure,
  bool isRecovery = false,
}) {
  return AuthLinkHandler(
    getInitialLink: () async => initial,
    linkStream: stream,
    host: 'nbhumi.com',
    scheme: 'nbhumi',
    onAuthCallback: (uri) async {
      exchanged?.add(uri);
      if (exchangeFailure != null) throw exchangeFailure;
      return isRecovery;
    },
    onAppRoute: routed!.add,
    onAuthError: (error) => failures?.add(error),
  );
}

void main() {
  group('AuthLinkHandler', () {
    test('cold-start auth link is exchanged', () async {
      final exchanged = <Uri>[];
      final routed = <String>[];
      final handler = _handler(
        initial: Uri.parse('https://nbhumi.com/auth/callback?code=abc'),
        stream: const Stream.empty(),
        exchanged: exchanged,
        routed: routed,
      );
      addTearDown(handler.dispose);

      await handler.start();

      expect(exchanged, hasLength(1));
      expect(exchanged.single.queryParameters['code'], 'abc');
      expect(routed, ['/']);
      expect(handler.isActive, isTrue);
    });

    test('recovery is routed only when the exchange says recovery', () async {
      final routed = <String>[];
      final handler = _handler(
        stream: const Stream.empty(),
        routed: routed,
        isRecovery: true,
      );
      addTearDown(handler.dispose);

      await handler.handleLink(
        Uri.parse('nbhumi://auth/callback?code=one-time-code'),
      );

      expect(routed, ['/auth/callback?type=recovery']);
      expect(routed.single, isNot(contains('one-time-code')));
    });

    test('forged recovery query cannot change a normal sign-in', () async {
      final routed = <String>[];
      final handler = _handler(
        stream: const Stream.empty(),
        routed: routed,
      );
      addTearDown(handler.dispose);

      await handler.handleLink(
        Uri.parse('nbhumi://auth/callback?code=normal&type=recovery'),
      );

      expect(routed, ['/']);
    });

    test('cold and warm duplicates exchange only once', () async {
      final exchanged = <Uri>[];
      final routed = <String>[];
      final links = StreamController<Uri>();
      addTearDown(links.close);
      final callback = Uri.parse('nbhumi://auth/callback?code=single-use');
      final handler = _handler(
        initial: callback,
        stream: links.stream,
        exchanged: exchanged,
        routed: routed,
      );
      addTearDown(handler.dispose);

      await handler.start();
      links.add(callback);
      await pumpEventQueue();

      expect(exchanged, [callback]);
      expect(routed, ['/']);
    });

    test('warm listing link routes without touching auth', () async {
      final exchanged = <Uri>[];
      final routed = <String>[];
      final links = StreamController<Uri>();
      addTearDown(links.close);
      final handler = _handler(
        stream: links.stream,
        exchanged: exchanged,
        routed: routed,
      );
      addTearDown(handler.dispose);
      await handler.start();

      links.add(Uri.parse('https://nbhumi.com/listing/id-1'));
      await pumpEventQueue();

      expect(routed, ['/listing/id-1']);
      expect(exchanged, isEmpty);
    });

    test('failed exchange reports AuthFailed and keeps the stream alive',
        () async {
      final routed = <String>[];
      final failures = <AppException>[];
      final links = StreamController<Uri>();
      addTearDown(links.close);
      final handler = _handler(
        stream: links.stream,
        exchanged: <Uri>[],
        routed: routed,
        failures: failures,
        exchangeFailure: _failure,
      );
      addTearDown(handler.dispose);
      await handler.start();

      final outcome = await handler.handleLink(
        Uri.parse('nbhumi://auth/callback?code=stale'),
      );

      expect(outcome, isA<AuthFailed>());
      expect((outcome as AuthFailed).error.code, 'auth.linkExpired');
      expect(failures, [_failure]);
      expect(routed, isEmpty);

      // The handler survives: a later good link still routes.
      links.add(Uri.parse('https://nbhumi.com/listing/id-2'));
      await pumpEventQueue();
      expect(routed, ['/listing/id-2']);
    });

    test('external links are ignored silently', () async {
      final exchanged = <Uri>[];
      final routed = <String>[];
      final handler = _handler(
        stream: const Stream.empty(),
        exchanged: exchanged,
        routed: routed,
      );
      addTearDown(handler.dispose);

      final outcome = await handler.handleLink(
        Uri.parse('https://other.example/page'),
      );

      expect(outcome, isA<LinkIgnored>());
      expect(exchanged, isEmpty);
      expect(routed, isEmpty);
    });

    test('a throwing platform source does not throw start', () async {
      final handler = AuthLinkHandler(
        getInitialLink: () => throw StateError('no plugin'),
        linkStream: const Stream.empty(),
        onAuthCallback: (_) async => false,
        onAppRoute: (_) {},
        onAuthError: (_) {},
      );
      addTearDown(handler.dispose);

      // Must not throw: tests, desktop and broken ROMs have no link platform.
      await handler.start();
      expect(handler.isActive, isTrue);
    });

    test('start is idempotent', () async {
      var initialCalls = 0;
      final handler = AuthLinkHandler(
        getInitialLink: () async {
          initialCalls++;
          return null;
        },
        linkStream: const Stream.empty(),
        onAuthCallback: (_) async => false,
        onAppRoute: (_) {},
        onAuthError: (_) {},
      );
      addTearDown(handler.dispose);

      await handler.start();
      await handler.start();

      expect(initialCalls, 1);
    });
  });
}
