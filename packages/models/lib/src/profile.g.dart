// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String?,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.buyer,
  isVerified: json['is_verified'] as bool? ?? false,
  kycTier:
      $enumDecodeNullable(_$KycTierEnumMap, json['kyc_tier']) ?? KycTier.none,
  agencyName: json['agency_name'] as String?,
  agencyRegNo: json['agency_reg_no'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'role': _$UserRoleEnumMap[instance.role]!,
  'is_verified': instance.isVerified,
  'kyc_tier': _$KycTierEnumMap[instance.kycTier]!,
  'agency_name': instance.agencyName,
  'agency_reg_no': instance.agencyRegNo,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.buyer: 'buyer',
  UserRole.agent: 'agent',
  UserRole.admin: 'admin',
};

const _$KycTierEnumMap = {
  KycTier.none: 'none',
  KycTier.account: 'account',
  KycTier.identity: 'identity',
  KycTier.property: 'property',
};
