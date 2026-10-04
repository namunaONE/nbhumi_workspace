import 'package:admin_panel/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Boots the admin panel against a stub Supabase client with no session.
///
/// The router reads `onAuthStateChange` while constructing its `GoRouter`, so
/// `Supabase.instance` must be initialised even for a signed-out assertion.
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
    await tester.pumpWidget(const ProviderScope(child: AdminPanel()));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Magic link login...'), findsOneWidget);
  });
}
