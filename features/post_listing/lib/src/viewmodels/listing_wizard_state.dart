import 'package:core/core.dart';
import 'package:models/models.dart';

/// One photo attached to a listing, before the listing exists.
///
/// [url] is already in Supabase Storage. Uploading happens when the seller
/// picks the image, not at submit, because Storage keys are namespaced by
/// seller id rather than listing id, so a listing row is not needed first.
///
/// [isUploading] covers the window between "picked" and "uploaded", so the UI
/// can show a placeholder rather than a broken image.
///
/// [error] is held as an [AppException] rather than a resolved string because
/// the upload runs in a notifier with no BuildContext, and so cannot know the
/// app locale. Resolving the message there would hard-code a language; the
/// widget resolves it on render instead.
class WizardPhoto {
  /// Creates a photo entry.
  const WizardPhoto({
    required this.url,
    this.isUploading = false,
    this.error,
    this.storagePath,
  });

  /// Public URL in the `listing-photos` bucket.
  final String url;

  /// Whether the upload is still in flight.
  final bool isUploading;

  /// Why the upload failed, if it did.
  final AppException? error;

  /// Storage object path behind [url] (HYA-300).
  ///
  /// Persisted on attach for the duplicate-photo signal. Null for uploads
  /// that predate path tracking; those rows stay URL-matched.
  final String? storagePath;
}

/// The wizard's five steps, in order.
///
/// A plain enum rather than an int so a step cannot be persisted as 2 and later
/// read back as a specs step when the order changes.
enum WizardStep {
  /// What kind of property, and whether it is for sale, rent or lease.
  type,

  /// District, city and ward.
  location,

  /// Area in local units, bedrooms, bathrooms, road access.
  specs,

  /// Price and photos.
  price,

  /// Review and submit.
  review;

  /// Position of this step in the wizard.
  ///
  /// Not called `index`: every enum already has an `index` field, and declaring
  /// a member with that name is a compile error rather than an override.
  int get position => WizardStep.values.indexOf(this);

  /// The step at [position], clamped to the valid range.
  static WizardStep at(int position) =>
      WizardStep.values[position.clamp(0, WizardStep.values.length - 1)];

  /// The step after this one, or null at the end.
  WizardStep? get next => position + 1 < WizardStep.values.length
      ? WizardStep.at(position + 1)
      : null;

  /// The step before this one, or null at the start.
  WizardStep? get previous =>
      position > 0 ? WizardStep.at(position - 1) : null;

  /// Title shown in the app bar.
  String get title => switch (this) {
        WizardStep.type => 'Property type',
        WizardStep.location => 'Location',
        WizardStep.specs => 'Size & rooms',
        WizardStep.price => 'Price & photos',
        WizardStep.review => 'Review',
      };
}

/// Field-level validation messages for one step.
///
/// Empty [errors] means the step may be left. Kept as a map so a step can show
/// every problem at once rather than one per submit attempt.
class StepValidation {
  /// Creates a validation result.
  const StepValidation(this.errors);

  /// An empty result, meaning valid.
  const StepValidation.valid() : errors = const <String, String>{};

  /// Messages keyed by field name.
  final Map<String, String> errors;

  /// Whether the step passed.
  bool get isValid => errors.isEmpty;

  /// The message for [field], or null.
  String? operator [](String field) => errors[field];
}

/// Everything the seller has entered so far.
///
/// Numeric fields are held as [String] rather than `int?` because they come
/// from text fields, where "12" and "" and "-" are all transiently reachable.
/// Parsing on validation keeps a half-typed number from throwing, and means the
/// state is the single source of truth the text fields initialise from.
class ListingWizardState {
  /// Creates a blank wizard.
  const ListingWizardState({
    this.step = WizardStep.type,
    this.propertyType,
    this.listingPurpose,
    this.title = '',
    this.description = '',
    this.district,
    this.municipality,
    this.city = '',
    this.ward = '',
    this.roadAccessFt = '',
    this.kittaNumber = '',
    this.areaRopani = '',
    this.areaAana = '',
    this.areaPaisa = '',
    this.areaDam = '',
    this.areaBigha = '',
    this.areaKattha = '',
    this.areaDhur = '',
    this.bedrooms = '',
    this.bathrooms = '',
    this.leaseTermMonths = '',
    this.leaseRenewable,
    this.depositAmount = '',
    this.availableFrom,
    this.furnishingStatus,
    this.utilitiesIncluded = '',
    this.petPolicy,
    this.parkingSpaces = '',
    this.floorNumber = '',
    this.totalFloors = '',
    this.propertyAgeYears = '',
    this.constructionStatus,
    this.priceNpr = '',
    this.photos = const <WizardPhoto>[],
    this.submitting = false,
    this.submitError,
    this.draftListingId,
    this.createdListingId,
  });

