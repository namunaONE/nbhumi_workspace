// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_kyc_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminKycEntry _$AdminKycEntryFromJson(Map<String, dynamic> json) =>
    _AdminKycEntry(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      profileName: json['profileName'] as String,
      docType: $enumDecode(_$KycDocTypeEnumMap, json['docType']),
      storagePath: json['storagePath'] as String,
      status: $enumDecode(_$KycDocStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      reviewedByName: json['reviewedByName'] as String?,
      listingId: json['listingId'] as String?,
      listingTitle: json['listingTitle'] as String?,
    );

Map<String, dynamic> _$AdminKycEntryToJson(_AdminKycEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profileId': instance.profileId,
      'profileName': instance.profileName,
      'docType': _$KycDocTypeEnumMap[instance.docType]!,
      'storagePath': instance.storagePath,
      'status': _$KycDocStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'reviewedByName': instance.reviewedByName,
      'listingId': instance.listingId,
      'listingTitle': instance.listingTitle,
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

_AdminKycCounts _$AdminKycCountsFromJson(Map<String, dynamic> json) =>
    _AdminKycCounts(
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      verified: (json['verified'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AdminKycCountsToJson(_AdminKycCounts instance) =>
    <String, dynamic>{
      'pending': instance.pending,
      'verified': instance.verified,
      'rejected': instance.rejected,
    };

_AdminKycPage _$AdminKycPageFromJson(Map<String, dynamic> json) =>
    _AdminKycPage(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => AdminKycEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      counts: AdminKycCounts.fromJson(json['counts'] as Map<String, dynamic>),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$AdminKycPageToJson(_AdminKycPage instance) =>
    <String, dynamic>{
      'entries': instance.entries,
      'counts': instance.counts,
      'nextCursor': instance.nextCursor,
    };
