import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/main.dart';

/// Boots the app against a stub Supabase client that reports "no session".
///
/// Two environment problems had to be solved to get here, both of which made
/// the original test fail:
///
/// * The router reads `onAuthStateChange` while constructing its `GoRouter`, so
///   `Supabase.instance` must be initialised even for a signed-out assertion.
///   Uninitialised, the library trips its own assertion.
/// * Supabase Auth persists through `shared_preferences`, which has no plugin
///   implementation under `flutter test`, so `setMockInitialValues` is required
///   or `initialize()` throws `MissingPluginException`.
///
/// `persistSession: false` additionally keeps any token off disk.
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

  testWidgets('UserApp renders for a signed-out guest', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: UserApp()));
    await tester.pump();

    expect(find.text('nBhumi'), findsWidgets);
  });
}
