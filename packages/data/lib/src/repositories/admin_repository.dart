import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Repository for the admin verification queue.
///
/// Admin-only by construction: every method here reaches either a
/// `SECURITY DEFINER` RPC gated on `private.is_admin()` or a table whose
/// RLS admits admins. Nothing in this class authorises anything: the server
/// on every call, and a caller without the role gets `42501` mapped to an
/// [AuthFailureException].
///
/// ### Why these are not on the listing repository
///
/// Approve and reject are moderation actions on someone else's data, not edits
/// to a listing the caller owns. Keeping them apart means the write path
/// sellers use cannot accidentally grow an admin capability, and the role
/// requirement is visible in the type rather than buried in a branch.
abstract class AdminRepository {
  /// One page of the verification queue.
  ///
  /// [status] selects the tab. [cursor] advances pagination; pass null for the
  /// first page. Returns an empty [QueuePage] when there is nothing to review,
  /// which is a successful answer rather than an error.
  ///
  /// Throws [AuthFailureException] when the caller is not an admin.
  Future<QueuePage> getQueue({
    ListingStatus status = ListingStatus.pendingReview,
    QueueCursor? cursor,
    int pageSize = 50,
  });

  /// Approves a pending listing, making it live.
  ///
  /// Returns the status the server reports afterwards, rather than void.
  /// Both admin RPCs answer `{"id": …, "status": …}`, and discarding it
  /// would force the UI to *assume* the outcome — to show "approved" on a
  /// request that the database may have resolved differently. Reading it
  /// costs nothing and is the only way to tell an admin that somebody else
  /// got there first.
  ///
  /// Writes an `audit_log` row server-side (Rule 8). Throws
  /// [ValidationException] when the listing is not in `pending_review` — most
  /// often because another admin already actioned it.
  Future<ListingStatus> approveListing(String listingId);

  /// Rejects a pending listing with a reason shown to the seller.
  ///
  /// Returns the status the server reports afterwards, for the same reason as
  /// [approveListing].
  ///
  /// [reason] must be non-blank: the RPC refuses whitespace-only text with
  /// `22023`. Validated here too (Rule 6) so the user sees the problem before a
  /// round trip. Writes an `audit_log` row server-side.
  Future<ListingStatus> rejectListing(String listingId, String reason);

  /// Pending KYC documents, oldest first.
  ///
  /// The admin review inbox for HYA-264 Tier 2 and HYA-265 Tier 3. Reads
  /// `kyc_documents` directly under `kyc_select_own_or_admin`, served by the
  /// `kyc_documents_pending_idx` partial index, rather than through an RPC:
  /// there is nothing to compute server-side. [limit] is clamped to 1..100
  /// here so a careless caller cannot page the whole table in one round trip.
  ///
  /// Throws [AuthFailureException] when the caller is not an admin.
  Future<List<KycDocument>> pendingKycDocuments({int limit = 50});

  /// Verifies a pending KYC document (doc-check only, never legal review).
  ///
  /// Calls `v1_admin_verify_kyc`, which flips `pending` to `verified`, bumps
  /// `profiles.kyc_tier` (`identity` for Tier 2, `property` for Tier 3) and
  /// writes the `audit_log` row (Rule 8). Returns the re-read row rather than
  /// echoing the id, so the admin sees the verdict the database stored.
  ///
  /// Throws [ValidationException] when the document is already reviewed —
  /// most often because another admin actioned it first.
  Future<KycDocument> verifyKyc(String docId);

  /// Rejects a pending KYC document with a reason shown to the seller.
  ///
  /// [reason] must be non-blank: the RPC refuses whitespace-only text with
  /// `22023`. Validated here too (Rule 6). Writes the `audit_log` row with
  /// the reason (Rule 8); the file bytes are purged after 30 days by
  /// `purge_rejected_kyc_docs()`.
  Future<KycDocument> rejectKyc(String docId, String reason);

  /// Admin actions on one entity, newest first.
  ///
  /// Reads `audit_log` directly under `audit_log_select_admin` rather than
  /// through an RPC: there is nothing to hide and nothing to compute, because
  /// RLS already restricts the table to admins. [limit] is bounded server-side.
  Future<List<AuditLogEntry>> auditTrail({
    required String entityId,
    String entityType = 'listing',
    int limit = 50,
  });

