import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for authentication data.
class AuthRepository {
  /// Wraps a Supabase client.
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Get current profile.
  Future<Profile?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return Profile.fromJson(response);
  }

  /// Create or update profile.
  Future<Profile> upsertProfile(Profile profile) async {
    final response = await _client
        .from('profiles')
        .upsert(profile.toJson())
        .select()
        .single();
    return Profile.fromJson(response);
  }

  /// Stream of auth state changes.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
}
