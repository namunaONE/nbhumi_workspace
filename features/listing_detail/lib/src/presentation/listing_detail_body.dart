import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                if (listing.parkingSpaces case final parking?)
                  _Spec(
                    icon: Icons.local_parking_outlined,
                    label: strings.specParking(parking),
                  ),
              ],
            ),
          ],

          // Purpose-conditioned terms. The database nulls anything that does
          // not apply, so each section appears only for its own purpose and
          // the buyer is never shown a lease term on a rental.
          if (listing.leaseTermMonths case final term?) ...<Widget>[
            const Divider(height: 32),
            _Section(
              title: strings.sectionLeaseTerms,
              children: <Widget>[
                _Spec(
                  icon: Icons.event_repeat_outlined,
                  label: strings.specLeaseTerm(term),
                  detail: listing.leaseRenewable == null
                      ? null
                      : (listing.leaseRenewable!
                          ? strings.termRenewable
                          : strings.termNotRenewable),
                ),
              ],
            ),
          ],

          if (_hasRentalTerms(listing)) ...<Widget>[
            const Divider(height: 32),
            _Section(
              title: strings.sectionRentalTerms,
              children: <Widget>[
                if (listing.depositAmount case final deposit?)
                  _Spec(
                    icon: Icons.savings_outlined,
                    label: strings.specDeposit(
                      NepaliCurrency.full(deposit),
                    ),
                  ),
                if (listing.availableFrom case final from?)
                  _Spec(
                    icon: Icons.event_available_outlined,
                    label: strings.specAvailableFrom(_date(context, from)),
                  ),
                if (listing.furnishingStatus case final furnishing?)
                  _Spec(
                    icon: Icons.chair_outlined,
                    label: strings.specFurnishing(
                      _furnishingLabel(strings, furnishing),
                    ),
                  ),
                if (listing.petPolicy case final pets?)
                  _Spec(
                    icon: Icons.pets_outlined,
                    label: strings.specPetPolicy(_petLabel(strings, pets)),
                  ),
                if ((listing.utilitiesIncluded ?? '').trim().isNotEmpty)
                  _Spec(
                    icon: Icons.power_outlined,
                    label: listing.utilitiesIncluded!.trim(),
                  ),
              ],
            ),
          ],

          // Type-conditioned building details: floor position, age, status.
          if (_hasBuildingDetails(listing)) ...<Widget>[
            const Divider(height: 32),
            _Section(
              title: strings.sectionBuilding,
              children: <Widget>[
                if (listing.floorNumber case final floor?)
                  _Spec(
                    icon: Icons.stairs_outlined,
                    label: _floorLabel(strings, listing, floor),
                  ),
                if (listing.propertyAgeYears case final age?)
                  _Spec(
                    icon: Icons.history_outlined,
                    label: strings.specAge(age),
                  ),
                if (listing.constructionStatus case final construction?)
                  _Spec(
                    icon: Icons.construction_outlined,
                    label: strings.specConstruction(
                      _constructionLabel(strings, construction),
                    ),
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

  /// Whether any rental term is present.
  ///
  /// The trigger nulls all of these for a sale or a lease, so the check is a
  /// plain "did the seller say anything" rather than a purpose test the page
  /// would have to repeat.
  static bool _hasRentalTerms(ListingDetail listing) =>
      listing.depositAmount != null ||
      listing.availableFrom != null ||
      listing.furnishingStatus != null ||
      listing.petPolicy != null ||
      (listing.utilitiesIncluded ?? '').trim().isNotEmpty;

  /// Whether any building detail is present.
  static bool _hasBuildingDetails(ListingDetail listing) =>
      listing.floorNumber != null ||
      listing.propertyAgeYears != null ||
      listing.constructionStatus != null;

  /// Floor position, with the building total when the seller gave one.
  static String _floorLabel(
    detail_strings.AppLocalizations strings,
    ListingDetail listing,
    int floor,
  ) {
    final total = listing.totalFloors;
    if (total != null) return strings.specFloorOf(floor, total);
    return strings.specFloor(floor);
  }

  /// Localized furnishing level.
  static String _furnishingLabel(
    detail_strings.AppLocalizations strings,
    FurnishingStatus level,
  ) =>
      switch (level) {
        FurnishingStatus.unfurnished => strings.furnishingUnfurnished,
        FurnishingStatus.semiFurnished => strings.furnishingSemiFurnished,
        FurnishingStatus.furnished => strings.furnishingFurnished,
      };

  /// Localized pet policy.
  static String _petLabel(
    detail_strings.AppLocalizations strings,
    PetPolicy policy,
  ) =>
      switch (policy) {
        PetPolicy.notAllowed => strings.petNotAllowed,
        PetPolicy.catsOk => strings.petCatsOk,
        PetPolicy.dogsOk => strings.petDogsOk,
        PetPolicy.allPets => strings.petAllPets,
        PetPolicy.negotiable => strings.petNegotiable,
      };

  /// Localized construction status.
  static String _constructionLabel(
    detail_strings.AppLocalizations strings,
    ConstructionStatus status,
  ) =>
      switch (status) {
        ConstructionStatus.newBuild => strings.constructionNew,
        ConstructionStatus.underConstruction =>
          strings.constructionUnderConstruction,
        ConstructionStatus.resale => strings.constructionResale,
      };

  /// Short local date for a value the server returns as a date, not a
  /// timestamp: an availability day must not shift with the viewer's offset.
  static String _date(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(value);
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
