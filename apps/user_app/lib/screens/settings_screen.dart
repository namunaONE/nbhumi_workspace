import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/settings/app_settings.dart';

/// App preferences: language, appearance, shortcuts and about.
///
/// Separated from the profile screen on purpose: profile answers "who am I
/// and what can I sell", settings answers "how does the app behave". Mixing
/// them is how the old screen grew an edit dialog, export, delete, sign-out,
/// notifications and about into one scroll with no hierarchy.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final locale = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(appThemeProvider);
    final theme = Theme.of(context);

    return PageTitle(
      title: strings.settingsTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(strings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              strings.settingsLanguageTitle,
              style: theme.textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'en',
                  label: Text(strings.settingsLanguageEn),
                ),
                ButtonSegment<String>(
                  value: 'ne',
                  label: Text(strings.settingsLanguageNe),
                ),
              ],
              selected: <String>{locale.languageCode},
              onSelectionChanged: (selection) {
                unawaited(
                  ref
                      .read(appLocaleProvider.notifier)
                      .setLocale(Locale(selection.first)),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              strings.settingsThemeTitle,
              style: theme.textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: <ButtonSegment<ThemeMode>>[
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text(strings.settingsThemeSystem),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text(strings.settingsThemeLight),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text(strings.settingsThemeDark),
                ),
              ],
              selected: <ThemeMode>{themeMode},
              onSelectionChanged: (selection) {
                unawaited(
                  ref.read(appThemeProvider.notifier).setMode(selection.first),
                );
              },
            ),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text(strings.profileKycTitle),
            subtitle: Text(strings.profileKycSubtitle),
            onTap: () => context.push('/kyc'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(strings.profileNotifTitle),
            subtitle: Text(strings.profileNotifSubtitle),
            onTap: () => context.push('/notifications'),
          ),
          const Divider(height: 16),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(strings.profileAboutTitle),
            subtitle: Text(strings.profileAboutBody),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              strings.profilePrivacyNote,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
