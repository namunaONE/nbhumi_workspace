import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyc_document.freezed.dart';
part 'kyc_document.g.dart';

/// Types of KYC documents.
enum KycDocType {
  citizenship,
  lalpurja,
  agencyReg,
}

/// KYC document verification status.
enum KycDocStatus {
  pending,
  verified,
  rejected,
}

/// A KYC document uploaded by a seller.
@freezed
class KycDocument with _$KycDocument {
  const factory KycDocument({
    required String id,
    required String profileId,
    required KycDocType docType,
    required String storagePath,
    @Default(KycDocStatus.pending) KycDocStatus status,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime? createdAt,
  }) = _KycDocument;

  factory KycDocument.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentFromJson(json);
}
