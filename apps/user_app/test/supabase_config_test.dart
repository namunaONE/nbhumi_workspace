import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/main.dart';

/// Startup configuration gate: a build without compiled-in Supabase
/// credentials fails before any network call exists, which otherwise surfaces
/// as mysterious auth errors with zero Auth → Logs traffic. `main` shows a
/// misconfiguration notice instead when this reads false.
///
/// `flutter test` runs without `--dart-define`, so the gate must read false
/// here — pinning both the extraction (not inlined, not dropped) and the
/// expectation that test builds carry no credentials.
void main() {
  test('test builds carry no Supabase credentials', () {
    expect(hasSupabaseConfig, isFalse);
  });
}
