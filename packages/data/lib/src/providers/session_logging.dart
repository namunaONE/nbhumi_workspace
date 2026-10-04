import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Who the user is and where they are, as far as logging is concerned
/// (Rule 37).
///
/// Browsing is anonymous by design, so a null [userId] is a normal state rather
/// than an error. Keeping both facts in one place means a repository can log a
/// fully-attributed failure without knowing anything about the widget tree.
///
/// [screen] is maintained by the router on every navigation. That is the only
/// place that reliably knows where the user is, and having the repository guess
/// would mean threading a `screen` argument through every ViewModel call.
@immutable
class SessionContext {
  /// Creates a session context.
  const SessionContext({this.userId, this.screen});

  /// Authenticated user id, or null for a guest.
  final String? userId;

  /// Route the user is currently on, e.g. `/listing/:id`.
  ///
  /// Null before the first navigation.
  final String? screen;

  /// The signed-out state, before any navigation has happened.
  static const SessionContext guest = SessionContext();

  /// Returns a copy carrying [userId].
  SessionContext withUser(String? userId) =>
      SessionContext(userId: userId, screen: screen);

  /// Returns a copy carrying [screen].
  ///
  /// Null clears the route rather than stringifying it, so a log entry never
  /// reads `screen=null` after the user has navigated away.
  SessionContext withScreen(String? screen) =>
      SessionContext(userId: userId, screen: screen);

  @override
  bool operator ==(Object other) =>
      other is SessionContext &&
      other.userId == userId &&
      other.screen == screen;

  @override
  int get hashCode => Object.hash(userId, screen);

  @override
  String toString() => 'SessionContext(${userId ?? 'guest'}, ${screen ?? '-'})';
}

/// Current [SessionContext].
///
/// A plain [ValueNotifier] rather than a provider, deliberately: logging has to
/// work before a `ProviderScope` exists, and `AppLogger` is called from code
/// that is not in the widget tree. `features/auth` writes the user; the router
/// writes the screen.
final ValueNotifier<SessionContext> sessionContext =
    ValueNotifier<SessionContext>(SessionContext.guest);

/// Builds a [LogContext] from the current session.
///
/// Every log entry should go through this rather than constructing a
/// `LogContext` inline, so user and screen are attached even when a call site
/// forgets. [action] is the only thing the call site must supply.
LogContext logContext({
  required String action,
  String? screen,
  Map<String, Object?>? detail,
}) {
  final current = sessionContext.value;
  return LogContext(
    userId: current.userId,
    // A call site that knows better than the router wins; otherwise use the
    // route the user is actually on.
    screen: screen ?? current.screen ?? 'unknown',
    action: action,
    detail: detail,
  );
}

/// Records the signed-in user, or clears it on sign-out.
void recordSessionUser(String? userId) {
  sessionContext.value = sessionContext.value.withUser(userId);
}

/// Records the current route.
///
/// Called by the router on every navigation. Cheap by design: this runs on the
/// hot path of every navigation and only assigns when the value changed.
void recordCurrentScreen(String? route) {
  if (route == null || route == sessionContext.value.screen) return;
  sessionContext.value = sessionContext.value.withScreen(route);
}
