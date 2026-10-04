import 'package:auth/auth.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listing_detail/listing_detail.dart';
import 'package:post_listing/post_listing.dart';
import 'package:search/search.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth state stream provider — emits on every Supabase auth change.
final _authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseAuthProvider).onAuthStateChange;
});

/// go_router configuration for the user app.
///
/// Guest browsing is allowed for public routes (RLS permits public SELECT
/// on live listings). Auth-gated routes redirect to /login.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(_authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = authState.value?.session;
      final isLoggedIn = session != null;
      final location = state.matchedLocation;

      const publicRoutes = {'/', '/search', '/login'};
      final isPublic = publicRoutes.contains(location) ||
          location.startsWith('/listing/');

      // Auth-gated route without a session → login.
      if (!isPublic && !isLoggedIn) return '/login';
      // Already logged in → skip the login screen.
      if (isLoggedIn && location == '/login') return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) => ListingDetailScreen(
          listingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/post',
        builder: (context, state) => const PostListingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});

/// Home screen — landing page with featured listings.
class HomeScreen extends ConsumerWidget {
  /// Creates the landing screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('nBhumi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/post'),
          ),
        ],
      ),
      body: const Center(
        child: Text('nBhumi — Nepal Property Marketplace'),
      ),
    );
  }
}
