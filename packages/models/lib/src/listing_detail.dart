import 'package:freezed_annotation/freezed_annotation.dart';
import 'listing.dart';

part 'listing_detail.freezed.dart';
part 'listing_detail.g.dart';

/// The seller card embedded in a listing detail response.
///
/// Deliberately narrow. The browse RPC is a `SECURITY DEFINER` function that
/// joins `profiles`; it must never be able to leak `email` or `phone`. Contact
/// details are only ever released through `v1_contact_seller`, which is
/// rate-limited and requires an authenticated buyer (HYA-252).
@freezed
sealed class ListingSeller with _$ListingSeller {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ListingSeller({
    required String id,
    String? fullName,
    @Default(false) bool isVerified,
    String? kycTier,
    String? role,
    String? agencyName,
  }) = _ListingSeller;

  factory ListingSeller.fromJson(Map<String, dynamic> json) =>
      _$ListingSellerFromJson(json);
}

/// A single listing with full detail, photos and seller card.
///
/// Mirrors `v1_get_listing_detail`. Favourites are M3 (HYA-212) — the field is
/// carried now so the model does not change shape when that table lands.
@freezed
sealed class ListingDetail with _$ListingDetail {
  // explicitToJson forces the generator to call `toJson()` on the nested
  // ListingSeller. Without it the encoder emits the `_ListingSeller` object
  // itself, so `ListingDetail.toJson()` cannot be read back and the
  // round-trip test fails with a cast error.
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory ListingDetail({
    required String id,
    required String sellerId,
    required String title,
    required int priceNpr,
    required String district,
    required String city,
    required PropertyType propertyType,
    required ListingPurpose listingPurpose,
    @Default(ListingStatus.draft) ListingStatus status,
    String? description,
    double? areaSqm,
    int? areaRopani,
    int? areaAana,
    int? areaPaisa,
    int? areaDam,
    int? areaBigha,
    int? areaKattha,
    int? areaDhur,
    String? ward,
    int? roadAccessFt,

    /// Bedroom and bathroom counts.
    ///
    /// Null for land and commercial premises. Absent from browse responses on
    /// purpose: the card never renders them, so `v1_get_listings` does not send
    /// them.
    int? bedrooms,
    int? bathrooms,
    /// Lease length in months, null unless the purpose is lease.
    int? leaseTermMonths,

    /// Whether the lease can be renewed. Null when the listing does not say.
    bool? leaseRenewable,

    /// Security deposit in NPR, null unless the purpose is rent.
    int? depositAmount,

    /// First occupancy date, null unless the purpose is rent.
    DateTime? availableFrom,

    /// Furnishing level, null unless the purpose is rent or when unstated.
    FurnishingStatus? furnishingStatus,

    /// Which utilities the rent covers, null unless the purpose is rent.
    String? utilitiesIncluded,

    /// Pet policy, null unless the purpose is rent or when unstated.
    PetPolicy? petPolicy,

    /// Parking spaces, null for land.
    int? parkingSpaces,

    /// Floor this unit is on, zero being the ground floor. Null when the
    /// building has no floor number to report.
    int? floorNumber,

    /// Total floors in the building. Null when not applicable.
    int? totalFloors,

    /// Building age in years, zero being new. Null for land.
    int? propertyAgeYears,

    /// New, under construction or resale. Null for land.
    ConstructionStatus? constructionStatus,

    /// Which way the plot or main entrance faces. Null when unstated.
    FacingDirection? facingDirection,

    /// Structured amenity tags. Empty when none stated.
    @Default(<String>[]) List<String> amenities,

    String? rejectionReason,

    /// When the seller submitted this for review. Null for a draft.
    ///
    /// Carried here rather than left to the admin queue's own model because the
    /// admin panel deep-links to a listing by id: `/listing/:id` is reachable
    /// in a fresh tab with no queue loaded, and without this the detail pane
    /// would have no submission clock to compute the 48h SLA against.
    /// Migration 010 added the column to `v1_get_listing_detail` for the same
    /// reason.
    DateTime? submittedAt,

    /// Ordered by `sort_order` server-side.
    @Default(<String>[]) List<String> photos,

    ListingSeller? seller,
    String? areaDisplay,

    /// Always false until M3 implements favourites.
    @Default(false) bool isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ListingDetail;

  factory ListingDetail.fromJson(Map<String, dynamic> json) =>
      _$ListingDetailFromJson(json);
}
