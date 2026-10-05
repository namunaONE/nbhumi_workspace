import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// Classifies with the production-shaped config. Explicit rather than the
/// EnvConfig defaults so tests do not depend on `--dart-define` flags —
/// the default host is empty until the real domain exists.
DeepLinkTarget _classify(String raw) => classifyDeepLink(
      Uri.parse(raw),
      host: 'nbhumi.com',
      scheme: 'nbhumi',
    );

void main() {
  group('classifyDeepLink', () {
    test('https auth callback is an auth callback', () {
      expect(
        _classify('https://nbhumi.com/auth/callback?code=abc-123'),
        isA<AuthCallbackLink>(),
      );
    });

    test('custom-scheme auth callback is an auth callback', () {
      expect(
        _classify('nbhumi://auth/callback?code=abc-123'),
        isA<AuthCallbackLink>(),
      );
    });

    test('host matching is case-insensitive', () {
      expect(
        _classify('https://NBHUMI.com/auth/callback?code=x'),
        isA<AuthCallbackLink>(),
      );
    });

    test('shared listing link becomes an app route without the domain', () {
      final target = _classify('https://nbhumi.com/listing/some-id-123');

      expect(target, isA<AppRouteLink>());
      expect((target as AppRouteLink).location, '/listing/some-id-123');
    });

    test('bare /listing without an id is not a route', () {
      expect(
        _classify('https://nbhumi.com/listing'),
        isA<ExternalLink>(),
      );
      expect(
        _classify('https://nbhumi.com/listing/'),
        isA<ExternalLink>(),
      );
    });

    test('foreign hosts are ignored', () {
      expect(
        _classify('https://evil.com/auth/callback?code=x'),
        isA<ExternalLink>(),
      );
    });

    test('unknown paths on our own host are ignored', () {
      expect(
        _classify('https://nbhumi.com/search?q=house'),
        isA<ExternalLink>(),
      );
    });

    test('unrelated schemes are ignored', () {
      expect(
        _classify('mailto:seller@example.com'),
        isA<ExternalLink>(),
      );
    });

    test('default config (no domain) still recognises the custom scheme', () {
      // No host/scheme passed: with the default empty host, https links match
      // nothing, but the custom scheme keeps working — that is the whole
      // pre-domain flow.
      expect(
        classifyDeepLink(Uri.parse('nbhumi://auth/callback?code=x')),
        isA<AuthCallbackLink>(),
      );
      expect(
        classifyDeepLink(Uri.parse('https://nbhumi.com/auth/callback?x=1')),
        isA<ExternalLink>(),
      );
    });
  });
}
