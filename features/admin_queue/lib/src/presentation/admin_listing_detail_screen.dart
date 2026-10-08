import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';

import '../providers/admin_queue_providers.dart';
import 'widgets/audit_trail.dart';
import 'widgets/fraud_signals_panel.dart';
import 'widgets/moderation_actions.dart';
import 'widgets/photo_gallery.dart';
import 'widgets/review_actions.dart';
import 'widgets/sla_chip.dart';
import 'widgets/spec_table.dart';

/// One listing under review: what is needed to decide, plus the decision.
///
/// ### Why KYC documents are absent
///
/// They are M3 (HYA-264), and deliberately so. There is no `kyc_documents`
/// table and no bucket, so there is nothing to show. A panel offering a "View
/// documents" button that failed would teach an admin to distrust the rest of
/// the screen. The seller card still carries `kyc_tier` and `is_verified`,
/// which
/// is the part a reviewer can act on today.
class AdminListingDetailScreen extends ConsumerWidget {
  /// Creates the detail pane for [listingId].
  ///
  /// [onBack] is the narrow layout's back action. Null in the wide layout,
  /// where
  /// there is no stack to pop.
  const AdminListingDetailScreen({
    required this.listingId,
    this.onBack,
    super.key,
  });

  /// The listing under review, from the route path or the selected row.
  final String listingId;

  /// Called by the back button, or null for the two-pane layout.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(adminListingDetailProvider(listingId));

    return Scaffold(
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back to the queue',
              ),
        title: const Text('Review listing'),
      ),
      body: switch (detail) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => _DetailLoadError(
            error: AppException.unmapped(error),
            onRetry: () =>
                ref.invalidate(adminListingDetailProvider(listingId)),
          ),
        // A null value is a *successful* load with nothing in it. The RPC
        // answers P0002 for missing, unpublished and not-yours alike, so this
        // screen cannot tell those apart and must not pretend to.
        AsyncData(value: null) => const _DetailUnavailable(),
        AsyncData(: final ListingDetail value) =>
          _DetailBody(listing: value),
      },
    );
  }
}

/// The loaded listing.
class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.listing});

  final ListingDetail listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Computed here rather than through a model getter, and against an explicit
    // clock, so this chip cannot disagree with the queue row it was opened
    // from.
    final sla = QueueSla.fromSubmittedAt(listing.submittedAt);
    final waited = listing.submittedAt == null
        ? null
        : DateTime.now().toUtc().difference(listing.submittedAt!.toUtc());

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(listing.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                _locationLine(listing),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              // Status and SLA together: "what state is this in" and "how long
              // has it been waiting" are one glance, and an admin deciding what
              // to open next needs both.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  _StatusChip(status: listing.status),
                  SlaChip(sla: sla, waited: waited),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                NepaliCurrency.compact(listing.priceNpr),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Signals ride above the photos: an admin who sees a warning
              // reads everything below it more carefully, which is the point.
              const SizedBox(height: 12),
              FraudSignalsPanel(listingId: listing.id),
              const SizedBox(height: 16),
              PhotoGallery(urls: listing.photos),
              const SizedBox(height: 16),
              SpecTable(listing: listing),
              if (listing.description case final description?
                  when description.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                Text('Seller description', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
              if (listing.rejectionReason case final reason?
                  when reason.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                _RejectionNotice(reason: reason, status: listing.status),
              ],
              const SizedBox(height: 16),
              _SellerCard(seller: listing.seller),
              const SizedBox(height: 12),
              // Suspension sits next to the identity it acts on. The listing
              // detail RPC's seller card carries no suspension state (it is
              // the buyer-facing shape), so this reads it separately.
              SellerModeration(sellerId: listing.sellerId),
              const SizedBox(height: 16),
              AuditTrailPanel(listingId: listing.id),
            ],
          ),
        ),
        // Pinned to the bottom rather than left at the end of the scroll: the
        // decision is the point of the screen and must not require scrolling
        // past a long description to reach.
        _ActionBar(listing: listing),
      ],
    );
  }

  /// "Ward 5, Kathmandu Metropolitan, Kathmandu", dropping absent parts rather
  /// than printing "null".
  static String _locationLine(ListingDetail listing) => <String?>[
        if (listing.ward case final ward? when ward.trim().isNotEmpty)
          'Ward $ward',
        listing.city,
        listing.district,
      ].whereType<String>().join(', ');
}

