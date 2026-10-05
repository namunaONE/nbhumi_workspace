import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// First-run gate: onboarding shows once per install (HYA-202 remainder).
///
/// A [ChangeNotifier] rather than a `StateProvider` so the router can merge it
/// into `refreshListenable` alongside the auth bridge: completing
/// onboarding re-runs `redirect` without rebuilding the whole `GoRouter`, the
/// same reason the auth bridge is a listener and not a watched provider.
class OnboardingGate extends ChangeNotifier {
  /// Creates a gate with the persisted answer.
  OnboardingGate({required this._seen});

  /// `shared_preferences` key. Versioned so a future redesign can re-show
  /// onboarding once by bumping the suffix.
  static const String seenKey = 'nbhumi.onboarding.seen.v1';

  bool _seen;

  /// Whether onboarding was completed on this install.
  bool get seen => _seen;

  /// Reads the persisted answer. False on a fresh install.
  static Future<bool> loadSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(seenKey) ?? false;
  }

  /// Marks onboarding complete and persists it.
  ///
  /// Idempotent: a double-tap notifies once and writes once.
  Future<void> markSeen() async {
    if (_seen) return;
    _seen = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(seenKey, true);
  }
}

/// The first-run gate for the process.
///
/// Defaults to seen: widgets pumped without `main()` (every widget test)
/// must never be ambushed by onboarding. `main()` overrides this with the
/// persisted value before `runApp`.
final onboardingGateProvider = Provider<OnboardingGate>((ref) {
  final gate = OnboardingGate(seen: true);
  ref.onDispose(gate.dispose);
  return gate;
});
