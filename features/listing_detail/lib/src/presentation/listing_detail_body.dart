import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
import 'package:models/models.dart';

import 'contact_seller_button.dart';
import 'report_listing_button.dart';

/// The loaded contents of a listing detail page.
///
/// Split from `ListingDetailScreen` so it is a plain widget over a finished
/// model: the screen owns loading and error states, this owns presentation. It
/// also means the whole layout can be pumped in a test without a provider, a
/// repository or a network.
class ListingDetailBody extends StatelessWidget {
  /// Creates the detail body.
  const ListingDetailBody({
    required this.listing,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.verificationSlot = const SizedBox.shrink(),
    this.leading,
    super.key,
  });

  /// The listing to render.
  final ListingDetail listing;

  /// Whether the viewer bookmarked this listing.
  ///
  /// Read from `favoriteIdsProvider` by the screen, never from the
  /// `is_favorite` wire field (hardcoded false until HYA-268 C2). Defaults
  /// to false so provider-free tests keep pumping this directly.
  final bool isFavorite;

  /// Called when the viewer taps the heart. Null hides the button: guests
  /// cannot save, so the screen passes null without a session rather than a
  /// button that only ever errors.
  final VoidCallback? onFavoriteToggle;

  /// Tier-3 verification badge or owner entry, supplied by the pane.
  ///
  /// Defaults to nothing so provider-free tests keep pumping this directly:
  /// the pane owns provider reads and passes the resolved widget in.
  final Widget verificationSlot;

  /// App-bar leading widget. Null keeps the automatic back button used by
  /// the full route; the embedded side pane supplies a close button instead,
  /// since popping the tab route would be wrong there.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final strings = detail_strings.AppLocalizations.of(context);
    final purposeColors = _purposeColors(context, listing.listingPurpose);
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        title: Text(listing.title, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          if (onFavoriteToggle != null)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_outline,
              ),
              tooltip:
                  isFavorite ? strings.favoriteRemove : strings.favoriteSave,
              onPressed: onFavoriteToggle,
            ),
          // A report is always meaningful when there is a listing to report,
          // signed in or out — the button itself decides to ask first.
          ReportListingButton(listing: listing),
        ],
      ),
      body: SelectionArea(
        child: ListView(
          children: <Widget>[
            AppImageGallery(
              photos: listing.photos,
              title: listing.title,
            ),
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
                    StatusChip(
                      label: _purposeLabel(
                        context,
                        listing.listingPurpose,
                      ),
                      background: purposeColors?.background,
                      foreground: purposeColors?.foreground,
                    ),
                    StatusChip(
                      label: _typeLabel(
                        context,
                        listing.propertyType,
                      ),
                    ),
                    // Rule 25: the seller's own units, pre-formatted
                    // server-side so cards, search and detail cannot disagree.
                    if (listing.areaDisplay case final area?)
                      StatusChip(label: area),
                    // Tier-3 verification (HYA-265): pane-supplied badge or
                    // owner entry; nothing by default.
                    verificationSlot,
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          _Section(
            title: strings.sectionLocation,
            children: <Widget>[
              _Spec(
                icon: Icons.place_outlined,
                label: listing.ward == null
                    ? '${listing.district}, ${listing.city}'
                    : strings.specWard(listing.city, listing.ward!),
                detail: listing.district,
              ),
              if (listing.roadAccessFt case final feet?)
                _Spec(
                  icon: Icons.alt_route,
                  label: strings.specRoadAccess(feet),
                ),
            ],
          ),
          // Bedrooms and bathrooms are only meaningful for things that have
          // rooms. Land and commercial premises leave both null, and rendering
          // "Bedrooms: 0" for a plot of land would be wrong rather than terse.
          if (listing.bedrooms != null ||
              listing.bathrooms != null) ...<Widget>[
            const Divider(height: 32),
            _Section(
              title: strings.sectionDetails,
              children: <Widget>[
                if (listing.bedrooms case final beds?)
                  _Spec(
                    icon: Icons.bed_outlined,
                    label: strings.specBedrooms(beds),
                  ),
                if (listing.bathrooms case final baths?)
                  _Spec(
                    icon: Icons.bathtub_outlined,
                    label: strings.specBathrooms(baths),
                  ),
              ],
            ),
          ],
          if ((listing.description ?? '').trim().isNotEmpty) ...<Widget>[
            const Divider(height: 32),
            _Section(
              title: strings.sectionDescription,
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
            title: strings.sectionSeller,
            children: <Widget>[_SellerCard(seller: listing.seller)],
          ),
          const SizedBox(height: 96),
          ],
        ),
      ),
      bottomNavigationBar: ContactSellerButton(listing: listing),
    );
  }

  /// Localized display name for a property type.
  static String _typeLabel(BuildContext context, PropertyType type) {
    final strings = detail_strings.AppLocalizations.of(context);
    return switch (type) {
      PropertyType.land => strings.typeLand,
      PropertyType.house => strings.typeHouse,
      PropertyType.apartment => strings.typeApartment,
      PropertyType.villa => strings.typeVilla,
      PropertyType.commercial => strings.typeCommercial,
      PropertyType.business => strings.typeBusiness,
    };
  }

  /// Localized display name for a listing purpose.
  static String _purposeLabel(BuildContext context, ListingPurpose purpose) {
    final strings = detail_strings.AppLocalizations.of(context);
    return switch (purpose) {
      ListingPurpose.sale => strings.purposeSale,
      ListingPurpose.rent => strings.purposeRent,
      ListingPurpose.lease => strings.purposeLease,
    };
  }
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
    final strings = detail_strings.AppLocalizations.of(context);
    final name = seller?.fullName;

    if (seller == null || (name == null || name.isEmpty)) {
      // The RPC always returns a seller object, but a profile with no name set
      // must not render an empty heading.
      return Text(
        strings.sellerUnavailable,
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
