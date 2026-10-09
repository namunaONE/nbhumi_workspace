import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/onboarding/onboarding_gate.dart';

/// First-run explanation of what nBhumi is and is not.
///
/// This screen exists for a legal reason as much as a UX one. DATA.md requires
/// the disclaimer — that nBhumi facilitates listings only and that property
/// transfer happens at Malpot — to be shown everywhere, and first run is the
/// one place a user is guaranteed to read it.
///
/// Shown once per install. The "seen" flag lives in `shared_preferences`
/// behind [OnboardingGate]; the router sends first-run users here and the
/// button below marks it complete.
class OnboardingScreen extends ConsumerWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                children: <Widget>[
                  Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    strings.appTitle,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.onboardingTagline,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _Feature(
                    icon: Icons.search,
                    title: strings.onboardingSearchTitle,
                    body: strings.onboardingSearchBody,
                  ),
                  _Feature(
                    icon: Icons.verified_user_outlined,
                    title: strings.onboardingVerifiedTitle,
                    body: strings.onboardingVerifiedBody,
                  ),
                  _Feature(
                    icon: Icons.photo_camera_outlined,
                    title: strings.onboardingPostTitle,
                    body: strings.onboardingPostBody,
                  ),
                  const SizedBox(height: 32),
                  // DATA.md: this disclaimer must be visible, not buried in
                  // terms nobody opens.
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              strings.onboardingDisclaimer,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryCTA(
                label: strings.onboardingBrowse,
                onPressed: () async {
                  await ref.read(onboardingGateProvider).markSeen();
                  // A fresh signup routes here once; completing it consumes
                  // the mark so later sessions land on the feed directly.
                  ref.read(freshSignupProvider.notifier).clear();
                  if (context.mounted) context.go('/');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
