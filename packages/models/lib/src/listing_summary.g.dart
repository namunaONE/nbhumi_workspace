// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingSummary _$ListingSummaryFromJson(Map<String, dynamic> json) =>
    _ListingSummary(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      title: json['title'] as String,
      priceNpr: (json['price_npr'] as num).toInt(),
      district: json['district'] as String,
      city: json['city'] as String,
      propertyType: $enumDecode(_$PropertyTypeEnumMap, json['property_type']),
      listingPurpose: $enumDecode(
        _$ListingPurposeEnumMap,
        json['listing_purpose'],
      ),
      status:
          $enumDecodeNullable(_$ListingStatusEnumMap, json['status']) ??
          ListingStatus.draft,
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
      photoUrl: json['photo_url'] as String?,
      isVerified: json['is_verified'] as bool?,
      sellerName: json['seller_name'] as String?,
      areaDisplay: json['area_display'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ListingSummaryToJson(_ListingSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seller_id': instance.sellerId,
      'title': instance.title,
      'price_npr': instance.priceNpr,
      'district': instance.district,
      'city': instance.city,
      'property_type': _$PropertyTypeEnumMap[instance.propertyType]!,
      'listing_purpose': _$ListingPurposeEnumMap[instance.listingPurpose]!,
      'status': _$ListingStatusEnumMap[instance.status]!,
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
      'photo_url': instance.photoUrl,
      'is_verified': instance.isVerified,
      'seller_name': instance.sellerName,
      'area_display': instance.areaDisplay,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
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
