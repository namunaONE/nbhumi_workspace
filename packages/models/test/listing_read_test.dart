import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// A row shaped exactly like `v1_get_listings` returns.
///
/// The pre-migration RPC omitted `seller_id`, which is why `Listing.fromJson`
/// threw on every browse response. These fixtures are copies of real responses
/// captured against the fixed RPC so the contract cannot silently regress.
Map<String, dynamic> browseRow({
  String id = 'a1b2c3d4-0000-4000-8000-000000000001',
  String title = '5 Aana Land Bhaktapur',
  int priceNpr = 2500000,
  String status = 'live',
  String propertyType = 'land',
  String listingPurpose = 'sale',
  String areaDisplay = '5 aana 4 paisa',
}) =>
    <String, dynamic>{
      'id': id,
      'seller_id': '11111111-1111-1111-1111-111111111111',
      'title': title,
      'description': 'Prime plot',
      'price_npr': priceNpr,
      'area_sqm': 1711.0,
      'area_ropani': 0,
      'area_aana': 5,
      'area_paisa': 4,
      'area_dam': null,
      'area_bigha': null,
      'area_kattha': null,
      'area_dhur': null,
      'district': 'Bhaktapur',
      'city': 'Bhaktapur',
      'ward': '4',
      'road_access_ft': 12,
      'property_type': propertyType,
      'listing_purpose': listingPurpose,
      'status': status,
      'created_at': '2026-10-01T10:00:00.000Z',
      'updated_at': '2026-10-01T10:00:00.000Z',
      'is_verified': true,
      'seller_name': 'Ram Bahadur',
      'photo_url': 'https://example.test/photo-1.jpg',
      'area_display': areaDisplay,
    };

