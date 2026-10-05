import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Authentication service — wraps Supabase Auth.
///
/// ### Two sign-in methods, deliberately
///
/// [sendMagicLink] is the **user app's** only method: DATA.md rules out OTP and
/// passwords for buyers and sellers, and the magic link is frictionless on a
/// phone.
///
/// [signInWithPassword] exists **solely for the admin panel** (HYA-259). It is
/// not reachable from the user app, and this class has no sign-up method on
/// purpose:
///
/// * Supabase magic links use the PKCE flow, so the link only validates if
///   opened in the same browser that requested it. The cross-browser fix is the
///   `token_hash` flow, which needs a server-side `/auth/confirm` route that a
///   pure Flutter web build cannot host. Acceptable for a buyer on a phone,
///   not acceptable for the one account that can approve or reject every
///   listing on the platform.
/// * An admin holds approve, reject and (from M2 onward) suspend authority.
///   One shared credential with a rotating password is easier to reason about
///   than a link that may expire unopened, and it leaves TOTP MFA as a
///   straightforward next step.
///
/// Enabling signup on the hosted project means any member of the public can
/// create an account. That is fine for the marketplace and irrelevant to the
/// panel, because the role lives in `profiles.role` and every admin read and
/// write is gated server-side by `private.is_admin()`.
class AuthService {
  /// Wraps a GoTrue client.
  AuthService(this._client);

  final GoTrueClient _client;

  /// Send magic link to email.
  ///
  /// User app only. The redirect is derived from [EnvConfig] (`https://host`
  /// + `/auth/callback`), so this must not be reused by the admin panel, which
  /// authenticates with [signInWithPassword] and never touches the redirect
  /// allowlist.
  ///
  /// The Supabase project must allowlist the redirect (plus the mobile
  /// deep-link URIs from HYA-257) before this works end to end.
  Future<void> sendMagicLink(String email) async {
    try {
      await _client.signInWithOtp(
        email: email,
        emailRedirectTo: EnvConfig.authRedirectUri.toString(),
      );
    } on AuthException catch (e) {
      // Same mapping as every other auth call (Rule 38): rate limits and a
      // raw GoTrue message must never reach the UI unmapped.
      final mapped = AuthExceptionMapper.map(e, action: 'sendMagicLink');
      AppLogger.error(
        'Failed in sendMagicLink',
        context: logContext(
          action: 'sendMagicLink',
          detail: <String, Object?>{'code': mapped.code},
        ),
        error: e,
      );
      throw mapped;
    }
  }

  /// Signs in with an email and password.
  ///
  /// Admin panel only (HYA-259). There is deliberately no matching `signUp`:
  /// accounts on this surface are provisioned out of band by
  /// `supabase/admin_bootstrap.example.sql`, never from a form.
  ///
  /// Throws [AuthFailureException] for wrong credentials and
  /// [ServerException] when Supabase rate-limits the attempt, both carrying a
  /// bilingual message (Rules 35, 36). The underlying gotrue message is never
  /// surfaced: "Invalid login credentials" is deliberately non-enumerating, and
  /// passing it through would not help a legitimate admin anyway.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _client.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      final mapped = AuthExceptionMapper.map(e, action: 'signInWithPassword');
      AppLogger.error(
        'Failed in signInWithPassword',
        // The email is deliberately not logged: log entries are shipped off
        // device, and an admin address is not something to put in one.
        context: logContext(
          action: 'signInWithPassword',
          detail: <String, Object?>{'code': mapped.code},
        ),
        error: e,
      );
      throw mapped;
    }
  }

  /// Exchanges a magic-link callback URL for a session (HYA-257).
  ///
  /// Called by the deep-link handler when an incoming link classifies as an
  /// auth callback. PKCE code exchange happens here; the resulting session is
  /// persisted by GoTrue and surfaces through `onAuthStateChange` like any
  /// other sign-in, which is what flips the router and the `Auth` notifier.
  ///
  /// Throws a mapped [AppException], never a raw [AuthException] (Rule 38).
  Future<void> exchangeSessionFromUrl(Uri url) async {
    try {
      await _client.getSessionFromUrl(url);
    } on AuthException catch (e) {
      final mapped = AuthExceptionMapper.map(
        e,
        action: 'exchangeSessionFromUrl',
      );
      AppLogger.error(
        'Failed in exchangeSessionFromUrl',
        context: logContext(
          action: 'exchangeSessionFromUrl',
          detail: <String, Object?>{'code': mapped.code},
        ),
        error: e,
      );
      throw mapped;
    }
  }

  /// Sign out current user.
  Future<void> signOut() async {
    try {
      await _client.signOut();
    } on AuthException catch (e) {
      final mapped = AuthExceptionMapper.map(e, action: 'signOut');
      AppLogger.error(
        'Failed in signOut',
        context: logContext(
          action: 'signOut',
          detail: <String, Object?>{'code': mapped.code},
        ),
        error: e,
      );
      throw mapped;
    }
  }

  /// Get current session.
  Session? get currentSession => _client.currentSession;

  /// Get current user.
  User? get currentUser => _client.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get onAuthStateChange => _client.onAuthStateChange;
}
