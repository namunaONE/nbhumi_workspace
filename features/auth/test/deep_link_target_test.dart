import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classifyDeepLink', () {
    test('https auth callback is an auth callback', () {
      final target = classifyDeepLink(
        Uri.parse('https://nbhumi.com/auth/callback?code=abc-123'),
      );

      expect(target, isA<AuthCallbackLink>());
    });

    test('custom-scheme auth callback is an auth callback', () {
      final target = classifyDeepLink(
        Uri.parse('nbhumi://auth/callback?code=abc-123'),
      );

      expect(target, isA<AuthCallbackLink>());
    });

    test('host matching is case-insensitive', () {
      final target = classifyDeepLink(
        Uri.parse('https://NBHUMI.com/auth/callback?code=x'),
      );

      expect(target, isA<AuthCallbackLink>());
    });

    test('shared listing link becomes an app route without the domain', () {
      final target = classifyDeepLink(
        Uri.parse('https://nbhumi.com/listing/some-id-123'),
      );

      expect(target, isA<AppRouteLink>());
      expect((target as AppRouteLink).location, '/listing/some-id-123');
    });

    test('bare /listing without an id is not a route', () {
      expect(
        classifyDeepLink(Uri.parse('https://nbhumi.com/listing')),
        isA<ExternalLink>(),
      );
      expect(
        classifyDeepLink(Uri.parse('https://nbhumi.com/listing/')),
        isA<ExternalLink>(),
      );
    });

    test('foreign hosts are ignored', () {
      expect(
        classifyDeepLink(Uri.parse('https://evil.com/auth/callback?code=x')),
        isA<ExternalLink>(),
      );
    });

    test('unknown paths on our own host are ignored', () {
      expect(
        classifyDeepLink(Uri.parse('https://nbhumi.com/search?q=house')),
        isA<ExternalLink>(),
      );
    });

    test('unrelated schemes are ignored', () {
      expect(
        classifyDeepLink(Uri.parse('mailto:seller@example.com')),
        isA<ExternalLink>(),
      );
    });
  });
}
