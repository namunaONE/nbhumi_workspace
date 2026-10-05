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
  AppException? exchangeFailure,
}) {
  return AuthLinkHandler(
    getInitialLink: () async => initial,
    linkStream: stream,
    onAuthCallback: (uri) async {
      exchanged?.add(uri);
      if (exchangeFailure != null) throw exchangeFailure;
    },
    onAppRoute: routed!.add,
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
      expect(handler.isActive, isTrue);
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
      final links = StreamController<Uri>();
      addTearDown(links.close);
      final handler = _handler(
        stream: links.stream,
        exchanged: <Uri>[],
        routed: routed,
        exchangeFailure: _failure,
      );
      addTearDown(handler.dispose);
      await handler.start();

      final outcome = await handler.handleLink(
        Uri.parse('nbhumi://auth/callback?code=stale'),
      );

      expect(outcome, isA<AuthFailed>());
      expect((outcome as AuthFailed).error.code, 'auth.linkExpired');

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
        onAuthCallback: (_) async {},
        onAppRoute: (_) {},
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
        onAuthCallback: (_) async {},
        onAppRoute: (_) {},
      );
      addTearDown(handler.dispose);

      await handler.start();
      await handler.start();

      expect(initialCalls, 1);
    });
  });
}
