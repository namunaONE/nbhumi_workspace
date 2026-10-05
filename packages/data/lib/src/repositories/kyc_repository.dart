import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Private Storage bucket holding KYC files.
///
/// Private, unlike `listing-photos`: every read goes through RLS or a
/// time-boxed signed URL (Rule 5). Never call `getPublicUrl` on this bucket.
const String _kycBucket = 'kyc-documents';

/// Largest KYC upload the client will attempt.
///
/// Mirrors the server-side intent: rejected-document retention and the
/// tombstone purge both assume small identity files, not video. The RPC does
/// not check bytes (it only sees the path), so this is the enforcement point
/// alongside the Storage dashboard limit.
const int _maxKycBytes = 10 * 1024 * 1024;

/// File extensions the KYC flow accepts, lower-cased with leading dot.
const Set<String> _allowedKycExtensions = <String>{
  '.pdf',
  '.jpg',
  '.jpeg',
  '.png',
};

/// Content type for [extension], matching the upload payload.
String _contentTypeFor(String extension) => switch (extension) {
      '.pdf' => 'application/pdf',
      '.png' => 'image/png',
      _ => 'image/jpeg',
    };

/// Lower-cased dot-prefixed extension of [filename], or empty when unusable.
String _extensionOf(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot < 0 || dot == filename.length - 1) return '';
  return filename.substring(dot).toLowerCase();
}

/// Repository for seller KYC documents (HYA-264 Tier 2, HYA-265 Tier 3).
///
/// Seller-scoped by construction: submit, list-own and signed-URL minting.
/// Admin verdicts (`v1_admin_verify_kyc`, `v1_admin_reject_kyc`) live on
/// moderation paths, not here, so the seller write path cannot grow an admin
/// capability by accident.
///
/// Every method maps transport failures onto the [AppException] hierarchy
/// (Rule 38) and logs with full context (Rule 37).
class KycRepository {
  /// Wraps a Supabase client.
  KycRepository(this._client);

  final SupabaseClient _client;

  /// Uploads one KYC file to the private bucket and returns its storage path.
  ///
  /// The path is `<userId>/<microseconds>_<docType><ext>`: the leading folder
  /// must be the caller's own id because the `kyc_docs_insert_own` storage
  /// policy only permits writes whose first folder segment equals the JWT
  /// subject. Returns the path (not a URL) — the caller passes it to
  /// [submitKyc], and reads go through [documentSignedUrl].
  ///
  /// Validates size and extension client-side (Rule 6); the server re-checks
  /// the path prefix and doc/listing pairing in `v1_submit_kyc`.
  Future<String> uploadKycFile({
    required String userId,
    required Uint8List bytes,
    required String filename,
    required KycDocType docType,
  }) async {
    final trimmedUser = userId.trim();
    if (trimmedUser.isEmpty) {
      throw const ValidationException(
        code: 'validation.kycUserRequired',
        messageEn: 'Sign in before uploading a document.',
        messageNe: 'कागजात अपलोड गर्नुअघि साइन इन गर्नुहोस्।',
      );
    }
    if (bytes.isEmpty) {
      throw const ValidationException(
        code: 'validation.kycEmptyFile',
        messageEn: 'That file is empty. Choose a photo or PDF and try again.',
        messageNe:
            'फाइल खाली छ। फोटो वा PDF छानेर पुनः प्रयास गर्नुहोस्।',
      );
    }
    if (bytes.length > _maxKycBytes) {
      throw const ValidationException(
        code: 'validation.kycTooLarge',
        messageEn: 'That file is larger than 10 MB. Choose a smaller file.',
        messageNe: 'फाइल १० MB भन्दा ठूलो छ। सानो फाइल छान्नुहोस्।',
      );
    }
    final extension = _extensionOf(filename);
    if (!_allowedKycExtensions.contains(extension)) {
      throw const ValidationException(
        code: 'validation.kycBadType',
        messageEn: 'Upload a PDF, JPG or PNG file.',
        messageNe: 'PDF, JPG वा PNG फाइल अपलोड गर्नुहोस्।',
      );
    }

    final path =
        '$trimmedUser/${DateTime.now().microsecondsSinceEpoch}_${docType.wireName}$extension';
    try {
      await _client.storage.from(_kycBucket).uploadBinary(
            path,
            bytes,
            fileOptions:
                FileOptions(contentType: _contentTypeFor(extension)),
          );
      return path;
    } on StorageException catch (e) {
      final mapped = PostgrestErrorMapper.mapStorage(
        e,
        action: 'uploadKycFile',
      );
      _logFailure(mapped, action: 'uploadKycFile', cause: e);
      throw mapped;
    }
  }

