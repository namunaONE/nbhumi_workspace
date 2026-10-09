import 'package:core/core.dart';
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

/// Pumps the pane with a stubbed detail provider.
Future<void> _pumpPane(
  WidgetTester tester,
  ListingDetail? detail, {
  Widget? leading,
}) async {
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
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          detail_strings.AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
        home: Scaffold(
          body: ListingDetailPane(
            listingId: 'listing-1',
            leading: leading,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Widget tests for [ListingDetailPane].
void main() {
  group('ListingDetailPane', () {
    testWidgets('loaded detail renders the shared body', (tester) async {
      await _pumpPane(tester, _detail());

      expect(find.byType(ListingDetailBody), findsOneWidget);
      expect(find.text('Shanti Villa'), findsWidgets);
    });

    testWidgets('embedded leading replaces the back button', (tester) async {
      await _pumpPane(
        tester,
        _detail(),
        leading: const Text('CLOSE'),
      );

      expect(find.text('CLOSE'), findsOneWidget);
    });

    testWidgets('missing detail renders the unavailable state', (tester) async {
      await _pumpPane(tester, null);

      expect(find.byType(ListingDetailBody), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
    });
  });
}
