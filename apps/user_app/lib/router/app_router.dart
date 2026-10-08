import 'package:auth/auth.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kyc/kyc.dart';
import 'package:listing_detail/listing_detail.dart';
import 'package:notifications/notifications.dart';
import 'package:post_listing/post_listing.dart';
import 'package:search/search.dart';
import 'package:user_app/onboarding/onboarding_gate.dart';
import 'package:user_app/screens/home_screen.dart';
import 'package:user_app/screens/onboarding_screen.dart';
import 'package:user_app/screens/profile_screen.dart';
import 'package:user_app/screens/saved_screen.dart';
import 'package:user_app/screens/settings_screen.dart';
import 'package:user_app/shell/app_shell.dart';

/// Routes reachable without a session.
///
/// Guest browsing is the product's primary use case, so the browse surface is
/// public and RLS permits SELECT on live listings. Only `/post` is gated, since
/// posting is the one action that genuinely requires an account.
///
/// `/profile` is deliberately public even though it is an account screen: it
/// is a bottom-nav destination, and bouncing a guest to the login screen the
/// moment they tap it is jarring when the screen can perfectly well show a
/// signed-out state with a sign-in prompt.
const Set<String> kPublicRoutes = <String>{
  '/',
  '/onboarding',
  '/search',
  '/saved',
  '/profile',
  '/profile/settings',
  '/login',
  // The auth callback arrives while signed out by definition: the session it
  // carries does not exist yet. Gating it would bounce the user to /login
  // before the exchange runs.
  '/auth/callback',
};

/// Whether [location] may be visited without a session.
bool isPublicRoute(String location) {
  if (kPublicRoutes.contains(location)) return true;
  // Listing detail is public: a guest must be able to open a listing from a
  // shared link without being asked to sign in first.
  return location.startsWith('/listing/');
}

/// go_router configuration for the user app.
///
/// Built once per container. Auth changes arrive through `data`'s shared
/// [AuthRefreshNotifier]. `apps/admin_panel` previously kept a private copy of
/// the session stream, which rebuilt its entire router on every auth emission;
/// two apps cannot import each other (Rule 10), so the bridge lives beside the
/// session providers it reads.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authRefresh = AuthRefreshNotifier(ref);
  ref.onDispose(authRefresh.dispose);
  final gate = ref.watch(onboardingGateProvider);

  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  final searchKey = GlobalKey<NavigatorState>(debugLabel: 'search');
  final savedKey = GlobalKey<NavigatorState>(debugLabel: 'saved');
  final profileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    // Both notifiers only *tell* the router to re-run `redirect`: neither
    // rebuilds the router itself (see AuthRefreshNotifier).
    refreshListenable: Listenable.merge([authRefresh, gate]),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoggedIn = authRefresh.isSignedIn;

      // First run goes through onboarding before anything else. No conflict
      // with the auth rules below: a fresh install is never signed in, and a
      // returning user already has seen=true.
      // A fresh install can receive a confirmation or recovery link before
      // onboarding has been completed. Let the callback exchange run first;
      // the normal home redirect returns to onboarding afterwards.
      if (!gate.seen &&
          location != '/onboarding' &&
          location != '/auth/callback') {
        return '/onboarding';
      }

      // Rule 37: log entries must carry the screen the user was on. Without
      // this every user-side failure logged `screen=unknown`.
      //
      // Recorded in `redirect` because go_router 14.8.1 has no navigation hook,
      // and `redirect` runs on every navigation attempt including the initial
      // one and deep links.
      recordCurrentScreen(state.uri.toString());

      // A gated route without a session sends the user to login.
      if (!isLoggedIn && !isPublicRoute(location)) return '/login';

      // Already signed in: the login screen serves no purpose.
      if (isLoggedIn && location == '/login') return '/';

      return null;
    },
    routes: [
      // Onboarding runs before the shell so the first-run experience is not
      // wrapped in bottom navigation.
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // The four-tab shell. StatefulShellRoute.indexedStack keeps each tab's
      // navigation stack and scroll position alive when switching, which is
      // what users expect from bottom navigation.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: homeKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: searchKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: savedKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: profileKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Listing detail. Top level rather than nested under the Home branch, so
      // that any tab can open a listing: Search and Saved both link into it,
      // and a route nested in one branch is invisible to the others. The detail
      // page owns its own chrome, so covering the tab bar is correct anyway.
      GoRoute(
        path: '/listing/:id',
        parentNavigatorKey: rootKey,
        builder: (context, state) => ListingDetailScreen(
          listingId: state.pathParameters['id']!,
        ),
      ),

      // Seller flow. Outside the shell because the wizard owns its own chrome
      // and progress indicator.
      GoRoute(
        path: '/post',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const PostListingScreen(),
      ),

      // Identity verification. Gated like `/post`: submitting needs a
      // session, so it stays out of `kPublicRoutes` and the redirect sends
      // guests to login.
      GoRoute(
        path: '/kyc',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const KycScreen(),
      ),

      // Notification inbox. Gated for the same reason: a guest has no inbox.
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const NotificationsScreen(),
      ),

      GoRoute(
        path: '/login',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const LoginScreen(),
      ),

      // Only local, sanitized query flags ever reach this route. The raw
      // one-time PKCE code is handled by app_links, not go_router.
      GoRoute(
        path: '/auth/callback',
        parentNavigatorKey: rootKey,
        builder: (context, state) => AuthCallbackScreen(
          isRecovery: state.uri.queryParameters['type'] == 'recovery',
          error: state.uri.queryParameters['error'],
        ),
      ),
    ],
  );
});
