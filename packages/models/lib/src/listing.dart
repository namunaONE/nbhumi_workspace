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

/// Rental furnishing level.
///
/// Only meaningful when [ListingPurpose.rent]: a sale listing describes its
/// furniture in the description, because "sold furnished" is a negotiation
/// rather than a listing term. Mirrors the `listings.furnishing_status` CHECK.
enum FurnishingStatus {
  /// Bare walls.
  @JsonValue('unfurnished')
  unfurnished('unfurnished'),

  /// Kitchen and wardrobes, no soft furnishings.
  @JsonValue('semi_furnished')
  semiFurnished('semi_furnished'),

  /// Complete, ready to occupy.
  @JsonValue('furnished')
  furnished('furnished');

  FurnishingStatus(this.wireName);

  /// The value the `furnishing_status` CHECK uses.
  final String wireName;

  /// The level whose [wireName] is [value].
  ///
  /// Throws [ArgumentError] rather than defaulting, so a new database level
  /// surfaces as a clear failure instead of silently reading as furnished.
  static FurnishingStatus fromWire(String value) => values.firstWhere(
        (level) => level.wireName == value,
        orElse: () => throw ArgumentError.value(
          value,
          'value',
          'not a furnishing_status value',
        ),
      );
}

/// Rental pet policy.
///
/// Only meaningful when [ListingPurpose.rent]. A text column rather than a
/// boolean because "cats but not dogs" is a real answer, and `negotiable` is
/// different from `allowed` in a way that changes whether the tenant asks.
enum PetPolicy {
  /// No animals of any kind.
  @JsonValue('not_allowed')
  notAllowed('not_allowed'),

  /// Cats welcome, dogs not stated.
  @JsonValue('cats_ok')
  catsOk('cats_ok'),

  /// Dogs welcome, cats not stated.
  @JsonValue('dogs_ok')
  dogsOk('dogs_ok'),

  /// Any pet.
  @JsonValue('all_pets')
  allPets('all_pets'),

  /// Ask the seller.
  @JsonValue('negotiable')
  negotiable('negotiable');

  PetPolicy(this.wireName);

  /// The value the `pet_policy` CHECK uses.
  final String wireName;

  /// The policy whose [wireName] is [value].
  static PetPolicy fromWire(String value) => values.firstWhere(
        (policy) => policy.wireName == value,
        orElse: () => throw ArgumentError.value(
          value,
          'value',
          'not a pet_policy value',
        ),
      );
}

/// Whether the building is new, still under construction, or being resold.
///
/// Null for land, which is not built. Mirrors the
/// `listings.construction_status` CHECK.
enum ConstructionStatus {
  /// Never occupied.
  @JsonValue('new')
  newBuild('new'),

  /// Not handed over yet.
  @JsonValue('under_construction')
  underConstruction('under_construction'),

  /// Previously owned and occupied.
  @JsonValue('resale')
  resale('resale');

  ConstructionStatus(this.wireName);

  /// The value the `construction_status` CHECK uses.
  final String wireName;

  /// The status whose [wireName] is [value].
  static ConstructionStatus fromWire(String value) => values.firstWhere(
        (status) => status.wireName == value,
        orElse: () => throw ArgumentError.value(
          value,
          'value',
          'not a construction_status value',
        ),
      );
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
    /// Lease length in months. Null unless [listingPurpose] is
    /// [ListingPurpose.lease]; the `listings_field_applicability` trigger
    /// nulls it for every other purpose.
    int? leaseTermMonths,

    /// Whether the lease can be renewed. Null unless the purpose is lease.
    ///
    /// Nullable on purpose: "the listing does not say" is a different answer
    /// from "no", and coercing it loses information the tenant would ask about.
    bool? leaseRenewable,

    /// Security deposit in NPR. Null unless the purpose is rent.
    ///
    /// Zero is a real term (no deposit asked), so the CHECK is `>= 0` rather
    /// than `> 0` unlike [bedrooms].
    int? depositAmount,

    /// First date the property can be occupied. Null unless the purpose is
    /// rent. Stored as a date, not a timestamptz: "available from the 1st"
    /// must not shift with the viewer's offset.
    DateTime? availableFrom,

    /// Furnishing level. Null unless the purpose is rent, or when the seller
    /// left it unstated.
    FurnishingStatus? furnishingStatus,

    /// Which utilities the rent covers. Null unless the purpose is rent.
    ///
    /// Free text capped at 200 characters server-side; anything longer
    /// belongs in the description.
    String? utilitiesIncluded,

    /// Pet policy. Null unless the purpose is rent, or when unstated.
    PetPolicy? petPolicy,

    /// Covered or off-street parking spaces.
    ///
    /// Null for land, which has none to count. Zero is rejected so a stored
    /// value is always a real count.
    int? parkingSpaces,

    /// Floor this unit is on, zero being the ground floor.
    ///
    /// Null for house, land, villa and business premises, which have no floor
    /// number to report.
    int? floorNumber,

    /// How many floors the building has. Null unless the building has floors.
    int? totalFloors,

    /// Age of the building in years, zero being brand new.
    ///
    /// Null for land, which is not aged.
    int? propertyAgeYears,

    /// New, under construction, or resale. Null for land.
    ConstructionStatus? constructionStatus,

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
