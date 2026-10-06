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
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(session?.user.email ?? strings.profileSignedOut),
            subtitle: session == null
                ? Text(strings.profileSignedOutHint)
                : Text(strings.profileSignedIn),
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
            _AccountSection(userId: session.user.id),
          ] else
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(strings.commonSignIn),
              subtitle: const Text('We email you a link, no password needed'),
              onTap: () => context.push('/login'),
            ),
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
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
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
    final name = profile?.fullName;
    final strings = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(strings.profileEditTitle),
          subtitle: Text(
            name == null || name.isEmpty ? 'Name, phone, agency' : name,
          ),
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
            style:
                TextStyle(color: Theme.of(context).colorScheme.error),
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
        ..showSnackBar(
          SnackBar(content: Text(e.localizedForContext(context))),
        );
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
  late final TextEditingController _name =
      TextEditingController(text: widget.profile?.fullName ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.profile?.phone ?? '');
  late final TextEditingController _agency =
      TextEditingController(text: widget.profile?.agencyName ?? '');
  late final TextEditingController _regNo =
      TextEditingController(text: widget.profile?.agencyRegNo ?? '');

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
        _phoneError =
            AppLocalizations.of(context).profileEditPhoneError;
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
      final updated = await ref.read(userRepositoryProvider).updateProfile(
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.profileCopied)),
            );
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
  ) =>
      showDialog<void>(
        context: context,
        builder: (context) =>
            _TypeToConfirmDialog(onConfirmed: onConfirmed),
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
        decoration: const InputDecoration(
          hintText: 'DELETE',
          border: OutlineInputBorder(),
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
