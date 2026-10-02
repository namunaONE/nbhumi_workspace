import 'package:flutter/material.dart';
import 'package:models/models.dart';

/// Listing card widget.
///
/// Shows photo, title, location, price, and purpose chip.
class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo placeholder
          Container(
            height: 160,
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Center(
              child: Icon(Icons.home, size: 48),
            ),
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
                  'NPR ${listing.priceNpr}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
