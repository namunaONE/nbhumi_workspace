// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Listing _$ListingFromJson(Map<String, dynamic> json) => _Listing(
  id: json['id'] as String,
  sellerId: json['seller_id'] as String,
  propertyType: $enumDecode(_$PropertyTypeEnumMap, json['property_type']),
  listingPurpose: $enumDecode(_$ListingPurposeEnumMap, json['listing_purpose']),
  title: json['title'] as String,
  priceNpr: (json['price_npr'] as num).toInt(),
  district: json['district'] as String,
  city: json['city'] as String,
  description: json['description'] as String?,
  areaSqm: (json['area_sqm'] as num?)?.toDouble(),
  areaRopani: (json['area_ropani'] as num?)?.toInt(),
  areaAana: (json['area_aana'] as num?)?.toInt(),
  areaPaisa: (json['area_paisa'] as num?)?.toInt(),
  areaDam: (json['area_dam'] as num?)?.toInt(),
  areaBigha: (json['area_bigha'] as num?)?.toInt(),
  areaKattha: (json['area_kattha'] as num?)?.toInt(),
  areaDhur: (json['area_dhur'] as num?)?.toInt(),
  ward: json['ward'] as String?,
  roadAccessFt: (json['road_access_ft'] as num?)?.toInt(),
  status:
      $enumDecodeNullable(_$ListingStatusEnumMap, json['status']) ??
      ListingStatus.draft,
  rejectionReason: json['rejection_reason'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  reviewedBy: json['reviewed_by'] as String?,
  reviewedAt: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
);

Map<String, dynamic> _$ListingToJson(_Listing instance) => <String, dynamic>{
  'id': instance.id,
  'seller_id': instance.sellerId,
  'property_type': _$PropertyTypeEnumMap[instance.propertyType]!,
  'listing_purpose': _$ListingPurposeEnumMap[instance.listingPurpose]!,
  'title': instance.title,
  'price_npr': instance.priceNpr,
  'district': instance.district,
  'city': instance.city,
  'description': instance.description,
  'area_sqm': instance.areaSqm,
  'area_ropani': instance.areaRopani,
  'area_aana': instance.areaAana,
  'area_paisa': instance.areaPaisa,
  'area_dam': instance.areaDam,
  'area_bigha': instance.areaBigha,
  'area_kattha': instance.areaKattha,
  'area_dhur': instance.areaDhur,
  'ward': instance.ward,
  'road_access_ft': instance.roadAccessFt,
  'status': _$ListingStatusEnumMap[instance.status]!,
  'rejection_reason': instance.rejectionReason,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'reviewed_by': instance.reviewedBy,
  'reviewed_at': instance.reviewedAt?.toIso8601String(),
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

const _$ListingStatusEnumMap = {
  ListingStatus.draft: 'draft',
  ListingStatus.pendingReview: 'pending_review',
  ListingStatus.live: 'live',
  ListingStatus.rejected: 'rejected',
};
