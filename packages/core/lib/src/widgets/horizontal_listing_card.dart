import 'package:flutter/material.dart';
import 'package:models/models.dart';

import '../theme/app_tokens.dart';
import '../theme/marketplace_colors.dart';
import '../utils/nepali_currency.dart';
import 'app_image.dart';
import 'focusable_card.dart';
import 'listing_card.dart';
import 'status_chip.dart';
import 'trust_badge.dart';

/// Dense horizontal row card: fixed thumbnail at the side, text at the right.
///
/// Same data contract as [ListingCard] packed into an [AppSizes]
/// fixed-height row: title, merged location line, compact price, type chip,
/// and verified badge. Used by list layouts and the saved shelf where
/// vertical cards would waste a full grid row per listing.
class HorizontalListingCard extends StatelessWidget {
  /// Creates a horizontal row card.
  const HorizontalListingCard({required this.listing, this.onTap, super.key});

  /// The listing to render.
  final ListingSummary listing;

  /// Called when the card is tapped.
  ///
  /// Null makes the card inert. Callers supply navigation; a preview inside
  /// a detail page does not.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<MarketplaceColors>();
    final isVerified = listing.isVerified ?? false;
    // Area merges into the location line rather than taking its own row:
    // one ellipsis line covers district, city, and the seller's own units.
    final area = listing.areaDisplay;
    final locationLine = area == null
        ? '${listing.district}, ${listing.city}'
        : '${listing.district}, ${listing.city} · $area';

    return FocusableCard(
      onTap: onTap,
      child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        // Desktop affordance (DESIGN.md §6.5): clickable rows show the
        // click cursor on hover; inert rows keep the basic arrow.
        mouseCursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: SizedBox(
          height: AppSizes.horizontalCardHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: AppSizes.horizontalThumbWidth,
                height: AppSizes.horizontalCardHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    AppImage(
                      url: listing.photoUrl,
                      semanticLabel: listing.title,
                    ),
                    Positioned(
                      left: AppSpacing.xs,
                      top: AppSpacing.xs,
                      child: StatusChip.purpose(
                        listing.listingPurpose,
                        colors: colors,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        listing.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        locationLine,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        // Rule 27: compact on a card, because the full figure
                        // does not fit beside the thumbnail.
                        NepaliCurrency.compact(listing.priceNpr),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: <Widget>[
                          // Neutral type chip: purpose already rides on the
                          // photo overlay, so the row names the property
                          // type instead of repeating it.
                          StatusChip(
                            label: ListingCard.typeLabel(
                              listing.propertyType,
                            ),
                            dense: true,
                          ),
                          if (isVerified) ...<Widget>[
                            const SizedBox(width: AppSpacing.xs),
                            // Non-interactive inside the card: the card
                            // itself handles taps for navigation.
                            const TrustBadge(
                              compact: true,
                              showInfoOnTap: false,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
