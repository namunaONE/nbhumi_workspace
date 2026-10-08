// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => _AdminUser(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String?,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.buyer,
  isVerified: json['is_verified'] as bool? ?? false,
  kycTier:
      $enumDecodeNullable(_$KycTierEnumMap, json['kyc_tier']) ?? KycTier.none,
  suspendedAt: json['suspended_at'] == null
      ? null
      : DateTime.parse(json['suspended_at'] as String),
  suspendedReason: json['suspended_reason'] as String?,
  suspended: json['suspended'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  listings:
      (json['listings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  openReportsAgainst: (json['open_reports_against'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AdminUserToJson(_AdminUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'is_verified': instance.isVerified,
      'kyc_tier': _$KycTierEnumMap[instance.kycTier]!,
      'suspended_at': instance.suspendedAt?.toIso8601String(),
      'suspended_reason': instance.suspendedReason,
      'suspended': instance.suspended,
      'created_at': instance.createdAt?.toIso8601String(),
      'listings': instance.listings,
      'open_reports_against': instance.openReportsAgainst,
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
