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
/// Municipalities and wards arrive with HYA-253.
@freezed
sealed class District with _$District {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory District({
    required String id,
    required String name,
    required String province,
    required Region region,
  }) = _District;

  factory District.fromJson(Map<String, dynamic> json) =>
      _$DistrictFromJson(json);

  // Private constructor hook so the generated mixin can implement isHill below.
  const District._();

  /// Whether this district measures area in hill units.
  bool get isHill => region == Region.hill;
}
