import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';

/// Account and seller actions.
///
/// Shows the seller entry point when signed in and a sign-in prompt when not.
/// Deliberately does not offer sign-out yet: that is HYA-202, which owns the
/// magic-link session lifecycle, and a half-wired sign-out would strand users
/// in an inconsistent auth state.
///
/// The one exception is account deletion below, which calls
/// `AuthService.signOut` after the server has removed the identity. That is
/// post-deletion local cleanup through the seam HYA-202 will wire — dropping
/// a dead session — not session lifecycle, which stays HYA-202's.
class ProfileScreen extends ConsumerWidget {
  /// Creates the profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(session?.user.email ?? 'Not signed in'),
            subtitle: session == null
                ? const Text('Sign in with a magic link to post a property')
                : const Text('Signed in'),
          ),
          const Divider(),
          if (session != null) ...<Widget>[
            ListTile(
              leading: const Icon(Icons.add_home_work_outlined),
              title: const Text('Post a property'),
              subtitle: const Text('Create a listing for review'),
              onTap: () => context.push('/post'),
            ),
            _AccountSection(userId: session.user.id),
          ] else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign in'),
              subtitle: const Text('We email you a link, no password needed'),
              onTap: () => context.push('/login'),
            ),
          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('About nBhumi'),
            subtitle: Text(
              'We facilitate listings only. Ownership transfers are '
              'completed at Malpot.',
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'nBhumi collects the minimum information needed to operate a '
              'marketplace, in line with the Privacy Act 2075 (2018).',
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

    return switch (profile) {
      AsyncLoading() => const ListTile(
          leading: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('Loading profile…'),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Edit profile'),
          subtitle: Text(
            name == null || name.isEmpty ? 'Name, phone, agency' : name,
          ),
          onTap: () => _EditProfileDialog.show(context, profile),
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Download my data'),
          subtitle: const Text('Profile, listings and reveal history as JSON'),
          onTap: () => _export(context, ref),
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Delete my account',
            style:
                TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: const Text('Permanent. Listings stay up without your name'),
          onTap: () => _confirmDelete(context, ref),
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final session = ref.read(sessionProvider);
    if (session == null) return;

    messenger.showSnackBar(
      const SnackBar(content: Text('Preparing your data…')),
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
    return AlertDialog(
      title: const Text('Edit profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
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
                labelText: 'Phone (optional)',
                hintText: '98XXXXXXXX',
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
              decoration: const InputDecoration(
                labelText: 'Agency name (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _regNo,
              decoration: const InputDecoration(
                labelText: 'Agency registration no. (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
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
        _phoneError = 'Enter a 10-digit mobile starting 97 or 98';
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
      messenger.showSnackBar(
        SnackBar(
          content: Text(savedName.isEmpty ? 'Saved' : 'Saved — $savedName'),
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
    return AlertDialog(
      title: const Text('Your data'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(child: SelectableText(json)),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy'),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: json));
            if (!context.mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard')),
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
    return AlertDialog(
      title: const Text('Delete your account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _Consequence(
            'Your profile and sign-in are removed permanently.',
          ),
          const _Consequence(
            'Your listings stay up, but without your name on them.',
          ),
          const _Consequence(
            'Your contact-reveal history is kept without your identity, '
            'as required for marketplace safety records.',
          ),
          const SizedBox(height: 8),
          Text(
            'This cannot be undone.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: onContinue,
          child: const Text('Continue'),
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
    return AlertDialog(
      title: const Text('Type DELETE to confirm'),
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
          child: const Text('Cancel'),
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
              : const Text('Delete my account'),
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
