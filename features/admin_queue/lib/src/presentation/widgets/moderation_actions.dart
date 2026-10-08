import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';

import '../../providers/moderation_providers.dart';
import 'review_actions.dart';

/// Unpublish and republish actions for the listing under review (HYA-262).
///
/// Shown in the detail screen's action bar when the listing is live (pull it)
/// or unpublished (put it back). Pending listings keep [ReviewActions]:
/// approve/reject is the verification decision, unpublish is a moderation
/// action against something already published, and one bar doing both would
/// invite approving what should be pulled.
///
/// Neither action touches the seller's other listings. Suspending the seller
/// is the separate [SellerModeration] control below the seller card.
class UnpublishActions extends ConsumerStatefulWidget {
  /// Creates the moderation actions for [listing].
  const UnpublishActions({required this.listing, super.key});

  /// The listing under review.
  final ListingDetail listing;

  @override
  ConsumerState<UnpublishActions> createState() => _UnpublishActionsState();
}

class _UnpublishActionsState extends ConsumerState<UnpublishActions> {
  /// Whether this widget has a moderation call out.
  bool _busy = false;

  /// Pulls a live listing, asking for a reason first.
  Future<void> _unpublish() async {
    if (_busy) return;

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _ModerationReasonDialog(
        title: 'Unpublish listing',
        hint: 'The seller sees this reason, so say what must change '
            'before it can go back up.',
        submitLabel: 'Unpublish listing',
      ),
    );
    if (reason == null) return;
    if (!mounted) return;

    setState(() => _busy = true);

    try {
      final outcome = await ref
          .read(adminModerationControllerProvider.notifier)
          .unpublish(widget.listing.id, reason);
      if (!mounted) return;
      _reportOutcome(outcome, expected: ListingStatus.unpublished);
    } on AppException catch (e) {
      if (!mounted) return;
      _reportError(e, retry: _unpublish);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Returns an unpublished listing to live.
  Future<void> _republish() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final outcome = await ref
          .read(adminModerationControllerProvider.notifier)
          .republish(widget.listing.id);
      if (!mounted) return;
      _reportOutcome(outcome, expected: ListingStatus.live);
    } on AppException catch (e) {
      if (!mounted) return;
      _reportError(e, retry: _republish);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Reports what the server actually did, which is not always what was asked.
  void _reportOutcome(
    ListingModerationOutcome outcome, {
    required ListingStatus expected,
  }) {
    if (outcome.serverStatus == expected) {
      _snack(
        expected == ListingStatus.live
            ? 'Listing republished and now live.'
            : 'Listing unpublished. The seller sees the reason.',
      );
      return;
    }

    // Somebody else got there first. Saying so beats reporting a success that
    // did not happen.
    _snack(
      'This listing is already ${outcome.serverStatus.wireName}, so nothing '
      'was changed.',
    );
  }

  /// Reports a failure, with a retry when retrying could help.
  void _reportError(AppException error, {required VoidCallback retry}) {
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

    if (_busy) {
      return const SizedBox(
        height: 24,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return switch (widget.listing.status) {
      ListingStatus.live => SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _unpublish,
            icon: const Icon(Icons.visibility_off_outlined),
            label: const Text('Unpublish'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ),
      ListingStatus.unpublished => FilledButton.icon(
          onPressed: _republish,
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('Republish'),
        ),
      // Pending keeps ReviewActions; every other status has no moderation
      // action to offer. Returning nothing rather than a disabled button: a
      // greyed-out control teaches an admin to wonder what unlocks it.
      _ => const SizedBox.shrink(),
    };
  }
}

/// Suspend and unsuspend for the listing's seller (HYA-262).
///
/// Reads the seller through [adminUserProvider] rather than the detail RPC's
/// seller card, which deliberately carries no suspension state (it is the same
/// shape the buyer-facing app reads). Placed under the seller card so the
/// suspension decision sits next to the identity it acts on.
class SellerModeration extends ConsumerWidget {
  /// Creates the suspension control for [sellerId].
  const SellerModeration({required this.sellerId, super.key});

  /// The seller to moderate.
  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(adminUserProvider(sellerId));

    return switch (user) {
      AsyncLoading() => const SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      AsyncError(:final error) => _ModerationLoadError(
          error: AppException.unmapped(error),
          onRetry: () => ref.invalidate(adminUserProvider(sellerId)),
        ),
      AsyncData(:final AdminUser value) => value.suspended
          ? _SuspendedNotice(user: value)
          : _SuspendAction(user: value),
    };
  }
}

/// A suspended account, with the reason and the way back.
class _SuspendedNotice extends ConsumerStatefulWidget {
  const _SuspendedNotice({required this.user});

  final AdminUser user;

  @override
  ConsumerState<_SuspendedNotice> createState() => _SuspendedNoticeState();
}

class _SuspendedNoticeState extends ConsumerState<_SuspendedNotice> {
  bool _busy = false;

  Future<void> _unsuspend() async {
    if (_busy) return;
    setState(() => _busy = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(adminModerationControllerProvider.notifier)
          .unsuspendUser(widget.user.id);
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Suspension lifted.')),
        );
    } on AppException catch (e) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(e.localizedForContext(context))),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.block_outlined,
                  size: 18,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Account suspended',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (widget.user.suspendedReason case final reason?
                when reason.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                reason,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : _unsuspend,
                child: const Text('Lift suspension'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The suspend affordance for an account in good standing.
class _SuspendAction extends ConsumerStatefulWidget {
  const _SuspendAction({required this.user});

  final AdminUser user;

  @override
  ConsumerState<_SuspendAction> createState() => _SuspendActionState();
}

class _SuspendActionState extends ConsumerState<_SuspendAction> {
  bool _busy = false;

  Future<void> _suspend() async {
    if (_busy) return;

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _ModerationReasonDialog(
        title: 'Suspend seller',
        hint: 'Suspended sellers cannot post or edit listings. Their live '
            'listings stay live until each is unpublished separately.',
        submitLabel: 'Suspend seller',
      ),
    );
    if (reason == null) return;
    if (!mounted) return;

    setState(() => _busy = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(adminModerationControllerProvider.notifier)
          .suspendUser(widget.user.id, reason);
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Seller suspended.')),
        );
    } on AppException catch (e) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.localizedForContext(context)),
            action: e.isRetryable
                ? SnackBarAction(label: 'Retry', onPressed: _suspend)
                : null,
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _busy ? null : _suspend,
        icon: const Icon(Icons.person_off_outlined),
        label: const Text('Suspend seller'),
      ),
    );
  }
}

/// Shown when the seller lookup itself fails.
class _ModerationLoadError extends StatelessWidget {
  const _ModerationLoadError({required this.error, required this.onRetry});

  final AppException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            error.localizedForContext(context),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

/// Collects a moderation reason.
///
/// Will not submit until the text is non-blank. Validated here as well as in
/// the repository (Rule 6): the suspend and unpublish RPCs both refuse blank
/// reasons with 22023, and the admin should hear that before a round trip.
class _ModerationReasonDialog extends StatefulWidget {
  const _ModerationReasonDialog({
    required this.title,
    required this.hint,
    required this.submitLabel,
  });

  final String title;
  final String hint;
  final String submitLabel;

  @override
  State<_ModerationReasonDialog> createState() =>
      _ModerationReasonDialogState();
}

class _ModerationReasonDialogState extends State<_ModerationReasonDialog> {
  final TextEditingController _controller = TextEditingController();

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
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.hint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
