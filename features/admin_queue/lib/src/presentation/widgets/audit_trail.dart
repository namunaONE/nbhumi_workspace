import 'package:admin_queue/admin_queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';

/// Admin actions on this listing, newest first (Rule 8).
///
/// ### Why a failed read renders as "History unavailable" and not an error page
///
/// The trail is evidence, not the decision. An admin who cannot load it still
/// has to be able to approve or reject, and the audit guarantee is server-side:
/// `v1_admin_approve_listing` inserts its `audit_log` row whether or not this
/// panel can display it afterwards. Blocking a moderation action on a display
/// problem would trade a cosmetic fault for a real one.
///
/// The wording distinguishes that from "nothing happened", because an admin
/// deciding whether a previous reviewer already looked must not be told there
/// is nothing when the truth is that the read failed.
class AuditTrailPanel extends ConsumerWidget {
  /// Creates the audit trail panel for [listingId].
  const AuditTrailPanel({required this.listingId, super.key});

  /// The listing whose history to show.
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trail = ref.watch(adminAuditTrailProvider(listingId));

    return switch (trail) {
      AsyncLoading() => const _AuditNote(message: 'Loading history…'),
      // The provider returns an empty list on failure, so AsyncError here means
      // something it did not anticipate. Shown plainly rather than swallowed.
      AsyncError() => const _AuditNote(message: 'History unavailable.'),
      AsyncData(value: final entries) => entries.isEmpty
          ? const _AuditNote(message: 'No admin actions yet.')
          : _AuditList(entries: entries),
    };
  }
}

/// The rendered trail.
class _AuditList extends StatelessWidget {
  const _AuditList({required this.entries});

  final List<AuditLogEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('History', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final entry in entries) _AuditRow(entry: entry),
      ],
    );
  }
}

/// One audit entry.
class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.entry});

  final AuditLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // A future admin action would carry a payload this build does not decode.
    // Rendering it by its action name rather than skipping it means the trail
    // stays complete as new actions land.
    final summary = switch (entry.action) {
      'approve' => 'Approved and published',
      'reject' => entry.reason == null
          ? 'Rejected'
          : 'Rejected — ${entry.reason}',
      _ => entry.action,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            entry.action == 'reject'
                ? Icons.block_outlined
                : Icons.check_circle_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(summary, style: theme.textTheme.bodyMedium),
                Text(
                  // The actor is a uuid with no display name reachable from
                  // here: the trail shows *that* an action was recorded, and
                  // the
                  // seller-facing rejection notice is what carries the
                  // explanation.
                  '${_when(entry.createdAt)} · admin',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A short local timestamp, or a note when the row has no time.
  static String _when(DateTime? createdAt) {
    if (createdAt == null) return 'unknown time';
    final local = createdAt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}

/// A one-line note standing in for the trail.
class _AuditNote extends StatelessWidget {
  const _AuditNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.history,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
