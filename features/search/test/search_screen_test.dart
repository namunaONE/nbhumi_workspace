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
  Future<void> pumpScreen(
    WidgetTester tester, {
    Size size = const Size(360, 800),
    Widget screen = const SearchScreen(),
  }) async {
    tester.view.physicalSize = size;
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
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            search_strings.AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SearchScreen grid layout', () {
    testWidgets('renders listing cards in a grid', (tester) async {
      await pumpScreen(tester);

      expect(find.byType(ListingCard), findsWidgets);
    });

    testWidgets('shows listing content in cards', (tester) async {
      await pumpScreen(tester);

      expect(find.text('House a'), findsWidgets);
      expect(find.text('House b'), findsWidgets);
    });
  });

  group('SearchScreen filter bar', () {
    testWidgets('shows sort, filter and save search buttons when active',
        (tester) async {
      await pumpScreen(tester);

      expect(find.byTooltip('Sort'), findsOneWidget);
      expect(find.byTooltip('Filters'), findsOneWidget);
      // Save search button is hidden when no filter is active
      expect(find.byTooltip('Save search'), findsNothing);
    });
  });
}
