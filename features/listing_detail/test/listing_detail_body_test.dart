import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
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
  int? bedrooms = 3,
  int? bathrooms = 2,
  FacingDirection? facingDirection,
  List<String> amenities = const <String>[],
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
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      facingDirection: facingDirection,
      amenities: amenities,
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
  bool isFavorite = false,
  VoidCallback? onFavoriteToggle,
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
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        detail_strings.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
      home: Scaffold(
        body: ListingDetailBody(
          listing: listing,
          isFavorite: isFavorite,
          onFavoriteToggle: onFavoriteToggle,
        ),
      ),
    ),
  );
}

/// Repository stub; the contact button is never pressed in these tests.
class _FakeRepository implements ListingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Repository stub that records the report call.
class _DelegatingRepository implements ListingRepository {
  _DelegatingRepository();

  /// The last call to [reportListing], or null when there has been none.
  ({String listingId, ReportReason reason, String? details})? lastReport;

  @override
  Future<ListingReport> reportListing({
    required String listingId,
    required ReportReason reason,
    String? details,
  }) async {
    lastReport = (
      listingId: listingId,
      reason: reason,
      details: details,
    );
    return ListingReport(
      reportId: 'r1',
      listingId: listingId,
      reason: reason,
      details: details,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pumps the detail body with a signed-in session and reports the calls made.
Widget _harnessSignedIn(
  ListingDetail listing, {
  Locale locale = const Locale('en'),
  _DelegatingRepository? repository,
}) {
  final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views
      .first
    ..physicalSize = const Size(500, 2400)
    ..devicePixelRatio = 1;
  addTearDown(() {
    view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });

  return ProviderScope(
    overrides: [
      listingRepositoryProvider.overrideWithValue(
        repository ?? _DelegatingRepository(),
      ),
      sessionProvider.overrideWithValue(null),
      isSignedInProvider.overrideWithValue(true),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        detail_strings.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
      home: Scaffold(
        body: ListingDetailBody(listing: listing),
      ),
    ),
  );
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

    testWidgets('shows facing when recorded', (tester) async {
      await tester.pumpWidget(
        _harness(_detail(facingDirection: FacingDirection.east)),
      );
      expect(find.text('Faces East'), findsOneWidget);
    });

    testWidgets('omits facing when null', (tester) async {
      await tester.pumpWidget(_harness(_detail()));
      expect(find.textContaining('Faces'), findsNothing);
    });

    testWidgets('shows amenity chips when recorded', (tester) async {
      await tester.pumpWidget(
        _harness(
          _detail(amenities: const <String>['Drinking water', 'Balcony']),
        ),
      );
      expect(find.text('Amenities'), findsOneWidget);
      expect(find.text('Drinking water'), findsOneWidget);
      expect(find.text('Balcony'), findsOneWidget);
    });

    testWidgets('omits the amenities section when empty', (tester) async {
      await tester.pumpWidget(_harness(_detail()));
      expect(find.text('Amenities'), findsNothing);
    });

    testWidgets('humanises enum values for display', (tester) async {
      await tester.pumpWidget(_harness(_detail()));
      expect(find.text('House'), findsOneWidget);
      expect(find.text('Sale'), findsOneWidget);
      expect(find.text('house'), findsNothing);
    });

    testWidgets('shows bedrooms and bathrooms', (tester) async {
      // WIREFRAMES.md Screen 2: "Bedrooms: 3", "Bathrooms: 2".
      await tester.pumpWidget(_harness(_detail()));
      expect(find.text('3 bedrooms'), findsOneWidget);
      expect(find.text('2 bathrooms'), findsOneWidget);
    });

    testWidgets('uses the singular for one', (tester) async {
      await tester.pumpWidget(
        _harness(_detail(bedrooms: 1, bathrooms: 1)),
      );
      expect(find.text('1 bedroom'), findsOneWidget);
      expect(find.text('1 bathroom'), findsOneWidget);
      expect(find.text('1 bedrooms'), findsNothing);
    });

    testWidgets('omits the section entirely for land', (tester) async {
      // Land has no bedrooms. "Bedrooms: 0" would be wrong, not terse.
      await tester.pumpWidget(
        _harness(_detail(bedrooms: null, bathrooms: null)),
      );
      expect(find.text('Details'), findsNothing);
      expect(find.text('0 bedrooms'), findsNothing);
    });

    testWidgets('shows only the half that is present', (tester) async {
      await tester.pumpWidget(
        _harness(_detail(bedrooms: 4, bathrooms: null)),
      );
      expect(find.text('4 bedrooms'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.textContaining('bathroom'), findsNothing);
    });
  });


  group('conditioned sections', () {
    testWidgets('a lease shows its term and the renewal answer',
        (tester) async {
      await tester.pumpWidget(_harness(
        _detail().copyWith(
          listingPurpose: ListingPurpose.lease,
          leaseTermMonths: 24,
          leaseRenewable: true,
        ),
      ));

      expect(find.text('Lease terms'), findsOneWidget);
      expect(find.text('24 months'), findsOneWidget);
      expect(find.text('Can be renewed'), findsOneWidget);
    });

    testWidgets('a lease without a renewal answer says nothing about it',
        (tester) async {
      // Unset is not "no": the row must not claim either way.
      await tester.pumpWidget(_harness(
        _detail().copyWith(
          listingPurpose: ListingPurpose.lease,
          leaseTermMonths: 12,
        ),
      ));

      expect(find.text('Lease terms'), findsOneWidget);
      expect(find.text('12 months'), findsOneWidget);
      expect(find.text('Can be renewed'), findsNothing);
      expect(find.text('Cannot be renewed'), findsNothing);
    });

    testWidgets('a sale shows no lease section', (tester) async {
      await tester.pumpWidget(_harness(_detail()));

      expect(find.text('Lease terms'), findsNothing);
      expect(find.text('Rental terms'), findsNothing);
    });

    testWidgets('a rent shows deposit, date, furnishing and pets',
        (tester) async {
      await tester.pumpWidget(_harness(
        _detail().copyWith(
          listingPurpose: ListingPurpose.rent,
          depositAmount: 50000,
          availableFrom: DateTime.utc(2026, 12),
          furnishingStatus: FurnishingStatus.semiFurnished,
          petPolicy: PetPolicy.catsOk,
          utilitiesIncluded: 'Water and maintenance',
        ),
      ));

      expect(find.text('Rental terms'), findsOneWidget);
      expect(find.text('Deposit NPR 50,000'), findsOneWidget);
      expect(find.textContaining('Dec 1, 2026'), findsOneWidget);
      expect(find.text('Partly furnished'), findsOneWidget);
      expect(find.text('Pets: Cats allowed'), findsOneWidget);
      expect(find.text('Water and maintenance'), findsOneWidget);
    });

    testWidgets('a rent with no terms shows no rental section',
        (tester) async {
      // The trigger guarantees this shape cannot come from the server, but
      // the page must still degrade to nothing rather than an empty heading.
      await tester.pumpWidget(_harness(
        _detail().copyWith(listingPurpose: ListingPurpose.rent),
      ));

      expect(find.text('Rental terms'), findsNothing);
    });

    testWidgets('an apartment shows floor, age and construction',
        (tester) async {
      await tester.pumpWidget(_harness(
        _detail().copyWith(
          propertyType: PropertyType.apartment,
          floorNumber: 3,
          totalFloors: 7,
          parkingSpaces: 1,
          propertyAgeYears: 10,
          constructionStatus: ConstructionStatus.resale,
        ),
      ));

      expect(find.text('Building'), findsOneWidget);
      expect(find.text('Floor 3 of 7'), findsOneWidget);
      expect(find.text('1 parking spaces'), findsOneWidget);
      expect(find.text('10 years old'), findsOneWidget);
      expect(find.text('Resale'), findsOneWidget);
    });

    testWidgets('a floor without a total still reads', (tester) async {
      await tester.pumpWidget(_harness(
        _detail().copyWith(
          propertyType: PropertyType.apartment,
          floorNumber: 2,
        ),
      ));

      expect(find.text('Floor 2'), findsOneWidget);
    });

    testWidgets('land shows no building section', (tester) async {
      await tester.pumpWidget(_harness(
        _detail().copyWith(
          propertyType: PropertyType.land,
          bedrooms: null,
          bathrooms: null,
        ),
      ));

      expect(find.text('Building'), findsNothing);
      expect(find.text('Lease terms'), findsNothing);
      expect(find.text('Rental terms'), findsNothing);
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
        'bedrooms': 3,
        'bathrooms': 2,
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
      expect(detail.bedrooms, 3);
      expect(detail.bathrooms, 2);
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

  group('favorite button (HYA-268 C1)', () {
    testWidgets('hidden without a toggle callback', (tester) async {
      // Guests get no heart: saving needs a session, and the screen passes
      // null for them. The default keeps provider-free pumps compiling.
      await tester.pumpWidget(_harness(_detail()));
      await tester.pump();

      expect(find.byTooltip('Save this property'), findsNothing);
      expect(find.byTooltip('Remove from saved'), findsNothing);
    });

    testWidgets('outline heart fires the toggle', (tester) async {
      var toggled = 0;
      await tester.pumpWidget(
        _harness(
          _detail(),
          onFavoriteToggle: () => toggled++,
        ),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Save this property'));
      expect(toggled, 1);
    });

    testWidgets('filled heart when already saved', (tester) async {
      await tester.pumpWidget(
        _harness(
          _detail(),
          isFavorite: true,
          onFavoriteToggle: () {},
        ),
      );
      await tester.pump();

      expect(find.byTooltip('Remove from saved'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('report button (HYA-263)', () {
    testWidgets('is offered on every detail page', (tester) async {
      // Unlike the heart, a report is always meaningful when there is a
      // listing to report — signed in or out, the button itself decides to
      // send a guest to sign in first.
      await tester.pumpWidget(_harness(_detail()));
      await tester.pump();

      expect(find.byTooltip('Report this listing'), findsOneWidget);
    });

    testWidgets('the tooltip is bilingual', (tester) async {
      await tester.pumpWidget(_harness(_detail(), locale: const Locale('ne')));
      await tester.pump();

      expect(find.byTooltip('रिपोर्ट गर्नुहोस्'), findsOneWidget);
    });

    testWidgets('a signed-in tap opens the reason picker', (tester) async {
      await tester.pumpWidget(_harnessSignedIn(_detail()));
      await tester.pump();

      await tester.tap(find.byTooltip('Report this listing'));
      await tester.pumpAndSettle();

      expect(find.text('Report this listing'), findsWidgets);
      expect(find.text('Fake listing'), findsOneWidget);
    });

    testWidgets("'other' with no details is refused in the sheet itself",
        (tester) async {
      // Rule 6, client side: the server refuses the same thing, but the
      // complaint should name the field rather than arrive as a snackbar
      // after a round trip.
      await tester.pumpWidget(_harnessSignedIn(_detail()));
      await tester.pump();

      await tester.tap(find.byTooltip('Report this listing'));
      await tester.pumpAndSettle();

      // Choose 'Other', which requires details.
      await tester.tap(find.byType(DropdownButton<ReportReason>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit report'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please describe the problem so our team can act on it.'),
        findsOneWidget,
      );
    });

    testWidgets('a specific reason submits with the listing id', (
      tester,
    ) async {
      // The happy path: pick a reason, optionally describe, submit. The
      // repository must receive the trimmed description, and a success must
      // be visible rather than assumed.
      final repository = _DelegatingRepository();
      await tester.pumpWidget(
        _harnessSignedIn(_detail(), repository: repository),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Report this listing'));
      await tester.pumpAndSettle();

      // Default reason is 'fake listing', which needs no details.
      await tester.tap(find.text('Submit report'));
      await tester.pumpAndSettle();

      expect(
        repository.lastReport?.reason,
        ReportReason.fakeListing,
      );
      expect(repository.lastReport?.listingId, 'listing-1');
      expect(
        find.text('Report filed. Our team will review it.'),
        findsOneWidget,
      );
    });
  });
}
