// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityPage _$ActivityPageFromJson(Map<String, dynamic> json) =>
    _ActivityPage(
      listings:
          (json['listings'] as List<dynamic>?)
              ?.map((e) => ListingSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ListingSummary>[],
      reveals:
          (json['reveals'] as List<dynamic>?)
              ?.map((e) => MyReveal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MyReveal>[],
      revealStats:
          (json['revealStats'] as List<dynamic>?)
              ?.map(
                (e) => ListingRevealStat.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ListingRevealStat>[],
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((e) => KycDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <KycDocument>[],
      updates:
          (json['updates'] as List<dynamic>?)
              ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AppNotification>[],
    );

Map<String, dynamic> _$ActivityPageToJson(_ActivityPage instance) =>
    <String, dynamic>{
      'listings': instance.listings,
      'reveals': instance.reveals,
      'revealStats': instance.revealStats,
      'documents': instance.documents,
      'updates': instance.updates,
    };
