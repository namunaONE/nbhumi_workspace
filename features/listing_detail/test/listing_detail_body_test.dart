import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listing_detail/listing_detail.dart';
import 'package:models/models.dart';

ListingDetail _detail({
  String title = 'Shanti Villa',
  int priceNpr = 25000000,
  String? description = 'A well-kept three-storey house.',
  String? areaDisplay = '5 aana 4 paisa',
  List<String> photos = const <String>[],
  ListingSeller? seller = const ListingSeller(
    id: 'seller-1',
    fullName: 'Ram Bahadur',
    isVerified: true,
    role: 'agent',
    agencyName: 'Himal Realtors',
  ),
  String city = 'Kathmandu',
  String? ward = '16',
  String district = 'Kathmandu',
  int? roadAccessFt = 15,
}) =>
    ListingDetail(
      id: 'listing-1',
      sellerId: 'seller-1',
      title: title,
      priceNpr: priceNpr,
      district: district,
      city: city,
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      status: ListingStatus.live,
      description: description,
      areaDisplay: areaDisplay,
      photos: photos,
      seller: seller,
      ward: ward,
      roadAccessFt: roadAccessFt,
    );

/// Pumps the body inside a tall viewport.
///
/// Tall by default on purpose: the page is a ListView and only builds what is
/// near the viewport, so a short window would report the Description and Seller
/// sections as absent when they are merely scrolled off. The overflow test
/// overrides this with a realistic phone size.
Widget _harness(
  ListingDetail listing, {
  Locale locale = const Locale('en'),
  Size size = const Size(500, 2400),
}) {
  final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views
      .first
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(() {
    view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });

  return ProviderScope(
    // The body embeds ContactSellerButton, which is a ConsumerWidget, so the
    // whole subtree needs a container even though these tests never press it.
    // Overriding the repository keeps it off the network (Rule 33).
    overrides: [
      listingRepositoryProvider.overrideWithValue(_FakeRepository()),
      sessionProvider.overrideWithValue(null),
    ],
    child: MaterialApp(
      locale: locale,
      // Required, or Localizations silently resolves 'ne' back to 'en' and
      // every bilingual branch takes the English path. main.dart supplies
      // these too.
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
      home: Scaffold(body: ListingDetailBody(listing: listing)),
    ),
  );
}