  /// One page of the buyer reports queue.
  ///
  /// [status] selects the tab. [cursor] advances pagination; pass null for the
  /// first page. Returns an empty [ReportPage] when there is nothing to review,
  /// which is a successful answer rather than an error.
  ///
  /// Throws [AuthFailureException] when the caller is not an admin.
  Future<ReportPage> getReports({
    ReportStatus status = ReportStatus.open,
    ReportCursor? cursor,
    int pageSize = 50,
  });

  /// Closes a report as actioned or dismissed.
  ///
  /// Returns the status the server stored rather than echoing [resolution],
  /// for the same reason [approveListing] returns rather than void: a response
  /// that does not say what it did means somebody else resolved the report
  /// first, and the admin should be told that rather than shown a success.
  ///
  /// Writes an `audit_log` row server-side in the same transaction (Rule 8).
  /// The row is recorded against the *listing*, not the report, so a report
  /// outcome shows up in the listing's existing audit trail.
  ///
  /// Throws [ValidationException] when the report is not open — most often
  /// because another admin resolved it first.
  Future<ReportStatus> resolveReport(
    String reportId,
    ReportResolution resolution,
  );

  /// Suspends an account (HYA-262).
  ///
  /// A suspended seller keeps their role and history but cannot insert or
  /// update listings — enforced both in the write RPCs (readable 42501) and
  /// in the RLS backstop (unbypassable). Existing live listings stay live:
  /// hiding inventory is a separate per-listing decision via
  /// [unpublishListing]. Writes an `audit_log` row server-side (Rule 8).
  ///
  /// [reason] must be non-blank (Rule 6, validated here and in the RPC).
  /// Throws [ValidationException] when the account is already suspended, is
  /// the caller's own, or is another admin.
  Future<AdminUser> suspendUser(String userId, String reason);

  /// Lifts a suspension, restoring write access. Audited like every other
  /// admin action. Throws [ValidationException] when the account is not
  /// currently suspended.
  Future<AdminUser> unsuspendUser(String userId);

  /// Pulls a live listing (HYA-262).
  ///
  /// Returns the status the server reports, for the same reason
  /// [approveListing] returns rather than void. Distinct from a rejection:
  /// the seller sees an unpublish reason, not a failed review, and the audit
  /// trail records `unpublish` rather than `reject`.
  ///
  /// Throws [ValidationException] when the listing is not live — most often
  /// because another admin already unpublished it.
  Future<ListingStatus> unpublishListing(String listingId, String reason);

  /// Returns an unpublished listing to live. Audited. Throws
  /// [ValidationException] when the listing is not unpublished.
  Future<ListingStatus> republishListing(String listingId);

  /// Reads one account for moderation (HYA-262).
  ///
  /// Returns suspension state, per-status listing counts, and how many open
  /// reports name this seller — the three facts an admin needs before
  /// suspending. Throws [AuthFailureException] for non-admins,
  /// [ValidationException]-mapped not-found when the id is unknown.
  Future<AdminUser> getUser(String userId);
}

