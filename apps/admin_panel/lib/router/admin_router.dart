import 'package:admin_panel/screens/admin_forbidden_screen.dart';
import 'package:admin_panel/screens/admin_sign_in_screen.dart';
import 'package:admin_queue/admin_queue.dart';
import 'package:data/data.dart';
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
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    initialLocation: '/queue',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSignedIn = authRefresh.isSignedIn;

      // Rule 37: log entries must carry the screen the admin was on.
      // `recordCurrentScreen` had no callers anywhere in the repo before this,
      // so every logged failure read `screen=unknown`.
      //
      // Recorded in `redirect` rather than an observer because go_router 14.8.1
      // has no navigation hook, and `redirect` runs on every navigation attempt
      // including the initial one and deep links. It is set before the guard
      // below so a redirect away from a gated route still records where the
      // admin actually was.
      recordCurrentScreen(state.uri.toString());

      if (!isSignedIn && !isAdminPublicRoute(location)) return '/login';
      if (isSignedIn && location == '/login') return '/queue';
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
        builder: (context, state) => const AdminQueueScreen(),
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
