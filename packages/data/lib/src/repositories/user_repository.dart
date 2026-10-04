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

  /// Upload KYC document.
  Future<KycDocument> uploadKycDocument({
    required String profileId,
    required KycDocType docType,
    required String storagePath,
  }) async {
    final response = await _client.rpc<Map<String, dynamic>>(
      'v1_upload_kyc_doc',
      params: <String, Object?>{
        'p_doc_type': docType.name,
        'p_storage_path': storagePath,
      },
    );
    return KycDocument(
      id: response['id'] as String,
      profileId: profileId,
      docType: docType,
      storagePath: storagePath,
    );
  }
}