  /// The step being edited.
  final WizardStep step;

  /// Chosen property type.
  final PropertyType? propertyType;

  /// Chosen purpose.
  final ListingPurpose? listingPurpose;

  /// Listing title.
  final String title;

  /// Free-text description.
  final String description;

  /// Chosen district, which decides hill or terai area units (Rule 25).
  final District? district;

  /// Chosen municipality, which decides the ward range.
  ///
  /// Always within [district]: `setDistrict` clears it, because a municipality
  /// belongs to exactly one district and keeping Kathmandu's selection after
  /// switching to Lalitpur would submit a pair the composite city FK refuses.
  final Municipality? municipality;

  /// City or municipality name, as submitted.
  ///
  /// Mirrors `municipality.name` rather than being typed: `listings` carries a
  /// composite FK on (district, city), so a free-text value that names no
  /// municipality in the district is refused server-side. The dropdown is the
  /// only writer, which makes an FK violation unreachable from this form.
  final String city;

  /// Ward number as typed. Optional.
  final String ward;

  /// Road frontage in feet. Optional.
  final String roadAccessFt;

  /// Land parcel (kitta) number as typed. Optional (HYA-300).
  ///
  /// Feeds the duplicate/missing-kitta signals. Blank stays blank: the RPC
  /// stores NULL for blank, and NULL is the "not provided" signal.
  final String kittaNumber;

  /// Hill area units: ropani.
  final String areaRopani;

  /// Hill area units: aana.
  final String areaAana;

  /// Hill area units: paisa.
  final String areaPaisa;

  /// Hill area units: dam.
  final String areaDam;

  /// Terai area units: bigha.
  final String areaBigha;

  /// Terai area units: kattha.
  final String areaKattha;

  /// Terai area units: dhur.
  final String areaDhur;

  /// Bedroom count as typed. Optional.
  final String bedrooms;

  /// Bathroom count as typed. Optional.
  final String bathrooms;
  /// Lease length in months as typed. Optional, and only meaningful for a
  /// lease listing.
  final String leaseTermMonths;

  /// Whether the lease can be renewed. Tri-state: unset means "not stated",
  /// which is a different answer from "no".
  final bool? leaseRenewable;

  /// Security deposit in NPR as typed. Optional, rent listings only.
  final String depositAmount;

  /// First occupancy date. Optional, rent listings only.
  ///
  /// A [DateTime] rather than a string because the field is a date picker, not
  /// a text box: holding it as text would mean parsing on every render and
  /// re-formatting for the picker's initial value.
  final DateTime? availableFrom;

  /// Furnishing level. Optional, rent listings only.
  final FurnishingStatus? furnishingStatus;

  /// Which utilities the rent covers. Optional, rent listings only.
  final String utilitiesIncluded;

  /// Pet policy. Optional, rent listings only.
  final PetPolicy? petPolicy;

  /// Parking space count as typed. Optional.
  final String parkingSpaces;

  /// Floor this unit is on as typed. Optional.
  final String floorNumber;

  /// Total floors as typed. Optional.
  final String totalFloors;

  /// Building age in years as typed. Optional.
  final String propertyAgeYears;

  /// New, under construction or resale. Optional.
  final ConstructionStatus? constructionStatus;

  /// Asking price in NPR as typed.
  final String priceNpr;

  /// Attached photos.
  final List<WizardPhoto> photos;

  /// Whether a submit is in flight.
  final bool submitting;

  /// Message from the last failed submit.
  final String? submitError;

  /// Id of the draft created before photos are attached.
  ///
  /// Kept after a failed attach or submit so retry uses the same row instead
  /// of adding duplicate drafts. Null until the first create succeeds.
  final String? draftListingId;

  /// Id of the listing created by a successful submit.
  final String? createdListingId;

  /// Which area unit system applies, from the chosen district's region.
  ///
  /// Null until a district is picked, which is why the specs step is only
  /// reachable after the location step.
  Region? get region => district?.region;

