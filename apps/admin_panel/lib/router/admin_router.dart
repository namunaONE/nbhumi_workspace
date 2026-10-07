import 'package:admin_panel/screens/admin_forbidden_screen.dart';
import 'package:admin_panel/screens/admin_sign_in_screen.dart';
import 'package:admin_queue/admin_queue.dart';
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Routes reachable without a session.
///
/// `/login` and `/forbidden` are the only two: everything else either needs an
/// account or needs admin rights.
const Set<String> kAdminPublicRoutes = <String>{
  '/login',
  '/forbidden',
};

/// Whether [location] may be visited without an admin session.
bool isAdminPublicRoute(String location) =>
    kAdminPublicRoutes.contains(location);

/// Bridges the resolved admin role into a [Listenable] for `GoRouter`.
///
/// `redirect` cannot await, so the role must be available synchronously.
/// This watches [adminAccessProvider] and keeps a plain bool, which is the
/// only shape the redirect can use.
///
/// The [isDenied] getter deliberately reports only the resolved negative.
/// "Checking" is not a denial: the provider's [AsyncValue] is loading on a cold
/// start, and treating that as a denial would send every real admin to
/// `/forbidden` before their role had loaded. The queue screen renders the
/// checking state itself.
class AdminAccessRefreshNotifier extends ChangeNotifier {
  /// Watches [adminAccessProvider] and mirrors the answer into [isDenied].
  ///
  /// `fireImmediately` seeds the value, so the first redirect sees a real
  /// answer rather than the default. Until the provider resolves, [isDenied] is
  /// false — see the class doc.
  AdminAccessRefreshNotifier(Ref ref) {
    _subscription = ref.listen<AsyncValue<AdminAccess>>(
      adminAccessProvider,
      (_, next) {
        final denied = next.value == AdminAccess.denied;
        if (denied == _isDenied) return;
        _isDenied = denied;
        notifyListeners();
      },
      fireImmediately: true,
    );
  }

  late final ProviderSubscription<AsyncValue<AdminAccess>> _subscription;

  bool _isDenied = false;

  /// Whether the session resolved to a non-admin.
  bool get isDenied => _isDenied;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// go_router configuration for the admin panel.
///
/// ### Two gates, not one
///
/// The client gate ([isSignedInProvider]) exists only to keep a signed-out
/// visitor off the queue; it is cosmetic. The real gate is server-side: every
/// read goes through RLS (`private.is_admin()`) and every mutation through a
/// `SECURITY DEFINER` `v1_admin_*` RPC that raises `42501` for non-admins. A
/// hand-crafted request from a non-admin gets nothing.
///
/// ### Why the role check is a redirect and not a client-side gate
///
/// The admin role lives in `profiles.role`, which a signed-in non-admin is
/// perfectly able to read for themselves but which RLS will not let anyone else
/// read authoritatively. So the panel resolves it once per session and sends
/// anyone who is not an admin to `/forbidden`, a designed screen rather than a
/// redirect loop: `enable_signup = true` means any member of the public who
/// signs up with a magic link can reach this point.
///
/// ### Why this is built once
///
/// It previously watched a private `StreamProvider<AuthState>` from inside this
/// provider, which rebuilt the whole `GoRouter`, and with it the navigation
/// stack, on every auth emission. Auth now arrives through `data`'s shared
/// [AuthRefreshNotifier] as `refreshListenable`. See `apps/user_app`'s router,
/// which was fixed first.
final adminRouterProvider = Provider<GoRouter>((ref) {
  final authRefresh = AuthRefreshNotifier(ref);
  final accessRefresh = AdminAccessRefreshNotifier(ref);
  ref
    ..onDispose(authRefresh.dispose)
    ..onDispose(accessRefresh.dispose);

  return GoRouter(
    initialLocation: '/queue',
    // One notifier per signal. go_router takes a single refreshListenable, and
    // these two change independently: the session flips at sign-in, the role
    // resolves a round trip later. Bundling them would either delay the sign-in
    // redirect until the role resolved, or re-run the redirect on every
    // unrelated role change.
    refreshListenable: Listenable.merge(<Listenable>[
      authRefresh,
      accessRefresh,
    ]),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSignedIn = authRefresh.isSignedIn;

      // Rule 37: log entries must carry the screen the admin was on.
      // `recordCurrentScreen` had no callers anywhere in the repo before this,
      // so every logged failure read `screen=unknown`.
      //
      // Recorded in `redirect` rather than an observer because go_router 14.8.1
      // has no navigation hook, and `redirect` runs on every navigation
      // attempt including the initial one and deep links. Set before the guards
      // below, so a redirect away from a gated route still records where the
      // admin actually was.
      recordCurrentScreen(state.uri.toString());

      if (!isSignedIn && !isAdminPublicRoute(location)) return '/login';
      if (isSignedIn && location == '/login') return '/queue';

      // The role gate. Three states, not two, because "not checked yet" and
      // "not an admin" need different handling: bouncing a real admin to
      // /forbidden on a cold start would make the panel unusable, and letting a
      // non-admin through would show a queue that fails on every read.
      //
      // While checking, this returns null rather than a destination: the guard
      // cannot send the admin anywhere useful, and redirecting to /queue would
      // bounce them back to /login on the next pass. The screen renders its own
      // loading state from adminAccessProvider.
      final denied = accessRefresh.isDenied &&
          !isAdminPublicRoute(location);
      if (isSignedIn && denied) {
        return '/forbidden';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminSignInScreen(),
      ),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const AdminForbiddenScreen(),
      ),
      GoRoute(
        path: '/queue',
        builder: (context, state) => AdminQueueScreen(
          // The affordance lives on the list's app bar; wiring it here keeps the
          // feature free of a go_router dependency.
          onOpenReports: () => GoRouter.of(context).go('/reports'),
        ),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) => AdminListingDetailScreen(
          listingId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
