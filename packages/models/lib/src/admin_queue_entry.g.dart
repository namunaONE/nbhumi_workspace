// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_queue_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QueueSeller _$QueueSellerFromJson(Map<String, dynamic> json) => _QueueSeller(
  id: json['id'] as String,
  fullName: json['full_name'] as String?,
  role: json['role'] as String?,
  isVerified: json['is_verified'] as bool? ?? false,
  kycTier: json['kyc_tier'] as String? ?? 'none',
  agencyName: json['agency_name'] as String?,
  agencyRegNo: json['agency_reg_no'] as String?,
);

Map<String, dynamic> _$QueueSellerToJson(_QueueSeller instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'role': instance.role,
      'is_verified': instance.isVerified,
      'kyc_tier': instance.kycTier,
      'agency_name': instance.agencyName,
      'agency_reg_no': instance.agencyRegNo,
    };

_AdminQueueEntry _$AdminQueueEntryFromJson(Map<String, dynamic> json) =>
    _AdminQueueEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      district: json['district'] as String,
      city: json['city'] as String,
      priceNpr: (json['price_npr'] as num).toInt(),
      propertyType: $enumDecode(_$PropertyTypeEnumMap, json['property_type']),
      listingPurpose: $enumDecode(
        _$ListingPurposeEnumMap,
        json['listing_purpose'],
      ),
      status: $enumDecode(_$ListingStatusEnumMap, json['status']),
      seller: QueueSeller.fromJson(json['seller'] as Map<String, dynamic>),
      ward: json['ward'] as String?,
      areaSqm: (json['area_sqm'] as num?)?.toDouble(),
      areaRopani: (json['area_ropani'] as num?)?.toInt(),
      areaAana: (json['area_aana'] as num?)?.toInt(),
      areaPaisa: (json['area_paisa'] as num?)?.toInt(),
      areaDam: (json['area_dam'] as num?)?.toInt(),
      areaBigha: (json['area_bigha'] as num?)?.toInt(),
      areaKattha: (json['area_kattha'] as num?)?.toInt(),
      areaDhur: (json['area_dhur'] as num?)?.toInt(),
      photoUrl: json['photo_url'] as String?,
      photoCount: (json['photo_count'] as num?)?.toInt() ?? 0,
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: json['submitted_at'] == null
          ? null
          : DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] == null
          ? null
          : DateTime.parse(json['reviewed_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AdminQueueEntryToJson(_AdminQueueEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'district': instance.district,
      'city': instance.city,
      'price_npr': instance.priceNpr,
      'property_type': _$PropertyTypeEnumMap[instance.propertyType]!,
      'listing_purpose': _$ListingPurposeEnumMap[instance.listingPurpose]!,
      'status': _$ListingStatusEnumMap[instance.status]!,
      'seller': instance.seller.toJson(),
      'ward': instance.ward,
      'area_sqm': instance.areaSqm,
      'area_ropani': instance.areaRopani,
      'area_aana': instance.areaAana,
      'area_paisa': instance.areaPaisa,
      'area_dam': instance.areaDam,
      'area_bigha': instance.areaBigha,
      'area_kattha': instance.areaKattha,
      'area_dhur': instance.areaDhur,
      'photo_url': instance.photoUrl,
      'photo_count': instance.photoCount,
      'rejection_reason': instance.rejectionReason,
      'submitted_at': instance.submittedAt?.toIso8601String(),
      'reviewed_at': instance.reviewedAt?.toIso8601String(),
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

const _$ListingStatusEnumMap = {
  ListingStatus.draft: 'draft',
  ListingStatus.pendingReview: 'pending_review',
  ListingStatus.live: 'live',
  ListingStatus.rejected: 'rejected',
  ListingStatus.unpublished: 'unpublished',
};

_AuditLogEntry _$AuditLogEntryFromJson(Map<String, dynamic> json) =>
    _AuditLogEntry(
      id: json['id'] as String,
      actorId: json['actor_id'] as String,
      action: json['action'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AuditLogEntryToJson(_AuditLogEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actor_id': instance.actorId,
      'action': instance.action,
      'entity_type': instance.entityType,
      'entity_id': instance.entityId,
      'created_at': instance.createdAt?.toIso8601String(),
      'details': instance.details,
    };
