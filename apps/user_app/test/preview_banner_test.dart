// Verifies the PreviewBanner gate and the strip it renders.
//
// The gate is EnvConfig.environment — a compile-time String.fromEnvironment —
// so it cannot be flipped at runtime. The honest tests are therefore: assert
// the constant, assert the no-op in the environment CI actually uses, and
// assert the strip directly (it carries no gate).

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/widgets/preview_banner.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
        home: Scaffold(body: child),
      );

  group('the gate', () {
    test('compares against the preview environment constant', () {
      expect(PreviewBanner.previewEnvironment, 'preview');
    });

    test('is closed in the environment CI and tests run in', () {
      // No --dart-define=ENVIRONMENT reaches flutter test, so this resolves to
      // the 'dev' default. If this ever fails, a banner has leaked into every
      // non-preview build — including the goldens.
      expect(EnvConfig.environment, isNot(PreviewBanner.previewEnvironment));
    });
  });

  group('PreviewBanner', () {
    testWidgets('passes the child through untouched when the gate is closed',
        (tester) async {
      await tester.pumpWidget(
        wrap(const PreviewBanner(child: Text('APP CONTENT'))),
      );

      expect(find.text('APP CONTENT'), findsOneWidget);
      expect(find.byType(PreviewBannerStrip), findsNothing);
    });

    testWidgets('does not introduce a Column when closed', (tester) async {
      // Guards the no-op: a wrapper that still built a Column would shift
      // layout even when the banner is hidden.
      await tester.pumpWidget(
        wrap(const PreviewBanner(child: Text('APP CONTENT'))),
      );

      expect(find.byType(Column), findsNothing);
    });
  });

  group('PreviewBannerStrip', () {
    testWidgets('renders both banner lines', (tester) async {
      await tester.pumpWidget(wrap(const PreviewBannerStrip()));

      expect(
        find.text('Preview build — not the live marketplace'),
        findsOneWidget,
      );
      expect(
        find.text('For review only. Data may be reset — do not rely on it.'),
        findsOneWidget,
      );
    });

    testWidgets('names a state, never a brand', (tester) async {
      // A previous draft used Nepali that collided with the owning
      // organisation's name (Namuna One), making the banner read as a rebrand
      // rather than a status. Pumped under the Nepali locale so the assertion
      // reads the string a Nepali-speaking tester actually sees.
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ne'),
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: <Locale>[Locale('en'), Locale('ne')],
          home: Scaffold(body: PreviewBannerStrip()),
        ),
      );

      final rendered = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ');

      expect(rendered, isNotEmpty);
      expect(rendered.contains('Namuna'), isFalse);
    });

    testWidgets('uses theme colors rather than literals (Rule 43)',
        (tester) async {
      await tester.pumpWidget(wrap(const PreviewBannerStrip()));

      // Descendant-of, not byType: the surrounding Scaffold is also a Material,
      // and a bare find would match both and throw "Too many elements".
      final strip = find.byType(PreviewBannerStrip);
      final material = tester.widget<Material>(
        find.descendant(of: strip, matching: find.byType(Material)),
      );
      final theme = Theme.of(tester.element(strip));

      expect(
        material.color,
        theme.colorScheme.errorContainer,
        reason: 'banner background must come from a ColorScheme role',
      );
    });

    testWidgets('carries an icon so the strip is not text-only',
        (tester) async {
      await tester.pumpWidget(wrap(const PreviewBannerStrip()));

      final strip = find.byType(PreviewBannerStrip);
      expect(
        find.descendant(of: strip, matching: find.byType(Icon)),
        findsOneWidget,
      );
    });
  });
}
