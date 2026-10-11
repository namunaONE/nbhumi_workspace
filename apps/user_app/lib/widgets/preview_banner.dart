import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:user_app/l10n/output/app_localizations.dart';

/// Strips [child] with a preview marker when the build is a preview build.
///
/// ### Why this exists
///
/// GitHub Pages is a *preview* target: its Terms of Service prohibit commercial
/// hosting and it serves no security headers. A tester who lands on
/// `namunaone.github.io/…` must not mistake it for the live marketplace, nor
/// draw conclusions about inventory, accounts or data durability. The build
/// advertises itself instead of relying on the URL to explain.
///
/// ### Why the wording avoids a brand name
///
/// The Nepali line is deliberately not a transliteration of any company or
/// product name. An earlier draft read "नमुना निर्माण", which collided with the
/// owning organisation's name (Namuna One) and made the banner read as a
/// rebrand rather than a status. "पूर्वावलोकन निर्माण" ("preview build") states
/// what the build is without impersonating anything. Keep it that way: this
/// strip names a state, never a brand.
///
/// ### Why the gate is compile-time
///
/// `EnvConfig.environment` is a `String.fromEnvironment`, baked in by
/// `--dart-define`. It is not a setting a tester could flip at runtime, and a
/// release build without the define resolves to `dev`, so [child] comes back
/// untouched and production sees a byte-identical widget tree. That is also why
/// the goldens in `test/goldens/ci/` stay valid: they build their own
/// `MaterialApp` and never reach this wrapper, and CI runs with no
/// `ENVIRONMENT` define anyway.
///
/// ### Why a Column and not an overlay
///
/// An overlay would cover the app bar and steal the first taps. A column
/// reserves its own space, so nothing is occluded and no hit target or scroll
/// offset moves. It is the honest shape for something meant to be impossible
/// to forget.
class PreviewBanner extends StatelessWidget {
  /// Creates the preview wrapper.
  const PreviewBanner({required this.child, super.key});

  /// The app content shown beneath the banner.
  final Widget child;

  /// The environment name that reveals the banner.
  ///
  /// Exposed as a constant so tests assert on the gate rather than duplicating
  /// the literal in two places.
  static const String previewEnvironment = 'preview';

  @override
  Widget build(BuildContext context) {
    // The whole feature collapses here in every non-preview build.
    if (EnvConfig.environment != previewEnvironment) return child;

    return Column(
      children: <Widget>[
        const PreviewBannerStrip(),
        Expanded(child: child),
      ],
    );
  }
}

/// The banner itself, with no gate.
///
/// Split from [PreviewBanner] so the rendered strip can be tested without
/// `--dart-define`, which would flip every other assertion in the suite. The
/// gate stays in one place and the content stays assertable.
class PreviewBannerStrip extends StatelessWidget {
  /// Creates the banner strip.
  const PreviewBannerStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);

    // Warning, not brand: this must not read as decoration.
    return Material(
      color: theme.colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.science_outlined,
                // One-off glyph size: not a spacing or radius token, so it
                // stays a literal rather than being derived from an unrelated
                // one.
                // a literal rather than being derived from an unrelated one.
                size: 18,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      strings.previewBanner,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      strings.previewBannerDetail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
