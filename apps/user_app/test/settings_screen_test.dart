import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/screens/settings_screen.dart';

/// Pumps the settings screen with default controllers.
Future<void> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  // Controllers persist via shared_preferences; the plugin needs mock values
  // under test or every tap throws MissingPluginException.
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: '/profile/settings',
    routes: [
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('settings screen', () {
    testWidgets('shows language and appearance sections', (tester) async {
      await _pump(tester);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('switching language updates the controller', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('नेपाली'));
      await tester.pumpAndSettle();

      // The segmented control reflects the new selection.
      final segmented = tester.widget<SegmentedButton<String>>(
        find.widgetWithText(SegmentedButton<String>, 'English'),
      );
      expect(segmented.selected, <String>{'ne'});
    });

    testWidgets('switching theme updates the controller', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final segmented = tester.widget<SegmentedButton<ThemeMode>>(
        find.widgetWithText(SegmentedButton<ThemeMode>, 'System'),
      );
      expect(segmented.selected, <ThemeMode>{ThemeMode.dark});
    });

    testWidgets('Nepali locale renders Nepali headings', (tester) async {
      await _pump(tester, locale: const Locale('ne'));

      expect(find.text('सेटिङ'), findsOneWidget);
      expect(find.text('भाषा'), findsOneWidget);
      expect(find.text('देखावट'), findsOneWidget);
    });
  });
}
