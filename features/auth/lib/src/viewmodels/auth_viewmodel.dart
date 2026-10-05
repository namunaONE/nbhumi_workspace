import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

/// Session state for the magic-link flow.
///
/// Mirrors `isSignedInProvider` rather than owning its own session copy so the
/// router's [AuthRefreshNotifier], the profile screen and this notifier can
/// never disagree. The notifier's real job is the side-effects (send link,
/// sign out) plus the validation gate (Rule 6) that belongs above the service.
@riverpod
class Auth extends _$Auth {
  @override
  bool build() {
    return ref.watch(isSignedInProvider);
  }

  /// Emails a sign-in link to [email].
  ///
  /// The message is trimmed and validated before the service is touched: a
  /// malformed address is a user error ([ValidationException]), never a server
  /// call. All [AppException] failures propagate to the screen, which renders
  /// them bilingually with a retry where retryable.
  Future<void> sendMagicLink(String email) async {
    await ref.read(authServiceProvider).sendMagicLink(_validEmail(email));
  }

  /// Creates an account with [email] and [password], then signs in.
  ///
  /// Whether a confirmation email intervenes depends on the project's
  /// "Confirm email" setting: either way the session (now or after the
  /// callback exchange) surfaces through `isSignedInProvider` like a
  /// magic-link session, so the router needs no second path.
  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    await ref.read(authServiceProvider).signUpWithPassword(
          email: _validEmail(email),
          password: _validPassword(password),
        );
  }

  /// Signs in with [email] and [password].
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await ref.read(authServiceProvider).signInWithPassword(
          email: _validEmail(email),
          password: password,
        );
  }

  /// Emails a password-recovery link to [email].
  ///
  /// The link lands on `/auth/callback?type=recovery`, where the callback
  /// screen shows the set-new-password form. GoTrue answers identically for
  /// unknown addresses, so there is nothing to branch on here — and no
  /// enumeration signal to leak.
  Future<void> resetPassword(String email) async {
    await ref
        .read(authServiceProvider)
        .resetPasswordForEmail(_validEmail(email));
  }

  /// Sets a new password for the current recovery session.
  Future<void> updatePassword(String password) async {
    await ref
        .read(authServiceProvider)
        .updatePassword(_validPassword(password));
  }

  /// Trims and validates [email], throwing a bilingual [ValidationException].
  String _validEmail(String email) {
    final trimmed = email.trim();
    if (!Validators.isValidEmail(trimmed)) {
      throw const ValidationException(
        code: 'validation.email',
        messageEn: 'Enter a valid email address.',
        messageNe: 'कृपया सही इमेल ठेगाना लेख्नुहोस्।',
      );
    }
    return trimmed;
  }

  /// Validates [password], throwing a bilingual [ValidationException].
  ///
  /// Length-only by policy (see `Validators.isValidPassword`): composition
  /// theater is not security.
  String _validPassword(String password) {
    if (!Validators.isValidPassword(password)) {
      throw const ValidationException(
        code: 'validation.password',
        messageEn: 'Password must be at least '
            '${Validators.minPasswordLength} characters.',
        messageNe: 'पासवर्ड कम्तीमा '
            '${Validators.minPasswordLength} अक्षरको हुनुपर्छ।',
      );
    }
    return password;
  }

  /// Clears the current session.
  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }
}
