import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/settings/app_settings.dart';

/// Account and seller actions.
///
/// Shows the seller entry point when signed in and a sign-in prompt when not.
/// Sign-out goes through `AuthService`, the same seam account deletion uses —
/// one session lifecycle owner (HYA-202), no parallel sign-out paths.
class ProfileScreen extends ConsumerWidget {
  /// Creates the profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final strings = AppLocalizations.of(context);

    return PageTitle(
      title: strings.profileTitle,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.profileTitle),
          actions: <Widget>[
            if (session != null)
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: strings.profileSettingsTitle,
                onPressed: () => context.push('/profile/settings'),
              ),
          ],
        ),
        // Capped at reading width on wide windows (DESIGN.md §4.4b).
        body: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: <Widget>[
              if (session == null)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(strings.profileSignedOut),
                  subtitle: Text(strings.profileSignedOutHint),
                )
              else
                _ProfileHeaderSection(
                  userId: session.user.id,
                  fallbackEmail: session.user.email,
                ),
              const Divider(),
              if (session != null) ...<Widget>[
                ListTile(
                  leading: const Icon(Icons.add_home_work_outlined),
                  title: Text(strings.profilePostTitle),
                  subtitle: Text(strings.profilePostSubtitle),
                  onTap: () => context.push('/post'),
                ),
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
                ListTile(
                  leading: const Icon(Icons.timeline_outlined),
                  title: Text(strings.activityTitle),
                  subtitle: Text(strings.activityEntrySubtitle),
                  onTap: () => context.push('/profile/activity'),
                ),
                _AgencySection(userId: session.user.id),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(strings.profileSettingsTitle),
                  subtitle: Text(strings.profileSettingsSubtitle),
                  onTap: () => context.push('/profile/settings'),
                ),
                _AccountSection(userId: session.user.id),
              ] else
                ListTile(
                  leading: const Icon(Icons.login),
                  title: Text(strings.commonSignIn),
                  subtitle: const Text(
                    'We email you a link, no password needed',
                  ),
                  onTap: () => context.push('/login'),
                ),
              const _AppearanceSection(),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(strings.profileAboutTitle),
                subtitle: Text(strings.profileAboutBody),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  strings.profilePrivacyNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Appearance preference: system / light / dark.
///
/// Surfaced here as well as in Settings because theme is device-level, not
/// account-level — guests never see the settings gear, but everyone sees
/// Profile. Same notifier and strings as the settings control, so the two
/// cannot disagree.
class _AppearanceSection extends ConsumerWidget {
  /// Creates the appearance section.
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final themeMode = ref.watch(appThemeProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Identity header: full name, email (auth-owned, read-only), phone.
///
/// Rendered only for a signed-in session. Email comes from the session with
/// the profile as fallback: the session owns the address, the profile row
/// mirrors it via `handle_new_user`, so the session is authoritative when
/// the two disagree.
class _ProfileHeaderSection extends ConsumerWidget {
  /// Creates the header section.
  const _ProfileHeaderSection({
    required this.userId,
    required this.fallbackEmail,
  });

  /// Profile row id (== auth user id).
  final String userId;

  /// Session email, authoritative over `profile.email`.
  final String? fallbackEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(userId: userId));
    final strings = AppLocalizations.of(context);

    return switch (profile) {
      AsyncLoading() => ListTile(
        leading: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(strings.profileLoading),
      ),
      // A missing profile must not hide identity: fall back to the session
      // email so a fresh confirmed session still sees who it is.
      AsyncError() => _ProfileHeaderCard(profile: null, email: fallbackEmail),
      AsyncData(:final value) => _ProfileHeaderCard(
        profile: value,
        email: fallbackEmail,
      ),
    };
  }
}

/// Identity card with avatar initials, contact rows and status chips.
///
/// Role, verification and KYC tier are display-only here: RLS pins them
/// server-side (`profiles_update_own`), so this card never offers to edit
/// them.
class _ProfileHeaderCard extends StatelessWidget {
  /// Creates the header card.
  const _ProfileHeaderCard({required this.profile, required this.email});

  /// Profile row, null when unloadable.
  final Profile? profile;

