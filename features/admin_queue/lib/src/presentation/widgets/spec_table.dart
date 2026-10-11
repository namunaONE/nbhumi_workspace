import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';

/// The listing's specifications, as label/value rows.
///
/// ### Why area is shown in local units, not square metres
///
/// Rule 25: store sqm, display local. A hill listing quoted in "4 aana 2
/// paisa" and a terai one in "1 bigha 4 kattha" are the only forms a Nepali
/// seller or buyer reads. [AreaConverter] does the conversion, so no row here
/// has to know which region it is in.
///
/// ### Why bedrooms are omitted rather than shown as a dash
///
/// A land listing has no bedrooms, and rendering a dash implies the seller left
/// something out. An absent row is the honest rendering: there is no such
/// attribute for this property type.
class SpecTable extends StatelessWidget {
  /// Creates a specification table for [listing].
  const SpecTable({required this.listing, super.key});

  /// The listing to describe.
  final ListingDetail listing;

  @override
  Widget build(BuildContext context) {
    final rows = _rows();

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Specifications', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final (label, value) in rows) _SpecRow(label: label, value: value),
      ],
    );
  }

  /// The rows worth showing, in the order a reviewer reads them.
  ///
  /// Built as a list of pairs rather than a Map so the order is explicit.
  /// Dart's
  /// Map preserves insertion order, but a reviewer scanning this table wants
  /// location, then size, then rooms, then access — and that intent is clearer
  /// written down than implied by insertion.
  ///
  /// ### Why the lease, rental and building rows read on null alone
  ///
  /// The `listings_field_applicability` trigger nulls anything that does not
  /// apply to the listing's purpose and property type, so a non-null value is
  /// proof the term belongs here. No purpose or type check is needed, and
  /// adding one would be a second owner for a rule the database already owns.
  List<(String, String)> _rows() {
    final area = _areaText;

    return <(String, String)>[
      ('Type', _propertyTypeLabel(listing.propertyType)),
      ('Purpose', _purposeLabel(listing.listingPurpose)),
      if (area != null) ('Area', area),
      if (listing.bedrooms != null) ('Bedrooms', '${listing.bedrooms}'),
      if (listing.bathrooms != null) ('Bathrooms', '${listing.bathrooms}'),
      if (listing.parkingSpaces != null)
        ('Parking', '${listing.parkingSpaces}'),
      if (listing.leaseTermMonths != null)
        ('Lease term', _leaseTermText),
      if (listing.depositAmount != null)
        ('Deposit', NepaliCurrency.full(listing.depositAmount!)),
      if (listing.availableFrom != null)
        ('Available from', _isoDate(listing.availableFrom!)),
      if (listing.furnishingStatus != null)
        ('Furnishing', _furnishingLabel(listing.furnishingStatus!)),
      if (listing.petPolicy != null)
        ('Pets', _petLabel(listing.petPolicy!)),
      if ((listing.utilitiesIncluded ?? '').trim().isNotEmpty)
        ('Utilities', listing.utilitiesIncluded!.trim()),
      if (listing.floorNumber != null) ('Floor', _floorText),
      if (listing.propertyAgeYears != null)
        ('Building age', '${listing.propertyAgeYears} yrs'),
      if (listing.constructionStatus != null)
        ('Construction', _constructionLabel(listing.constructionStatus!)),
      if (listing.roadAccessFt != null)
        ('Road access', '${listing.roadAccessFt} ft'),
      if (listing.district.isNotEmpty) ('District', listing.district),
      if (listing.city.isNotEmpty) ('City/Municipality', listing.city),
      if (_ward != null) ('Ward', '$_ward'),
    ];
  }

  /// Lease length with the renewal answer composed in.
  ///
  /// Unset renewal reads as nothing extra: "24 months" alone is honest, while
  /// appending "renewal unknown" would noise up every row for a question most
  /// sellers were never asked.
  String get _leaseTermText {
    final months = listing.leaseTermMonths!;
    final renewable = listing.leaseRenewable;
    if (renewable == null) return '$months months';
    return renewable ? '$months months, renewable' : '$months months, fixed';
  }

  /// Floor position with the building total when the seller gave one.
  String get _floorText {
    final floor = listing.floorNumber!;
    final total = listing.totalFloors;
    if (total != null) return '$floor of $total';
    return '$floor';
  }

  /// Calendar date without a time or offset.
  ///
  /// `available_from` is a Postgres date, so rendering it through a DateFormat
  /// would attach the viewer's timezone to a value that has none. ISO order
  /// reads unambiguously in either app language.
  static String _isoDate(DateTime value) =>
      value.toIso8601String().split('T').first;

  /// Area in whichever local units apply.
  ///
  /// Prefers the server's `area_display` when present: it already applied the
  /// hill/terai split server-side, which this client cannot know from a
  /// district
  /// name alone. Falls back to sqm rather than guessing a unit, because showing
  /// "2,500 sqm" for a hill listing is odd but not wrong, whereas showing it as
  /// "4 aana" in the wrong region would be.
  String? get _areaText {
    final display = listing.areaDisplay;
    if (display != null && display.trim().isNotEmpty) return display;

    final sqm = listing.areaSqm;
    if (sqm == null) return null;

    // Whole numbers without a trailing ".0", which `toStringAsFixed` would
    // otherwise add and make a precise-looking but meaningless figure.
    final isWhole = sqm.truncateToDouble() == sqm;
    return '${sqm.toStringAsFixed(isWhole ? 0 : 2)} sqm';
  }

  /// The ward, when it is one the database would accept.
  ///
  /// Delegates to [Validators.isValidWard] rather than parsing here. That is
  /// not
  /// a stylistic preference — this getter was wrong three ways when it parsed
  /// for
  /// itself:
  ///
  ///   * the ceiling was 32, but Pokhara Metropolitan City genuinely has 33
  ///     wards, so a real ward 33 was dropped from the pane;
  ///   * `int.tryParse('01')` succeeds, but the `ward_valid` CHECK has no `0`
  ///     branch, so the database rejects a leading zero;
  ///   * `.trim()` accepted `' 5'`, which the same pattern rejects.
  ///
  /// The rule is "show what the server would accept", and exactly one place
  /// knows what that is. [Validators.maxWard] carries the ceiling and why it
  /// has
  /// already been corrected twice.
  int? get _ward {
    final raw = listing.ward;
    if (raw == null || !Validators.isValidWard(raw)) return null;
    return int.parse(raw);
  }

  /// Display name for a property type.
  static String _propertyTypeLabel(PropertyType type) => switch (type) {
        PropertyType.land => 'Land',
        PropertyType.house => 'House',
        PropertyType.apartment => 'Apartment',
        PropertyType.villa => 'Villa',
        PropertyType.commercial => 'Commercial',
        PropertyType.business => 'Business',
      };

  /// Display name for a purpose.
  static String _purposeLabel(ListingPurpose purpose) => switch (purpose) {
        ListingPurpose.sale => 'For sale',
        ListingPurpose.rent => 'For rent',
        ListingPurpose.lease => 'For lease',
      };

  /// Display name for a furnishing level.
  ///
  /// Hardcoded English like every other label here: the admin panel ships no
  /// l10n, and these strings mirror the wire values 1:1 so a new database
  /// level surfaces as a compile error in the switch, not a blank row.
  static String _furnishingLabel(FurnishingStatus level) => switch (level) {
        FurnishingStatus.unfurnished => 'Unfurnished',
        FurnishingStatus.semiFurnished => 'Partly furnished',
        FurnishingStatus.furnished => 'Furnished',
      };

  /// Display name for a pet policy.
  static String _petLabel(PetPolicy policy) => switch (policy) {
        PetPolicy.notAllowed => 'No pets',
        PetPolicy.catsOk => 'Cats allowed',
        PetPolicy.dogsOk => 'Dogs allowed',
        PetPolicy.allPets => 'All pets allowed',
        PetPolicy.negotiable => 'Negotiable',
      };

  /// Display name for a construction status.
  static String _constructionLabel(ConstructionStatus status) =>
      switch (status) {
        ConstructionStatus.newBuild => 'New build',
        ConstructionStatus.underConstruction => 'Under construction',
        ConstructionStatus.resale => 'Resale',
      };
}

/// One label/value row.
class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            // A fixed label column rather than IntrinsicWidth: IntrinsicWidth
            // costs a layout pass per row, and these are the most numerous
            // widgets on the screen. The fixed width is the reason to have a
            // column at all — the values align.
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
