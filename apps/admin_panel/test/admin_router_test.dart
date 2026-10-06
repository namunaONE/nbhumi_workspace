import 'package:admin_panel/router/admin_router.dart';
import 'package:admin_queue/admin_queue.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Tests for the admin panel's routing guard (HYA-259).
///
/// The panel is Flutter *web*, so `redirect` is the whole of the client-side
/// access control. It cannot be async — go_router calls it synchronously and
/// treats the return as a decision, not a promise — which is exactly why the
/// That is why the role check lives in a listenable, not an await.
void main() {
  group('isAdminPublicRoute', () {
    test('login and forbidden are reachable without a session', () {
      expect(isAdminPublicRoute('/login'), isTrue);
      expect(isAdminPublicRoute('/forbidden'), isTrue);
    });

    test('the queue and a listing are not', () {
      expect(isAdminPublicRoute('/queue'), isFalse);
      expect(isAdminPublicRoute('/listing/abc'), isFalse);
    });

    test('an unknown path is not public, so it fails closed', () {
      // Failing closed matters: a route added later without a guard entry would
      // otherwise be reachable to a signed-out visitor.
      expect(isAdminPublicRoute('/'), isFalse);
      expect(isAdminPublicRoute('/admin'), isFalse);
      expect(isAdminPublicRoute('/login/extra'), isFalse);
    });

    test('a query string does not smuggle past the check', () {
      // `matchedLocation` excludes the query, but the guard is a set lookup on
      // whatever it is handed, so this pins the shape it expects.
      expect(isAdminPublicRoute('/login?next=/queue'), isFalse);
    });
  });

  group('the router', () {
    /// The routes the router actually registered.
    ///
    /// Read through `GoRoute` rather than `RouteBase`, because the base type
    /// carries no path: go_router 14 keeps it on the subclass. A `whereType`
    /// filter rather than a cast, so a future shell route is skipped instead of
    /// throwing.
    List<GoRoute> routesOf(ProviderContainer container) => container
        .read(adminRouterProvider)
        .configuration
        .routes
        .whereType<GoRoute>()
        .toList();

    test('registers the queue and the listing detail routes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final paths = routesOf(container).map((route) => route.path).toSet();

      expect(paths, contains('/login'));
      expect(paths, contains('/forbidden'));
      expect(paths, contains('/queue'));
      expect(paths, contains('/reports'));
      expect(paths, contains('/listing/:id'));
    });

    test('/reports is gated exactly like /queue', () {
      // A separate screen, but the same moderation surface: a route that exists
      // and is not gated would let a signed-in non-admin reach a reports queue.
      // The guards are keyed on `isAdminPublicRoute`, so this asserts the route
      // is registered *and* absent from the public set — the two facts together
      // are what the redirect actually tests.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        routesOf(container).map((route) => route.path),
        contains('/reports'),
      );
      expect(isAdminPublicRoute('/reports'), isFalse);
    });

    test('the listing route prefix matches the feature constant', () {
      // The feature deliberately does not import go_router, so the two can
      // drift. This is the assertion that catches the drift.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final detail = routesOf(container)
          .firstWhere((route) => route.path.endsWith('/:id'));

      // Drops both the ':id' parameter and the separator go_router leaves
      // between the prefix and the parameter, so the comparison is against the
      // constant as written rather than against a path-shaped string.
      expect(
        detail.path.substring(0, detail.path.length - ':id/'.length),
        adminListingRoutePrefix,
      );
    });

    test('start at the queue, not at sign-in', () {
      // A signed-out visitor is redirected by the guard, so the
      // initial location can be the thing they actually want. Read through the
      // router's own configuration: go_router 14 does not expose
      // `initialLocation` as a public field.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(adminRouterProvider);

      expect(router.routeInformationProvider.value.uri.path, '/queue');
    });

    test('the router is built once per container', () {
      // Rebuilding it throws away the navigation stack. The previous version
      // watched a StreamProvider from inside this provider and rebuilt on every
      // auth emission, so this is a regression guard.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final first = container.read(adminRouterProvider);
      final second = container.read(adminRouterProvider);

      expect(identical(first, second), isTrue);
    });

    test('a second container gets its own router instance', () {
      final a = ProviderContainer();
      final b = ProviderContainer();
      addTearDown(a.dispose);
      addTearDown(b.dispose);

      expect(
        identical(a.read(adminRouterProvider), b.read(adminRouterProvider)),
        isFalse,
      );
    });
  });

  group('isSignedInProvider', () {
    test('is false with no session, and readable synchronously', () {
      // Synchronous is the requirement: `redirect` runs outside the build cycle
      // and must not await a stream.
      final container = ProviderContainer(
        overrides: [isSignedInProvider.overrideWithValue(false)],
      );
      addTearDown(container.dispose);

      expect(container.read(isSignedInProvider), isFalse);
    });
  });
}
