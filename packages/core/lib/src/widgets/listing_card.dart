import 'package:flutter/material.dart';
import 'package:models/models.dart';

import '../theme/marketplace_colors.dart';
import '../utils/nepali_currency.dart';

/// Browse-feed card for a single listing.
///
/// Lives in `core` rather than in a feature because two features render it:
/// `search` and `listing_detail`. Rule 10 forbids a feature importing another
/// feature, so while the card lived in `features/listing_detail` the search
/// screen simply could not use it.
///
/// Takes [ListingSummary] rather than `Listing`: the browse RPC returns a
/// different shape from the write RPCs, and forcing one model to serve both is
/// what made the original card impossible to construct from a real response.
class ListingCard extends StatelessWidget {
  /// Creates a browse card.
  const ListingCard({required this.listing, this.onTap, super.key});

  /// The listing to render.
  final ListingSummary listing;

  /// Called when the card is tapped.
  ///
  /// Null makes the card inert. The browse grid supplies navigation; a preview
  /// inside a detail page does not.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<MarketplaceColors>();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _CoverPhoto(url: listing.photoUrl),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Rule 27: compact on a card, because the full figure
                  // `NPR 1,50,00,000` does not fit at 180dp and would push
                  // the title into truncation.
                  Text(
                    NepaliCurrency.compact(listing.priceNpr),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      _PurposeChip(purpose: listing.listingPurpose),
                      if (listing.isVerified ?? false) ...<Widget>[
                        const SizedBox(width: 6),
                        _VerifiedBadge(colors: colors),
                      ],
                    ],
                  ),
                  if (listing.areaDisplay case final area?) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(area, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cover image with a placeholder fallback.
///
/// Uses `Image.network` with `cacheWidth` rather than a caching package:
/// `cacheWidth` makes Flutter decode at roughly the display size instead of
/// full resolution, which is most of the benefit a cache library provides for a
/// grid, at no dependency cost (Rule 41).
class _CoverPhoto extends StatelessWidget {
  const _CoverPhoto({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.home, size: 48, color: theme.colorScheme.outline),
      ),
    );

    if (url == null || url!.isEmpty) return _framed(placeholder);

    return _framed(
      Image.network(
        url!,
        // Decode near display size. 400 is roughly two 180dp cards at 2x.
        cacheWidth: 400,
        fit: BoxFit.cover,
        // A broken image URL must not leave a hole in the grid.
        errorBuilder: (context, error, stackTrace) => placeholder,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
      ),
    );
  }

  Widget _framed(Widget child) =>
      SizedBox(height: 160, width: double.infinity, child: child);
}

/// Purpose chip, coloured from the design tokens rather than a hard-coded hex.
class _PurposeChip extends StatelessWidget {
  const _PurposeChip({required this.purpose});

  final ListingPurpose purpose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<MarketplaceColors>();

    // Falls back to the primary container pair when the extension is absent,
    // so a widget test or a theme without MarketplaceColors still renders.
    final fallback = (
      theme.colorScheme.primaryContainer,
      theme.colorScheme.onPrimaryContainer,
    );

    final (Color background, Color foreground) = switch (purpose) {
      ListingPurpose.sale =>
        colors == null ? fallback : (colors.saleOrange, colors.onSaleOrange),
      ListingPurpose.rent =>
        colors == null ? fallback : (colors.rentBlue, colors.onRentBlue),
      ListingPurpose.lease =>
        colors == null ? fallback : (colors.leaseTeal, colors.onLeaseTeal),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        purpose.name,
        style: theme.textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}

/// KYC-verified badge.
///
/// Deliberately does not claim KYC is legal verification: DATA.md is explicit
/// that it is a document check only.
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({required this.colors});

  final MarketplaceColors? colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        colors?.verifiedGreen ?? theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.verified, size: 14, color: foreground),
        const SizedBox(width: 2),
        Text(
          'Verified',
          style: theme.textTheme.labelSmall?.copyWith(color: foreground),
        ),
      ],
    );
  }
}