/// The listing's current status, as a chip.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Nullable with a fallback, as in ListingCard: a theme without
    // MarketplaceColors still renders.
    final colors = theme.extension<MarketplaceColors>();

    // Colour follows the queue tabs so a status means the same thing in both
    // places: pending is the neutral surface, live is the verified green,
    // rejected is the error colour, unpublished is the warning surface --
    // pulled, not failed, so it must not read as red.
    final (background, foreground) = switch (status) {
      ListingStatus.live => colors == null
          ? (theme.colorScheme.primary, theme.colorScheme.onPrimary)
          : (colors.verifiedGreen, colors.onVerifiedGreen),
      ListingStatus.rejected => (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
        ),
      ListingStatus.pendingReview => colors == null
          ? (
              theme.colorScheme.tertiaryContainer,
              theme.colorScheme.onTertiaryContainer,
            )
          : (colors.saleOrange, colors.onSaleOrange),
      ListingStatus.draft => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
        ),
      ListingStatus.unpublished => (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        // The wire name, not `.name`: the database and the UI must agree on the
        // spelling, and every other surface in this app shows the wire form.
        status.wireName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A rejection reason, called out rather than inline.
///
/// Reached when an admin opens a rejected listing, or a resubmission whose
/// previous reason is still on the record. The seller is waiting on this text,
/// so it is the most consequential thing on the screen after the listing
/// itself.
///
/// The heading follows the status: an unpublished listing carries its unpublish
/// reason in the same column, and calling that "Rejected" would mislabel an
/// admin pull as a failed review (HYA-262).
class _RejectionNotice extends StatelessWidget {
  const _RejectionNotice({required this.reason, required this.status});

  final String reason;
  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unpublished = status == ListingStatus.unpublished;
    final onContainer = unpublished
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onErrorContainer;

    return Card(
      color: unpublished
          ? theme.colorScheme.tertiaryContainer
          : theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              unpublished
                  ? Icons.visibility_off_outlined
                  : Icons.report_gmailerrorred_outlined,
              size: 20,
              color: onContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    unpublished ? 'Unpublished' : 'Rejected',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: onContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onContainer,
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

/// The seller card.
///
/// No phone, no email, and no "reveal" action. Contact details reach a buyer
/// only through the rate-limited `v1_contact_seller` (HYA-252); widening that
/// boundary for admin convenience would undo it, and an admin moderating a
/// listing has no need to call the seller.
class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.seller});

  final ListingSeller? seller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = seller;

    if (s == null) return const SizedBox.shrink();

    // Read here rather than reaching into the status chip's copy: the seller
    // card is a separate widget with its own build, and passing a colour down
    // would couple two things that have nothing to do with each other.
    final verifiedColor =
        theme.extension<MarketplaceColors>()?.verifiedGreen ??
            theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            CircleAvatar(child: Text(_initial(s.fullName))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          s.fullName ?? 'Unnamed seller',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (s.isVerified) ...<Widget>[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: verifiedColor,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    <String>[
                      if (s.role != null) s.role!,
                      _kycLabel(s.kycTier),
                      if (s.agencyName != null) s.agencyName!,
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  /// Wording for a KYC tier.
  ///
  /// "Checked" rather than "verified" wherever the tier describes a document: a
  /// doc-check is not a legal verification and DATA.md is explicit about not
  /// claiming one.
  static String _kycLabel(String? tier) => switch (tier) {
        'identity' => 'Citizenship checked',
        'property' => 'Property documents checked',
        'account' => 'Email confirmed',
        _ => 'Not verified',
      };

  /// First letter of [name], or a question mark when there is none.
  ///
  /// An initial rather than an avatar URL: there is no avatar column, and
  /// fetching one would mean inventing a URL that 404s.
  static String _initial(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}

/// Approve and reject, pinned to the bottom.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.listing});

  final ListingDetail listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Only a pending listing can be approved or rejected, and only a live
    // one unpublished: showing live buttons on any other status would produce
    // exactly the 22023 the RPC raises — and waste an admin's click finding
    // out. Unpublished keeps its own action (republish) for the same reason.
    final isPending = listing.status == ListingStatus.pendingReview;

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: isPending
            ? ReviewActions(listingId: listing.id)
            : listing.status == ListingStatus.live ||
                    listing.status == ListingStatus.unpublished
                ? UnpublishActions(listing: listing)
                : Row(
                    children: <Widget>[
                      Icon(
                        listing.status == ListingStatus.live
                            ? Icons.check_circle_outline
                            : Icons.block_outlined,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          listing.status == ListingStatus.live
                              ? 'This listing is live.'
                              : 'This listing is ${listing.status.wireName}.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

/// Shown when the listing cannot be loaded at all.
class _DetailLoadError extends StatelessWidget {
  const _DetailLoadError({required this.error, required this.onRetry});

  final AppException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              error.localizedForContext(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the listing is missing, unpublished, or not the admin's to see.
class _DetailUnavailable extends StatelessWidget {
  const _DetailUnavailable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.search_off,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'This listing is not available.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'It may have been removed, or another admin may have already '
              'actioned it.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
