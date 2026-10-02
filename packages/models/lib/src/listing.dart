import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing.freezed.dart';
part 'listing.g.dart';

/// Property types available in Nepal.
enum PropertyType {
  land,
  house,
  apartment,
  villa,
  commercial,
  business,
}

/// Listing purpose — what the seller wants to do.
enum ListingPurpose {
  sale,
  rent,
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
    String? description,
    required int priceNpr,
    double? areaSqm,
    int? areaRopani,
    int? areaAana,
    int? areaPaisa,
    int? areaDam,
    int? areaBigha,
    int? areaKattha,
    int? areaDhur,
    required String district,
    required String city,
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
