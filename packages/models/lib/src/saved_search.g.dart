// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedSearch _$SavedSearchFromJson(Map<String, dynamic> json) => _SavedSearch(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  district: json['district'] as String?,
  propertyType: $enumDecodeNullable(
    _$PropertyTypeEnumMap,
    json['property_type'],
  ),
  listingPurpose: $enumDecodeNullable(
    _$ListingPurposeEnumMap,
    json['listing_purpose'],
  ),
  minPriceNpr: (json['min_price_npr'] as num?)?.toInt(),
  maxPriceNpr: (json['max_price_npr'] as num?)?.toInt(),
  minAreaSqm: (json['min_area_sqm'] as num?)?.toDouble(),
  maxAreaSqm: (json['max_area_sqm'] as num?)?.toDouble(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SavedSearchToJson(_SavedSearch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'district': instance.district,
      'property_type': _$PropertyTypeEnumMap[instance.propertyType],
      'listing_purpose': _$ListingPurposeEnumMap[instance.listingPurpose],
      'min_price_npr': instance.minPriceNpr,
      'max_price_npr': instance.maxPriceNpr,
      'min_area_sqm': instance.minAreaSqm,
      'max_area_sqm': instance.maxAreaSqm,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$PropertyTypeEnumMap = {
  PropertyType.land: 'land',
  PropertyType.house: 'house',
  PropertyType.apartment: 'apartment',
  PropertyType.villa: 'villa',
  PropertyType.commercial: 'commercial',
  PropertyType.business: 'business',
};

const _$ListingPurposeEnumMap = {
  ListingPurpose.sale: 'sale',
  ListingPurpose.rent: 'rent',
  ListingPurpose.lease: 'lease',
};
