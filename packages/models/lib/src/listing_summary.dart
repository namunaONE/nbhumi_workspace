import 'package:freezed_annotation/freezed_annotation.dart';
import 'listing.dart';

part 'listing_summary.freezed.dart';
part 'listing_summary.g.dart';

/// A listing as it appears in browse results.
///
/// Deliberately separate from [Listing]: the browse RPC returns a *different*
/// shape from the one the create/update RPCs accept. One overloaded model
/// forced the repository to either drop fields or fabricate them, and
/// `Listing.sellerId` being required made `Listing.fromJson` throw on every
/// browse response.
///
/// Field set mirrors `v1_get_listings` exactly — see migration
/// `20261002082158_repoint_browse_rpcs_to_current_uid.sql`.
@freezed
sealed class ListingSummary with _$ListingSummary {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ListingSummary({
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

    /// Cover photo, already joined server-side (no N+1).
    String? photoUrl,

    /// Whether the *seller* is KYC-verified, not the listing.
    bool? isVerified,
    String? sellerName,

    /// Pre-formatted area in the units the seller supplied, e.g.
    /// `5 aana 4 paisa` for hill districts and `1 bigha` for terai. Falls back
    /// to `1200 sqm`. Computed in SQL so cards, search results and the detail
    /// page can never disagree on how an area reads (Rule 25).
    String? areaDisplay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ListingSummary;

  factory ListingSummary.fromJson(Map<String, dynamic> json) =>
      _$ListingSummaryFromJson(json);
}
