import 'package:flutter/widgets.dart';
import 'package:models/models.dart';
import 'package:search/l10n/output/search_localizations.dart'
    as search_strings;

/// Localized display name for a property type.
///
/// Shared by the filter sheet chips and the saved-search name builder so the
/// two can never disagree on what a type is called.
String searchTypeLabel(BuildContext context, PropertyType type) {
  final strings = search_strings.AppLocalizations.of(context);
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
///
/// `null` (any purpose) reads as sale in names: most saved searches are
/// sales, and "any" would make the name evasive rather than informative.
String searchPurposeLabel(BuildContext context, ListingPurpose? purpose) {
  final strings = search_strings.AppLocalizations.of(context);
  return switch (purpose) {
    ListingPurpose.rent => strings.purposeRent,
    ListingPurpose.lease => strings.purposeLease,
    _ => strings.purposeSale,
  };
}

/// Localized sort-chip labels.
String searchSortLabel(BuildContext context, ListingSort sort) {
  final strings = search_strings.AppLocalizations.of(context);
  return switch (sort) {
    ListingSort.newest => strings.sortNewest,
    ListingSort.oldest => strings.sortOldest,
    ListingSort.priceAsc => strings.sortPriceAsc,
    ListingSort.priceDesc => strings.sortPriceDesc,
  };
}
