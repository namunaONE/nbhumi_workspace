import 'package:freezed_annotation/freezed_annotation.dart';

part 'municipality.freezed.dart';
part 'municipality.g.dart';

/// The four kinds of Nepali local body.
///
/// Carries an explicit [wireName] because the Dart names and the Postgres enum
/// differ (`subMetropolitan` is `sub_metropolitan` in the database). Same
/// lesson as `ListingStatus`: never `.name` or `.byName` for anything crossing
/// the wire, because the one value where they differ is exactly the one that
/// breaks silently.
enum MunicipalityType {
  /// Metropolitan city (6 in Nepal).
  metropolitan('metropolitan'),

  /// Sub-metropolitan city (11 in Nepal).
  @JsonValue('sub_metropolitan')
  subMetropolitan('sub_metropolitan'),

  /// Municipality (276 in Nepal).
  municipality('municipality'),

  /// Rural municipality / gaunpalika (460 in Nepal).
  @JsonValue('rural_municipality')
  ruralMunicipality('rural_municipality');

  MunicipalityType(this.wireName);

  /// The value stored in `municipalities.type`.
  final String wireName;

  /// The type whose [wireName] is [value].
  ///
  /// Throws [ArgumentError] for an unknown value rather than defaulting, so a
  /// newly added database type surfaces as a clear failure.
  static MunicipalityType fromWire(String value) => values.firstWhere(
        (type) => type.wireName == value,
        orElse: () => throw ArgumentError.value(
          value,
          'value',
          'not a municipality_type value',
        ),
      );
}

/// A Nepali local body, used as reference data by the wizard.
///
/// Reference data only: all 753 rows are readable by guests through the
/// `municipalities_select_public` policy, so nothing here is sensitive.
///
/// Two fields deserve an explanation:
///
/// * [slug] is the identifier, not [name]. Names recur across districts
///   (Baluwatar, Rampur and others exist in more than one), and are unique
///   only per district. Anything needing to reference a municipality uses the
///   globally unique slug.
/// * [wardCount] sizes the wizard's ward picker. It is the per-municipality
///   bound the flat 5..33 CHECK cannot express.
@freezed
sealed class Municipality with _$Municipality {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Municipality({
    required String id,
    required String slug,
    required String district,
    required String name,
    required MunicipalityType type,
    required int wardCount,
    String? nameNe,
  }) = _Municipality;

  factory Municipality.fromJson(Map<String, dynamic> json) =>
      _$MunicipalityFromJson(json);

  // Private constructor hook so the generated mixin can implement helpers.
  const Municipality._();

  /// Whether this body elects a mayor (as opposed to a chairperson).
  ///
  /// True for everything except rural municipalities. Display-only: the wizard
  /// labels the contact line "Municipality office" versus "Gaunpalika office".
  bool get hasMayor => type != MunicipalityType.ruralMunicipality;
}
