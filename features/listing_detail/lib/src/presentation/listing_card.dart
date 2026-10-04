import 'package:flutter/material.dart';
import 'package:models/models.dart';

/// Browse-feed card for a single listing.
///
/// Takes [ListingSummary] rather than `Listing`: the browse RPC returns a
/// different shape from the write RPCs, and forcing one model to serve both is
/// what made the original card unconstructible from a real response.
///
/// Rule 10 forbids `features/search` from importing `features/listing_detail`,
/// yet the search screen is this card's primary caller. HYA-256 moves it into
/// `packages/core`; until then only `listing_detail` may reference it.
class ListingCard extends StatelessWidget {
  /// Creates a browse card.
  const ListingCard({required this.listing, super.key});

  /// The listing to render.
  final ListingSummary listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover photo. Real image loading lands with HYA-203's lazy grid.
          Container(
            height: 160,
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Center(child: Icon(Icons.home, size: 48)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${listing.district}, ${listing.city}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  listing.areaDisplay ?? '',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'NPR ${listing.priceNpr}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  listing.listingPurpose.name,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
