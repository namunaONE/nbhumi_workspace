import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Authentication service — wraps Supabase Auth.
///
/// ### Email + password only
///
/// The user app signs up and signs in with email and password; there is no
/// magic-link path. [signUpWithPassword] creates the account (email
/// confirmation enforced server-side), [signInWithPassword] opens sessions,
/// [resetPasswordForEmail] + [updatePassword] cover recovery through the same
/// `/auth/callback` exchange. The login screen offers sign-in, account
/// creation and recovery; nothing else is accepted.
///
/// [signInWithPassword] is shared with the **admin panel** (HYA-259). One
/// shared credential with a rotating password is easier to reason about than
/// a link that may expire unopened, and it leaves TOTP MFA as a
/// straightforward next step.
///
/// There is no app-side sign-up *form* logic beyond validation: accounts are
/// created by [signUpWithPassword] and confirmed through the `/auth/callback`
/// exchange before the first session exists.
///
/// Enabling signup on the hosted project means any member of the public can
/// create an account. That is fine for the marketplace and irrelevant to the
/// panel, because the role lives in `profiles.role` and every admin read and
/// write is gated server-side by `private.is_admin()`.
///
/// Password hygiene notes for the operator: enable leaked-password protection
/// in the Supabase dashboard, and keep the recovery email template
/// (`supabase/email-templates/recovery.html`) in sync with the confirmation
/// one.
class AuthService {
  /// Wraps a GoTrue client.
  AuthService(this._client);

  final GoTrueClient _client;

  /// Signs up with an email and password.
  ///
  /// User app (and any future surface that wants it). Confirmation goes
  /// through the `/auth/callback` exchange when the project requires email
  /// confirmation; the redirect is [EnvConfig]'s, so the allowlist covers
  /// both signup confirmation and recovery.
  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _client.signUp(
        email: email,
        password: password,
        emailRedirectTo: EnvConfig.authRedirectUri.toString(),
      );
    } on AuthException catch (e) {
      final mapped = AuthExceptionMapper.map(e, action: 'signUpWithPassword');
      AppLogger.error(
        'Failed in signUpWithPassword',
        context: logContext(
          action: 'signUpWithPassword',
          detail: <String, Object?>{'code': mapped.code},
        ),
        error: e,
      );
      throw mapped;
    }
  }

  /// Emails a password-recovery link.
  ///
  /// The redirect carries `?type=recovery` so the callback screen knows to
  /// show the set-new-password form instead of the signed-in hop. Same
  /// allowlist as signup confirmation, plus the query string — if Supabase
  /// ever rejects it, its wildcard form covers it (see
  /// `deep-links/README.md`).
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _client.resetPasswordForEmail(
        email,
        redirectTo: EnvConfig.authRedirectUri
            .replace(queryParameters: <String, String>{'type': 'recovery'})
            .toString(),
      );
    } on AuthException catch (e) {
      final mapped = AuthExceptionMapper.map(
        e,
        action: 'resetPasswordForEmail',
      );
      AppLogger.error(
        'Failed in resetPasswordForEmail',
        context: logContext(
          action: 'resetPasswordForEmail',
          detail: <String, Object?>{'code': mapped.code},
        ),
        error: e,
      );
      throw mapped;
    }
  }

  /// Sets a new password for the current recovery session.
  ///
  /// Called from the recovery form after the callback exchange establishes
  /// the session. Never the email — that identifies the account and is not
  /// the caller's to change here.
  Future<void> updatePassword(String password) async {
    try {
      await _client.updateUser(UserAttributes(password: password));
    } on AuthException catch (e) {
      final mapped = AuthExceptionMapper.map(e, action: 'updatePassword');
      AppLogger.error(
        'Failed in updatePassword',
        context: logContext(
          action: 'updatePassword',
          detail: <String, Object?>{'code': mapped.code},
        ),
        error: e,
      );
      throw mapped;
    }
  }

  /// Signs in with an email and password.
  ///
  /// Shared by the user app's password pane and the admin panel (HYA-259).
  /// There is deliberately no app-side password policy beyond length:
  /// accounts on the admin surface are provisioned out of band by
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

  /// Exchanges an email-confirmation or recovery callback URL for a session.
  ///
  /// Called by the deep-link handler when an incoming link classifies as an
  /// auth callback. PKCE code exchange happens here; the resulting session is
  /// persisted by GoTrue and surfaces through `onAuthStateChange` like any
  /// other sign-in, which is what flips the router and the `Auth` notifier.
  ///
  /// Returns whether this was a password-recovery exchange. GoTrue records
  /// the intent with the PKCE verifier, so a caller cannot turn an ordinary
  /// sign-in link into a recovery flow by appending `?type=recovery`.
  ///
  /// Throws a mapped [AppException], never a raw [AuthException] (Rule 38).
  ///
  /// Token-shaped failures map through
  /// [AuthExceptionMapper.mapCallbackExchange] rather than
  /// [AuthExceptionMapper.map]: the exchange redeems a one-time
  /// link and there is no session yet that could have expired, so reporting
  /// them as `auth.sessionExpired` would tell a user who never had a session
  /// something confusing. They surface as `auth.linkInvalid` instead.
  Future<bool> exchangeSessionFromUrl(Uri url) async {
    try {
      final response = await _client.getSessionFromUrl(url);
      return response.redirectType == AuthChangeEvent.passwordRecovery.name;
    } on AuthException catch (e) {
      final mapped = AuthExceptionMapper.mapCallbackExchange(
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
