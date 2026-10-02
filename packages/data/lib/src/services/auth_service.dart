import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service — wraps Supabase Auth.
///
/// Magic link only (NO OTP).
class AuthService {
  AuthService(this._client);

  final GoTrueClient _client;

  /// Send magic link to email.
  Future<void> sendMagicLink(String email) async {
    await _client.signInWithOtp(
      email: email,
      emailRedirectTo: 'https://nbhumi.com/auth/callback',
    );
  }

  /// Sign out current user.
  Future<void> signOut() async {
    await _client.signOut();
  }

  /// Get current session.
  Session? get currentSession => _client.currentSession;

  /// Get current user.
  User? get currentUser => _client.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get onAuthStateChange => _client.onAuthStateChange;
}