  /// Whether this district measures in hill units.
  bool get usesHillUnits => region == Region.hill;
  // -------------------------------------------------------------------------
  // Applicability: which groups of fields answer to this listing
  // -------------------------------------------------------------------------
  // These mirror `enforce_listing_field_applicability` in the database. Having
  // them here is what lets the steps decide what to render and the validation
  // decide what to require, and having them in one place is what stops the two
  // from drifting into "the form asks for a lease term on a house for sale".
  /// Whether anyone sleeps in it: house, apartment or villa.
  ///
  /// Land has no rooms, and a "commercial shop" or a "business" listing is
  /// premises, not a home -- a shop floor does not carry a bedroom count.
  bool get isResidential =>
      propertyType == PropertyType.house ||
      propertyType == PropertyType.apartment ||
      propertyType == PropertyType.villa;

  /// Whether the building has floors to report: apartment, commercial or
  /// business premises.
  ///
  /// A house, a villa and a plot of land have no floor number worth naming.
  bool get hasFloors =>
      propertyType == PropertyType.apartment ||
      propertyType == PropertyType.commercial ||
      propertyType == PropertyType.business;

  /// Whether there is a building at all, so age and construction status mean
  /// something.
  bool get isBuilt =>
      propertyType != null && propertyType != PropertyType.land;

  /// Whether parking can be counted. Land has none.
  bool get hasParking =>
      propertyType != null && propertyType != PropertyType.land;

  /// Whether this is a lease, which is the only purpose with a term.
  bool get isLease => listingPurpose == ListingPurpose.lease;

  /// Whether this is a rental, which is the only purpose with rent-specific
  /// terms.
  bool get isRent => listingPurpose == ListingPurpose.rent;

  /// Whether the seller actually stated a renewal answer.
  bool get hasLeaseRenewable => isLease && leaseRenewable != null;

  /// Any hill unit entered.
  bool get hasHillArea => _anyUnits(
        <String>[areaRopani, areaAana, areaPaisa, areaDam],
      );

  /// Any terai unit entered.
  bool get hasTeraiArea => _anyUnits(
        <String>[areaBigha, areaKattha, areaDhur],
      );

  /// Whether any area was entered in the unit system this district uses.
  ///
  /// Deliberately not `hasHillArea || hasTeraiArea`. That expression is true
  /// when a seller typed *any* number, including numbers in the wrong unit
  /// system for their district — and the area would then be computed from the
  /// wrong set, publishing a plot of size 0 while their input was silently
  /// dropped. 1 ropani and 1 bigha differ by about 12x (Rule 25).
  bool get hasArea {
    if (district == null) return false;
    return usesHillUnits ? hasHillArea : hasTeraiArea;
  }

  /// Whether area was entered in the unit system that does *not* apply here.
  ///
  /// Used to tell the seller they used the wrong units, rather than only that
  /// they left the field empty.
  bool get hasAreaInWrongUnits {
    if (district == null) return false;
    return usesHillUnits ? hasTeraiArea : hasHillArea;
  }

  /// Area in square metres, derived from whichever unit system applies.
  ///
  /// Null when no district is chosen or nothing is entered. Rule 25: store sqm,
  /// display local, and let the server's `area_display` do the reverse.
  double? get areaSqm {
    if (district == null || !hasArea) return null;
    return usesHillUnits
        ? AreaConverter.hillToSqm(
            ropani: _intOrZero(areaRopani),
            aana: _intOrZero(areaAana),
            paisa: _intOrZero(areaPaisa),
            dam: _intOrZero(areaDam),
          )
        : AreaConverter.teraiToSqm(
            bigha: _intOrZero(areaBigha),
            kattha: _intOrZero(areaKattha),
            dhur: _intOrZero(areaDhur),
          );
  }

  /// Photos that finished uploading, in order.
  ///
  /// What gets written to `listing_photos`. Failed and in-flight entries are
  /// excluded, so a partial upload cannot produce rows pointing at nothing.
  List<String> get uploadedPhotoUrls => photos
      .where((photo) => !photo.isUploading && photo.error == null)
      .map((photo) => photo.url)
      .toList(growable: false);

  /// Photos that finished uploading with their storage paths (HYA-300).
  ///
  /// The attach step persists the path alongside the URL for the
  /// duplicate-photo signal. Same membership rule as [uploadedPhotoUrls].
  List<PhotoAttachment> get uploadedPhotos => photos
      .where((photo) => !photo.isUploading && photo.error == null)
      .map(
        (photo) => (url: photo.url, storagePath: photo.storagePath),
      )
      .toList(growable: false);

