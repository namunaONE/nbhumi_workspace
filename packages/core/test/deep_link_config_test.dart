import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnvConfig deep links', () {
    test('no domain configured by default', () {
      // The project has no URL yet: the default build must not assume one.
      expect(EnvConfig.deepLinkHost, isEmpty);
    });

    test('redirect defaults to the custom scheme without a domain', () {
      // Zero-domain magic-link sign-in: only a Supabase allowlist entry for
      // this exact URI is needed, no DNS or .well-known hosting.
      expect(EnvConfig.useCustomSchemeRedirect, isTrue);
      expect(
        EnvConfig.authRedirectUri.toString(),
        'nbhumi://auth/callback',
      );
    });

    test('callback path is the single agreed value', () {
      expect(EnvConfig.authCallbackPath, '/auth/callback');
    });
  });
}
