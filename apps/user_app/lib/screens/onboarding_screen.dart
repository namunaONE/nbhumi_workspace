import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/screens/onboarding_content.dart';

/// First-run explanation of what nBhumi is and is not.
///
/// This screen exists for a legal reason as much as a UX one. DATA.md requires
/// the disclaimer — that nBhumi facilitates listings only and that property
/// transfer happens at Malpot — to be shown everywhere, and first run is the
/// one place a user is guaranteed to read it.
///
/// Shown once per install. The "seen" flag lives in `shared_preferences`
/// behind `OnboardingGate`; the router sends first-run users here and the
/// button below marks it complete.
///
/// Responsive (DESIGN.md §6): the content is measured with [LayoutBuilder] —
/// never a cached size — and branches at [AppBreakpoints.expanded]. Compact
/// keeps the single column capped at [AppContentWidths.form]; expanded splits
/// into a hero + content pair inside [AppContentWidths.feed]. The CTA stays
/// `fullWidth`, but it fills the capped column (~480px), never the window.
class OnboardingScreen extends StatelessWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // LayoutBuilder, not MediaQuery: the route owns its chrome, but the
        // builder stays correct in split-screen and under golden constraints,
        // where MediaQuery still reports the full test surface.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= AppBreakpoints.expanded;
            if (wide) {
              return _WideBody(
                maxHeight: constraints.maxHeight,
              );
            }
            return _NarrowBody(
              maxHeight: constraints.maxHeight,
            );
          },
        ),
      ),
    );
  }
}

/// Single column for phones and narrow windows.
///
/// Capped at [AppContentWidths.form] so the disclaimer card and the CTA never
/// stretch: the button fills the column, not the screen.
class _NarrowBody extends StatelessWidget {
  /// Creates the compact layout.
  const _NarrowBody({required this.maxHeight});

  /// Body height from the [LayoutBuilder]; makes the inner [Column] tight so
  /// its [Expanded] scroll region keeps working under the [CenteredContent].
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return CenteredContent(
      maxWidth: AppContentWidths.form,
      child: SizedBox(
        height: maxHeight,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.xxxl,
                ),
                children: <Widget>[
                  OnboardingHeroHeader(strings: strings),
                  const SizedBox(height: AppSpacing.xxxl),
                  OnboardingFeatureList(strings: strings),
                  const SizedBox(height: AppSpacing.xxxl),
                  OnboardingDisclaimerCard(strings: strings),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: OnboardingBrowseButton(strings: strings),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero + content split for wide windows.
///
/// The pair is capped at [AppContentWidths.feed]: each pane lands near
/// [AppContentWidths.form], so neither the feature rows nor the CTA stretch.
/// Mirrors the shell's expanded `Row` pattern (drawer + content).
class _WideBody extends StatelessWidget {
  /// Creates the wide layout.
  const _WideBody({required this.maxHeight});

  /// Body height from the [LayoutBuilder]; keeps the [Row] tight so the right
  /// pane's sticky CTA keeps working under the [CenteredContent].
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return CenteredContent(
      maxWidth: AppContentWidths.feed,
      child: SizedBox(
        height: maxHeight,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: OnboardingHeroHeader(strings: strings),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                        vertical: AppSpacing.xxxl,
                      ),
                      children: <Widget>[
                        OnboardingFeatureList(strings: strings),
                        const SizedBox(height: AppSpacing.xxxl),
                        OnboardingDisclaimerCard(strings: strings),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: OnboardingBrowseButton(strings: strings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
