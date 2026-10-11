import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
import 'package:listing_detail/listing_detail.dart';
import 'package:models/models.dart';

/// Minimal loaded fixture: title, price, location, and seller.
ListingDetail _detail() => const ListingDetail(
      id: 'listing-1',
      sellerId: 'seller-1',
      title: 'Shanti Villa',
      priceNpr: 25000000,
      district: 'Kathmandu',
      city: 'Kirtipur',
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      status: ListingStatus.live,
      seller: ListingSeller(
        id: 'seller-1',
        fullName: 'Ram Bahadur',
        isVerified: true,
      ),
    );

/// Notifier stub answering a fixed detail (Rule 33).
class _FakeDetailView extends ListingDetailView {
  _FakeDetailView(this._detail);

  final ListingDetail? _detail;

  @override
  Future<ListingDetail?> build(String listingId) async => _detail;
}

/// Repository stub; the contact button is never pressed in these tests.
class _FakeRepository implements ListingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pumps the screen with a stubbed detail provider.
Future<void> _pumpScreen(
  WidgetTester tester,
  ListingDetail? detail) async {
  tester.view.physicalSize = const Size(500, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        listingRepositoryProvider.overrideWithValue(_FakeRepository()),
        sessionProvider.overrideWithValue(null),
        favoriteIdsProvider.overrideWith((ref) async => <String>{}),
        listingVerificationProvider(listingId: 'listing-1').overrideWith(
          (ref) async => (verified: false, reviewedAt: null),
        ),
        listingDetailViewProvider('listing-1')
            .overrideWith(() => _FakeDetailView(detail)),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          detail_strings.AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: <Locale>[Locale('en'), Locale('ne')],
        home: ListingDetailScreen(listingId: 'listing-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Widget tests for [ListingDetailScreen].
void main() {
  group('ListingDetailScreen', () {
    testWidgets('loaded detail renders the shared body', (tester) async {
      await _pumpScreen(tester, _detail());

      expect(find.byType(ListingDetailBody), findsOneWidget);
      expect(find.text('Shanti Villa'), findsWidgets);
    });

    testWidgets('missing detail renders the unavailable state', (tester) async {
      await _pumpScreen(tester, null);

      expect(find.byType(ListingDetailBody), findsNothing);
      // _NotAvailable shows the not available title and body
      expect(find.text('This property is no longer available'), findsOneWidget);
      expect(
        find.text(
          'It may have been sold, withdrawn by the seller, or the link may be wrong.',
        ),
        findsOneWidget,
      );
    });
  });
}
