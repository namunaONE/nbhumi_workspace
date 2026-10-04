import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';

/// The loaded contents of a listing detail page.
///
/// Split from `ListingDetailScreen` so it is a plain widget over a finished
/// model: the screen owns loading and error states, this owns presentation. It
/// also means the whole layout can be pumped in a test without a provider, a
/// repository or a network.
class ListingDetailBody extends StatelessWidget {
  /// Creates the detail body.
  const ListingDetailBody({required this.listing, super.key});

  /// The listing to render.
  final ListingDetail listing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listing.title, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        children: <Widget>[
          _PhotoHero(photos: listing.photos, title: listing.title),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  listing.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                // Rule 27: the full figure, not the compact card form. On a
                // detail page the exact price is the point, and there is room.
                Text(
                  NepaliCurrency.full(listing.priceNpr),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _Chip(
                      label: _humanise(listing.listingPurpose.name),
                      colors: _purposeColors(
                        context,
                        listing.listingPurpose,
                      ),
                    ),
                    _Chip(
                      label: _humanise(
                        listing.propertyType.name,
                      ),
                    ),
                    // Rule 25: the seller's own units, pre-formatted
                    // server-side so cards, search and detail cannot disagree.
                    if (listing.areaDisplay case final area?)
                      _Chip(label: area),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          _Section(
            title: 'Location',
            children: <Widget>[
              _Spec(
                icon: Icons.place_outlined,
                label: listing.ward == null
                    ? '${listing.district}, ${listing.city}'
                    : '${listing.city}, Ward ${listing.ward}',
                detail: listing.district,
              ),
              if (listing.roadAccessFt case final feet?)
                _Spec(
                  icon: Icons.alt_route,
                  label: '$feet ft road access',
                ),
            ],
          ),
          if ((listing.description ?? '').trim().isNotEmpty) ...<Widget>[
            const Divider(height: 32),
            _Section(
              title: 'Description',
              children: <Widget>[
                Text(
                  listing.description!.trim(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          const Divider(height: 32),
          _Section(
            title: 'Seller',
            children: <Widget>[_SellerCard(seller: listing.seller)],
          ),
          const SizedBox(height: 96),
        ],
      ),
      bottomNavigationBar: const _ContactBar(),
    );
  }

  /// `house` -> `House`. Enum values are snake_case; UI copy is not.
  static String _humanise(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

/// Purpose-tinted chips, matching the browse card so a purpose reads the same
/// colour everywhere in the app.
({Color background, Color foreground})? _purposeColors(
  BuildContext context,
  ListingPurpose purpose,
) {
  final colors = Theme.of(context).extension<MarketplaceColors>();
  if (colors == null) return null;

  return switch (purpose) {
    ListingPurpose.sale => (
        background: colors.saleOrange,
        foreground: colors.onSaleOrange,
      ),
    ListingPurpose.rent => (
        background: colors.rentBlue,
        foreground: colors.onRentBlue,
      ),
    ListingPurpose.lease => (
        background: colors.leaseTeal,
        foreground: colors.onLeaseTeal,
      ),
  };
}

/// Swipeable photo strip.
///
/// A `PageView` rather than a fixed hero because sellers upload up to ten
/// photos and a single image would hide the rest. Falls back to a placeholder
/// when a listing has none, so the layout does not collapse.
class _PhotoHero extends StatelessWidget {
  const _PhotoHero({required this.photos, required this.title});

  final List<String> photos;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.home, size: 64, color: theme.colorScheme.outline),
      ),
    );

    if (photos.isEmpty) {
      return SizedBox(height: 220, width: double.infinity, child: placeholder);
    }

    return SizedBox(
      height: 260,
      child: PageView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) => Image.network(
          photos[index],
          // Decode near display size rather than at camera resolution.
          cacheWidth: 1000,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => placeholder,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : placeholder,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.icon, required this.label, this.detail});

  final IconData icon;
  final String label;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: theme.colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: theme.textTheme.bodyMedium),
                if (detail case final extra?)
                  Text(
                    extra,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.colors});

  final String label;
  final ({Color background, Color foreground})? colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pair = colors ??
        (
          background: theme.colorScheme.surfaceContainerHighest,
          foreground: theme.colorScheme.onSurfaceVariant,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: pair.foreground,
        ),
      ),
    );
  }
}

/// Seller identity, deliberately without contact details.
///
/// DATA.md is explicit that a public browse response must not carry a
/// seller's phone or email. Releasing them is `v1_contact_seller`'s job, and it
/// needs an authenticated buyer plus rate limiting (HYA-252). Showing a phone
/// number here would bypass both.
class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.seller});

  final ListingSeller? seller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<MarketplaceColors>();
    final name = seller?.fullName;

    if (seller == null || (name == null || name.isEmpty)) {
      // The RPC always returns a seller object, but a profile with no name set
      // must not render an empty heading.
      return Text(
        'Seller details unavailable',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.outline),
      );
    }

    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            name.characters.first.toUpperCase(),
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      name,
                      style: theme.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (seller!.isVerified) ...<Widget>[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: colors?.verifiedGreen ?? theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
              if (seller!.agencyName case final agency?)
                Text(
                  agency,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sticky bottom bar holding the contact action.
///
/// The action is inert in M1: `v1_contact_seller` does not exist yet (HYA-252),
/// so there is nothing honest to call. Rather than ship a button that silently
/// does nothing, or a fake phone number, it states what is missing.
class _ContactBar extends StatelessWidget {
  const _ContactBar();

  @override
  Widget build(BuildContext context) {
    final isNepali = Localizations.maybeLocaleOf(context)?.languageCode != 'en';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          // Explicitly disabled with an explanation, not a no-op tap handler.
          onPressed: null,
          icon: const Icon(Icons.phone_outlined),
          label: Text(
            isNepali
                ? 'विक्रेता सम्पर्क (छिट्टै आउँदैछ)'
                : 'Contact seller (coming soon)',
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ),
    );
  }
}