/// Supabase-backed [AdminRepository].
class SupabaseAdminRepository implements AdminRepository {
  /// Wraps a Supabase client.
  SupabaseAdminRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<QueuePage> getQueue({
    ListingStatus status = ListingStatus.pendingReview,
    QueueCursor? cursor,
    int pageSize = 50,
  }) async {
    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_get_queue',
        params: <String, Object?>{
          'p_status': status.wireName,
          // Spread rather than assigned conditionally: PostgREST sends every
          // declared parameter, and the RPC's `coalesce` exists because
          // an explicit null would otherwise defeat the SQL default.
          // Omitting the key entirely is tidier and equally wrong: see
          // note in the migration about what the client actually sends.
          ...?cursor?.toRpcParams(),
          'p_page_size': pageSize,
        },
      ),
      action: 'getQueue',
    );

    // The RPC returns a json object rather than a table, so there is no
    // PostgREST row mapping here: parsing is QueuePage's job, and it owns the
    // cursor rules.
    return QueuePage.fromJson(response);
  }

  @override
  Future<ReportPage> getReports({
    ReportStatus status = ReportStatus.open,
    ReportCursor? cursor,
    int pageSize = 50,
  }) async {
    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_get_reports',
        params: buildReportParams(
          status: status,
          cursor: cursor,
          pageSize: pageSize,
        ),
      ),
      action: 'getReports',
    );

    return ReportPage.fromJson(response);
  }

  @override
  Future<ListingStatus> approveListing(String listingId) async {
    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_approve_listing',
        params: <String, Object?>{'p_listing_id': listingId},
      ),
      action: 'approveListing',
    );

    return _readStatus(response, action: 'approveListing');
  }

  @override
  Future<ListingStatus> rejectListing(String listingId, String reason) async {
    final trimmed = reason.trim();

    // Checked client-side as well as server-side (Rule 6). The RPC already
    // refuses a blank reason with 22023; catching it here means the admin sees
    // the complaint against the field they typed into rather than as a toast
    // after a round trip.
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.rejectionReasonRequired',
        messageEn: 'Please give a reason so the seller knows what to fix.',
        messageNe: 'विक्रेतालाई के मिलाउने भन्ने जानकारी दिनुहोस्।',
      );
    }

    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_reject_listing',
        params: <String, Object?>{
          'p_listing_id': listingId,
          'p_reason': trimmed,
        },
      ),
      action: 'rejectListing',
    );

    return _readStatus(response, action: 'rejectListing');
  }

  @override
  Future<List<KycDocument>> pendingKycDocuments({int limit = 50}) async {
    // Clamping is the caller's honesty bound: the table grows with every
    // submission the platform ever receives, and an unbounded read is a cheap
    // way to pull all of it in one round trip.
    // Written out rather than `limit.clamp(1, 100)`: `clamp` returns num,
    // and the implicit downcast is a no-op the analyzer flags. The explicit
    // form states the int-ness rather than leaving it to inference.
    final int bounded;
    if (limit < 1) {
      bounded = 1;
    } else if (limit > 100) {
      bounded = 100;
    } else {
      bounded = limit;
    }
    final response = await _guard(
      () => _client
          .from('kyc_documents')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: true)
          .limit(bounded),
      action: 'pendingKycDocuments',
    );

    return response.map(KycDocument.fromJson).toList(growable: false);
  }

  @override
  Future<KycDocument> verifyKyc(String docId) async {
    final trimmed = docId.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.kycDocIdRequired',
        messageEn: 'That document could not be found. Refresh and try again.',
        messageNe: 'यो कागजात फेला परेन। ताजा पारेर पुनः प्रयास गर्नुहोस्।',
      );
    }

    await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_verify_kyc',
        params: buildVerifyKycParams(docId: trimmed),
      ),
      action: 'verifyKyc',
    );

    return await _readKycDocument(trimmed, action: 'verifyKyc');
  }

  @override
  Future<KycDocument> rejectKyc(String docId, String reason) async {
    final trimmedId = docId.trim();
    final trimmedReason = reason.trim();

    if (trimmedId.isEmpty) {
      throw const ValidationException(
        code: 'validation.kycDocIdRequired',
        messageEn: 'That document could not be found. Refresh and try again.',
        messageNe: 'यो कागजात फेला परेन। ताजा पारेर पुनः प्रयास गर्नुहोस्।',
      );
    }

    // Same reasoning as [rejectListing]: the RPC refuses a blank reason with
    // 22023, but catching it here puts the complaint against the field the
    // admin typed into rather than a toast after a round trip.
    if (trimmedReason.isEmpty) {
      throw const ValidationException(
        code: 'validation.kycRejectionReasonRequired',
        messageEn: 'Please give a reason so the seller knows what to fix.',
        messageNe: 'विक्रेतालाई के मिलाउने भन्ने जानकारी दिनुहोस्।',
      );
    }

    await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_reject_kyc',
        params: buildRejectKycParams(
          docId: trimmedId,
          reason: trimmedReason,
        ),
      ),
      action: 'rejectKyc',
    );

    return await _readKycDocument(trimmedId, action: 'rejectKyc');
  }

  /// Reads the `status` out of an admin RPC's response.
  ///
  /// Throws rather than defaulting. A response without a recognisable status
  /// is a contract break between this client and the database, and defaulting
  /// to [ListingStatus.live] would report a rejection as an approval — the
  /// worst available failure, because the admin would leave believing the
  /// listing was published. A mapped [ServerException] surfaces as "that did
  /// not work, try again", which is honest and actionable.
  ListingStatus _readStatus(
    Map<String, dynamic> response, {
    required String action,
  }) {
    final raw = response['status'];

    if (raw is String) {
      for (final status in ListingStatus.values) {
        if (status.wireName == raw) return status;
      }
    }

    const failure = ServerException(
      code: 'server.unexpectedResponse',
      messageEn: 'The server accepted the decision but did not say what it '
          'did. Nothing was changed — please try again.',
      // Nepali + English on every user-facing message (Rule 36). The two
      // clauses are separated rather than joined so a translator can reorder
      // them, which Nepali grammar often needs.
      messageNe: 'सर्भरले निर्णय स्वीकार गर्‍यो तर के परिवर्तन भयो भन्ने '
          'जानकारी दिएन। केही परिवर्तन भएको छैन — कृपया फेरि प्रयास '
          'गर्नुहोस्।',
    );
    _logFailure(
      failure,
      action: action,
      cause: StateError(
        'v1_admin_*_listing returned no usable status: $response',
      ),
      detail: <String, Object?>{'response': response},
    );
    throw failure;
  }

  /// Re-reads one KYC row after a verdict RPC.
  ///
  /// The RPC answers a summary (`{"id": …, "status": …}`); the row is the
  /// source of truth for everything the review screen renders (doc type,
  /// listing binding, reviewer, timestamps). A missing row is remapped from
  /// the generic `server.notFound` to an honest "no longer pending", because
  /// the only thing this read can not find is a document that another admin
  /// already actioned or the purge already removed.
  Future<KycDocument> _readKycDocument(
    String docId, {
    required String action,
  }) async {
    try {
      final row = await _guard(
        () => _client.from('kyc_documents').select().eq('id', docId).single(),
        action: action,
      );
      return KycDocument.fromJson(row);
    } on ServerException catch (e) {
      if (e.code == 'server.notFound') {
        throw ValidationException(
          code: 'validation.kycNotFound',
          messageEn: 'That document is no longer pending review.',
          messageNe: 'यो कागजात अब समीक्षामा छैन।',
          context: action,
          cause: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<AuditLogEntry>> auditTrail({
    required String entityId,
    String entityType = 'listing',
    int limit = 50,
  }) async {
    final response = await _guard(
      () => _client
          .from('audit_log')
          .select()
          .eq('entity_type', entityType)
          .eq('entity_id', entityId)
          .order('created_at', ascending: false)
          .limit(limit),
      action: 'auditTrail',
    );

    return response.map(AuditLogEntry.fromJson).toList(growable: false);
  }

  /// Closes a report as actioned or dismissed.
  @override
  Future<ReportStatus> resolveReport(
    String reportId,
    ReportResolution resolution,
  ) async {
    final trimmed = reportId.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.reportIdRequired',
        messageEn: 'That report could not be found. Refresh and try again.',
        messageNe: 'यो रिपोर्ट फेला परेन। ताजा पारेर पुनः प्रयास गर्नुहोस्।',
      );
    }

    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_resolve_report',
        params: <String, Object?>{
          'p_report_id': trimmed,
          // resolution.name, not a wireName lookup: ReportResolution has no
          // multi-word value, so the Dart name IS the enum label. Both labels
          // are checked against the report_status enum in the model, and the
          // RPC refuses anything else with 22023 — so a future value added to
          // only one of the two places fails loudly rather than silently
          // resolving the report under a name the database does not have.
          'p_resolution': resolution.name,
        },
      ),
      action: 'resolveReport',
    );

    return _readReportStatus(response, action: 'resolveReport');
  }

  @override
  Future<AdminUser> suspendUser(String userId, String reason) async {
    final trimmedId = userId.trim();
    if (trimmedId.isEmpty) {
      throw const ValidationException(
        code: 'validation.userIdRequired',
        messageEn: 'That account could not be found. Refresh and try again.',
        messageNe: 'यो खाता फेला परेन। ताजा पारेर पुनः प्रयास गर्नुहोस्।',
      );
    }

    final trimmedReason = reason.trim();

    // Same Rule 6 ordering as rejectListing: the RPC refuses a blank reason
    // with 22023, but the complaint belongs against the field the admin typed
    // into, not in a toast after a round trip.
    if (trimmedReason.isEmpty) {
      throw const ValidationException(
        code: 'validation.suspensionReasonRequired',
        messageEn: 'Please give a reason. Suspensions without one cannot '
            'be appealed against.',
        messageNe: 'कृपया कारण दिनुहोस्। कारणबिना निलम्बनमाथि पुनरावेदन '
            'गर्न सकिँदैन।',
      );
    }

    await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_suspend_user',
        params: buildSuspendUserParams(
          userId: trimmedId,
          reason: trimmedReason,
        ),
      ),
      action: 'suspendUser',
    );

    // Re-read rather than echo: the row is the source of truth for what the
    // database stored (timestamps, actor), the same reason verifyKyc re-reads
    // the document instead of trusting the RPC summary.
    return await getUser(trimmedId);
  }

  @override
  Future<AdminUser> unsuspendUser(String userId) async {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.userIdRequired',
        messageEn: 'That account could not be found. Refresh and try again.',
        messageNe: 'यो खाता फेला परेन। ताजा पारेर पुनः प्रयास गर्नुहोस्।',
      );
    }

    await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_unsuspend_user',
        params: <String, Object?>{'p_user_id': trimmed},
      ),
      action: 'unsuspendUser',
    );

    return await getUser(trimmed);
  }

  @override
  Future<ListingStatus> unpublishListing(
    String listingId,
    String reason,
  ) async {
    final trimmedId = listingId.trim();
    if (trimmedId.isEmpty) {
      throw const ValidationException(
        code: 'validation.listingIdRequired',
        messageEn: 'That listing could not be found. Refresh and try again.',
        messageNe: 'यो लिस्टिङ फेला परेन। ताजा पारेर पुनः प्रयास गर्नुहोस्।',
      );
    }

    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw const ValidationException(
        code: 'validation.unpublishReasonRequired',
        messageEn: 'Please give a reason so the seller knows what to fix.',
        messageNe: 'विक्रेतालाई के मिलाउने भन्ने जानकारी दिनुहोस्।',
      );
    }

    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_unpublish_listing',
        params: <String, Object?>{
          'p_listing_id': trimmedId,
          'p_reason': trimmedReason,
        },
      ),
      action: 'unpublishListing',
    );

    return _readStatus(response, action: 'unpublishListing');
  }

  @override
  Future<ListingStatus> republishListing(String listingId) async {
    final trimmed = listingId.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.listingIdRequired',
        messageEn: 'That listing could not be found. Refresh and try again.',
        messageNe: 'यो लिस्टिङ फेला परेन। ताजा पारेर पुनः प्रयास गर्नुहोस्।',
      );
    }

    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_republish_listing',
        params: <String, Object?>{'p_listing_id': trimmed},
      ),
      action: 'republishListing',
    );

    return _readStatus(response, action: 'republishListing');
  }

  @override
  Future<AdminUser> getUser(String userId) async {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.userIdRequired',
        messageEn: 'That account could not be found. Refresh and try again.',
        messageNe: 'यो खाता फेला परेन। ताजा पारेर पुनः प्रयास गर्नुहोस्।',
      );
    }

    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_admin_get_user',
        params: <String, Object?>{'p_user_id': trimmed},
      ),
      action: 'getUser',
    );

    return AdminUser.fromJson(response);
  }

  /// Reads the `status` out of `v1_admin_resolve_report`'s response.
  ///
  /// Throws rather than defaulting, for the same reason [_readStatus] does and
  /// with the same severity: defaulting to [ReportStatus.dismissed] after an
  /// *actioned* resolution would tell the admin the seller was cleared when the
  /// listing was actually pulled.
  ///
  /// [ReportStatus.open] is refused even though it is a real status, and the
  /// reason is the SQL bug this function exists to catch: the first version of
  /// `v1_admin_resolve_report` reused one variable for both the requested
  /// resolution and the row's current status, so the UPDATE wrote `status =
  /// 'open'` while still stamping `resolved_at`. A response saying `open` means
  /// the report was not resolved, and returning it would show the admin a
  /// success for work that did not happen.
  ///
  /// The database now prevents that twice over — the two-variable fix, plus
  /// `reports_resolution_consistent`, which refuses an open row carrying a
  /// resolution timestamp. This is the third layer, and it is the one that
  /// reports the problem as a failed action rather than as a silent no-op.
  ReportStatus _readReportStatus(
    Map<String, dynamic> response, {
    required String action,
  }) {
    final raw = response['status'];

    if (raw is String) {
      for (final status in ReportStatus.values) {
        if (status.name != raw) continue;
        if (status == ReportStatus.open) break;
        return status;
      }
    }

    const failure = ServerException(
      code: 'server.unexpectedResponse',
      messageEn: 'The server accepted the decision but did not say what it '
          'did. Nothing was changed — please try again.',
      messageNe: 'सर्भरले निर्णय स्वीकार गर्‍यो तर के परिवर्तन भयो भन्ने '
          'जानकारी दिएन। केही परिवर्तन भएको छैन — कृपया फेरि प्रयास '
          'गर्नुहोस्।',
    );
    _logFailure(
      failure,
      action: action,
      cause: StateError(
        'v1_admin_resolve_report returned no usable resolved status: '
        '$response',
      ),
      detail: <String, Object?>{'response': response},
    );
    throw failure;
  }

  /// Runs [call], converting transport failures into the [AppException]
  /// hierarchy so callers only match on types they can render (Rule 38), and
  /// logging with full context (Rule 37).
  ///
  /// Mirrors the listing repository's guard. Duplicated rather than extracted:
  /// it is nine lines, and lifting it into a mixin or shared base couples
  /// two repositories with no reason to know each other. The rule that
  /// matters is that every *call site* is wrapped, not that the wrapper is
  /// shared.
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
  ///
  /// Network failures log at warning: a dropped connection is expected rather
  /// than an incident, and promoting every blip to an error buries the real
  /// ones. Everything else is an error.
  ///
  /// `detail` is included for the admin actions, where knowing *which* listing
  /// failed matters: this is the surface where a mistake is a moderation error
  /// against a real seller rather than a cosmetic failure.
  void _logFailure(
    AppException mapped, {
    required String action,
    required Object cause,
    Map<String, Object?>? detail,
  }) {
    final context = logContext(
      action: action,
      detail: <String, Object?>{...?detail, 'code': mapped.code},
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

  /// RPC parameters for [getQueue], exposed for tests.
  ///
  /// Same reasoning as `ListingRepository.buildCreateParams`: asserting on the
  /// parameter map catches a wrong key or dropped cursor without needing
  /// a live database, which Rule 31 forbids in the unit test loop.
  @visibleForTesting
  static Map<String, Object?> buildQueueParams({
    ListingStatus status = ListingStatus.pendingReview,
    QueueCursor? cursor,
    int pageSize = 50,
  }) =>
      <String, Object?>{
        'p_status': status.wireName,
        ...?cursor?.toRpcParams(),
        'p_page_size': pageSize,
      };

  /// RPC parameters for `v1_admin_verify_kyc`, exposed for tests.
  ///
  /// A one-key map today; asserted so a renamed parameter fails here rather
  /// than as a 400 from PostgREST with the admin staring at a queue.
  @visibleForTesting
  static Map<String, Object?> buildVerifyKycParams({
    required String docId,
  }) =>
      <String, Object?>{'p_doc_id': docId};

  /// RPC parameters for `v1_admin_reject_kyc`, exposed for tests.
  ///
  /// Takes the already-trimmed reason: trimming is the caller's job
  /// ([rejectKyc]), and asserting on this map pins the wire contract —
  /// `p_reason` arrives trimmed, so the seller never reads stray whitespace
  /// in the rejection notice.
  @visibleForTesting
  static Map<String, Object?> buildRejectKycParams({
    required String docId,
    required String reason,
  }) =>
      <String, Object?>{
        'p_doc_id': docId,
        'p_reason': reason,
      };

  /// RPC parameters for [getReports], exposed for tests.
  ///
  /// Separate from [buildQueueParams] even though the two look alike, because
  /// asserting on the key *name* is what catches a rename: a shared builder
  /// would let both tests pass against one shape while the other RPC silently
  /// changed. `p_cursor` / `p_cursor_id` are the same names but order reports
  /// by `(created_at, id)` where the queue orders by `(submitted_at, id)`.
  @visibleForTesting
  static Map<String, Object?> buildReportParams({
    ReportStatus status = ReportStatus.open,
    ReportCursor? cursor,
    int pageSize = 50,
  }) =>
      <String, Object?>{
        'p_status': status.name,
        ...?cursor?.toRpcParams(),
        'p_page_size': pageSize,
      };

  /// RPC parameters for [resolveReport], exposed for tests.
  ///
  /// A two-key map; asserted so a renamed parameter fails here rather than as a
  /// 400 from PostgREST with the admin staring at a queue.
  @visibleForTesting
  static Map<String, Object?> buildResolveReportParams({
    required String reportId,
    required ReportResolution resolution,
  }) =>
      <String, Object?>{
        'p_report_id': reportId,
        'p_resolution': resolution.name,
      };

  /// RPC parameters for [suspendUser], exposed for tests.
  ///
  /// Takes the already-trimmed reason: trimming is the caller's job
  /// ([suspendUser]), and asserting here pins that the wire carries no stray
  /// whitespace into the audit row a future appeal will be judged against.
  @visibleForTesting
  static Map<String, Object?> buildSuspendUserParams({
    required String userId,
    required String reason,
  }) =>
      <String, Object?>{
        'p_user_id': userId,
        'p_reason': reason,
      };
}
