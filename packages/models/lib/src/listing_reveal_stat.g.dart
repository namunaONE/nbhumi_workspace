// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_reveal_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingRevealStat _$ListingRevealStatFromJson(Map<String, dynamic> json) =>
    _ListingRevealStat(
      listingId: json['listing_id'] as String,
      title: json['title'] as String,
      revealCount: (json['reveal_count'] as num?)?.toInt() ?? 0,
      lastRevealedAt: json['last_revealed_at'] == null
          ? null
          : DateTime.parse(json['last_revealed_at'] as String),
    );

Map<String, dynamic> _$ListingRevealStatToJson(_ListingRevealStat instance) =>
    <String, dynamic>{
      'listing_id': instance.listingId,
      'title': instance.title,
      'reveal_count': instance.revealCount,
      'last_revealed_at': instance.lastRevealedAt?.toIso8601String(),
    };
