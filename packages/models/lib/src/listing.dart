import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing.freezed.dart';
part 'listing.g.dart';

/// Property types available in Nepal.
enum PropertyType {
  /// Bare land. Displayed with hill units in hill districts, terai in terai.
  land,

  /// Detached house.
  house,

  /// Flat in a multi-storey building.
  apartment,

  /// Detached house with a compound.
  villa,

  /// Shop, office or warehouse.
  commercial,

  /// Business premises sold with the operating trade.
  business,
}

/// Listing purpose — what the seller wants to do.
enum ListingPurpose {
  /// Transfer of ownership.
  sale,

  /// Periodic rent.
  rent,

  /// Long lease contract.
  lease,
}

/// Listing status state machine.
enum ListingStatus {
  /// Seller editing, not visible publicly.
  draft,

  /// Submitted, waiting for admin review.
  @JsonValue('pending_review')
  pendingReview,

  /// Approved, visible publicly.
  live,

  /// Rejected by admin.
  rejected,
}

/// A property listing in the nBhumi marketplace.
@freezed
sealed class Listing with _$Listing {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Listing({
    required String id,
    required String sellerId,
    required PropertyType propertyType,
    required ListingPurpose listingPurpose,
    required String title,
    required int priceNpr,
    required String district,
    required String city,
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
    @Default(ListingStatus.draft) ListingStatus status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);
}
