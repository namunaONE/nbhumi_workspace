import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Repository for user data.
class UserRepository {
  /// Wraps a Supabase client.
  UserRepository(this._client);

  final SupabaseClient _client;

  /// Get user by ID.
  Future<Profile?> getUserById(String id) {
    return _guard(
      () async {
        final response = await _client
            .from('profiles')
            .select()
            .eq('id', id)
            .maybeSingle();

        if (response == null) return null;
        return Profile.fromJson(response);
      },
      action: 'getUserById',
    );
  }

  /// Update user profile.
  ///
  /// Sends the whole profile, but only the editable fields can actually change:
  /// `profiles_update_own` pins `role`, `is_verified` and `kyc_tier` to their
  /// current values, so a client cannot self-promote by posting a doctored
  /// payload. The server is the owner of that rule, not this method.
  Future<Profile> updateProfile(Profile profile) async {
    final response = await _guard(
      () => _client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single(),
      action: 'updateProfile',
    );
    return Profile.fromJson(response);
  }

  /// Exports everything the platform holds about [userId], as plain JSON.
  ///
  /// Privacy Act 2075 data-subject right. Assembled client-side from the three
  /// tables the owner can already read (profile, own listings including drafts,
  /// own contact reveals) rather than through a dedicated RPC, so there is no
  /// new server surface to secure and every row in the export is one the
  /// caller could already see. All values come back from PostgREST as JSON
  /// primitives, so the map encodes directly with `jsonEncode`.
  Future<Map<String, Object?>> exportMyData({
    required String userId,
  }) {
    return _guard(
      () async {
        final profile = await _client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        final listings = await _client
            .from('listings')
            .select(
              'id, title, description, price_npr, district, city, ward, '
              'property_type, listing_purpose, status, created_at, updated_at',
            )
            .eq('seller_id', userId)
            .order('created_at');

        final reveals = await _client
            .from('contact_logs')
            .select('listing_id, revealed_at, expires_at')
            .eq('buyer_id', userId)
            .order('revealed_at');

        return <String, Object?>{
          'exported_at': DateTime.now().toUtc().toIso8601String(),
          'profile': profile,
          'listings': listings,
          'contact_reveals': reveals,
        };
      },
      action: 'exportMyData',
    );
  }

  /// Deletes the caller's account via `v1_delete_my_account`.
  ///
  /// Returns the server's summary (anonymized listings, retained logs). A
  /// repeat call after a successful delete answers P0002, which the generic
  /// mapper would word as a missing *listing* — remapped here to an honest
  /// "already deleted", because that is the only thing this call can not find.
  Future<Map<String, Object?>> deleteMyAccount() async {
    try {
      final response = await _guard(
        () => _client.rpc<Map<String, dynamic>>('v1_delete_my_account'),
        action: 'deleteMyAccount',
      );
      return response;
    } on ServerException catch (e) {
      if (e.code == 'server.notFound') {
        throw ValidationException(
          code: 'account.alreadyDeleted',
          messageEn: 'Your account is already deleted.',
          messageNe: 'तपाईंको खाता पहिले नै मेटिसकिएको छ।',
          context: 'deleteMyAccount',
          cause: e,
        );
      }
      rethrow;
    }
  }

  /// Upload a KYC document.
  ///
  /// ### Not implemented — do not call
  ///
  /// There is no `v1_upload_kyc_doc` RPC, no `kyc_documents` table and no
  /// `kyc-documents` Storage bucket in any migration. This method previously
  /// issued the RPC call anyway, so it failed at runtime with a PostgREST
  /// `PGRST202` (function not found) rather than at compile time. Nothing calls
  /// it today, which is the only reason that stayed quiet.
  ///
  /// KYC is M3, scoped to HYA-264 (citizenship upload, admin doc review,
  /// verified badge). It is deliberately *not* pulled into M2: the verification
  /// queue reviews listings, and showing a document viewer there would mean
  /// building the whole KYC subsystem — private bucket, signed URLs, a 30-day
  /// rejected-document purge and the Privacy Act 2075 retention rules — as a
  /// prerequisite for reviewing a listing's photos and price.
  ///
  /// The signature is kept so the call site in a future M3 PR is obvious, and
  /// so the model type stays referenced by the data layer. Throwing
  /// [UnimplementedError] makes the gap fail loudly at the first attempt
  /// instead of silently once more.
  ///
  /// When HYA-264 lands this becomes a real `v1_upload_kyc_doc` call, and the
  /// upload itself must go to the **private** `kyc-documents` bucket (Rule 5) —
  /// not to `listing-photos`, which is public by design.
  Future<KycDocument> uploadKycDocument({
    required String profileId,
    required KycDocType docType,
    required String storagePath,
  }) {
    throw UnimplementedError(
      'KYC upload is M3 / HYA-264. No v1_upload_kyc_doc RPC, kyc_documents '
      'table or kyc-documents bucket exists yet. See the doc comment on '
      'UserRepository.uploadKycDocument.',
    );
  }

  /// Runs [call], converting failures into the [AppException] hierarchy so
  /// callers only ever match on types they can render (Rule 38), and logging
  /// the failure with full context (Rule 37).
  Future<T> _guard<T>(
    Future<T> Function() call, {
    required String action,
  }) async {
    try {
      return await call();
    } on PostgrestException catch (e) {
      final mapped = PostgrestErrorMapper.map(e, action: action);
      AppLogger.error(
        'User failure in $action',
        context: logContext(
          action: action,
          detail: <String, Object?>{'code': mapped.code},
        ),
        error: e,
      );
      throw mapped;
    }
  }
}
