import 'package:core/core.dart';

/// What an incoming deep link means (HYA-257).
///
/// A sealed class so the handler matches exhaustively: adding a link type
/// later is a compile error at every match site rather than a silently
/// ignored branch.
sealed class DeepLinkTarget {
  const DeepLinkTarget();

  /// A Supabase auth callback carrying a PKCE `code` (or an error).
  ///
  /// The handler exchanges it for a session via
  /// `AuthService.exchangeSessionFromUrl`. The [uri] is kept so failures log
  /// the path that failed without ever logging the code itself.
  const factory DeepLinkTarget.authCallback(Uri uri) = AuthCallbackLink;

  /// An in-app route, e.g. a shared listing link `/listing/<id>`.
  ///
  /// [location] is a go_router location the router already knows.
  const factory DeepLinkTarget.appRoute(String location) = AppRouteLink;

  /// Anything this app does not handle. Ignored, not errored: users tap
  /// arbitrary links, and a deep-link handler that throws on them is a
  /// crash vector.
  const factory DeepLinkTarget.external(Uri uri) = ExternalLink;
}

/// A Supabase auth callback. See [DeepLinkTarget.authCallback].
final class AuthCallbackLink extends DeepLinkTarget {
  /// Creates an auth-callback target.
  const AuthCallbackLink(this.uri);

  /// The callback URL.
  final Uri uri;
}

/// An in-app route. See [DeepLinkTarget.appRoute].
final class AppRouteLink extends DeepLinkTarget {
  /// Creates an app-route target.
  const AppRouteLink(this.location);

  /// The go_router location to navigate to.
  final String location;
}

/// An unhandled link. See [DeepLinkTarget.external].
final class ExternalLink extends DeepLinkTarget {
  /// Creates an external-link target.
  const ExternalLink(this.uri);

  /// The ignored URL.
  final Uri uri;
}

/// Classifies [uri] into a [DeepLinkTarget].
///
/// Pure function of the URI plus the deep-link host/scheme, so it is unit
/// tested without any platform plugin. [host] and [scheme] default to the
/// [EnvConfig] values; tests pass explicit values so they do not depend on
/// `--dart-define` flags.
///
/// * `https://<host>/auth/callback?...` → auth callback (universal link).
/// * `<scheme>://auth/callback?...` → auth callback (custom-scheme fallback,
///   works before DNS/assetlinks exist).
/// * `https://<host>/listing/<id>` → app route (shared listing links open
///   in-app instead of a browser).
/// * Everything else → external (ignored).
///
/// Matching is case-insensitive on host and scheme, because the OS hands over
/// whatever the email client produced. The path comparison is exact: a prefix
/// match here would route links the router has no route for.
DeepLinkTarget classifyDeepLink(Uri uri, {String? host, String? scheme}) {
  final linkHost = uri.host.toLowerCase();
  final linkScheme = uri.scheme.toLowerCase();
  final deepHost = (host ?? EnvConfig.deepLinkHost).toLowerCase();
  final deepScheme = (scheme ?? EnvConfig.deepLinkScheme).toLowerCase();

  final isCallbackPath = uri.path == EnvConfig.authCallbackPath;
  // Custom schemes put the first segment in `host` (`nbhumi://auth/callback`
  // parses as host=`auth`, path=`/callback`), so rejoin before comparing.
  final customPath = '/${uri.host}${uri.path}'.replaceAll('//', '/');
  if (isCallbackPath && linkScheme == 'https' && linkHost == deepHost) {
    return DeepLinkTarget.authCallback(uri);
  }
  if (linkScheme == deepScheme && customPath == EnvConfig.authCallbackPath) {
    return DeepLinkTarget.authCallback(uri);
  }

  if (linkScheme == 'https' &&
      linkHost == deepHost &&
      uri.pathSegments.length == 2 &&
      uri.pathSegments.first == 'listing' &&
      uri.pathSegments[1].isNotEmpty) {
    return DeepLinkTarget.appRoute('/listing/${uri.pathSegments[1]}');
  }

  return DeepLinkTarget.external(uri);
}
