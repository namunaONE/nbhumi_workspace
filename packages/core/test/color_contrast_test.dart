import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.1 contrast floors for every role pair the theme hands out.
///
/// M3's tonal algorithm enforces contrast through `ContrastCurve`s, but nBhumi
/// overrides parts of the scheme (donated tertiary family, hand-set
/// `tertiary`/`onTertiary`, explicit warm/charcoal surfaces) — an override can
/// always break what the algorithm guaranteed. These tests are the
/// receipt: they assert the floors rather than trust them.
///
/// ### Why these floors and not M3's "7:1"
///
/// M3 quotes 7:1 for the on-primary family, but that is **MCU's tone-based
/// metric** (`Contrast.ratioOfTones`, derived from L*), not WCAG 2.1 relative
/// luminance. Measured in WCAG terms the same pairs land at ~6.5:1 — which is
/// what M3's algorithm actually delivers and is comfortably above AA. The
/// floors below are therefore WCAG 2.1 AA, the standard that governs
/// accessibility compliance:
///
///   text and icons ................. >= 4.5:1  (normal text)
///   boundaries, graphics ........... >= 3:1    (non-text)
///
/// A stricter target is not better here: asserting 7:1 would fail on a
/// correct scheme, and a red test nobody can make green is a test that gets
/// deleted.
///
/// Two real defects were found by the first draft of this file and are now
/// pinned: the verified wash ink (1.74:1 in light) and the Sale chip
/// (3.79:1 in light).
void main() {
  /// Relative-luminance contrast ratio, WCAG 2.1 formula.
  double ratio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// WCAG AA for normal text.
  const textFloor = 4.5;

  /// WCAG AA for non-text — boundaries and graphical objects.
  const graphicFloor = 3.0;

  /// Both schemes, so a light-only fix cannot silently pass.
  final schemes = <String, ColorScheme>{
    'light': AppTheme.lightScheme,
    'dark': AppTheme.darkScheme,
  };

  /// Translucent wash of [fg] over [bg], as the chips paint it.
  Color wash(Color fg, Color bg, double alpha) {
    int ch(double a, double b) =>
        (a * 255 * alpha + b * 255 * (1 - alpha)).round();
    return Color.fromARGB(
      255,
      ch(fg.r, bg.r),
      ch(fg.g, bg.g),
      ch(fg.b, bg.b),
    );
  }

  group('accent families meet their on-pair floors', () {
    for (final entry in schemes.entries) {
      final s = entry.value;

      test('${entry.key}: onPrimary over primary is >= 4.5:1', () {
        expect(
          ratio(s.onPrimary, s.primary),
          greaterThanOrEqualTo(textFloor),
          reason: 'FilledButton label sits on primary',
        );
      });

      test('${entry.key}: onSecondary over secondary is >= 4.5:1', () {
        expect(ratio(s.onSecondary, s.secondary),
            greaterThanOrEqualTo(textFloor));
      });

      test('${entry.key}: onTertiary over tertiary is >= 4.5:1', () {
        // The scheme pins `tertiary` to logoGreen and `onTertiary` to
        // logoBlue by hand — the one hand-set pair, so it gets its own test.
        expect(
          ratio(s.onTertiary, s.tertiary),
          greaterThanOrEqualTo(textFloor),
          reason: 'the logo green/blue pair is hand-set, not generated',
        );
      });

      test('${entry.key}: onError over error is >= 4.5:1', () {
        expect(ratio(s.onError, s.error), greaterThanOrEqualTo(textFloor));
      });
    }
  });

  group('containers meet 4.5:1', () {
    for (final entry in schemes.entries) {
      final s = entry.value;

      test('${entry.key}: onPrimaryContainer over primaryContainer', () {
        // Nav indicators and selection pills use this pair.
        expect(
          ratio(s.onPrimaryContainer, s.primaryContainer),
          greaterThanOrEqualTo(textFloor),
        );
      });

      test('${entry.key}: onSecondaryContainer over secondaryContainer', () {
        expect(
          ratio(s.onSecondaryContainer, s.secondaryContainer),
          greaterThanOrEqualTo(textFloor),
        );
      });

      test('${entry.key}: onTertiaryContainer over tertiaryContainer', () {
        expect(
          ratio(s.onTertiaryContainer, s.tertiaryContainer),
          greaterThanOrEqualTo(textFloor),
        );
      });

      test('${entry.key}: onErrorContainer over errorContainer', () {
        expect(
          ratio(s.onErrorContainer, s.errorContainer),
          greaterThanOrEqualTo(textFloor),
        );
      });
    }
  });

  group('surface text meets 4.5:1', () {
    for (final entry in schemes.entries) {
      final s = entry.value;

      test('${entry.key}: onSurface over the brightest container', () {
        // Dark mode lifts surfaces as elevation rises, so the worst case is
        // the *brightest* container. Light mode worst case is the lowest, but
        // testing the brightest covers both without a per-scheme branch.
        expect(
          ratio(s.onSurface, s.surfaceContainerHighest),
          greaterThanOrEqualTo(textFloor),
        );
      });

      test('${entry.key}: onSurface over surface', () {
        expect(ratio(s.onSurface, s.surface), greaterThanOrEqualTo(textFloor));
      });

      test('${entry.key}: onSurfaceVariant over surface', () {
        // Secondary copy: dividers, captions, hints.
        expect(
          ratio(s.onSurfaceVariant, s.surface),
          greaterThanOrEqualTo(textFloor),
        );
      });

      test('${entry.key}: primary as ink over surface', () {
        // Used for the focused-border ring and selected rail labels.
        expect(ratio(s.primary, s.surface), greaterThanOrEqualTo(textFloor));
      });
    }
  });

  group('boundaries meet 3:1', () {
    for (final entry in schemes.entries) {
      final s = entry.value;

      test('${entry.key}: outline over surface', () {
        expect(ratio(s.outline, s.surface), greaterThanOrEqualTo(graphicFloor));
      });
    }
  });

  group('marketplace accents meet their on-pair floors', () {
    for (final entry in <MarketplaceColors>[
      MarketplaceColors.light,
      MarketplaceColors.dark,
    ]) {
      test('verified badge pair (solid fill) is >= 4.5:1', () {
        expect(
          ratio(entry.onVerifiedGreen, entry.verifiedGreen),
          greaterThanOrEqualTo(textFloor),
        );
      });

      test('sale chip pair is >= 4.5:1', () {
        // Regression pin: white on #E65100 was 3.79:1 — a live WCAG failure
        // on an 11px bold label. Darkened to #C43E00 (5.28:1).
        expect(ratio(entry.onSaleOrange, entry.saleOrange),
            greaterThanOrEqualTo(textFloor));
      });

      test('rent chip pair is >= 4.5:1', () {
        expect(
          ratio(entry.onRentBlue, entry.rentBlue),
          greaterThanOrEqualTo(textFloor),
        );
      });

      test('lease chip pair is >= 4.5:1', () {
        expect(ratio(entry.onLeaseTeal, entry.leaseTeal),
            greaterThanOrEqualTo(textFloor));
      });
    }
  });

  group('the verified wash is legible on the surface it sits on', () {
    // StatusChip.verified and TrustBadge both paint a 12%-alpha wash of the
    // ink over the card surface. The ink is what must pass, so the test has
    // to blend the way the widgets do.
    //
    // Regression pin: painting the raw logo green (tone 75) on this wash was
    // 1.74:1 in the light scheme — a live WCAG failure, shipped.
    const lightSurface = Color(0xFFFAFAF8);
    const darkSurface = Color(0xFF121417);

    test('light: ink on 12% wash over the light surface is >= 4.5:1', () {
      final ink = MarketplaceColors.light.onVerifiedTint;
      expect(
        ratio(ink, wash(ink, lightSurface, 0.12)),
        greaterThanOrEqualTo(4.5),
        reason: 'StatusChip.verified / TrustBadge in the light scheme',
      );
    });

    test('dark: ink on 12% wash over the dark surface is >= 4.5:1', () {
      final ink = MarketplaceColors.dark.onVerifiedTint;
      expect(
        ratio(ink, wash(ink, darkSurface, 0.12)),
        greaterThanOrEqualTo(4.5),
        reason: 'the dark scheme keeps the bright logo green as its tint ink',
      );
    });

    test('the light ink is NOT the raw logo green', () {
      // Pins the regression itself: if someone "simplifies" the light ink
      // back to the brand green, this fails before the contrast test does.
      expect(MarketplaceColors.light.onVerifiedTint,
          isNot(MarketplaceColors.light.verifiedGreen));
    });
  });
}
