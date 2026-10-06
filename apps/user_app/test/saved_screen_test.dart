import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/screens/saved_screen.dart';

/// A signed-in session, built by hand (see profile_self_service_test.dart).
Session _session() => Session(
      accessToken: 'token',
      refreshToken: 'refresh',
      tokenType: 'bearer',
      user: const User(
        id: 'buyer-1',
        appMetadata: <String, dynamic>{},
        userMetadata: <String, dynamic>{},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
      ),
    );

const ListingSummary _house = ListingSummary(
  id: 'l1',
  sellerId: 's1',
  title: 'Shanti Villa',
  priceNpr: 25000000,
  district: 'Kathmandu',
  city: 'Kirtipur',
  propertyType: PropertyType.house,
  listingPurpose: ListingPurpose.sale,
);

/// Widget tests for [SavedScreen].
///
/// Rule 33: pump with `ProviderScope` overrides, never real providers.
void main() {
  group('SavedScreen', () {
    /// English locale with delegates, or `localizedForContext` falls back to
    /// Nepali and every English assertion below fails (same note as in
    /// profile_self_service_test.dart).
    Widget harness(Widget child, {Locale locale = const Locale('en')}) =>
        MaterialApp(
          locale: locale,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
          home: child,
        );

    testWidgets('guests get a sign-in prompt, not an empty shelf',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionProvider.overrideWithValue(null)],
          child: harness(const SavedScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign in to save properties'), findsOneWidget);
      expect(find.text('Nothing saved yet'), findsNothing);
    });

    testWidgets('empty shelf explains the heart', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWithValue(_session()),
            savedListingsProvider.overrideWith(
              (ref) async => const <ListingSummary>[],
            ),
          ],
          child: harness(const SavedScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nothing saved yet'), findsOneWidget);
      expect(find.textContaining('Tap the heart'), findsOneWidget);
    });

    testWidgets('saved listings render as cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWithValue(_session()),
            savedListingsProvider.overrideWith(
              (ref) async => const <ListingSummary>[_house],
            ),
          ],
          child: harness(const SavedScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shanti Villa'), findsWidgets);
    });

    testWidgets('Nepali locale renders Nepali chrome', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWithValue(_session()),
            savedListingsProvider.overrideWith(
              (ref) async => const <ListingSummary>[],
            ),
          ],
          child: harness(const SavedScreen(), locale: const Locale('ne')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('सेभ'), findsWidgets);
      expect(find.text('अहिलेसम्म केही सेभ छैन'), findsOneWidget);
    });

    testWidgets('a failed shelf offers a retry that recovers', (tester) async {
      // Riverpod retries a failed build automatically, so every attempt must
      // fail until the retry tap: a call counter cannot distinguish "first
      // mount" from "retry". A flag flipped after the first settle can.
      var fail = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWithValue(_session()),
            savedListingsProvider.overrideWith((ref) async {
              if (fail) {
                throw const NetworkException(
                  code: 'network.unreachable',
                  messageEn: 'No connection.',
                  messageNe: 'इन्टरनेट छैन।',
                );
              }
              return const <ListingSummary>[_house];
            }),
          ],
          child: harness(const SavedScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No connection.'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Shanti Villa'), findsWidgets);
    });
  });
}
