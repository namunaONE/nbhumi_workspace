import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
import 'package:models/models.dart';

/// Reveals the seller's phone number for this listing.
///
/// ### Why this is a mutation, not a read
///
/// Fetching a contact is not idempotent: every first-time reveal is counted
/// against a ten-per-day cap and written to an audit log. Modelling it as a
/// plain provider read would let Riverpod's automatic retry spend several of
/// those ten on a single tap, which the server would then refuse. A `Mutation`
/// runs exactly once per invocation, so one tap costs at most one reveal.
///
/// ### Why the seller card shows nothing
///
/// Until this button is pressed there is no phone number anywhere in the widget
/// tree. A guest — or any signed-in user who has not spent a reveal — cannot
/// read it off the screen or out of the detail response.
class ContactSellerButton extends ConsumerStatefulWidget {
  /// Creates the contact button for [listing].
  const ContactSellerButton({required this.listing, super.key});

  /// The listing whose seller should be contacted.
  final ListingDetail listing;

  @override
  ConsumerState<ContactSellerButton> createState() =>
      _ContactSellerButtonState();
}

class _ContactSellerButtonState extends ConsumerState<ContactSellerButton> {
  SellerContact? _contact;
  bool _busy = false;
  AppException? _error;

  /// Whether a session exists.
  ///
  /// Read rather than watched so a sign-in mid-page does not rebuild this
  /// subtree; the button is re-evaluated each time it is pressed anyway.
  bool get _isSignedIn => ref.read(isSignedInProvider);

  Future<void> _reveal() async {
    if (_busy) return;

    if (!_isSignedIn) {
      // Guest browsing is the norm, so this is the expected path rather than an
      // error state. Sign in and return here afterwards.
      await context.push('/login');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final contact = await ref
          .read(listingRepositoryProvider)
          .contactSeller(widget.listing.id);

      if (!mounted) return;
      setState(() {
        _contact = contact;
        _busy = false;
      });
    } on AppException catch (e) {
      // Rule 38: repositories map before they throw, so by here the message is
      // already user-safe and bilingual.
      if (!mounted) return;
      setState(() {
        _error = e;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = detail_strings.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final contact = _contact;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (contact != null) ...<Widget>[
              _ContactCard(contact: contact),
              const SizedBox(height: 12),
            ],
            if (_error case final error?) ...<Widget>[
              Text(
                error.localizedForContext(context),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: _busy ? null : _reveal,
              icon: _busy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.phone_outlined),
              label: Text(
                switch ((_busy, contact, _isSignedIn)) {
                  (true, _, _) => strings.contactLoading,
                  (false, _, false) => strings.contactSignIn,
                  // Re-offered rather than hidden: the reveal may have expired
                  // server-side, and a user who has hit the daily cap needs
                  // to see that it is still there rather than wonder where
                  // it went.
                  (false, _, true) => strings.contactSeller,
                },
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The revealed contact, with a copy-to-clipboard affordance.
///
/// Tapping to copy rather than launching the dialler directly: the phone
/// number is rendered as selectable text so a user can also long-press it, and
/// some Nepali numbers are landlines that a dialler prompt handles badly.
class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact});

  final SellerContact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = detail_strings.AppLocalizations.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (contact.sellerPhone case final phone? when phone.isNotEmpty)
              _CopyRow(
                icon: Icons.phone,
                value: phone,
                label: strings.contactPhone,
              ),
            if (contact.sellerEmail case final email? when email.isNotEmpty)
              _CopyRow(
                icon: Icons.email_outlined,
                value: email,
                label: strings.contactEmail,
              ),
            if (contact.agencyName case final agency? when agency.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.business,
                      size: 18,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        agency,
                        style: theme.textTheme.bodyMedium,
                      ),
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

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
                SelectableText(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: detail_strings.AppLocalizations.of(context).contactCopy,
            onPressed: () async {
              final strings =
                  detail_strings.AppLocalizations.of(context);
              await Clipboard.setData(ClipboardData(text: value));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.contactCopied(label)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
