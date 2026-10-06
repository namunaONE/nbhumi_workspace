import 'package:core/core.dart' show AppException;
import 'package:data/data.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_access_providers.g.dart';

/// Whether the current session may use the admin panel.
///
/// Four states, not two. Collapsing "we have not checked yet" into "not an
/// admin" would bounce a real admin to `/forbidden` on every cold start, and
/// collapsing it into "allowed" would show a non-admin a queue that then fails
/// with `42501` on every read.
enum AdminAccess {
  /// Nobody is signed in.
  signedOut,

  /// A session exists; the role has not been read yet.
  ///
  /// Its own state rather than a nullable bool, because the router's `redirect`
  /// runs synchronously and must distinguish "ask again" from "deny".
  checking,

  /// Signed in with `profiles.role = 'admin'`.
  granted,

  /// Signed in, and not an admin.
  denied,
}

/// The role of the signed-in user, resolved once per session.
///
/// ### Why `profiles.role` and not a JWT claim
///
/// `profiles.role` is authoritative and server-owned: `profiles_update_own`
/// pins it, so a client cannot self-promote. Reading it through RLS gives the
/// panel the same answer the admin RPCs will give. A role claim inside the JWT
/// would be a cache of a value that can be revoked, and a stale cache here
/// means
/// an admin panel that keeps working after the role is removed — until the
/// first
/// RPC fails.
///
/// ### Why every failure collapses to [AdminAccess.denied]
///
/// A role read can fail for several very different reasons — signed out,
/// network
/// down, `profiles` unreadable — and the panel must not lump "cannot tell" in
/// with "allowed". Failing closed is correct, and the server gate means a false
/// denial costs one sign-in rather than a security hole.
///
/// ### Why retry is disabled
///
/// Ten attempts with backoff would hold the panel in `checking` for roughly
/// forty
/// seconds on a genuinely offline network. Failing to `/forbidden` immediately
/// and letting the admin retry explicitly is faster and honest.
@riverpod
Future<AdminAccess> adminAccess(Ref ref) async {
  // Watches the session rather than reading it, so a sign-out invalidates this
  // provider and the next read resolves for whoever is signed in then.
  if (ref.watch(sessionProvider) == null) return AdminAccess.signedOut;

  try {
    final profile = await ref.watch(authRepositoryProvider).getCurrentProfile();

    // A signed-in user with no profile row is a half-finished signup, not an
    // admin. Denying is the only safe answer: `private.is_admin()` reads the
    // same table and would also find nothing.
    if (profile == null) return AdminAccess.denied;

    return profile.role == UserRole.admin
        ? AdminAccess.granted
        : AdminAccess.denied;
  } on AppException catch (_) {
    // One clause, not one per exception type. `getCurrentProfile` maps its own
    // transport failures into the AppException hierarchy before they reach here
    // (Rule 38), so catching AppException is sufficient. A narrower clause
    // alongside it would be dead code, and the analyzer says so.
    //
    // Includes a 42501, which would mean RLS refused even to read one's own
    // profile. Deny, and let the server gate be the backstop.
    return AdminAccess.denied;
  }
}

/// Whether the current session is an admin, as a plain bool.
///
/// Convenience for UI that does not care *why* access was refused. Derived from
/// [adminAccessProvider] rather than read separately, so there is one network
/// call and one source of truth.
@riverpod
bool adminIsAuthorized(Ref ref) {
  return ref.watch(adminAccessProvider).value == AdminAccess.granted;
}

/// The signed-in admin's display name, for the panel's app bar.
///
/// Null until the profile loads, and null for a non-admin. Best-effort: the
/// panel
/// works without it, so a failure here must not gate anything. Kept separate
/// from
/// [adminAccessProvider] so a naming change cannot invalidate the authorization
/// decision and bounce an admin back to the gate.
@riverpod
Future<String?> adminDisplayName(Ref ref) async {
  try {
    final profile = await ref.watch(authRepositoryProvider).getCurrentProfile();
    return profile?.fullName;
  } on AppException {
    return null;
  }
}
