import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:search/l10n/output/search_localizations.dart'
    as search_strings;
import 'package:search/search.dart';

ListingSummary _listing(String id) => ListingSummary(
      id: id,
      sellerId: 'seller-1',
      title: 'House $id',
      district: 'Kathmandu',
      city: 'Kathmandu',
      priceNpr: 2500000,
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      createdAt: DateTime.utc(2026),
    );

/// Repository stub serving one fixed page (Rule 33).
class _FakeListingRepository implements ListingRepository {
  @override
  Future<ListingPage> getListings({
    ListingFilter filter = const ListingFilter(),
    ListingCursor? cursor,
  }) async =>
      ListingPage(listings: [_listing('a'), _listing('b')]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Widget tests for [SearchScreen] results layout.
void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listingRepositoryProvider.overrideWithValue(
            _FakeListingRepository(),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            search_strings.AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: <Locale>[Locale('en'), Locale('ne')],
          home: SearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SearchScreen layout toggle', () {
    testWidgets('starts in the grid with vertical cards', (tester) async {
      await pumpScreen(tester);

      expect(find.byType(ListingCard), findsWidgets);
      expect(find.byType(HorizontalListingCard), findsNothing);
      expect(find.byTooltip('List view'), findsOneWidget);
    });

    testWidgets('toggling shows horizontal rows and back', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('List view'));
      await tester.pumpAndSettle();

      expect(find.byType(HorizontalListingCard), findsWidgets);
      expect(find.byType(ListingCard), findsNothing);
      expect(find.byTooltip('Grid view'), findsOneWidget);

      await tester.tap(find.byTooltip('Grid view'));
      await tester.pumpAndSettle();

      expect(find.byType(ListingCard), findsWidgets);
      expect(find.byType(HorizontalListingCard), findsNothing);
    });

    testWidgets('list rows keep the listing content', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('List view'));
      await tester.pumpAndSettle();

      expect(find.text('House a'), findsOneWidget);
      expect(find.text('House b'), findsOneWidget);
    });
  });
}
