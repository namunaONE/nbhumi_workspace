import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/main.dart';
import 'package:user_app/router/app_router.dart';
import 'package:user_app/screens/onboarding_screen.dart';
import 'package:user_app/shell/app_shell.dart';

/// Boots the app against a stub Supabase client that reports "no session".
///
/// Two environment problems had to be solved to get here, both of which made
/// the original test fail:
///
/// * The router reads auth state while constructing, so `Supabase.instance`
///   must be initialised even for a signed-out assertion. Uninitialised, the
///   library trips its own assertion.
/// * Supabase Auth persists through `shared_preferences`, which has no plugin
///   implementation under `flutter test`, so `setMockInitialValues` is required
///   or `initialize()` throws `MissingPluginException`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://project.supabase.co',
      publishableKey: 'sb_publishable_test_key',
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUri: false,
      ),
    );
  });

  setUp(() => sessionContext.value = SessionContext.guest);

  /// Renders the app at [size] and settles.
  ///
  /// The view size is set explicitly because the shell chooses its navigation
  /// affordance from width, and the default test surface is too narrow to
  /// exercise the medium or expanded layouts.
  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(400, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: UserApp()));
    await tester.pump();
    await tester.pumpAndSettle();
  }

  group('AppTab', () {
    test('exposes four tabs in the order the shell indexes them', () {
      // StatefulShellRoute maps branches to indices positionally. Inserting a
      // tab in the middle would silently repoint every saved index, so the
      // count and order are asserted rather than assumed.
      expect(AppTab.values, hasLength(4));
      expect(
        AppTab.values.map((t) => t.label),
        <String>['Home', 'Search', 'Saved', 'Profile'],
      );
    });

    test('every tab has a distinct route', () {
      final routes = AppTab.values.map((t) => t.route).toSet();
      expect(routes, hasLength(AppTab.values.length));
    });

    test('every tab has distinct selected and unselected icons', () {
      for (final tab in AppTab.values) {
        expect(tab.icon, isNot(tab.selectedIcon), reason: tab.label);
      }
    });
  });

  group('isPublicRoute', () {
    test('browse routes are reachable by a guest', () {
      // Guest browsing is the product's primary use case; gating any of these
      // would make the app useless before sign-up.
      expect(isPublicRoute('/'), isTrue);
      expect(isPublicRoute('/search'), isTrue);
      expect(isPublicRoute('/saved'), isTrue);
      expect(isPublicRoute('/login'), isTrue);
      expect(isPublicRoute('/onboarding'), isTrue);
    });

    test('listing detail is public so shared links work', () {
      expect(isPublicRoute('/listing/abc-123'), isTrue);
    });

    test('only posting is gated', () {
      // Profile is public so a guest tapping that tab sees a signed-out state
      // rather than being bounced to login.
      expect(isPublicRoute('/post'), isFalse);
      expect(isPublicRoute('/profile'), isTrue);
    });

    test('a path merely starting with /listing is not enough', () {
      // Guards against a prefix check that would wave through a route the app
      // does not actually have.
      expect(isPublicRoute('/listing'), isFalse);
    });
  });

  group('AppShell layout', () {
    testWidgets('compact shows a bottom NavigationBar', (tester) async {
      await pumpApp(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(AppDrawer), findsNothing);
    });

    testWidgets('medium shows a NavigationRail', (tester) async {
      await pumpApp(tester, size: const Size(700, 900));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('expanded shows a permanently visible drawer', (tester) async {
      // DESIGN.md specifies a permanent drawer at this width, not a hamburger.
      await pumpApp(tester, size: const Size(1000, 900));

      expect(find.byType(AppDrawer), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('every tab is reachable at compact width', (tester) async {
      await pumpApp(tester);

      for (final tab in AppTab.values) {
        await tester.tap(find.text(tab.label));
        await tester.pumpAndSettle();
      }

      // Profile is last and only signed-out users land on the sign-in prompt.
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('the saved tab explains itself instead of showing nothing',
        (tester) async {
      // Favourites are M3. An empty list would read as a bug.
      await pumpApp(tester);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      expect(
        find.text('Saved listings are not available yet'),
        findsOneWidget,
      );
    });

    testWidgets('the profile tab prompts a guest to sign in', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Post a property'), findsNothing);
    });

    testWidgets('onboarding shows the Malpot disclaimer', (tester) async {
      // DATA.md requires the disclaimer to be visible. First run is the only
      // place a user is guaranteed to read it. Rendered directly rather than
      // through the router, because onboarding is not the initial location.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => const OnboardingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Malpot'), findsWidgets);
      expect(find.textContaining('not a broker'), findsOneWidget);
      expect(find.text('Browse listings'), findsOneWidget);
    });
  });
}
