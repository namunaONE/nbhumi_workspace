import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyc_document.freezed.dart';
part 'kyc_document.g.dart';

/// Types of KYC documents.
///
/// Carries an explicit [wireName]: `agencyReg` is `agency_reg` in the
/// database, and sending `.name` straight to `v1_submit_kyc` would fail the
/// RPC's `INVALID_DOC_TYPE` check. Use [wireName] outbound, [fromWire]
/// inbound — never `.name` for anything crossing the wire.
enum KycDocType {
  /// Citizenship certificate.
  citizenship('citizenship'),

  /// Land ownership certificate (लालपुर्जा).
  lalpurja('lalpurja'),

  /// Agency registration certificate.
  @JsonValue('agency_reg')
  agencyReg('agency_reg');

  /// Creates a document type with its Postgres wire value.
  KycDocType(this.wireName);

  /// The value the `kyc_documents.doc_type` check constraint uses.
  final String wireName;

  /// The type whose [wireName] is [value].
  static KycDocType fromWire(String value) => values.firstWhere(
        (type) => type.wireName == value,
        orElse: () => throw ArgumentError.value(
          value,
          'value',
          'not a kyc doc_type value',
        ),
      );
}

/// KYC document verification status.
enum KycDocStatus {
  /// Uploaded, awaiting an admin decision.
  pending,

  /// Checked and accepted. Doc-check only, never legal verification.
  verified,

  /// Checked and refused. Document is purged from Storage after 30 days
  /// (DATA.md retention policy).
  rejected,
}

/// A KYC document uploaded by a seller.
///
/// Tier 2 (identity) has no [listingId]; Tier 3 (per-listing property check,
/// HYA-265) binds the row to one listing. Doc-check only — a `verified` row
/// means an admin looked at the file, never legal/title verification.
@freezed
sealed class KycDocument with _$KycDocument {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory KycDocument({
    required String id,
    required String profileId,
    required KycDocType docType,
    required String storagePath,
    @Default(KycDocStatus.pending) KycDocStatus status,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime? createdAt,
    /// Null for Tier 2 identity checks; set for Tier 3 per-listing checks.
    String? listingId,
    DateTime? updatedAt,
  }) = _KycDocument;

  factory KycDocument.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentFromJson(json);
}
