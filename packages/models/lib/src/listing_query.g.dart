// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingCursor _$ListingCursorFromJson(Map<String, dynamic> json) =>
    _ListingCursor(k: json['k'] as String, id: json['id'] as String);

Map<String, dynamic> _$ListingCursorToJson(_ListingCursor instance) =>
    <String, dynamic>{'k': instance.k, 'id': instance.id};

_ListingPage _$ListingPageFromJson(Map<String, dynamic> json) => _ListingPage(
  listings:
      (json['listings'] as List<dynamic>?)
          ?.map((e) => ListingSummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ListingSummary>[],
  totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
  pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
  hasMore: json['has_more'] as bool? ?? false,
);

Map<String, dynamic> _$ListingPageToJson(_ListingPage instance) =>
    <String, dynamic>{
      'listings': instance.listings,
      'total_count': instance.totalCount,
      'page_size': instance.pageSize,
      'has_more': instance.hasMore,
    };
