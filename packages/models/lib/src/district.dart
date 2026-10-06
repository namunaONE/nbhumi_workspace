import 'package:freezed_annotation/freezed_annotation.dart';

part 'district.freezed.dart';
part 'district.g.dart';

/// Which of Nepal's two area-unit systems a district uses (Rule 25).
///
/// Not a cosmetic distinction. Hill districts measure land in
/// ropani-aana-paisa-dam and terai districts in bigha-kattha-dhur, and mixing
/// them up misstates a plot's size by a factor of about 12. The wizard uses
/// this to show the right inputs, and `area_display` uses it to render back.
enum Region {
  /// Ropani, aana, paisa, dam.
  hill,

  /// Bigha, kattha, dhur.
  terai;

  /// The value stored in `districts.region`.
  static Region fromWire(String value) => switch (value) {
        'hill' => Region.hill,
        'terai' => Region.terai,
        _ => throw ArgumentError.value(
            value,
            'value',
            'not a district region: expected hill or terai',
          ),
      };
}

/// A Nepali district, used as reference data by the wizard and the filters.
///
/// Reference data only: all 77 rows are readable by guests through the
/// `districts_select_public` policy, so nothing here is sensitive.
///
/// Two fields are `int` where a reader might expect text, and that is the
/// schema, not an accident: `districts.id` is `smallint generated always as
/// identity` and `districts.province` is `smallint check (between 1 and 7)`.
/// A previous revision of this model declared both as `String`, which made
/// every live row throw in `fromJson` and the wizard's district dropdown
/// never loaded. Display grouping uses [provinceName], never the number.
@freezed
sealed class District with _$District {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory District({
    required int id,
    required String name,
    required int province,
    required Region region,
  }) = _District;

  factory District.fromJson(Map<String, dynamic> json) =>
      _$DistrictFromJson(json);

  // Private constructor hook so the generated mixin can implement isHill below.
  const District._();

  /// Whether this district measures area in hill units.
  bool get isHill => region == Region.hill;

  /// The province's name for display grouping.
  ///
  /// Throws [ArgumentError] for a number outside 1–7 rather than defaulting,
  /// so a future eighth province (or a corrupt row) surfaces instead of
  /// grouping under a wrong name.
  String get provinceName => switch (province) {
        1 => 'Koshi',
        2 => 'Madhesh',
        3 => 'Bagmati',
        4 => 'Gandaki',
        5 => 'Lumbini',
        6 => 'Karnali',
        7 => 'Sudurpashchim',
        _ => throw ArgumentError.value(
            province,
            'province',
            'not a Nepali province number: expected 1–7',
          ),
      };
}
