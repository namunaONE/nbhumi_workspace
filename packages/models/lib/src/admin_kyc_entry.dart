import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:models/models.dart';

part 'admin_kyc_entry.freezed.dart';
part 'admin_kyc_entry.g.dart';

/// KYC document as shown in the admin review queue.
///
/// Mirrors the KYC document row with the SLA fields resolved server-side
/// so the list renders without re-evaluating `DateTime.now()` per row.
@freezed
sealed class AdminKycEntry with _$AdminKycEntry {
  const factory AdminKycEntry({
    required String id,
    required String profileId,
    required String profileName,
    required KycDocType docType,
    required String storagePath,
    required KycDocStatus status,
    required DateTime createdAt,
    required DateTime? reviewedAt,
    required String? reviewedByName,
    required String? listingId,
    required String? listingTitle,
  }) = _AdminKycEntry;

  factory AdminKycEntry.fromJson(Map<String, dynamic> json) =>
      _$AdminKycEntryFromJson(json);
}

/// Counts for the KYC queue tabs.
@freezed
sealed class AdminKycCounts with _$AdminKycCounts {
  const factory AdminKycCounts({
    @Default(0) int pending,
    @Default(0) int verified,
    @Default(0) int rejected,
  }) = _AdminKycCounts;

  factory AdminKycCounts.fromJson(Map<String, dynamic> json) =>
      _$AdminKycCountsFromJson(json);
}

/// KYC queue page returned by the repository.
@freezed
sealed class AdminKycPage with _$AdminKycPage {
  const factory AdminKycPage({
    required List<AdminKycEntry> entries,
    required AdminKycCounts counts,
    String? nextCursor,
  }) = _AdminKycPage;

  factory AdminKycPage.fromJson(Map<String, dynamic> json) =>
      _$AdminKycPageFromJson(json);
}