  /// Session email fallback.
  final String? email;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = profile?.fullName.trim() ?? '';
    final displayEmail = (email ?? profile?.email ?? '').trim();
    final phone = (profile?.phone ?? '').trim();
    final initials = name.isEmpty
        ? '?'
        : name
              .split(RegExp(r'\s+'))
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Suspension notice (HYA-301): the one state that changes what
              // this whole screen means. Rendered first so a suspended seller
              // learns it before trying to post and meeting a raw error. The
              // admin's internal reason is deliberately NOT shown: it may
              // name an ongoing investigation, and the notice is about the
              // state, not the case file.
              if (profile?.suspended ?? false)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.block_outlined,
                            size: 20,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  strings.profileSuspendedTitle,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  strings.profileSuspendedBody,
                                  style: theme.textTheme.bodyMedium?.copyWith(
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
                ),
              // WhatsApp-style entry: tapping the identity row opens the
              // same edit dialog as the Edit profile tile below.
              InkWell(
                borderRadius: AppRadius.radiusMd,
                onTap: () => _EditProfileDialog.show(context, profile),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          initials,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              name.isEmpty ? displayEmail : name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            // WhatsApp-style second line: the phone number
                            // (or its missing hint) under the name. Email
                            // stays in the contact section below so it
                            // renders exactly once on the screen.
                            Text(
                              phone.isEmpty
                                  ? strings.profileContactPhoneMissing
                                  : phone,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (profile != null && profile!.isVerified)
                        const TrustBadge(compact: true, showInfoOnTap: false),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                strings.profileContactTitle,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  const Icon(Icons.email_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(displayEmail, style: theme.textTheme.bodyMedium),
                        Text(
                          strings.profileContactEmailLocked,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Icon(Icons.phone_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: phone.isEmpty
                        ? Text(
                            strings.profileContactPhoneMissing,
                            style: theme.textTheme.bodyMedium,
                          )
                        : Text(phone, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
              if (phone.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 26),
                  child: Text(
                    strings.profileContactAddPhoneHint,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 12),
              if (profile != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    Chip(
                      label: Text(switch (profile!.role) {
                        UserRole.agent => strings.profileRoleAgent,
                        UserRole.admin => strings.profileRoleAdmin,
                        UserRole.buyer => strings.profileRoleBuyer,
                      }),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text(switch (profile!.kycTier) {
                        KycTier.account => strings.profileKycAccount,
                        KycTier.identity => strings.profileKycIdentity,
                        KycTier.property => strings.profileKycProperty,
                        KycTier.none => strings.profileKycNone,
                      }),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Agency section: optional display identity with a verification upsell.
///
/// `agencyName` / `agencyRegNo` are free text shown on listings; they prove
/// nothing on their own. The `agency_reg` KYC document
/// (`KycDocType.agencyReg`) is the proof, reviewed in `/kyc`. This card
/// states both so filling the fields is never mistaken for verification.
class _AgencySection extends ConsumerWidget {
  /// Creates the agency section.
  const _AgencySection({required this.userId});

  /// Profile row id.
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(userId: userId));

    return switch (profile) {
      AsyncLoading() => const SizedBox.shrink(),
      AsyncError() => const SizedBox.shrink(),
      AsyncData(:final value) => _AgencyCard(profile: value),
    };
  }
}

/// Agency card body.
class _AgencyCard extends StatelessWidget {
  /// Creates the agency card.
  const _AgencyCard({required this.profile});

  /// Profile row, null when unloadable.
  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final agencyName = (profile?.agencyName ?? '').trim();
    final agencyRegNo = (profile?.agencyRegNo ?? '').trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.business_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          strings.profileAgencyTitle,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          agencyName.isEmpty
                              ? strings.profileAgencySubtitle
                              : agencyName,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (agencyName.isNotEmpty)
                    Chip(
                      label: Text(strings.profileAgencyUnverifiedHint),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              if (agencyRegNo.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(agencyRegNo, style: theme.textTheme.bodySmall),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                strings.profileAgencyExplainer,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              // Editing lives in the Edit profile tile below: a second
              // same-labelled button here doubled `find.text` matches and
              // split the edit entry point for no benefit.
              FilledButton.tonal(
                onPressed: () => context.push('/kyc'),
                child: Text(strings.profileAgencyVerifyCta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Privacy Act 2075 self-service: edit profile, export data, delete account.
///
/// Rendered only for a signed-in session. Each action states what it does with
/// the user's data before doing it, because consent text buried elsewhere is
/// how these screens fail the Act's purpose-limitation requirement.
class _AccountSection extends ConsumerWidget {
  const _AccountSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(userId: userId));
    final strings = AppLocalizations.of(context);

    return switch (profile) {
      AsyncLoading() => ListTile(
        leading: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(strings.profileLoading),
      ),
      // A missing or unloadable profile must not hide the delete action: the
      // user who most needs self-service is the one whose data is broken.
      AsyncError() => const _SelfServiceTiles(profile: null),
      AsyncData(:final value) => _SelfServiceTiles(profile: value),
    };
  }
}

class _SelfServiceTiles extends ConsumerWidget {
  const _SelfServiceTiles({required this.profile});

  final Profile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    // The header card owns the name; this tile summarizes what editing
    // covers so the two never render duplicate text (widget-test `findsOne`
    // and screen-reader) output.
    final phone = profile?.phone?.trim() ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(strings.profileEditTitle),
          subtitle: Text(phone.isEmpty ? 'Name, phone, agency' : phone),
          onTap: () => _EditProfileDialog.show(context, profile),
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: Text(strings.profileDownloadTitle),
          subtitle: Text(strings.profileDownloadSubtitle),
          onTap: () => _export(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.logout_outlined),
          title: Text(strings.profileSignOutTitle),
          subtitle: Text(strings.profileSignOutSubtitle),
          onTap: () => _signOut(context, ref),
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            strings.profileDeleteTitle,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: Text(strings.profileDeleteSubtitle),
          onTap: () => _confirmDelete(context, ref),
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final session = ref.read(sessionProvider);
    final strings = AppLocalizations.of(context);
    if (session == null) return;

    messenger.showSnackBar(
      SnackBar(content: Text(strings.profilePreparingData)),
    );

    try {
      final data = await ref
          .read(userRepositoryProvider)
          .exportMyData(userId: session.user.id);
      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      await showDialog<void>(
        context: context,
        builder: (context) => _ExportDialog(
          json: const JsonEncoder.withIndent('  ').convert(data),
        ),
      );
    } on AppException catch (e) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.localizedForContext(context))));
    }
  }

  /// Signs out locally and returns to the signed-out profile state.
  ///
  /// No navigation: `/profile` is public, so the screen simply re-renders the
  /// sign-in prompt once the session is gone. Failures surface bilingually
  /// with a retry where retryable (Rule 36).
  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppLocalizations.of(context);
    try {
      await ref.read(authServiceProvider).signOut();
    } on AppException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.localizedForContext(context)),
          action: e.isRetryable
              ? SnackBarAction(
                  label: strings.commonRetry,
                  onPressed: () => _signOut(context, ref),
                )
              : null,
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => _DeleteConfirmDialog(
        // dialogContext opens nothing: it dies with the first dialog. The
        // second dialog opens from the screen's context, which outlives both.
        onContinue: () {
          Navigator.of(dialogContext).pop();
          unawaited(
            _TypeToConfirmDialog.show(
              context,
              () => _deleteAccount(context, ref),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await ref.read(userRepositoryProvider).deleteMyAccount();
    } on AppException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.localizedForContext(context))),
      );
      return;
    }

    // The server has removed the identity, so the local session is dead. Drop
    // it through the AuthService seam rather than leaving a zombie signed-in
    // state that every subsequent call rejects.
    await ref.read(authServiceProvider).signOut();
    if (!context.mounted) return;
    router.go('/login');
  }
}

/// Edit dialog for the fields a user owns.
///
/// Role, verification and KYC tier are deliberately absent: the server owns
/// those (and RLS pins them), so offering them here would imply a control the
/// caller does not have.
class _EditProfileDialog extends ConsumerStatefulWidget {
  const _EditProfileDialog({required this.profile});

  final Profile? profile;

  static Future<void> show(BuildContext context, Profile? profile) =>
      showDialog<void>(
        context: context,
        builder: (context) => _EditProfileDialog(profile: profile),
      );

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.profile?.fullName ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.profile?.phone ?? '',
  );
  late final TextEditingController _agency = TextEditingController(
    text: widget.profile?.agencyName ?? '',
  );
  late final TextEditingController _regNo = TextEditingController(
    text: widget.profile?.agencyRegNo ?? '',
  );

  String? _phoneError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _agency.dispose();
    _regNo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.profileEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: strings.profileEditName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            TextField(
              controller: _agency,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: strings.profileEditAgency,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _regNo,
              decoration: InputDecoration(
                labelText: strings.profileEditRegNo,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(strings.commonCancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(strings.commonSave),
        ),
      ],
    );
  }

