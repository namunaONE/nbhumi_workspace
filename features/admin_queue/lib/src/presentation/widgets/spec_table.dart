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
  List<(String, String)> _rows() {
    final area = _areaText;

    return <(String, String)>[
      ('Type', _propertyTypeLabel(listing.propertyType)),
      ('Purpose', _purposeLabel(listing.listingPurpose)),
      if (area != null) ('Area', area),
      if (listing.bedrooms != null) ('Bedrooms', '${listing.bedrooms}'),
      if (listing.bathrooms != null) ('Bathrooms', '${listing.bathrooms}'),
      if (listing.roadAccessFt != null)
        ('Road access', '${listing.roadAccessFt} ft'),
      if (listing.district.isNotEmpty) ('District', listing.district),
      if (listing.city.isNotEmpty) ('City/Municipality', listing.city),
      if (_ward != null) ('Ward', '$_ward'),
    ];
  }

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

  /// The ward, when it is a real ward number.
  ///
  /// [ListingDetail.ward] is a String because that is what the RPC sends. Rule
  /// 28 puts the valid range at 1-32, and both bounds are checked: a listing
  /// submitted before HYA-253 landed could carry 0, and an unparseable value is
  /// dropped rather than rendered, since "Ward abc" is a bug report, not
  /// information.
  int? get _ward {
    final parsed = int.tryParse(listing.ward?.trim() ?? '');
    if (parsed == null) return null;
    return parsed >= 1 && parsed <= 32 ? parsed : null;
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
