import 'package:freezed_annotation/freezed_annotation.dart';

import 'listing.dart';
import 'listing_query.dart';

part 'saved_search.freezed.dart';
part 'saved_search.g.dart';

/// A buyer-stored browse filter (HYA-268 C2b).
///
/// Flat columns mirror [ListingFilter] field-for-field (minus query text,
/// sort and page size, which are presentation concerns, not alert criteria).
/// A null bound is a wildcard. Stored flat rather than as JSON so the C3
/// matcher compares columns in SQL instead of extracting jsonb paths.
@freezed
sealed class SavedSearch with _$SavedSearch {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SavedSearch({
    required String id,
    required String userId,
    required String name,
    String? district,
    PropertyType? propertyType,
    ListingPurpose? listingPurpose,
    int? minPriceNpr,
    int? maxPriceNpr,
    double? minAreaSqm,
    double? maxAreaSqm,
    DateTime? createdAt,
  }) = _SavedSearch;

  factory SavedSearch.fromJson(Map<String, dynamic> json) =>
      _$SavedSearchFromJson(json);

  const SavedSearch._();

  /// Rebuilds the browse filter this search was stored from.
  ///
  /// Presentation-only fields were never stored (see [savedSearchFromFilter]),
  /// so the rebuilt filter always sorts newest-first at the default page
  /// size: re-running a saved search shows what is new, not a stale cursor.
  ListingFilter toFilter() => ListingFilter(
        district: district,
        propertyType: propertyType,
        listingPurpose: listingPurpose,
        minPriceNpr: minPriceNpr,
        maxPriceNpr: maxPriceNpr,
        minAreaSqm: minAreaSqm,
        maxAreaSqm: maxAreaSqm,
      );
}

/// Builds a [SavedSearch] row from a user id, a name and a browse filter.
///
/// Drops the presentation-only filter fields (query text, sort, page size):
/// what wakes a buyer at 7am is new matches, not how they were sorted.
SavedSearch savedSearchFromFilter({
  required String id,
  required String userId,
  required String name,
  required ListingFilter filter,
}) =>
    SavedSearch(
      id: id,
      userId: userId,
      name: name,
      district: filter.district,
      propertyType: filter.propertyType,
      listingPurpose: filter.listingPurpose,
      minPriceNpr: filter.minPriceNpr,
      maxPriceNpr: filter.maxPriceNpr,
      minAreaSqm: filter.minAreaSqm,
      maxAreaSqm: filter.maxAreaSqm,
    );