  /// Whether a submit has already succeeded.
  bool get isSubmitted => createdListingId != null;

  /// Returns a copy with the given fields replaced.
  ///
  /// Every numeric field is passed through as-is; an empty string is a real
  /// value meaning "cleared", not "unchanged", because the text fields it backs
  /// are the source of truth.
  ListingWizardState copyWith({
    WizardStep? step,
    PropertyType? propertyType,
    ListingPurpose? listingPurpose,
    String? title,
    String? description,
    District? district,
    Municipality? municipality,
    String? city,
    String? ward,
    String? roadAccessFt,
    String? kittaNumber,
    String? areaRopani,
    String? areaAana,
    String? areaPaisa,
    String? areaDam,
    String? areaBigha,
    String? areaKattha,
    String? areaDhur,
    String? bedrooms,
    String? bathrooms,
    String? leaseTermMonths,
    bool? leaseRenewable,
    String? depositAmount,
    DateTime? availableFrom,
    FurnishingStatus? furnishingStatus,
    String? utilitiesIncluded,
    PetPolicy? petPolicy,
    String? parkingSpaces,
    String? floorNumber,
    String? totalFloors,
    String? propertyAgeYears,
    ConstructionStatus? constructionStatus,
    String? priceNpr,
    List<WizardPhoto>? photos,
    bool? submitting,
    String? submitError,
    String? draftListingId,
    String? createdListingId,
    bool clearSubmitError = false,
    bool clearDistrict = false,
    bool clearMunicipality = false,
    bool clearLeaseRenewable = false,
    bool clearAvailableFrom = false,
    bool clearFurnishingStatus = false,
    bool clearPetPolicy = false,
    bool clearConstructionStatus = false,
  }) =>
      ListingWizardState(
        step: step ?? this.step,
        propertyType: propertyType ?? this.propertyType,
        listingPurpose: listingPurpose ?? this.listingPurpose,
        title: title ?? this.title,
        description: description ?? this.description,
        district: clearDistrict ? null : (district ?? this.district),
        municipality: clearMunicipality
            ? null
            : (municipality ?? this.municipality),
        city: city ?? this.city,
        ward: ward ?? this.ward,
        roadAccessFt: roadAccessFt ?? this.roadAccessFt,
        kittaNumber: kittaNumber ?? this.kittaNumber,
        areaRopani: areaRopani ?? this.areaRopani,
        areaAana: areaAana ?? this.areaAana,
        areaPaisa: areaPaisa ?? this.areaPaisa,
        areaDam: areaDam ?? this.areaDam,
        areaBigha: areaBigha ?? this.areaBigha,
        areaKattha: areaKattha ?? this.areaKattha,
        areaDhur: areaDhur ?? this.areaDhur,
        bedrooms: bedrooms ?? this.bedrooms,
        bathrooms: bathrooms ?? this.bathrooms,
        leaseTermMonths: leaseTermMonths ?? this.leaseTermMonths,
        leaseRenewable: clearLeaseRenewable
            ? null
            : (leaseRenewable ?? this.leaseRenewable),
        depositAmount: depositAmount ?? this.depositAmount,
        availableFrom: clearAvailableFrom
            ? null
            : (availableFrom ?? this.availableFrom),
        furnishingStatus: clearFurnishingStatus
            ? null
            : (furnishingStatus ?? this.furnishingStatus),
        utilitiesIncluded: utilitiesIncluded ?? this.utilitiesIncluded,
        petPolicy: clearPetPolicy ? null : (petPolicy ?? this.petPolicy),
        parkingSpaces: parkingSpaces ?? this.parkingSpaces,
        floorNumber: floorNumber ?? this.floorNumber,
        totalFloors: totalFloors ?? this.totalFloors,
        propertyAgeYears: propertyAgeYears ?? this.propertyAgeYears,
        constructionStatus: clearConstructionStatus
            ? null
            : (constructionStatus ?? this.constructionStatus),
        priceNpr: priceNpr ?? this.priceNpr,
        photos: photos ?? this.photos,
        submitting: submitting ?? this.submitting,
        submitError:
            clearSubmitError ? null : (submitError ?? this.submitError),
        draftListingId: draftListingId ?? this.draftListingId,
        createdListingId: createdListingId ?? this.createdListingId,
      );

  static bool _anyUnits(List<String> values) =>
      values.any((value) => value.trim().isNotEmpty);

  static int _intOrZero(String value) => int.tryParse(value.trim()) ?? 0;
}
