import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

/// Auth state notifier.
@riverpod
class Auth extends _$Auth {
  @override
  bool build() {
    // TODO: Implement auth state
    return false;
  }

  /// Send magic link to email.
  Future<void> sendMagicLink(String email) async {
    // TODO: Implement magic link
  }

  /// Sign out.
  Future<void> signOut() async {
    // TODO: Implement sign out
  }
}
