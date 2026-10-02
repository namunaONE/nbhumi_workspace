import 'package:admin_queue/admin_queue.dart';
import 'package:auth/auth.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth state stream provider — emits on every Supabase auth change.
final _authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseAuthProvider).onAuthStateChange;
});

/// go_router configuration for the admin panel.
///
/// All admin routes require authentication. Admin role enforcement happens
/// server-side via RLS + RPC; the client redirects unauthenticated users.
final adminRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(_authStateProvider);

  return GoRouter(
    initialLocation: '/queue',
    redirect: (context, state) {
      final session = authState.value?.session;
      final isLoggedIn = session != null;
      final location = state.matchedLocation;

      // Everything except /login requires a session.
      if (!isLoggedIn && location != '/login') return '/login';
      if (isLoggedIn && location == '/login') return '/queue';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
