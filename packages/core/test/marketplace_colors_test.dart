import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The logo SVG is the single source of truth for brand color. These tests
/// pin the theme tokens to it, so a future hex tweak fails loudly instead of
/// silently drifting the icon away from the UI again.
void main() {
  group('BrandColors match the logo SVG', () {
    test('logo blues are the gradient stops', () {
      expect(BrandColors.logoBlue, const Color(0xFF002C6D));
      expect(BrandColors.logoBlueBright, const Color(0xFF0B3F94));
    });

    test('logo green is the land-arc and pin-dot fill', () {
      expect(BrandColors.logoGreen, const Color(0xFF4FD166));
    });

    test('logo gradient runs bright to deep, top-left to bottom-right', () {
      expect(BrandColors.logoGradient.colors,
          const <Color>[Color(0xFF0B3F94), Color(0xFF002C6D)]);
      expect(BrandColors.logoGradient.begin, Alignment.topLeft);
      expect(BrandColors.logoGradient.end, Alignment.bottomRight);
    });

    test('seed color is the logo blue, not a copy of it', () {
      expect(AppTheme.seedColor, BrandColors.logoBlue);
    });
  });

  group('verifiedGreen stays logo-locked in both schemes', () {
    test('light scheme uses the logo pair', () {
      expect(MarketplaceColors.light.verifiedGreen, BrandColors.logoGreen);
      expect(MarketplaceColors.light.onVerifiedGreen, BrandColors.logoBlue);
    });

    test('dark scheme uses the same logo pair, not a lightened twin', () {
      expect(MarketplaceColors.dark.verifiedGreen, BrandColors.logoGreen);
      expect(MarketplaceColors.dark.onVerifiedGreen, BrandColors.logoBlue);
    });

    test('foreground meets WCAG AA on the badge fill, both schemes', () {
      for (final scheme in <MarketplaceColors>[
        MarketplaceColors.light,
        MarketplaceColors.dark,
      ]) {
        expect(
          _contrastRatio(
              scheme.onVerifiedGreen, scheme.verifiedGreen),
          greaterThanOrEqualTo(4.5),
        );
      }
    });
  });
}

double _contrastRatio(Color foreground, Color background) {
  final l1 = foreground.computeLuminance();
  final l2 = background.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}
