import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/main.dart';
import 'package:user_app/onboarding/onboarding_gate.dart';
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
    OnboardingGate? gateOverride,
    Session? session,
    bool freshSignup = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (gateOverride != null)
            onboardingGateProvider.overrideWithValue(gateOverride),
          if (session != null) sessionProvider.overrideWithValue(session),
          freshSignupProvider.overrideWith(
            () => FreshSignupNotifier(initial: freshSignup),
          ),
          // The bell owns the unread badge now (HYA-299 moved it off the
          // profile tab). Pinned to zero here so shell tests never touch the
          // network through the stub Supabase client; inbox tests cover the
          // provider itself.
          unreadNotificationCountProvider.overrideWith((ref) async => 0),
        ],
        child: const UserApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  group('AppTab', () {
    test('exposes four tabs in the order the shell indexes them', () {
      // StatefulShellRoute maps branches to indices positionally. Inserting a
      // tab in the middle would silently repoint every saved index, so the
      // count and order are asserted rather than assumed. Posting is a center
      // action, not a branch, for the same reason.
      expect(AppTab.values, hasLength(4));
      expect(
        AppTab.values.map((t) => t.label),
        <String>['Explore', 'Saved', 'My Listings', 'Profile'],
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
      expect(isPublicRoute('/saved'), isTrue);
      expect(isPublicRoute('/my-listings'), isTrue);
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

    test('the auth callback is public so the link exchange can run', () {
      // The callback arrives while signed out by definition: the session it
      // carries does not exist yet. Gating it would bounce to /login before
      // AuthLinkHandler exchanges the PKCE code.
      expect(isPublicRoute('/auth/callback'), isTrue);
    });

    test('a path merely starting with /listing is not enough', () {
      // Guards against a prefix check that would wave through a route the app
      // does not actually have.
      expect(isPublicRoute('/listing'), isFalse);
    });
  });

  group('Onboarding gate', () {
    testWidgets('first run lands on onboarding, not home', (tester) async {
      final gate = OnboardingGate(seen: false);
      addTearDown(gate.dispose);

      await pumpApp(tester, gateOverride: gate);

      expect(find.text('Browse listings'), findsOneWidget);
      expect(find.byType(BottomAppBar), findsNothing);
    });

    testWidgets('completing onboarding persists and goes home',
        (tester) async {
      final gate = OnboardingGate(seen: false);
      addTearDown(gate.dispose);

      await pumpApp(tester, gateOverride: gate);
      await tester.tap(find.text('Browse listings'));
      await tester.pumpAndSettle();

      expect(gate.seen, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(OnboardingGate.seenKey), isTrue);
      expect(find.byType(BottomAppBar), findsOneWidget);
    });

    testWidgets('an auth callback bypasses first-run onboarding',
        (tester) async {
      final gate = OnboardingGate(seen: false);
      addTearDown(gate.dispose);
      await pumpApp(tester, gateOverride: gate);

      GoRouter.of(tester.element(find.byType(OnboardingScreen)))
          .go('/auth/callback?error=expired');
      await tester.pumpAndSettle();

      expect(find.text('Sign-in link failed'), findsOneWidget);
      expect(gate.seen, isFalse);
    });

    testWidgets('a fresh signup routes through onboarding once',
        (tester) async {
      // Install already seen: the only reason to land on onboarding now is
      // the fresh-signup mark set by Auth.signUpWithPassword.
      final gate = OnboardingGate(seen: true);
      addTearDown(gate.dispose);

      await pumpApp(
        tester,
        gateOverride: gate,
        session: Session(
          accessToken: 'token',
          refreshToken: 'refresh',
          tokenType: 'bearer',
          user: const User(
            id: 'seller-1',
            appMetadata: <String, dynamic>{},
            userMetadata: <String, dynamic>{},
            aud: 'authenticated',
            createdAt: '2026-01-01T00:00:00Z',
          ),
        ),
        freshSignup: true,
      );

      expect(find.text('Browse listings'), findsOneWidget);
      expect(find.byType(BottomAppBar), findsNothing);
    });

    testWidgets('a fresh signup sees the profile step', (tester) async {
      // Same routing as above: install seen, fresh session, fresh mark.
      final gate = OnboardingGate(seen: true);
      addTearDown(gate.dispose);

      await pumpApp(
        tester,
        gateOverride: gate,
        session: Session(
          accessToken: 'token',
          refreshToken: 'refresh',
          tokenType: 'bearer',
          user: const User(
            id: 'seller-1',
            appMetadata: <String, dynamic>{},
            userMetadata: <String, dynamic>{},
            aud: 'authenticated',
            createdAt: '2026-01-01T00:00:00Z',
          ),
        ),
        freshSignup: true,
      );

      expect(find.text('Complete your profile'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('a first-run guest sees no profile step', (tester) async {
      final gate = OnboardingGate(seen: false);
      addTearDown(gate.dispose);

      await pumpApp(tester, gateOverride: gate);

      expect(find.text('Complete your profile'), findsNothing);
    });

    testWidgets('an empty name blocks the profile save inline',
        (tester) async {
      final gate = OnboardingGate(seen: true);
      addTearDown(gate.dispose);

      await pumpApp(
        tester,
        gateOverride: gate,
        session: Session(
          accessToken: 'token',
          refreshToken: 'refresh',
          tokenType: 'bearer',
          user: const User(
            id: 'seller-1',
            appMetadata: <String, dynamic>{},
            userMetadata: <String, dynamic>{},
            aud: 'authenticated',
            createdAt: '2026-01-01T00:00:00Z',
          ),
        ),
        freshSignup: true,
      );
      // Validation runs before any repository call, so no network stub
      // is needed: the empty name never reaches the server.
      await tester.ensureVisible(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your full name'), findsOneWidget);
    });

    testWidgets('completing post-signup onboarding lands home, not back',
        (tester) async {
      final gate = OnboardingGate(seen: true);
      addTearDown(gate.dispose);

      await pumpApp(
        tester,
        gateOverride: gate,
        session: Session(
          accessToken: 'token',
          refreshToken: 'refresh',
          tokenType: 'bearer',
          user: const User(
            id: 'seller-1',
            appMetadata: <String, dynamic>{},
            userMetadata: <String, dynamic>{},
            aud: 'authenticated',
            createdAt: '2026-01-01T00:00:00Z',
          ),
        ),
        freshSignup: true,
      );
      await tester.tap(find.text('Browse listings'));
      await tester.pumpAndSettle();

      // Mark consumed the fresh flag (cleared alongside seen): the shell is
      // up and there is no bounce back to onboarding.
      expect(find.byType(BottomAppBar), findsOneWidget);
      expect(find.text('Browse listings'), findsNothing);
    });

    test('markSeen notifies and writes exactly once', () async {
      final gate = OnboardingGate(seen: false);
      addTearDown(gate.dispose);
      var notified = 0;
      gate.addListener(() => notified++);

      await gate.markSeen();
      await gate.markSeen();

      expect(notified, 1);
      expect(gate.seen, isTrue);
    });
  });

  group('AppShell layout', () {
    testWidgets('compact shows a notched bottom bar with a post button',
        (tester) async {
      await pumpApp(tester);

      expect(find.byType(BottomAppBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(AppDrawer), findsNothing);
    });

    testWidgets('compact destinations show the click cursor', (tester) async {
      // DESIGN.md §6.5: custom navigation targets name their cursor
      // explicitly so desktop hover reads as clickable.
      await pumpApp(tester);

      final bar = find.byType(BottomAppBar);
      expect(bar, findsOneWidget);
      final cursors = tester
          .widgetList<InkWell>(
            find.descendant(of: bar, matching: find.byType(InkWell)),
          )
          .map((destination) => destination.mouseCursor);
      expect(cursors, isNotEmpty);
      expect(cursors, everyElement(SystemMouseCursors.click));
    });

    testWidgets('medium shows a NavigationRail', (tester) async {
      await pumpApp(tester, size: const Size(700, 900));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(BottomAppBar), findsNothing);
    });

    testWidgets('expanded shows a permanently visible drawer', (tester) async {
      // DESIGN.md specifies a permanent drawer at this width, not a hamburger.
      await pumpApp(tester, size: const Size(1000, 900));

      expect(find.byType(AppDrawer), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(BottomAppBar), findsNothing);
    });

    testWidgets('every tab is reachable at compact width', (tester) async {
      await pumpApp(tester);

      for (final tab in AppTab.values) {
        // Scoped to the bar: tab labels repeat as screen titles (Explore
        // hosts SearchScreen titled Explore), so a bare text tap is
        // ambiguous.
        await tester.tap(
          find.descendant(
            of: find.byType(BottomAppBar),
            matching: find.text(tab.label),
          ),
        );
        await tester.pumpAndSettle();
      }

      // Profile is last and only signed-out users land on the sign-in prompt.
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('the saved tab prompts a guest instead of showing nothing',
        (tester) async {
      // Favourites landed in HYA-268 C1. A guest has no shelf, so the tab
      // offers sign-in rather than the old "not available yet" placeholder.
      await pumpApp(tester);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      expect(
        find.text('Sign in to save properties'),
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

    testWidgets('the my-listings tab prompts a guest to sign in',
        (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('My Listings'));
      await tester.pumpAndSettle();

      expect(
        find.text('Sign in to see the properties you posted'),
        findsOneWidget,
      );
    });

    testWidgets('the center post button sends a guest to login',
        (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Post property'));
      await tester.pumpAndSettle();

      // `/post` is gated, so the redirect lands on the login screen.
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('explore shows the notification bell', (tester) async {
      await pumpApp(tester);

      expect(find.byTooltip('Notifications'), findsOneWidget);
    });

    testWidgets('a legacy /search link lands on Explore', (tester) async {
      await pumpApp(tester);

      GoRouter.of(tester.element(find.byType(BottomAppBar))).go('/search');
      await tester.pumpAndSettle();

      // Same screen SearchScreen renders at `/`: filter entry visible, and
      // the bell proves this is the Explore branch, not a dead route.
      expect(find.byTooltip('Notifications'), findsOneWidget);
    });

    testWidgets('onboarding shows the Malpot disclaimer', (tester) async {
      // DATA.md requires the disclaimer to be visible. First run is the only
      // place a user is guaranteed to read it. Rendered directly rather than
      // through the router, because onboarding is not the initial location.
      // Needs the app delegates: the screen reads localized strings, and a
      // bare MaterialApp leaves AppLocalizations.of(context) null.
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates:
                AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => const OnboardingScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The disclaimer sits below the feature rows in a lazily-built
      // ListView, so scroll it into view before asserting: the requirement
      // is that it is reachable on the screen, not buried in terms.
      await tester.scrollUntilVisible(
        find.textContaining('Malpot'),
        200,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Malpot'), findsWidgets);
      expect(find.textContaining('not a broker'), findsOneWidget);
      expect(find.text('Browse listings'), findsOneWidget);
    });
  });
}
