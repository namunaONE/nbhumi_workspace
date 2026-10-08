import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';

import '../../providers/admin_queue_providers.dart';
import '../../providers/admin_review_controller.dart';

/// Approve and reject actions for the listing under review.
///
/// Approve is one tap. Reject opens a dialog that will not submit until a
/// reason
/// is given, because the RPC refuses a blank one and because a seller told
/// "rejected" with no explanation cannot fix anything and will resubmit
/// unchanged.
///
/// ### Why the busy flag is local state
///
/// A busy flag does not belong in shared state: it is about *this* button, and
/// two open panes disabling each other's buttons would be a worse bug than a
/// missed spinner. The controller holds the authoritative guard, keyed by
/// listing id, so this flag only has to stop a double tap on the same widget.
///
/// ### Why the outcome is read, not assumed
///
/// [ReviewOutcome] carries the status the *server* reported. An approve can
/// land on a listing another admin has already moved, and reporting "approved"
/// unconditionally would tell the admin something false. The report path checks
/// what came back and says so plainly.
class ReviewActions extends ConsumerStatefulWidget {
  /// Creates the action bar for [listingId].
  const ReviewActions({required this.listingId, super.key});

  /// The listing being reviewed.
  final String listingId;

  @override
  ConsumerState<ReviewActions> createState() => _ReviewActionsState();
}

class _ReviewActionsState extends ConsumerState<ReviewActions> {
  /// Whether this widget has a decision out.
  bool _busy = false;

  /// Approves the listing.
  Future<void> _approve() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final outcome = await ref
          .read(adminReviewControllerProvider.notifier)
          .approve(widget.listingId);
      if (!mounted) return;
      _report(outcome);
    } on AppException catch (e) {
      if (!mounted) return;
      _reportError(e, retry: _approve);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Rejects the listing, asking for a reason first.
  Future<void> _reject() async {
    if (_busy) return;

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _RejectDialog(),
    );
    if (reason == null) return;
    if (!mounted) return;

    setState(() => _busy = true);

    try {
      final outcome = await ref
          .read(adminReviewControllerProvider.notifier)
          .reject(widget.listingId, reason);
      if (!mounted) return;
      _report(outcome);
    } on AppException catch (e) {
      if (!mounted) return;
      _reportError(e, retry: _reject);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Reports what the server actually did, which is not always what was asked.
  void _report(ReviewOutcome outcome) {
    final expected = outcome.decision == ReviewDecision.approve
        ? ListingStatus.live
        : ListingStatus.rejected;

    if (outcome.serverStatus == expected) {
      _snack(
        outcome.decision == ReviewDecision.approve
            ? 'Listing approved and now live.'
            : 'Listing rejected. The seller can fix it and resubmit.',
      );
      return;
    }

    // Somebody else got there first, or the state machine moved it elsewhere.
    // Saying so beats reporting a success that did not happen.
    _snack(
      'This listing is already ${outcome.serverStatus.wireName}, so nothing '
      'was changed.',
    );
  }

  /// Reports a failure, with a retry when retrying could help.
  ///
  /// A retry action is offered only when [AppException.isRetryable] says so.
  /// Putting one on a validation failure would invite an admin to retry a
  /// request that will fail identically.
  void _reportError(AppException error, {required VoidCallback retry}) {
    // One cascade for the whole interaction. Hiding first is not cosmetic: a
    // stale confirmation left on screen under a new error is how an admin ends
    // up believing both.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error.localizedForContext(context)),
          action: error.isRetryable
              ? SnackBarAction(label: 'Retry', onPressed: retry)
              : null,
        ),
      );
  }

  /// Shows a confirmation.
  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _reject,
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _busy ? null : _approve,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Approve'),
          ),
        ),
      ],
    );
  }
}

/// Collects a rejection reason.
///
/// Will not submit until the text is non-blank. Validated here as well as in
/// `SupabaseAdminRepository` (Rule 6), so the admin is told immediately rather
/// than after a round trip.
class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final TextEditingController _controller = TextEditingController();

  /// Canned reasons, offered as chips.
  ///
  /// Typing a clear reason is the single highest-leverage thing an admin does
  /// here: it is the only part of the rejection the seller actually sees, and a
  /// vague one produces a resubmission that fails for the same reason. These
  /// cover the recurring cases without pre-judging the listing — a suggestion
  /// is
  /// a starting point, and the admin can always rewrite it.
  static const List<String> _suggestions = <String>[
    'Photos do not show the property clearly.',
    'Price looks incorrect. Please check the figure.',
    'Location or ward is missing or wrong.',
    'Description is too short to judge the property.',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = _controller.text.trim().isNotEmpty;

    return AlertDialog(
      title: const Text('Reject listing'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'The seller sees this reason, so be specific about what to fix.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                for (final suggestion in _suggestions)
                  ActionChip(
                    label: Text(suggestion),
                    onPressed: () => setState(
                      () => _controller.text = suggestion,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              minLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              // Rebuilds on every keystroke so the submit button tracks
              // validity. Cheap here: one setState over a dialog subtree.
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: canSubmit
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: const Text('Reject listing'),
        ),
      ],
    );
  }
}
