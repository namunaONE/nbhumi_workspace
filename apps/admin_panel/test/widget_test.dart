import 'package:admin_panel/main.dart';
import 'package:admin_panel/router/admin_router.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Boots the admin panel against a stub Supabase client with no session.
///
/// The router reads the session through `refreshListenable`, but
/// `Supabase.instance` must still be initialised because
/// `supabaseClientProvider` and `supabaseAuthProvider` both resolve from it.
/// Supabase Auth persists through `shared_preferences`, which has no plugin
/// implementation under `flutter test`, so `setMockInitialValues` is required
/// or `initialize()` throws `MissingPluginException`.
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

  testWidgets('AdminPanel redirects an unauthenticated visitor to /login',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        observers: <ProviderObserver>[AppProviderObserver()],
        child: const AdminPanel(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('nBhumi Admin'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('/forbidden offers a way out rather than looping back to /login',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        observers: <ProviderObserver>[AppProviderObserver()],
        child: const AdminPanel(),
      ),
    );
    await tester.pumpAndSettle();

    final container =
        ProviderScope.containerOf(tester.element(find.byType(AdminPanel)));

    container.read(adminRouterProvider).go('/forbidden');
    await tester.pumpAndSettle();

    expect(find.text('Access denied'), findsOneWidget);
    expect(
      find.text('This account is not an administrator'),
      findsOneWidget,
    );
    // The escape hatch: signing out is the only thing that moves a signed-in
    // non-admin off this screen, because /login redirects away from anyone
    // holding a session.
    expect(find.widgetWithText(FilledButton, 'Sign out'), findsOneWidget);
  });

  testWidgets('every route except /login and /forbidden requires a session',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        observers: <ProviderObserver>[AppProviderObserver()],
        child: const AdminPanel(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AdminPanel)),
    );
    final router = container.read(adminRouterProvider);

    expect(isAdminPublicRoute('/login'), isTrue);
    expect(isAdminPublicRoute('/forbidden'), isTrue);
    expect(isAdminPublicRoute('/queue'), isFalse);
    expect(isAdminPublicRoute('/listing/abc'), isFalse);

    // And the redirect actually fires: deep-linking into the queue while
    // signed out lands on the sign-in screen.
    router.go('/listing/abc');
    await tester.pumpAndSettle();
    expect(find.text('nBhumi Admin'), findsOneWidget);
  });
}
