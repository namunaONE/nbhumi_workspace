// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'municipality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Municipality _$MunicipalityFromJson(Map<String, dynamic> json) =>
    _Municipality(
      id: json['id'] as String,
      slug: json['slug'] as String,
      district: json['district'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$MunicipalityTypeEnumMap, json['type']),
      wardCount: (json['ward_count'] as num).toInt(),
      nameNe: json['name_ne'] as String?,
    );

Map<String, dynamic> _$MunicipalityToJson(_Municipality instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'district': instance.district,
      'name': instance.name,
      'type': _$MunicipalityTypeEnumMap[instance.type]!,
      'ward_count': instance.wardCount,
      'name_ne': instance.nameNe,
    };

const _$MunicipalityTypeEnumMap = {
  MunicipalityType.metropolitan: 'metropolitan',
  MunicipalityType.subMetropolitan: 'sub_metropolitan',
  MunicipalityType.municipality: 'municipality',
  MunicipalityType.ruralMunicipality: 'rural_municipality',
};
