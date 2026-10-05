import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for user data.
class UserRepository {
  /// Wraps a Supabase client.
  UserRepository(this._client);

  final SupabaseClient _client;

  /// Get user by ID.
  Future<Profile?> getUserById(String id) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Profile.fromJson(response);
  }

  /// Update user profile.
  Future<Profile> updateProfile(Profile profile) async {
    final response = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();
    return Profile.fromJson(response);
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
}
