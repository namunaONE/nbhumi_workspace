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
    Size size = const Size(400, 800),
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

  /// Vertical cards rendered by the results grid (not the carousel above).
  Finder gridCards() => find.descendant(
        of: find.byType(GridView),
        matching: find.byType(ListingCard),
      );

  group('SearchScreen layout toggle', () {
    testWidgets('starts in the grid with vertical cards', (tester) async {
      await pumpScreen(tester);

      expect(gridCards(), findsWidgets);
      expect(find.byTooltip('List view'), findsOneWidget);
    });

    testWidgets('toggling shows horizontal rows and back', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('List view'));
      await tester.pumpAndSettle();

      // Grid cards gone; rows render in the list (and the featured header).
      expect(gridCards(), findsNothing);
      expect(find.byType(HorizontalListingCard), findsWidgets);
      expect(find.byTooltip('Grid view'), findsOneWidget);

      await tester.tap(find.byTooltip('Grid view'));
      await tester.pumpAndSettle();

      expect(gridCards(), findsWidgets);
    });

    testWidgets('list rows keep the listing content', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('List view'));
      await tester.pumpAndSettle();

      expect(find.text('House a'), findsWidgets);
      expect(find.text('House b'), findsWidgets);
    });
  });

  group('SearchScreen featured carousel', () {
    testWidgets('shows newest listings above unfiltered results',
        (tester) async {
      await pumpScreen(tester);

      expect(find.text('Latest listings'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });
  });

  group('SearchScreen wide side pane', () {
    Widget harness() => SearchScreen(
          detailPaneBuilder: (listingId, onClose) => Column(
            children: <Widget>[
              Text('pane:$listingId'),
              TextButton(onPressed: onClose, child: const Text('SHUT')),
            ],
          ),
        );

    testWidgets('a tap selects into the pane instead of navigating',
        (tester) async {
      await pumpScreen(
        tester,
        size: const Size(1200, 800),
        screen: harness(),
      );

      // The grid card, not the carousel row: both read House a, so tap the
      // one inside the grid.
      final gridCard = find.descendant(
        of: find.byType(GridView),
        matching: find.text('House a'),
      );
      await tester.tap(gridCard);
      await tester.pumpAndSettle();

      expect(find.text('pane:a'), findsOneWidget);
    });

    testWidgets('closing the pane returns to the single feed',
        (tester) async {
      await pumpScreen(
        tester,
        size: const Size(1200, 800),
        screen: harness(),
      );

      await tester.tap(
        find.descendant(
          of: find.byType(GridView),
          matching: find.text('House a'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('pane:a'), findsOneWidget);

      await tester.tap(find.text('SHUT'));
      await tester.pumpAndSettle();

      expect(find.text('pane:a'), findsNothing);
      expect(find.text('House a'), findsWidgets);
    });

    testWidgets('wide feed caps content width instead of stretching',
        (tester) async {
      await pumpScreen(
        tester,
        size: const Size(1200, 800),
        screen: harness(),
      );

      final gridWidth = tester.getSize(find.byType(GridView)).width;
      expect(gridWidth, lessThanOrEqualTo(960));
    });
  });
}
