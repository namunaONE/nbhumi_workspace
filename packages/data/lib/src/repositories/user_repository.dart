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

  /// KYC lives in `KycRepository`, not here.
  ///
  /// Removed in HYA-264 A2: this class once carried an `uploadKycDocument`
  /// stub that threw [UnimplementedError] because no table, RPC or bucket
  /// existed. The migration `20261005120000_kyc_documents_tier2_tier3.sql`
  /// now provides them, and `KycRepository` (`uploadKycFile` + `submitKyc` +
  /// `myDocuments` + `documentSignedUrl`) is the call site. Kept as a note
  /// so a stale tutorial or branch referencing the old signature lands here
  /// instead of silently re-adding it.

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
