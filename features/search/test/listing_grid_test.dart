import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:search/search.dart';

/// Builds a summary with only the fields the card reads.
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

void main() {
  /// Resizes the test surface, restoring it when the test ends.
  Future<void> resize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  group('ListingGrid.columnsFor', () {
    test('is 1 on a phone', () {
      // 360dp phone minus grid padding.
      expect(ListingGrid.columnsFor(336), 1);
    });

    test('is 2 once a second card fits', () {
      // Two 180dp cards plus the 12dp cross-axis spacing.
      expect(ListingGrid.columnsFor(372), 2);
    });

    test('is 3 on a wide window', () {
      expect(ListingGrid.columnsFor(600), 3);
    });

    test('never exceeds 3 columns', () {
      // WIREFRAMES.md specifies at most three; a 4K window must not make a
      // fourth column appear.
      expect(ListingGrid.columnsFor(4000), 3);
    });

    test('never drops below 1 column', () {
      // Guards against a division result of 0 for a very narrow or
      // not-yet-laid-out constraint.
      expect(ListingGrid.columnsFor(10), 1);
      expect(ListingGrid.columnsFor(0), 1);
      expect(ListingGrid.columnsFor(-100), 1);
    });

    test('changes count only when a card would otherwise be too narrow', () {
      // The whole point of deriving from width rather than the Material 600/840
      // breakpoints: no window width should render a card under minCardWidth,
      // and no width should be wide enough for one more column than it was
      // given.
      const spacing = ListingGrid.crossAxisSpacing;

      for (var width = 180; width <= 2000; width += 7) {
        final columns = ListingGrid.columnsFor(width.toDouble());

        final perColumn = (width - spacing * (columns - 1)) / columns;
        expect(
          perColumn,
          greaterThanOrEqualTo(ListingGrid.minCardWidth),
          reason: 'width $width gave $columns columns at $perColumn px each',
        );

        // Adding a column takes its own share plus another gap, so the width a
        // further column would need is not simply minCardWidth more. Skipped at
        // the cap: a fourth column may well fit, and is refused on purpose.
        if (columns >= ListingGrid.maxColumns) continue;

        final ifOneMoreColumn = (width - spacing * columns) / (columns + 1);
        expect(
          ifOneMoreColumn,
          lessThan(ListingGrid.minCardWidth),
          reason: 'width $width should have had ${columns + 1} columns',
        );
      }
    });

    test('does not squeeze cards to fit a column they cannot fill', () {
      // The specific failure the spacing-aware formula exists to prevent:
      // 362 / 180 is 2.01, so a naive count says 2 columns, but two 180px cards
      // plus a 12px gap need 372px.
      expect(ListingGrid.columnsFor(361), 1);
      expect(ListingGrid.columnsFor(372), 2);
      expect(ListingGrid.columnsFor(554), 2);
      expect(ListingGrid.columnsFor(564), 3);
    });
  });

  group('ListingGrid rendering', () {
    Widget harness(List<ListingSummary> listings, {bool hasMore = false}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 600,
            child: ListingGrid(
              listings: listings,
              hasMore: hasMore,
              onLoadMore: () async {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders one card per listing', (tester) async {
      // Resized window on purpose. GridView.builder only builds what is near
      // the viewport, so a short window would legitimately show fewer cards
      // than rows — that is the lazy loading HYA-203 asks for, not a bug. A
      // SizedBox alone cannot do this: Scaffold clamps the body to the screen.
      await resize(tester, const Size(360, 2000));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListingGrid(
              listings: [_listing('a'), _listing('b'), _listing('c')],
              onLoadMore: () async {},
            ),
          ),
        ),
      );

      expect(find.byType(ListingCard), findsNWidgets(3));
    });

    testWidgets('builds only the visible rows, not the whole feed',
        (tester) async {
      // The other half of the lazy-building contract: a long feed must not be
      // turned into hundreds of widgets up front.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 600,
              child: ListingGrid(
                listings: [for (var i = 0; i < 200; i++) _listing('$i')],
                hasMore: true,
                onLoadMore: () async {},
              ),
            ),
          ),
        ),
      );

      final built = tester.widgetList<ListingCard>(find.byType(ListingCard));
      expect(built, isNotEmpty);
      expect(built.length, lessThan(200));
    });

    testWidgets('renders nothing but the grid when empty', (tester) async {
      await tester.pumpWidget(harness(const <ListingSummary>[]));
      expect(find.byType(ListingCard), findsNothing);
    });

    testWidgets('reports the tapped listing id', (tester) async {
      final tapped = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 600,
              child: ListingGrid(
                listings: [_listing('first'), _listing('second')],
                onLoadMore: () async {},
                onListingTap: tapped.add,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('House first'));
      await tester.pump();

      expect(tapped, <String>['first']);
    });

    testWidgets('is inert when no tap callback is supplied', (tester) async {
      // A preview inside another screen passes no callback; tapping must not
      // throw.
      await tester.pumpWidget(harness([_listing('a')]));
      await tester.tap(find.byType(ListingCard));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('adds a loading cell while a page is in flight',
        (tester) async {
      // The spinner must be an extra cell, not a replacement for the rows: the
      // already-loaded pages stay on screen while page two loads.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 600,
              child: ListingGrid(
                listings: [_listing('a')],
                hasMore: true,
                isLoadingMore: true,
                onLoadMore: () async {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListingCard), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not call onLoadMore while the list is short',
        (tester) async {
      // A short list is never scrolled past the threshold, so the feed must not
      // fire a second request for a page that does not exist.
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 600,
              child: ListingGrid(
                listings: [_listing('a')],
                hasMore: true,
                onLoadMore: () async {
                  calls++;
                },
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(GridView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(calls, 0);
    });
  });
}
