import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';

import 'sla_chip.dart';

/// One listing in the queue list.
///
/// Shows what an admin needs to triage without opening it: the cover photo, the
/// title and location, the price, the seller, how long it has waited, and
/// anything that should make the admin suspicious before they click.
///
/// ### Why the warnings are on the row
///
/// A reviewer opens a detail pane to decide, and every second spent scanning a
/// list is a second not spent on the decision. Two things are surfaced here
/// rather than inside the pane:
///
/// * the SLA, which determines the work order
/// * a photo count below the wizard's floor, the single most common reason a
///   listing gets rejected
///
/// Anything subtler than that belongs in the detail pane.
class QueueRow extends StatelessWidget {
  /// Creates a row for [entry].
  const QueueRow({
    required this.entry,
    required this.selected,
    required this.onTap,
    required this.asOf,
    super.key,
  });

  /// The listing this row represents.
  final AdminQueueEntry entry;

  /// Whether this row is the one open in the detail pane.
  final bool selected;

  /// Called when the admin selects this row.
  final VoidCallback onTap;

  /// The instant every row in this list is judged against.
  ///
  /// Passed in rather than read from the clock, so the chips across a list
  /// cannot disagree with each other mid-frame.
  final DateTime asOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sla = QueueSla.fromSubmittedAt(entry.submittedAt, now: asOf);
    final waited = entry.submittedAt == null
        ? null
        : asOf.toUtc().difference(entry.submittedAt!.toUtc());

    return Material(
      // A selected row reads as selected by more than colour alone: it also
      // gets a thicker leading edge, so the state survives a monochrome theme
      // and is legible to a colour-blind reviewer.
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _CoverPhoto(url: entry.photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.district}, ${entry.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        SlaChip(sla: sla, waited: waited),
                        _PriceLabel(priceNpr: entry.priceNpr),
                        if (entry.isUnderPhotoMinimum)
                          _PhotoWarning(count: entry.photoCount),
                        if (entry.seller.isVerified)
                          _VerifiedBadge(seller: entry.seller),
                      ],
                    ),
                    if (entry.rejectionReason case final reason?
                        when reason.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      // A resubmission carries the previous reason, and the
                      // reviewer needs to know whether the seller addressed it.
                      _PreviousReason(reason: reason),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cover photo, or a placeholder when the listing has none.
class _CoverPhoto extends StatelessWidget {
  const _CoverPhoto({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.square(
        dimension: 64,
        child: url == null
            ? ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.photo_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                // A broken or slow photo must not take the row down with it:
                // the admin still has to review the listing.
                errorBuilder: (_, _, _) => ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
      ),
    );
  }
}

/// Price in Nepali lakh/crore grouping (Rule 27).
class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.priceNpr});

  final int priceNpr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      NepaliCurrency.compact(priceNpr),
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Warning that a listing has fewer photos than the wizard asks for.
class _PhotoWarning extends StatelessWidget {
  const _PhotoWarning({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: 'Only $count photos. The wizard asks for at least '
          '$minPhotosPerListing.',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.photo_library_outlined,
            size: 14,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 2),
          Text(
            '$count photos',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// KYC-verified marker for the seller.
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({required this.seller});

  final QueueSeller seller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MarketplaceColors>();

    // Deliberately does not claim legal verification: DATA.md is explicit that
    // this is a document check only.
    final tooltip = switch (seller.kycTier) {
      'identity' => 'Citizenship document checked',
      'property' => 'Property documents checked',
      _ => 'Account verified',
    };

    return Tooltip(
      message: tooltip,
      child: Icon(
        Icons.verified,
        size: 16,
        // Falls back to the theme's primary, so a theme without
        // MarketplaceColors still renders. See ListingCard for the same
        // treatment.
        color: colors?.verifiedGreen ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// The reason a previous submission was rejected.
class _PreviousReason extends StatelessWidget {
  const _PreviousReason({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.history,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Previously rejected: $reason',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
