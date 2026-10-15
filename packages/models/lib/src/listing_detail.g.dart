// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingSeller _$ListingSellerFromJson(Map<String, dynamic> json) =>
    _ListingSeller(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      kycTier: json['kyc_tier'] as String?,
      role: json['role'] as String?,
      agencyName: json['agency_name'] as String?,
    );

Map<String, dynamic> _$ListingSellerToJson(_ListingSeller instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'is_verified': instance.isVerified,
      'kyc_tier': instance.kycTier,
      'role': instance.role,
      'agency_name': instance.agencyName,
    };

_ListingDetail _$ListingDetailFromJson(
  Map<String, dynamic> json,
) => _ListingDetail(
  id: json['id'] as String,
  sellerId: json['seller_id'] as String,
  title: json['title'] as String,
  priceNpr: (json['price_npr'] as num).toInt(),
  district: json['district'] as String,
  city: json['city'] as String,
  propertyType: $enumDecode(_$PropertyTypeEnumMap, json['property_type']),
  listingPurpose: $enumDecode(_$ListingPurposeEnumMap, json['listing_purpose']),
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
  bedrooms: (json['bedrooms'] as num?)?.toInt(),
  bathrooms: (json['bathrooms'] as num?)?.toInt(),
  leaseTermMonths: (json['lease_term_months'] as num?)?.toInt(),
  leaseRenewable: json['lease_renewable'] as bool?,
  depositAmount: (json['deposit_amount'] as num?)?.toInt(),
  availableFrom: json['available_from'] == null
      ? null
      : DateTime.parse(json['available_from'] as String),
  furnishingStatus: $enumDecodeNullable(
    _$FurnishingStatusEnumMap,
    json['furnishing_status'],
  ),
  utilitiesIncluded: json['utilities_included'] as String?,
  petPolicy: $enumDecodeNullable(_$PetPolicyEnumMap, json['pet_policy']),
  parkingSpaces: (json['parking_spaces'] as num?)?.toInt(),
  floorNumber: (json['floor_number'] as num?)?.toInt(),
  totalFloors: (json['total_floors'] as num?)?.toInt(),
  propertyAgeYears: (json['property_age_years'] as num?)?.toInt(),
  constructionStatus: $enumDecodeNullable(
    _$ConstructionStatusEnumMap,
    json['construction_status'],
  ),
  facingDirection: $enumDecodeNullable(
    _$FacingDirectionEnumMap,
    json['facing_direction'],
  ),
  amenities:
      (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  rejectionReason: json['rejection_reason'] as String?,
  submittedAt: json['submitted_at'] == null
      ? null
      : DateTime.parse(json['submitted_at'] as String),
  photos:
      (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  seller: json['seller'] == null
      ? null
      : ListingSeller.fromJson(json['seller'] as Map<String, dynamic>),
  areaDisplay: json['area_display'] as String?,
  isFavorite: json['is_favorite'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ListingDetailToJson(_ListingDetail instance) =>
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
      'bedrooms': instance.bedrooms,
      'bathrooms': instance.bathrooms,
      'lease_term_months': instance.leaseTermMonths,
      'lease_renewable': instance.leaseRenewable,
      'deposit_amount': instance.depositAmount,
      'available_from': instance.availableFrom?.toIso8601String(),
      'furnishing_status': _$FurnishingStatusEnumMap[instance.furnishingStatus],
      'utilities_included': instance.utilitiesIncluded,
      'pet_policy': _$PetPolicyEnumMap[instance.petPolicy],
      'parking_spaces': instance.parkingSpaces,
      'floor_number': instance.floorNumber,
      'total_floors': instance.totalFloors,
      'property_age_years': instance.propertyAgeYears,
      'construction_status':
          _$ConstructionStatusEnumMap[instance.constructionStatus],
      'facing_direction': _$FacingDirectionEnumMap[instance.facingDirection],
      'amenities': instance.amenities,
      'rejection_reason': instance.rejectionReason,
      'submitted_at': instance.submittedAt?.toIso8601String(),
      'photos': instance.photos,
      'seller': instance.seller?.toJson(),
      'area_display': instance.areaDisplay,
      'is_favorite': instance.isFavorite,
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
  ListingStatus.unpublished: 'unpublished',
};

const _$FurnishingStatusEnumMap = {
  FurnishingStatus.unfurnished: 'unfurnished',
  FurnishingStatus.semiFurnished: 'semi_furnished',
  FurnishingStatus.furnished: 'furnished',
};

const _$PetPolicyEnumMap = {
  PetPolicy.notAllowed: 'not_allowed',
  PetPolicy.catsOk: 'cats_ok',
  PetPolicy.dogsOk: 'dogs_ok',
  PetPolicy.allPets: 'all_pets',
  PetPolicy.negotiable: 'negotiable',
};

const _$ConstructionStatusEnumMap = {
  ConstructionStatus.newBuild: 'new',
  ConstructionStatus.underConstruction: 'under_construction',
  ConstructionStatus.resale: 'resale',
};

const _$FacingDirectionEnumMap = {
  FacingDirection.north: 'north',
  FacingDirection.northEast: 'north_east',
  FacingDirection.east: 'east',
  FacingDirection.southEast: 'south_east',
  FacingDirection.south: 'south',
  FacingDirection.southWest: 'south_west',
  FacingDirection.west: 'west',
  FacingDirection.northWest: 'north_west',
};
