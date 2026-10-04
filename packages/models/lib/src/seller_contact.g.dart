// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SellerContact _$SellerContactFromJson(Map<String, dynamic> json) =>
    _SellerContact(
      listingId: json['listing_id'] as String,
      sellerId: json['seller_id'] as String,
      sellerName: json['seller_name'] as String?,
      sellerPhone: json['seller_phone'] as String?,
      sellerEmail: json['seller_email'] as String?,
      agencyName: json['agency_name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      revealedAt: json['revealed_at'] == null
          ? null
          : DateTime.parse(json['revealed_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$SellerContactToJson(_SellerContact instance) =>
    <String, dynamic>{
      'listing_id': instance.listingId,
      'seller_id': instance.sellerId,
      'seller_name': instance.sellerName,
      'seller_phone': instance.sellerPhone,
      'seller_email': instance.sellerEmail,
      'agency_name': instance.agencyName,
      'is_verified': instance.isVerified,
      'revealed_at': instance.revealedAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
    };