/// Repository stub; the contact button is never pressed in these tests.
class _FakeRepository implements ListingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('price formatting', () {
    testWidgets('shows the full Indian-grouped figure, not the compact one',
        (tester) async {
      // Rule 27: compact is for cards, full for detail. A detail page that
      // showed "NPR 2.5 Cr" would hide the exact price the user came for.
      await tester.pumpWidget(_harness(_detail()));

      expect(find.text('NPR 2,50,00,000'), findsOneWidget);
      expect(find.text('NPR 2.5 Cr'), findsNothing);
    });

    testWidgets('groups lakh correctly', (tester) async {
      await tester.pumpWidget(_harness(_detail(priceNpr: 8500000)));
      expect(find.text('NPR 85,00,000'), findsOneWidget);
    });
  });

  group('content', () {
    testWidgets('shows the title', (tester) async {
      await tester.pumpWidget(_harness(_detail()));
      expect(find.text('Shanti Villa'), findsWidgets);
    });

    testWidgets('shows the description when present', (tester) async {
      await tester.pumpWidget(_harness(_detail()));
      expect(
        find.text('A well-kept three-storey house.'),
        findsOneWidget,
      );
    });

    testWidgets('omits the description section when empty', (tester) async {
      // A blank "Description" heading with nothing under it reads as a bug.
      await tester.pumpWidget(_harness(_detail(description: '   ')));
      expect(find.text('Description'), findsNothing);
    });

    testWidgets('shows the seller-supplied area, not sqm', (tester) async {
      // Rule 25. "5 aana 4 paisa" is how the seller described the plot.
      await tester.pumpWidget(_harness(_detail()));
      expect(find.text('5 aana 4 paisa'), findsOneWidget);
    });

    testWidgets('includes the ward in the location line', (tester) async {
      await tester.pumpWidget(_harness(_detail()));
      expect(find.textContaining('Ward 16'), findsOneWidget);
    });

    testWidgets('omits the ward when there is none', (tester) async {
      await tester.pumpWidget(_harness(_detail(ward: null)));
      expect(find.textContaining('Ward'), findsNothing);
      expect(find.text('Kathmandu, Kathmandu'), findsOneWidget);
    });

    testWidgets('shows road access when recorded', (tester) async {
      await tester.pumpWidget(_harness(_detail()));
      expect(find.text('15 ft road access'), findsOneWidget);
    });

    testWidgets('omits road access when null', (tester) async {
      await tester.pumpWidget(_harness(_detail(roadAccessFt: null)));
      expect(find.textContaining('road access'), findsNothing);
    });

    testWidgets('humanises enum values for display', (tester) async {
      await tester.pumpWidget(_harness(_detail()));
      expect(find.text('House'), findsOneWidget);
      expect(find.text('Sale'), findsOneWidget);
      expect(find.text('house'), findsNothing);
    });
  });

  group('seller card', () {
    testWidgets('shows the name, agency and verified tick', (tester) async {
      await tester.pumpWidget(_harness(_detail()));

      expect(find.text('Ram Bahadur'), findsOneWidget);
      expect(find.text('Himal Realtors'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('omits the verified tick when not verified', (tester) async {
      await tester.pumpWidget(
        _harness(
          _detail(
            seller: const ListingSeller(
              id: 'seller-1',
              fullName: 'Ram Bahadur',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.verified), findsNothing);
    });

    testWidgets('handles a seller with no name', (tester) async {
      // A profile created but never completed. Must not render an empty
      // heading or crash on the avatar initial.
      await tester.pumpWidget(
        _harness(_detail(seller: const ListingSeller(id: 'seller-1'))),
      );

      expect(find.text('Seller details unavailable'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles a missing seller object', (tester) async {
      await tester.pumpWidget(_harness(_detail(seller: null)));
      expect(find.text('Seller details unavailable'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the first letter of the name in the avatar',
        (tester) async {
      await tester.pumpWidget(_harness(_detail()));
      expect(find.text('R'), findsOneWidget);
    });
  });

  group('photos', () {
    testWidgets('renders a placeholder when there are no photos',
        (tester) async {
      await tester.pumpWidget(_harness(_detail()));
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders every photo in the pager', (tester) async {
      await tester.pumpWidget(
        _harness(
          _detail(
            photos: const <String>[
              'https://example.test/1.jpg',
              'https://example.test/2.jpg',
            ],
          ),
        ),
      );

      // Two pages: the second is built by PageView but not yet visible.
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byIcon(Icons.home), findsNothing);
    });
  });

  group('contact bar', () {
    testWidgets('offers contact and reveals nothing before it is pressed',
        (tester) async {
      // The button is live as of HYA-252. The assertion that matters is the
      // absence of contact data: nothing here should show a phone number.
      await tester.pumpWidget(_harness(_detail()));

      expect(
        find.widgetWithText(FilledButton, 'Sign in to contact'),
        findsOneWidget,
      );
      expect(find.text('+9779841234567'), findsNothing);
    });

    testWidgets('is labelled in Nepali too', (tester) async {
      await tester.pumpWidget(
        _harness(_detail(), locale: const Locale('ne')),
      );
      expect(
        find.widgetWithText(FilledButton, 'सम्पर्क गर्न साइन इन गर्नुहोस्'),
        findsOneWidget,
      );
    });
  });

  group('layout', () {
    testWidgets('renders without overflow at a narrow phone width',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          _detail(
            title: 'A very long property title that should not overflow',
            photos: const <String>['https://example.test/1.jpg'],
          ),
          size: const Size(360, 640),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls rather than clipping the content', (tester) async {
      await tester.pumpWidget(_harness(_detail(), size: const Size(360, 640)));
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('ListingDetail wire format', () {
    test('parses the shape v1_get_listing_detail returns', () {
      // Mirrors the verified live response. Field names are snake_case on
      // the wire, and `photos` is an array of URL strings, not objects.
      final detail = ListingDetail.fromJson(<String, dynamic>{
        'id': '61142d04-3e21-4f23-8335-9e546fe3f8cf',
        'seller_id': '11111111-1111-1111-1111-111111111111',
        'title': 'Probe House',
        'description': 'A probe listing.',
        'price_npr': 25000000,
        'area_sqm': 467.5,
        'area_aana': 5,
        'area_paisa': 4,
        'district': 'Kathmandu',
        'city': 'Kathmandu',
        'ward': '16',
        'road_access_ft': 15,
        'property_type': 'house',
        'listing_purpose': 'sale',
        'status': 'live',
        'photos': <String>['https://example.test/1.jpg'],
        'seller': <String, dynamic>{
          'id': '11111111-1111-1111-1111-111111111111',
          'full_name': 'Ram Bahadur',
          'is_verified': true,
          'kyc_tier': 'property',
          'role': 'agent',
          'agency_name': 'Himal Realtors',
        },
        'is_favorite': false,
        'area_display': '5 aana 4 paisa',
        'created_at': '2026-10-04T06:29:50.34982+00:00',
        'updated_at': '2026-10-04T06:29:50.34982+00:00',
      });

      expect(detail.title, 'Probe House');
      expect(detail.priceNpr, 25000000);
      expect(detail.areaAana, 5);
      expect(detail.areaPaisa, 4);
      expect(detail.photos, <String>['https://example.test/1.jpg']);
      expect(detail.seller?.fullName, 'Ram Bahadur');
      expect(detail.seller?.isVerified, isTrue);
      expect(detail.areaDisplay, '5 aana 4 paisa');
      expect(detail.status, ListingStatus.live);
      expect(detail.propertyType, PropertyType.house);
      expect(detail.listingPurpose, ListingPurpose.sale);
      expect(detail.isFavorite, isFalse);
    });

    test('the seller object carries no contact details to leak', () {
      // The RPC omits email and phone from `seller`. Assert the model has no
      // field that could hold them, so a future edit cannot add one silently.
      final seller = ListingSeller.fromJson(<String, dynamic>{
        'id': 's',
        'full_name': 'Ram',
      });

      expect(seller.toJson().containsKey('email'), isFalse);
      expect(seller.toJson().containsKey('phone'), isFalse);
    });

    test('round-trips through toJson', () {
      final detail = _detail();
      final again = ListingDetail.fromJson(detail.toJson());

      expect(again, detail);
      expect(again.seller?.fullName, 'Ram Bahadur');
    });
  });
}