  Future<void> _save() async {
    // Captured before the dialog closes: looking the messenger up afterwards
    // uses a defunct context and the confirmation never appears.
    final messenger = ScaffoldMessenger.of(context);
    // Rule 26: Nepali mobiles are 10 digits starting 97/98, stored without a
    // '+' prefix. A leading '+' is stripped rather than rejected, because
    // existing rows (and pasted E.164 numbers) carry one, and rejecting what
    // the database already holds would make the form unsavable. Validation
    // runs on the canonical form, so stored values never vary.
    final phone = Validators.canonicalNepaliPhone(_phone.text);
    if (phone.isNotEmpty && !Validators.isValidNepaliPhone(phone)) {
      setState(() {
        _phoneError = AppLocalizations.of(context).profileEditPhoneError;
      });
      return;
    }

    final session = ref.read(sessionProvider);
    final base = widget.profile;
    if (session == null || base == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _busy = true);

    try {
      final updated = await ref
          .read(userRepositoryProvider)
          .updateProfile(
            base.copyWith(
              fullName: _name.text.trim(),
              phone: phone.isEmpty ? null : phone,
              agencyName: _agency.text.trim().isEmpty
                  ? null
                  : _agency.text.trim(),
              agencyRegNo: _regNo.text.trim().isEmpty
                  ? null
                  : _regNo.text.trim(),
            ),
          );
      ref.invalidate(userProfileProvider(userId: session.user.id));
      if (!mounted) return;
      Navigator.of(context).pop();
      final savedName = updated.fullName;
      final strings = AppLocalizations.of(context);
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
}

/// Read-only view of the export, with a copy affordance.
///
/// Copy-to-clipboard rather than a file download or share sheet: it needs no
/// new dependency (Rule 39) and the JSON is small — a profile, their listings
/// and their reveal history.
class _ExportDialog extends StatelessWidget {
  const _ExportDialog({required this.json});

  final String json;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.profileExportTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(child: SelectableText(json)),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.commonClose),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.copy, size: 18),
          label: Text(strings.commonCopy),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: json));
            if (!context.mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(strings.profileCopied)));
          },
        ),
      ],
    );
  }
}

