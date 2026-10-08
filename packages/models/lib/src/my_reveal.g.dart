// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_reveal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyReveal _$MyRevealFromJson(Map<String, dynamic> json) => _MyReveal(
  listingId: json['listing_id'] as String,
  listingTitle: json['listing_title'] as String?,
  revealedAt: json['revealed_at'] == null
      ? null
      : DateTime.parse(json['revealed_at'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$MyRevealToJson(_MyReveal instance) => <String, dynamic>{
  'listing_id': instance.listingId,
  'listing_title': instance.listingTitle,
  'revealed_at': instance.revealedAt?.toIso8601String(),
  'expires_at': instance.expiresAt?.toIso8601String(),
};
