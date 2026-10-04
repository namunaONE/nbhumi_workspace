import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

/// Session state for the magic-link flow.
///
/// Every method is a stub. HYA-202 fills them in once the deep-link plumbing
/// exists, because sending a magic link before the app can receive the
/// redirect would leave users stranded on a "check your inbox" screen with no
/// way back in.
@riverpod
class Auth extends _$Auth {
  @override
  bool build() {
    // TODO(HYA-202): read the session from Supabase, not a hardcoded false.
    return false;
  }

  /// Emails a sign-in link to [email].
  Future<void> sendMagicLink(String email) async {
    // TODO(HYA-202): call AuthService.sendMagicLink and surface a sent state.
  }

  /// Clears the current session.
  Future<void> signOut() async {
    // TODO(HYA-202): call AuthService.signOut and invalidate the profile cache.
  }
}
