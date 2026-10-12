import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/onboarding/onboarding_gate.dart';

/// Brand mark, title and tagline shared by both onboarding layouts.
class OnboardingHeroHeader extends StatelessWidget {
  /// Creates the hero header.
  const OnboardingHeroHeader({required this.strings, super.key});

  /// Localized strings.
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.home_work_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          strings.appTitle,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          strings.onboardingTagline,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// The three onboarding feature rows.
class OnboardingFeatureList extends StatelessWidget {
  /// Creates the feature list.
  const OnboardingFeatureList({required this.strings, super.key});

  /// Localized strings.
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OnboardingFeature(
          icon: Icons.search,
          title: strings.onboardingSearchTitle,
          body: strings.onboardingSearchBody,
        ),
        OnboardingFeature(
          icon: Icons.verified_user_outlined,
          title: strings.onboardingVerifiedTitle,
          body: strings.onboardingVerifiedBody,
        ),
        OnboardingFeature(
          icon: Icons.photo_camera_outlined,
          title: strings.onboardingPostTitle,
          body: strings.onboardingPostBody,
        ),
      ],
    );
  }
}

/// The Malpot disclaimer card.
///
/// DATA.md requires this to be visible on first run, not buried in terms.
class OnboardingDisclaimerCard extends StatelessWidget {
  /// Creates the disclaimer card.
  const OnboardingDisclaimerCard({required this.strings, super.key});

  /// Localized strings.
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.info_outline,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                strings.onboardingDisclaimer,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The complete-and-continue CTA shared by both onboarding layouts.
class OnboardingBrowseButton extends ConsumerWidget {
  /// Creates the browse button.
  const OnboardingBrowseButton({required this.strings, super.key});

  /// Localized strings.
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PrimaryCTA(
      label: strings.onboardingBrowse,
      onPressed: () async {
        // Consuming the fresh-signup mark alongside seen: without this the
        // router's fresh-signup redirect sends `go('/')` straight back to
        // onboarding and the button appears to do nothing.
        ref.read(freshSignupProvider.notifier).clear();
        await ref.read(onboardingGateProvider).markSeen();
        if (context.mounted) context.go('/');
      },
    );
  }
}

/// One icon-led feature row.
class OnboardingFeature extends StatelessWidget {
  /// Creates a feature row.
  const OnboardingFeature({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  /// Leading icon.
  final IconData icon;

  /// Row title.
  final String title;

  /// Row body.
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
