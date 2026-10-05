import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import 'session_logging.dart';

/// Emits on every Supabase auth change.
///
/// The single source of auth truth for the whole app. Both routers previously
/// declared their own private copy, which is how they ended up rebuilding the
/// entire `GoRouter` on every emission.
///
/// Lives in `data` rather than in `features/auth` because these are session
/// plumbing over the Supabase client, not auth UI. Any feature needs to know
/// whether a session exists — the detail page must send a guest to sign in
/// before revealing a seller contact — and Rule 10 forbids one feature
/// importing another to ask.
final authSessionProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseAuthProvider).onAuthStateChange;
});

/// The current session, or null for a guest.
final sessionProvider = Provider<Session?>((ref) {
  return ref.watch(authSessionProvider).value?.session;
});

/// Whether a user is signed in.
///
/// Synchronous on purpose: the router's `redirect` runs outside the build cycle
/// and must not await a stream.
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(sessionProvider) != null;
});

/// Mirrors the session into `sessionContext` so log entries are attributed.
///
/// Listening here rather than inside `AppLogger` keeps logging synchronous and
/// free of provider dependencies, which matters because `AppLogger` is called
/// from code that has no `Ref`.
final sessionLoggingBridgeProvider = Provider<void>((ref) {
  ref.listen<Session?>(sessionProvider, (previous, next) {
    recordSessionUser(next?.user.id);
  }, fireImmediately: true);
});

/// Bridges auth state into a [Listenable] for `GoRouter.refreshListenable`.
///
/// ### Why this lives here rather than in each app
///
/// It was originally written inside `apps/user_app/lib/router/app_router.dart`.
/// `apps/admin_panel` then grew its own private `_authStateProvider` and
/// rebuilt its entire `GoRouter` on every auth emission — the exact bug this
/// class exists to prevent. Two routers are not allowed to import each other
/// (Rule 10), so the shared bridge lives beside the session providers it reads.
///
/// ### Why a `ChangeNotifier` rather than a provider
///
/// `GoRouter` is meant to be constructed once and *told* about changes
/// through `refreshListenable`. Watching the session inside the provider that
/// builds the router instead throws away the navigation stack and can fire a
/// redirect mid-interaction.
class AuthRefreshNotifier extends ChangeNotifier {
  /// Subscribes to [isSignedInProvider] and mirrors it into [isSignedIn].
  ///
  /// `fireImmediately` seeds the initial value so the very first redirect sees
  /// a correct answer instead of defaulting to signed-out and bouncing a
  /// returning user to `/login` on cold start.
  AuthRefreshNotifier(Ref ref) {
    _subscription = ref.listen<bool>(
      isSignedInProvider,
      (_, next) {
        if (next == _isSignedIn) return;
        _isSignedIn = next;
        notifyListeners();
      },
      fireImmediately: true,
    );
  }

  late final ProviderSubscription<bool> _subscription;

  bool _isSignedIn = false;

  /// Whether a session exists, readable synchronously from `redirect`.
  bool get isSignedIn => _isSignedIn;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
