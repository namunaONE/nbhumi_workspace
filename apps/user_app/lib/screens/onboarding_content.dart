import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
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

/// Profile-completion step, shown only to fresh signups with a session.
///
/// Guests and returning installs see nothing: the seen-gate is per-install
/// while signup is per-account, so only a fresh session proves a brand-new
/// account. Saving is best-effort and never blocks Browse — the legal
/// disclaimer and entry matter more than a display name, which Profile can
/// edit later.
class OnboardingProfileSection extends ConsumerWidget {
  /// Creates the profile section.
  const OnboardingProfileSection({required this.strings, super.key});

  /// Localized strings.
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(freshSignupProvider)) return const SizedBox.shrink();
    if (ref.watch(sessionProvider) == null) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _OnboardingProfileForm(strings: strings),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

/// Name + phone form for a brand-new account.
///
/// Mirrors the profile edit dialog's save path (canonical phone, RLS-pinned
/// server fields untouched) without its dialog chrome.
class _OnboardingProfileForm extends ConsumerStatefulWidget {
  /// Creates the profile form.
  const _OnboardingProfileForm({required this.strings});

  /// Localized strings.
  final AppLocalizations strings;

  @override
  ConsumerState<_OnboardingProfileForm> createState() =>
      _OnboardingProfileFormState();
}

class _OnboardingProfileFormState
    extends ConsumerState<_OnboardingProfileForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  String? _nameError;
  String? _phoneError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final strings = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = strings.onboardingProfileNameError);
      return;
    }
    // Rule 26: Nepali mobiles are 10 digits starting 97/98. A leading '+'
    // is stripped rather than rejected (pasted E.164 numbers); validation
    // runs on the canonical form, so stored values never vary.
    final phone = Validators.canonicalNepaliPhone(_phone.text);
    if (phone.isNotEmpty && !Validators.isValidNepaliPhone(phone)) {
      setState(() => _phoneError = strings.profileEditPhoneError);
      return;
    }

    final session = ref.read(sessionProvider);
    if (session == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      final base = await ref
          .read(userRepositoryProvider)
          .getUserById(session.user.id);
      // handle_new_user mirrors a profile row on signup, so base is
      // normally present; the skeleton keeps a missing row savable rather
      // than dead-ending onboarding.
      final effective = (base ??
              Profile(
                id: session.user.id,
                email: session.user.email ?? '',
                fullName: name,
              ))
          .copyWith(
        fullName: name,
        phone: phone.isEmpty ? null : phone,
      );
      final updated =
          await ref.read(userRepositoryProvider).updateProfile(effective);
      ref.invalidate(userProfileProvider(userId: session.user.id));
      if (!mounted) return;
      setState(() => _busy = false);
      final savedName = updated.fullName;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            savedName.isEmpty
                ? strings.profileSaved
                : strings.profileSavedAs(savedName),
          ),
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(content: Text(e.localizedForContext(context))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.onboardingProfileTitle,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              strings.onboardingProfileSubtitle,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: strings.profileEditName,
                border: const OutlineInputBorder(),
                errorText: _nameError,
              ),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: strings.profileEditPhone,
                hintText: strings.profileEditPhoneHint,
                border: const OutlineInputBorder(),
                errorText: _phoneError,
              ),
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryCTA(
              label: strings.commonSave,
              isLoading: _busy,
              onPressed: _busy ? null : _save,
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