  /// Submits an uploaded file for admin doc-check via `v1_submit_kyc`.
  ///
  /// Pass `listingId` for Tier 3 per-listing checks (HYA-265); omit it for
  /// Tier 2 identity checks (HYA-264). Citizenship documents are identity-only:
  /// pairing one with a listing is refused here (Rule 6) before the RPC's
  /// own `22023`.
  Future<KycDocument> submitKyc({
    required KycDocType docType,
    required String storagePath,
    String? listingId,
  }) async {
    final trimmedPath = storagePath.trim();
    if (trimmedPath.isEmpty || trimmedPath.contains('..')) {
      throw const ValidationException(
        code: 'validation.kycPathRequired',
        messageEn: 'Upload a document before submitting.',
        messageNe: 'पेस गर्नुअघि कागजात अपलोड गर्नुहोस्।',
      );
    }
    final trimmedListing = (listingId ?? '').trim();
    if (docType == KycDocType.citizenship && trimmedListing.isNotEmpty) {
      throw const ValidationException(
        code: 'validation.kycCitizenshipListing',
        messageEn:
            'Citizenship is verified for your identity, not per listing. '
            'Submit it without a listing.',
        messageNe:
            'नागरिकता पहिचानका लागि प्रमाणित हुन्छ, सूचीका लागि होइन। '
            'सूचीबिना पेस गर्नुहोस्।',
      );
    }

    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_submit_kyc',
        params: buildSubmitParams(
          docType: docType,
          storagePath: trimmedPath,
          listingId: trimmedListing.isEmpty ? null : trimmedListing,
        ),
      ),
      action: 'submitKyc',
    );

    // The RPC answers a summary, not the row: re-read the authoritative row
    // under `kyc_select_own_or_admin` rather than echoing the inputs back.
    final row = await _guard(
      () => _client
          .from('kyc_documents')
          .select()
          .eq('id', response['id'] as String)
          .single(),
      action: 'submitKycReadBack',
    );
    return KycDocument.fromJson(row);
  }

  /// Lists the caller's own KYC documents, newest first.
  ///
  /// No profile filter is sent: RLS already confines the read to the caller's
  /// rows (admins read everything, but admins review through the moderation
  /// path, not this list).
  Future<List<KycDocument>> myDocuments() async {
    final response = await _guard(
      () => _client
          .from('kyc_documents')
          .select()
          .order('created_at', ascending: false),
      action: 'myDocuments',
    );
    return response
        .map(KycDocument.fromJson)
        .toList(growable: false);
  }

  /// Mints a time-boxed signed URL for one private KYC file (Rule 5).
  ///
  /// [expiresIn] is seconds, clamped to 1..3600 so the client can never mint
  /// a longer-lived URL than the service default. The URL is for display or
  /// admin review only — never persisted, because it expires.
  Future<String> documentSignedUrl(
    String storagePath, {
    int expiresIn = 3600,
  }) async {
    final trimmed = storagePath.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.kycPathRequired',
        messageEn: 'That document has no file to show.',
        messageNe: 'यो कागजातमा देखाउने फाइल छैन।',
      );
    }
    if (expiresIn < 1 || expiresIn > 3600) {
      throw const ValidationException(
        code: 'validation.kycExpiryRange',
        messageEn: 'Link expiry must be between 1 second and 1 hour.',
        messageNe: 'लिङ्क म्याद १ सेकेन्डदेखि १ घण्टासम्म हुनुपर्छ।',
      );
    }
    try {
      return await _client.storage
          .from(_kycBucket)
          .createSignedUrl(trimmed, expiresIn);
    } on StorageException catch (e) {
      final mapped = PostgrestErrorMapper.mapStorage(
        e,
        action: 'documentSignedUrl',
      );
      _logFailure(mapped, action: 'documentSignedUrl', cause: e);
      throw mapped;
    }
  }

  /// RPC parameters for `v1_submit_kyc`, exposed for tests.
  ///
  /// Asserting on this map catches a wrong key or a `.name`-vs-wire slip
  /// without a live database (Rule 31). `agencyReg` must arrive as
  /// `agency_reg`: see [KycDocType.wireName].
  @visibleForTesting
  static Map<String, Object?> buildSubmitParams({
    required KycDocType docType,
    required String storagePath,
    String? listingId,
  }) =>
      <String, Object?>{
        'p_doc_type': docType.wireName,
        'p_storage_path': storagePath,
        'p_listing_id': listingId,
      };

  /// Runs [call], converting transport failures into the [AppException]
  /// hierarchy (Rule 38) and logging with full context (Rule 37).
  Future<T> _guard<T>(
    Future<T> Function() call, {
    required String action,
  }) async {
    try {
      return await call();
    } on PostgrestException catch (e) {
      final mapped = PostgrestErrorMapper.map(e, action: action);
      _logFailure(mapped, action: action, cause: e);
      throw mapped;
    } on AuthException catch (e) {
      final mapped = AuthExceptionMapper.map(e, action: action);
      _logFailure(mapped, action: action, cause: e);
      throw mapped;
    }
  }

  /// Records a failed call.
  void _logFailure(
    AppException mapped, {
    required String action,
    required Object cause,
  }) {
    final context = logContext(
      action: action,
      detail: <String, Object?>{'code': mapped.code},
    );

    if (mapped is NetworkException) {
      AppLogger.warning(
        'Network failure in $action',
        context: context,
        error: cause,
      );
      return;
    }

    AppLogger.error(
      'Failed in $action',
      context: context,
      error: cause,
    );
  }
}
