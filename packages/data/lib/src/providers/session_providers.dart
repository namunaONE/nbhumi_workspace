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
