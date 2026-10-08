import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:user_app/main.dart';

/// Splash-screen behaviour: animated handoff, test bypass, error fallback.
///
/// The production shell (`UserApp`) passes `enabled: false` under
/// `flutter test` so app-level widget tests never sit behind the animation;
/// these tests exercise `SplashScreen` directly with explicit flags.
void main() {
  Future<void> pumpSplash(
    WidgetTester tester, {
    bool enabled = true,
    String asset = 'assets/animations/splash.json',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          enabled: enabled,
          animationAsset: asset,
          child: const Text('app'),
        ),
      ),
    );
  }

  testWidgets('plays animation then reveals the app', (tester) async {
    await pumpSplash(tester);

    // Splash visible, app content not yet in the tree.
    expect(find.byType(LottieBuilder), findsOneWidget);
    expect(find.text('app'), findsNothing);

    // Past the 3s fallback: animation dismissed, content revealed.
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(LottieBuilder), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('disabled splash renders content immediately', (tester) async {
    await pumpSplash(tester, enabled: false);

    expect(find.byType(LottieBuilder), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('missing composition falls back to the static wordmark',
      (tester) async {
    await pumpSplash(tester, asset: 'assets/animations/does-not-exist.json');

    // Load fails asynchronously; settle past it but before the fallback.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('nBhumi'), findsOneWidget);
    expect(find.text('app'), findsNothing);

    // Backstop still dismisses to the app.
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('app'), findsOneWidget);
  });
}