/// First of two confirmations for account deletion.
///
/// States the consequences in full sentences rather than linking elsewhere:
/// consent text the user never reads is how deletion flows fail the Act.
class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.profileDeleteConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Consequence(strings.profileDeleteC1),
          _Consequence(strings.profileDeleteC2),
          _Consequence(strings.profileDeleteC3),
          const SizedBox(height: 8),
          Text(
            strings.profileDeleteFinal,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: onContinue,
          child: Text(strings.profileDeleteContinue),
        ),
      ],
    );
  }
}

/// Second confirmation: typing DELETE.
///
/// A second tap is too cheap for something irreversible; typing the word is
/// just enough friction to catch the accidental press without punishing the
/// deliberate one.
class _TypeToConfirmDialog extends StatefulWidget {
  const _TypeToConfirmDialog({required this.onConfirmed});

  final Future<void> Function() onConfirmed;

  static Future<void> show(
    BuildContext context,
    Future<void> Function() onConfirmed,
  ) => showDialog<void>(
    context: context,
    builder: (context) => _TypeToConfirmDialog(onConfirmed: onConfirmed),
  );

  @override
  State<_TypeToConfirmDialog> createState() => _TypeToConfirmDialogState();
}

class _TypeToConfirmDialogState extends State<_TypeToConfirmDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;
  bool _match = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.profileTypeDeleteTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: strings.profileDeleteConfirmHint,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() => _match = value.trim() == 'DELETE'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(strings.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: !_match || _busy ? null : _run,
          child: _busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(strings.profileDeleteTitle),
        ),
      ],
    );
  }

  Future<void> _run() async {
    setState(() => _busy = true);
    // The dialog closes first so a success navigates cleanly; a failure shows
    // a snackbar from the caller, which owns the scaffold.
    final confirmed = widget.onConfirmed;
    if (!mounted) return;
    Navigator.of(context).pop();
    await confirmed();
  }
}

class _Consequence extends StatelessWidget {
  const _Consequence(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final resolved = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('•  ', style: resolved.textTheme.bodyMedium),
          Expanded(child: Text(text, style: resolved.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
