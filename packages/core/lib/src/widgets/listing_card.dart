import 'package:flutter/material.dart';
import 'package:models/models.dart';

import '../theme/app_tokens.dart';
import '../theme/marketplace_colors.dart';
import '../utils/nepali_currency.dart';

import 'app_image.dart';
import 'focusable_card.dart';
import 'status_chip.dart';
import 'trust_badge.dart';

/// Browse-feed card for a single property listing.
///
/// Lives in `core` rather than in a feature because two features render it:
/// `search` and `listing_detail`. Rule 10 forbids a feature importing another
/// feature.
///
/// Takes [ListingSummary] rather than `Listing`: the browse RPC returns a
/// different shape from the write RPCs, and forcing one model to serve both is
/// what made the original card impossible to construct from a real response.
///
/// Visual system: 4:3 cover via [AppImage] with shimmer and failure states,
/// purpose chip top-left and verified badge top-right overlaid on the photo,
/// then a compact price/location/title hierarchy below. The purpose chip
/// lives only on the photo — repeating it in the body cost a full row per
/// card. Property type renders as a neutral chip next to the verified badge,
/// and area merges into the location line rather than taking its own row.
class ListingCard extends StatelessWidget {
  /// Creates a browse card.
  const ListingCard({
    required this.listing,
    this.onTap,
    this.compact = false,
    super.key,
  });

  /// The listing to render.
  final ListingSummary listing;

  /// Called when the card is tapped.
  ///
  /// Null makes the card inert. The browse grid supplies navigation; a preview
  /// inside a detail page does not.
  final VoidCallback? onTap;

  /// Compact density for narrow grid columns.
  ///
  /// The browse grid sets this when the per-card width drops below the
  /// comfortable threshold, tightening padding and type so narrow cards stay
  /// legible across phone, tablet, and expanded breakpoints.
  final bool compact;

  /// Human-readable property type label.
  ///
  /// Humanised here rather than localized: `core` cannot import feature
  /// localizations (Rule 10), and the purpose chips alongside it already use
  /// English enum names. Detail pages keep the fully localized label.
  static String typeLabel(PropertyType type) =>
      '${type.name[0].toUpperCase()}${type.name.substring(1)}';

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
        // Desktop affordance (DESIGN.md §6.5): a clickable card shows the
        // click cursor on hover; an inert preview keeps the basic arrow.
        // Explicit rather than the adaptive default so widget tests pin
        // the behavior on every host platform.
        mouseCursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: AppImage(
                    url: listing.photoUrl,
                    semanticLabel: listing.title,
                  ),
                ),
                Positioned(
                  left: AppSpacing.sm,
                  top: AppSpacing.sm,
                  child: StatusChip.purpose(
                    listing.listingPurpose,
                    colors: colors,
                    dense: true,
                  ),
                ),
                if (isVerified)
                  const Positioned(
                    right: AppSpacing.sm,
                    top: AppSpacing.sm,
                    child: TrustBadge(
                      compact: true,
                      showInfoOnTap: false,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(
                compact ? AppSpacing.sm : AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    listing.title,
                    style: (compact
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          locationLine,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Rule 27: compact on a card, because the full figure
                  // `NPR 1,50,00,000` does not fit at 180dp and would push
                  // the title into truncation.
                  Text(
                    NepaliCurrency.compact(listing.priceNpr),
                    style: (compact
                            ? theme.textTheme.titleMedium
                            : theme.textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: <Widget>[
                      // Neutral type chip: purpose already rides on the photo
                      // overlay, so the body row names the property type
                      // instead of repeating it.
                      StatusChip(
                        label: typeLabel(listing.propertyType),
                        dense: true,
                      ),
                      if (isVerified) ...<Widget>[
                        const SizedBox(width: AppSpacing.xs),
                        // Non-interactive inside the card: the card itself
                        // handles taps for navigation, so the badge must not
                        // open a dialog here. Detail pages keep it tappable.
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
          ],
        ),
      ),
    ),
    );
  }
}
