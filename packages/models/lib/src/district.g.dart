// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'district.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_District _$DistrictFromJson(Map<String, dynamic> json) => _District(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  province: (json['province'] as num).toInt(),
  region: $enumDecode(_$RegionEnumMap, json['region']),
);

Map<String, dynamic> _$DistrictToJson(_District instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'province': instance.province,
  'region': _$RegionEnumMap[instance.region]!,
};

const _$RegionEnumMap = {Region.hill: 'hill', Region.terai: 'terai'};
