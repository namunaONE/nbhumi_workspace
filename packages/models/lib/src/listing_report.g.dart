// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportedListing _$ReportedListingFromJson(Map<String, dynamic> json) =>
    _ReportedListing(
      id: json['id'] as String,
      title: json['title'] as String,
      priceNpr: (json['price_npr'] as num).toInt(),
      status: $enumDecode(_$ListingStatusEnumMap, json['status']),
      district: json['district'] as String,
      city: json['city'] as String,
      sellerId: json['seller_id'] as String,
    );

Map<String, dynamic> _$ReportedListingToJson(_ReportedListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price_npr': instance.priceNpr,
      'status': _$ListingStatusEnumMap[instance.status]!,
      'district': instance.district,
      'city': instance.city,
      'seller_id': instance.sellerId,
    };

const _$ListingStatusEnumMap = {
  ListingStatus.draft: 'draft',
  ListingStatus.pendingReview: 'pending_review',
  ListingStatus.live: 'live',
  ListingStatus.rejected: 'rejected',
  ListingStatus.unpublished: 'unpublished',
};

_ReportAuthor _$ReportAuthorFromJson(Map<String, dynamic> json) =>
    _ReportAuthor(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );

Map<String, dynamic> _$ReportAuthorToJson(_ReportAuthor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'role': instance.role,
      'is_verified': instance.isVerified,
    };

_AdminReportEntry _$AdminReportEntryFromJson(Map<String, dynamic> json) =>
    _AdminReportEntry(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      reason: $enumDecode(_$ReportReasonEnumMap, json['reason']),
      status: $enumDecode(_$ReportStatusEnumMap, json['status']),
      listing: ReportedListing.fromJson(
        json['listing'] as Map<String, dynamic>,
      ),
      reporter: ReportAuthor.fromJson(json['reporter'] as Map<String, dynamic>),
      details: json['details'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AdminReportEntryToJson(_AdminReportEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listing_id': instance.listingId,
      'reason': _$ReportReasonEnumMap[instance.reason]!,
      'status': _$ReportStatusEnumMap[instance.status]!,
      'listing': instance.listing.toJson(),
      'reporter': instance.reporter.toJson(),
      'details': instance.details,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$ReportReasonEnumMap = {
  ReportReason.duplicateListing: 'duplicate_listing',
  ReportReason.photosMisleading: 'photos_misleading',
  ReportReason.priceSuspicious: 'price_suspicious',
  ReportReason.wrongLocation: 'wrong_location',
  ReportReason.alreadySold: 'already_sold',
  ReportReason.sellerAskedOffsite: 'seller_asked_offsite',
  ReportReason.fakeListing: 'fake_listing',
  ReportReason.other: 'other',
};

const _$ReportStatusEnumMap = {
  ReportStatus.open: 'open',
  ReportStatus.actioned: 'actioned',
  ReportStatus.dismissed: 'dismissed',
};

_ListingReport _$ListingReportFromJson(Map<String, dynamic> json) =>
    _ListingReport(
      reportId: json['report_id'] as String,
      listingId: json['listing_id'] as String,
      reason: $enumDecode(_$ReportReasonEnumMap, json['reason']),
      details: json['details'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ListingReportToJson(_ListingReport instance) =>
    <String, dynamic>{
      'report_id': instance.reportId,
      'listing_id': instance.listingId,
      'reason': _$ReportReasonEnumMap[instance.reason]!,
      'details': instance.details,
      'created_at': instance.createdAt?.toIso8601String(),
    };
