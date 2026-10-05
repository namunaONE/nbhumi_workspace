// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KycDocument _$KycDocumentFromJson(Map<String, dynamic> json) => _KycDocument(
  id: json['id'] as String,
  profileId: json['profile_id'] as String,
  docType: $enumDecode(_$KycDocTypeEnumMap, json['doc_type']),
  storagePath: json['storage_path'] as String,
  status:
      $enumDecodeNullable(_$KycDocStatusEnumMap, json['status']) ??
      KycDocStatus.pending,
  reviewedBy: json['reviewed_by'] as String?,
  reviewedAt: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  listingId: json['listing_id'] as String?,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$KycDocumentToJson(_KycDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile_id': instance.profileId,
      'doc_type': _$KycDocTypeEnumMap[instance.docType]!,
      'storage_path': instance.storagePath,
      'status': _$KycDocStatusEnumMap[instance.status]!,
      'reviewed_by': instance.reviewedBy,
      'reviewed_at': instance.reviewedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'listing_id': instance.listingId,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$KycDocTypeEnumMap = {
  KycDocType.citizenship: 'citizenship',
  KycDocType.lalpurja: 'lalpurja',
  KycDocType.agencyReg: 'agency_reg',
};

const _$KycDocStatusEnumMap = {
  KycDocStatus.pending: 'pending',
  KycDocStatus.verified: 'verified',
  KycDocStatus.rejected: 'rejected',
};
