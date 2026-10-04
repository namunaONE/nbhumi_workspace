import 'package:auth/auth.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listing_detail/listing_detail.dart';
import 'package:post_listing/post_listing.dart';
import 'package:search/search.dart';
import 'package:user_app/screens/home_screen.dart';
import 'package:user_app/screens/onboarding_screen.dart';
import 'package:user_app/screens/profile_screen.dart';
import 'package:user_app/screens/saved_screen.dart';
import 'package:user_app/shell/app_shell.dart';

/// Bridges auth state into GoRouter's `refreshListenable`.
///
/// ### Why this exists
///
/// The previous router watched the auth stream from inside the provider that
/// builds the router. That rebuilds the whole router object on every auth
/// emission, which throws away the navigation stack and can fire a redirect
/// mid-interaction. GoRouter is meant to be constructed once and told about
/// changes through `refreshListenable`; this notifier is that channel.
///
/// The signed-in flag is read synchronously by `redirect`, which is why it is a
/// plain field rather than a `Future` or a widget-level watch.
class AuthRefreshNotifier extends ChangeNotifier {
  /// Subscribes to the auth session and mirrors it into [isSignedIn].
  ///
  /// fireImmediately seeds the initial value so the very first redirect sees a
  /// correct answer rather than defaulting to signed-out and bouncing a
  /// returning user to /login on cold start.
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
  '/login',
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
/// Built once per container. Auth changes arrive through [AuthRefreshNotifier].
final appRouterProvider = Provider<GoRouter>((ref) {
  final authRefresh = AuthRefreshNotifier(ref);
  ref.onDispose(authRefresh.dispose);

  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  final searchKey = GlobalKey<NavigatorState>(debugLabel: 'search');
  final savedKey = GlobalKey<NavigatorState>(debugLabel: 'saved');
  final profileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoggedIn = authRefresh.isSignedIn;

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

      GoRoute(
        path: '/login',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});
