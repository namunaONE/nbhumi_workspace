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
///
/// Carries an explicit [wireName] because the Dart name and the Postgres enum
/// differ. `pendingReview` is `pending_review` in the database, and confusing
/// the two is not a theoretical problem: the client once sent `status.name`
/// straight to `v1_create_listing`, so every attempt to submit a listing for
/// review failed with
/// `VALIDATION_ERROR: status must be draft or pending_review`. The mirror image
/// broke too, since `values.byName('pending_review')` throws on a value the
/// database genuinely returns.
///
/// Use [wireName] outbound and [fromWire] inbound. Never `.name` or `.byName`
/// for anything crossing the wire.
enum ListingStatus {
  /// Seller editing, not visible publicly.
  draft('draft'),

  /// Submitted, waiting for admin review.
  @JsonValue('pending_review')
  pendingReview('pending_review'),

  /// Approved, visible publicly.
  live('live'),

  /// Rejected by admin.
  rejected('rejected'),

  /// Pulled by an admin after going live (HYA-262).
  ///
  /// Distinct from [rejected]: rejected means "submitted and failed review",
  /// unpublished means "was live and got pulled". Reusing rejected would tell
  /// a seller their live listing failed review, a lie the audit trail then
  /// enshrines. Hidden from browse exactly like every other non-live status.
  unpublished('unpublished');

  ListingStatus(this.wireName);

  /// The value the `listing_status` enum uses in Postgres.
  final String wireName;

  /// The status whose [wireName] is [value].
  ///
  /// Throws [ArgumentError] for an unknown value rather than defaulting, so a
  /// newly added database state surfaces as a clear failure instead of silently
  /// becoming `draft`.
  static ListingStatus fromWire(String value) => values.firstWhere(
        (status) => status.wireName == value,
        orElse: () => throw ArgumentError.value(
          value,
          'value',
          'not a listing_status value',
        ),
      );
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

    /// Land parcel (kitta) number as the seller wrote it (HYA-300).
    ///
    /// Null means "not provided" and is itself a review signal; duplicates
    /// across listings are a fraud signal. Free text: numbering varies by
    /// district, so the server only trims and length-caps it.
    String? kittaNumber,

    /// Bedroom count.
    ///
    /// Null rather than 0 for land and commercial premises, which have none.
    /// The column carries `CHECK (bedrooms > 0)`, so a stored 0 is impossible
    /// and absence is the only way to say "not applicable".
    int? bedrooms,

    /// Bathroom count. Null when not applicable, as with [bedrooms].
    int? bathrooms,

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