void main() {
  group('ListingSummary', () {
    test('parses a real browse row including sellerId', () {
      final listing = ListingSummary.fromJson(browseRow());

      expect(listing.id, 'a1b2c3d4-0000-4000-8000-000000000001');
      expect(listing.sellerId, '11111111-1111-1111-1111-111111111111');
      expect(listing.title, '5 Aana Land Bhaktapur');
      expect(listing.priceNpr, 2500000);
      expect(listing.propertyType, PropertyType.land);
      expect(listing.listingPurpose, ListingPurpose.sale);
      expect(listing.status, ListingStatus.live);
      expect(listing.isVerified, isTrue);
      expect(listing.photoUrl, 'https://example.test/photo-1.jpg');
    });

    test('carries the server-formatted area display', () {
      // Rule 25: hill districts read in ropani/aana/paisa/dam. The RPC builds
      // this string so the card and the detail page can never disagree.
      expect(
        ListingSummary.fromJson(browseRow()).areaDisplay,
        '5 aana 4 paisa',
      );

      expect(
        ListingSummary.fromJson(
          browseRow(areaDisplay: '1 bigha'),
        ).areaDisplay,
        '1 bigha',
      );

      expect(
        ListingSummary.fromJson(
          browseRow(areaDisplay: '1200 sqm'),
        ).areaDisplay,
        '1200 sqm',
      );
    });

    test('parses a pending_review status', () {
      final listing =
          ListingSummary.fromJson(browseRow(status: 'pending_review'));
      expect(listing.status, ListingStatus.pendingReview);
    });

    test('parses rows for every property type and purpose', () {
      for (final type in PropertyType.values) {
        expect(
          ListingSummary.fromJson(
            browseRow(propertyType: type.name),
          ).propertyType,
          type,
          reason: 'property type $type must round-trip',
        );
      }
      for (final purpose in ListingPurpose.values) {
        expect(
          ListingSummary.fromJson(
            browseRow(listingPurpose: purpose.name),
          ).listingPurpose,
          purpose,
          reason: 'purpose $purpose must round-trip',
        );
      }
    });

    test('tolerates null photo and verification fields', () {
      final json = browseRow()
        ..remove('photo_url')
        ..remove('is_verified')
        ..remove('seller_name')
        ..remove('area_display');

      final listing = ListingSummary.fromJson(json);
      expect(listing.photoUrl, isNull);
      expect(listing.isVerified, isNull);
      expect(listing.areaDisplay, isNull);
    });

    test('round-trips through toJson', () {
      final listing = ListingSummary.fromJson(browseRow());
      expect(ListingSummary.fromJson(listing.toJson()), listing);
    });
  });

  group('ListingDetail', () {
    Map<String, dynamic> detailRow() => <String, dynamic>{
          ...browseRow(),
          'rejection_reason': null,
          'photos': <String>[
            'https://example.test/1.jpg',
            'https://example.test/2.jpg',
          ],
          'seller': <String, dynamic>{
            'id': '11111111-1111-1111-1111-111111111111',
            'full_name': 'Ram Bahadur',
            'is_verified': true,
            'kyc_tier': 'identity',
            'role': 'agent',
            'agency_name': 'ABC Realty',
          },
          'is_favorite': false,
        };

    test('parses the nested seller card', () {
      final detail = ListingDetail.fromJson(detailRow());

      expect(detail.seller, isNotNull);
      expect(detail.seller!.id, '11111111-1111-1111-1111-111111111111');
      expect(detail.seller!.fullName, 'Ram Bahadur');
      expect(detail.seller!.isVerified, isTrue);
      expect(detail.seller!.kycTier, 'identity');
      expect(detail.seller!.role, 'agent');
      expect(detail.seller!.agencyName, 'ABC Realty');
    });

    test('seller card never carries email or phone', () {
      // The browse RPC is SECURITY DEFINER and joins `profiles`. Contact
      // details must only ever come from v1_contact_seller, so their absence
      // here is a security property, not an oversight.
      final detail = ListingDetail.fromJson(detailRow());

      expect(detail.seller!.toJson().containsKey('email'), isFalse);
      expect(detail.seller!.toJson().containsKey('phone'), isFalse);
    });

    test('parses the ordered photo list', () {
      final detail = ListingDetail.fromJson(detailRow());

      expect(detail.photos, <String>[
        'https://example.test/1.jpg',
        'https://example.test/2.jpg',
      ]);
    });

    test('defaults photos to empty and isFavorite to false', () {
      final json = detailRow()
        ..remove('photos')
        ..remove('is_favorite');

      final detail = ListingDetail.fromJson(json);
      expect(detail.photos, isEmpty);
      expect(detail.isFavorite, isFalse);
    });

    test('round-trips through toJson', () {
      final detail = ListingDetail.fromJson(detailRow());
      final restored = ListingDetail.fromJson(detail.toJson());

      expect(restored, detail);
      expect(restored.photos, detail.photos);
      expect(restored.seller, detail.seller);
    });
  });

  group('ListingSort', () {
    test('wire names match the p_sort enum exactly', () {
      // A mismatch here silently falls back to newest server-side, which looks
      // like "sort is broken" with no error anywhere.
      expect(ListingSort.newest.wireName, 'newest');
      expect(ListingSort.oldest.wireName, 'oldest');
      expect(ListingSort.priceAsc.wireName, 'price_asc');
      expect(ListingSort.priceDesc.wireName, 'price_desc');
    });
  });

  group('ListingCursor', () {
    test('after() uses the price for price sorts', () {
      final listing = ListingSummary.fromJson(browseRow());

      final cursor = ListingCursor.after(listing, ListingSort.priceAsc);

      expect(cursor.k, '2500000');
      expect(cursor.id, listing.id);
    });

    test('after() uses createdAt for date sorts', () {
      final listing = ListingSummary.fromJson(browseRow());

      final cursor = ListingCursor.after(listing, ListingSort.newest);

      expect(cursor.k, startsWith('2026-10-01'));
      expect(cursor.id, listing.id);
    });

    test('after() throws for a date sort when createdAt is absent', () {
      // Silently building a wrong cursor would skip or duplicate rows, which is
      // far harder to notice than a loud failure.
      final listing = ListingSummary.fromJson(
        browseRow()..remove('created_at'),
      );

      expect(
        () => ListingCursor.after(listing, ListingSort.newest),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('round-trips through toJson as the p_cursor shape', () {
      const cursor = ListingCursor(k: '2500000', id: 'abc');
      final json = cursor.toJson();

      expect(json, <String, dynamic>{'k': '2500000', 'id': 'abc'});
      expect(ListingCursor.fromJson(json), cursor);
    });
  });

  group('ListingFilter', () {
    test('isEmpty is true only when nothing is narrowing results', () {
      expect(const ListingFilter().isEmpty, isTrue);
      expect(const ListingFilter(district: 'Lalitpur').isEmpty, isFalse);
    });

    test('activeCount counts only narrowing fields, not sort or pageSize', () {
      const filter = ListingFilter(
        propertyType: PropertyType.land,
        district: 'Lalitpur',
        maxPriceNpr: 5000000,
        sort: ListingSort.priceAsc,
        pageSize: 50,
      );

      expect(filter.activeCount, 3);
    });

    test('sort and pageSize changes produce a new value for Riverpod', () {
      const a = ListingFilter();
      const b = ListingFilter(sort: ListingSort.priceAsc);

      // Riverpod invalidates a provider when the watched value changes identity
      // or equality. Filter changes must therefore be observable.
      expect(a, isNot(b));
      expect(a == const ListingFilter(), isTrue);
    });

    test('cleared() resets every filter', () {
      const filter = ListingFilter(
        propertyType: PropertyType.house,
        district: 'Pokhara',
        minPriceNpr: 1,
        sort: ListingSort.priceDesc,
      );

      expect(filter.cleared(), const ListingFilter());
    });
  });

  group('ListingPage', () {
    ListingSummary summaryAt(String id, int price, String createdAt) =>
        ListingSummary.fromJson(
          browseRow(id: id, priceNpr: price)..['created_at'] = createdAt,
        );

    test('nextCursor is null when there is no next page', () {
      final page = ListingPage(
        listings: [summaryAt('id-1', 100, '2026-10-01T00:00:00.000Z')],
      );

      expect(page.nextCursor, isNull);
    });

    test('nextCursor is null when hasMore is true but no rows came back', () {
      // A page with no rows but hasMore would otherwise build a cursor from
      // nothing and loop forever on scroll.
      const page = ListingPage(hasMore: true);
      expect(page.nextCursor, isNull);
    });

    test('nextCursor points past the last listing', () {
      final last = summaryAt('id-2', 200, '2026-10-01T00:00:00.000Z');
      final page = ListingPage(
        listings: [summaryAt('id-1', 100, '2026-10-02T00:00:00.000Z'), last],
        hasMore: true,
      );

      final cursor = page.nextCursor;
      expect(cursor, isNotNull);
      expect(cursor!.id, 'id-2');
    });

    test('parses the RPC envelope', () {
      // Shape captured from v1_get_listings after HYA-249.
      final page = ListingPage.fromJson(<String, dynamic>{
        'listings': <dynamic>[browseRow()],
        'total_count': 3,
        'page_size': 20,
        'has_more': true,
      });

      expect(page.listings, hasLength(1));
      expect(page.totalCount, 3);
      expect(page.pageSize, 20);
      expect(page.hasMore, isTrue);
      expect(page.isEmpty, isFalse);
    });

    test('defaults an empty envelope rather than throwing', () {
      final page = ListingPage.fromJson(<String, dynamic>{});

      expect(page.listings, isEmpty);
      expect(page.totalCount, 0);
      expect(page.isEmpty, isTrue);
    });
  });
}
