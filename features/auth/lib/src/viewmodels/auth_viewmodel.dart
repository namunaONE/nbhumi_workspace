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
    final trimmed = email.trim();
    if (!Validators.isValidEmail(trimmed)) {
      throw const ValidationException(
        code: 'validation.email',
        messageEn: 'Enter a valid email address.',
        messageNe: 'कृपया सही इमेल ठेगाना लेख्नुहोस्।',
      );
    }
    await ref.read(authServiceProvider).sendMagicLink(trimmed);
  }

  /// Clears the current session.
  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }
}
