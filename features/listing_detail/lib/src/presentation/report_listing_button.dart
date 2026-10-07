import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
import 'package:models/models.dart';

/// Flags a listing for moderation (HYA-263).
///
/// ### Why a mutation, not a read
///
/// Filing a report is not idempotent on the buyer: the unique constraint means
/// a second tap is a validation error, not a second row. Modelling it as a
/// provider read would let Riverpod's automatic retry spend attempts a buyer
/// did not mean to, and a double submission would surface as a confusing
/// "already reported" error after a momentary spinner. A stateful widget that
/// runs exactly once per tap reports no error at all unless one actually
/// happened.
///
/// ### Why the reason is a picker, not free text
///
/// `report_reason` is an enum. A free-text field would accept anything and be
/// rejected server-side, and the eight reasons a buyer might mean are known —
/// so the buyer picks the closest, and `other` carries the details field for
/// the rest.
class ReportListingButton extends ConsumerStatefulWidget {
  /// Creates the report button for [listing].
  const ReportListingButton({required this.listing, super.key});

  /// The listing being reported.
  final ListingDetail listing;

  @override
  ConsumerState<ReportListingButton> createState() =>
      _ReportListingButtonState();
}

class _ReportListingButtonState extends ConsumerState<ReportListingButton> {
  bool _busy = false;

  /// Whether a session exists.
  ///
  /// Read rather than watched so a sign-in mid-page does not rebuild this
  /// subtree; the button is re-evaluated each time it is pressed anyway.
  bool get _isSignedIn => ref.read(isSignedInProvider);

  Future<void> _report() async {
    if (_busy) return;

    if (!_isSignedIn) {
      // Guest browsing is the norm, so this is the expected path rather than an
      // error state. Sign in and return here afterwards.
      await context.push('/login');
      return;
    }

    final result = await showModalBottomSheet<_ReportDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ReportSheet(listing: widget.listing),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);

    try {
      await ref.read(listingRepositoryProvider).reportListing(
            listingId: widget.listing.id,
            reason: result.reason,
            details: result.details,
          );

      if (!mounted) return;
      final strings = detail_strings.AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.reportFiled),
        ),
      );
    } on AppException catch (e) {
      // Rule 38: repositories map before they throw, so by here the message is
      // already user-safe and bilingual.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.localizedForContext(context))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _busy
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.outlined_flag_outlined),
      tooltip: detail_strings.AppLocalizations.of(context).reportTooltip,
      onPressed: _busy ? null : _report,
    );
  }
}

/// What the sheet collected.
class _ReportDraft {
  const _ReportDraft({required this.reason, this.details});

  final ReportReason reason;
  final String? details;
}

/// The reason picker.
///
/// A bottom sheet rather than a dialog: on a phone a dialog crowds the seller
/// details the buyer is reacting to, and a sheet keeps them on screen, which is
/// the point of reporting.
class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.listing});

  final ListingDetail listing;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  ReportReason _reason = ReportReason.fakeListing;
  final TextEditingController _details = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _details.text.trim();
    final strings = detail_strings.AppLocalizations.of(context);

    // Rule 6, client side: the server refuses the same thing, but catching it
    // here means the buyer sees the complaint against the field, not as a
    // snackbar after a round trip.
    if (_reason.requiresDetails && trimmed.isEmpty) {
      setState(() {
        _error = strings.reportDetailsError;
      });
      return;
    }

    Navigator.pop(
      context,
      _ReportDraft(
        reason: _reason,
        details: trimmed.isEmpty ? null : trimmed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = detail_strings.AppLocalizations.of(context);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardInset + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            strings.reportTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ReportReason>(
            initialValue: _reason,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: strings.reportReasonLabel,
              border: const OutlineInputBorder(),
            ),
            items: <DropdownMenuItem<ReportReason>>[
              for (final reason in ReportReason.values)
                DropdownMenuItem<ReportReason>(
                  value: reason,
                  child: Text(_reasonLabel(context, reason)),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _reason = value;
                _error = null;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _details,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: _reason.requiresDetails
                  ? strings.reportDetailsRequired
                  : strings.reportDetailsOptional,
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            child: Text(strings.reportSubmit),
          ),
        ],
      ),
    );
  }

  /// Labels for the reasons, mirroring the moderation queue's wording.
  ///
  /// Kept next to the picker rather than on the enum: the label is UI, and the
  /// model package is dependency-free by design (models has no Flutter and is
  /// consumed by tooling, so wording does not belong in it).
  String _reasonLabel(BuildContext context, ReportReason reason) {
    final strings = detail_strings.AppLocalizations.of(context);
    return switch (reason) {
      ReportReason.duplicateListing => strings.reasonDuplicate,
      ReportReason.photosMisleading => strings.reasonPhotos,
      ReportReason.priceSuspicious => strings.reasonPrice,
      ReportReason.wrongLocation => strings.reasonLocation,
      ReportReason.alreadySold => strings.reasonSold,
      ReportReason.sellerAskedOffsite => strings.reasonOffsite,
      ReportReason.fakeListing => strings.reasonFake,
      ReportReason.other => strings.reasonOther,
    };
  }
}
