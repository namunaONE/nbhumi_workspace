import 'dart:async';

import 'package:core/core.dart';
import 'package:data/data.dart';

import 'deep_link_target.dart';

/// What happened to one incoming link.
///
/// Returned by [AuthLinkHandler.handleLink] so tests assert outcomes without
/// stubbing the router or Supabase.
sealed class DeepLinkOutcome {
  const DeepLinkOutcome();
}

/// The link was an auth callback and the session exchange succeeded.
final class AuthExchanged extends DeepLinkOutcome {
  /// Creates a successful-exchange outcome.
  const AuthExchanged();
}

/// The link was an auth callback but the exchange failed.
///
/// Failures are logged inside the handler (Rule 37) and reported here rather
/// than thrown, because the link stream must survive one bad tap: a throwing
/// handler cancels the subscription and kills every future deep link.
final class AuthFailed extends DeepLinkOutcome {
  /// Creates a failed-exchange outcome.
  const AuthFailed(this.error);

  /// The mapped failure.
  final AppException error;
}

/// The link was an in-app route and was handed to the router.
final class RouteHandled extends DeepLinkOutcome {
  /// Creates a routed outcome.
  const RouteHandled(this.location);

  /// Where the router was asked to go.
  final String location;
}

/// The link was for something else and was ignored.
final class LinkIgnored extends DeepLinkOutcome {
  /// Creates an ignored-link outcome.
  const LinkIgnored();
}

/// Routes incoming deep links to auth or the router (HYA-257).
///
/// Plugin-agnostic on purpose: the constructor takes a `getInitialLink`
/// function and a link stream, so `apps/user_app` passes the real `AppLinks`
/// plugin while tests pass a `StreamController`. Nothing here imports
/// `app_links`, which keeps `features/auth` free of platform plugins
/// (Rule 39).
class AuthLinkHandler {
  /// Creates a handler.
  ///
  /// The auth callback exchanges the link for a session (normally
  /// `AuthService.exchangeSessionFromUrl`); the app-route callback navigates
  /// (normally `GoRouter.go`).
  AuthLinkHandler({
    required this._getInitialLink,
    required this._linkStream,
    required this._onAuthCallback,
    required this._onAppRoute,
    this.host,
    this.scheme,
  });

  final Future<Uri?> Function() _getInitialLink;
  final Stream<Uri> _linkStream;
  final Future<void> Function(Uri uri) _onAuthCallback;
  final void Function(String location) _onAppRoute;

  /// Host override for link classification. Defaults to the [EnvConfig]
  /// value; tests pass the production-shaped host explicitly.
  final String? host;

  /// Scheme override for link classification. Same defaulting as [host].
  final String? scheme;

  StreamSubscription<Uri>? _subscription;

  /// Whether [start] has been called without a matching [dispose].
  bool get isActive => _subscription != null;

  /// Handles the cold-start link, then subscribes to warm links.
  ///
  /// Never throws: a platform that cannot provide links (tests, desktop,
  /// a misbehaving OEM ROM) logs and continues with no deep-link support
  /// rather than crashing startup.
  Future<void> start() async {
    if (_subscription != null) return;
    try {
      final initial = await _getInitialLink();
      if (initial != null) await handleLink(initial);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Deep-link cold start unavailable',
        context: logContext(action: 'deepLinkStart'),
        error: error,
        stackTrace: stackTrace,
      );
    }
    _subscription = _linkStream.listen(
      handleLink,
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.error(
          'Deep-link stream error',
          context: logContext(action: 'deepLinkStream'),
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  /// Classifies one link and acts on it. Never throws (see [AuthFailed]).
  Future<DeepLinkOutcome> handleLink(Uri uri) {
    final target = classifyDeepLink(uri, host: host, scheme: scheme);
    return switch (target) {
      AuthCallbackLink(uri: final callbackUri) => _exchange(callbackUri),
      AppRouteLink(:final location) => Future.value(_route(location)),
      ExternalLink() => Future.value(const LinkIgnored()),
    };
  }

  Future<DeepLinkOutcome> _exchange(Uri uri) async {
    try {
      await _onAuthCallback(uri);
      AppLogger.info(
        'Auth callback exchanged',
        context: logContext(
          action: 'deepLinkAuth',
          // The path proves which callback shape arrived; the query holds the
          // one-time PKCE code and must never be logged.
          detail: <String, Object?>{'path': uri.path},
        ),
      );
      return const AuthExchanged();
    } on AppException catch (error, stackTrace) {
      AppLogger.error(
        'Auth callback exchange failed',
        context: logContext(
          action: 'deepLinkAuth',
          detail: <String, Object?>{'code': error.code, 'path': uri.path},
        ),
        error: error,
        stackTrace: stackTrace,
      );
      return AuthFailed(error);
    }
  }

  DeepLinkOutcome _route(String location) {
    _onAppRoute(location);
    return RouteHandled(location);
  }

  /// Cancels the warm-link subscription.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
