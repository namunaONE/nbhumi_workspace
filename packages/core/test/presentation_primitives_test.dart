import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Pumps [child] under the light app theme.
Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}

void main() {
  group('StatusChip', () {
    testWidgets('purpose chip names the purpose', (tester) async {
      await _pump(
        tester,
        StatusChip.purpose(ListingPurpose.sale),
      );
      expect(find.text('Sale'), findsOneWidget);
    });

    testWidgets('verified chip names verification', (tester) async {
      await _pump(tester, StatusChip.verified());
      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });
  });

  group('AppStates', () {
    testWidgets('empty state shows title, body, and action', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        EmptyState(
          title: 'Nothing here',
          body: 'Try again later.',
          actionLabel: 'Retry now',
          onAction: () => tapped = true,
        ),
      );
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Try again later.'), findsOneWidget);
      await tester.tap(find.text('Retry now'));
      expect(tapped, isTrue);
    });

    testWidgets('error state shows message and retry', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        ErrorState(
          message: 'Something broke.',
          retryLabel: 'Retry',
          onRetry: () => tapped = true,
        ),
      );
      expect(find.text('Something broke.'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });

    testWidgets('loading state shows a spinner', (tester) async {
      await _pump(tester, const LoadingState());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('PrimaryCTA', () {
    testWidgets('loading shows spinner and ignores taps', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        PrimaryCTA(
          label: 'Submit',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Submit'));
      expect(tapped, isFalse);
    });

    testWidgets('idle forwards taps', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        PrimaryCTA(label: 'Go', onPressed: () => tapped = true),
      );
      await tester.tap(find.text('Go'));
      expect(tapped, isTrue);
    });
  });

  group('AppContentWidths', () {
    test('orders form < reading < feed', () {
      expect(AppContentWidths.form, lessThan(AppContentWidths.reading));
      expect(AppContentWidths.reading, lessThan(AppContentWidths.feed));
    });

    test('feed aliases the grid cap so the two cannot drift', () {
      expect(AppContentWidths.feed, AppSizes.contentMaxWidth);
      expect(AppContentWidths.feed, 960);
    });
  });

  group('CenteredContent', () {
    Future<void> pumpCapped(
      WidgetTester tester, {
      required double surfaceWidth,
      double maxWidth = AppContentWidths.form,
    }) async {
      tester.view.physicalSize = Size(surfaceWidth, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pump(
        tester,
        CenteredContent(
          maxWidth: maxWidth,
          child: Container(
            key: const Key('capped-child'),
            height: 20,
            color: Colors.red,
          ),
        ),
      );
    }

    testWidgets('caps a wide window instead of stretching', (tester) async {
      await pumpCapped(tester, surfaceWidth: 1280);
      expect(tester.getSize(find.byKey(const Key('capped-child'))).width, 480);
    });

    testWidgets('leaves a phone-width window untouched', (tester) async {
      await pumpCapped(tester, surfaceWidth: 400);
      expect(tester.getSize(find.byKey(const Key('capped-child'))).width, 400);
    });
  });

  group('ListingCard', () {
    const summary = ListingSummary(
      id: 'l1',
      sellerId: 's1',
      title: 'Sunny House',
      priceNpr: 25000000,
      district: 'Kathmandu',
      city: 'Kirtipur',
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      areaDisplay: '5 aana',
      isVerified: true,
    );

    testWidgets('shows type label and merged location line', (tester) async {
      // Constrained to a phone-grid column: the card always renders under
      // a bounded width in production (grid columns, shelf rows).
      await _pump(
        tester,
        const SizedBox(width: 360, child: ListingCard(listing: summary)),
      );
      // Type chip names the property type; purpose rides on the photo
      // overlay only, so it appears exactly once.
      expect(find.text('House'), findsOneWidget);
      expect(find.text('Sale'), findsOneWidget);
      expect(
        find.text('Kathmandu, Kirtipur · 5 aana'),
        findsOneWidget,
      );
    });

    testWidgets('compact density renders the same content', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 180,
          child: ListingCard(listing: summary, compact: true),
        ),
      );
      expect(find.text('Sunny House'), findsOneWidget);
      expect(find.text('House'), findsOneWidget);
    });

    testWidgets('horizontal card shows the same content', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 360,
          child: HorizontalListingCard(listing: summary),
        ),
      );
      expect(find.text('Sunny House'), findsOneWidget);
      expect(find.text('House'), findsOneWidget);
      expect(
        find.text('Kathmandu, Kirtipur · 5 aana'),
        findsOneWidget,
      );
    });

    testWidgets('uses large text without overflowing', (tester) async {
      await _pump(
        tester,
        const MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(1.3),
          ),
          child: SizedBox(
            width: 360,
            child: ListingCard(listing: summary),
          ),
        ),
      );
      expect(find.text('Sunny House'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('horizontal card uses large text without overflowing',
        (tester) async {
      await _pump(
        tester,
        const MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(1.3),
          ),
          child: SizedBox(
            width: 360,
            child: HorizontalListingCard(listing: summary),
          ),
        ),
      );
      expect(find.text('Sunny House'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
