import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

Listing _listing({
  int? bedrooms = 3,
  int? bathrooms = 2,
  int? areaAana = 5,
  int? areaPaisa = 4,
  int? areaBigha,
  String? kittaNumber,
}) =>
    Listing(
      id: 'l1',
      sellerId: 's1',
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      title: 'Shanti Villa',
      priceNpr: 25000000,
      district: 'Kathmandu',
      city: 'Kathmandu',
      areaAana: areaAana,
      areaPaisa: areaPaisa,
      areaBigha: areaBigha,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      kittaNumber: kittaNumber,
    );

void main() {
  group('buildCreateParams', () {
    test('sends bedrooms and bathrooms', () {
      final params = ListingRepository.buildCreateParams(
        _listing(),
        ListingStatus.draft,
      );

      expect(params['p_bedrooms'], 3);
      expect(params['p_bathrooms'], 2);
    });

    test('sends null for absent bedroom counts', () {
      // Land has none. The column is nullable by design and CHECKs > 0, so null
      // is the only correct encoding for "not applicable".
      final params = ListingRepository.buildCreateParams(
        _listing(bedrooms: null, bathrooms: null),
        ListingStatus.draft,
      );

      expect(params['p_bedrooms'], isNull);
      expect(params['p_bathrooms'], isNull);
    });

    test('sends all seven local area units', () {
      // G-13. These are the parameters the RPC was missing.
      final listing = _listing(areaBigha: 2);
      final params = ListingRepository.buildCreateParams(
        listing,
        ListingStatus.pendingReview,
      );

      expect(params['p_area_ropani'], isNull);
      expect(params['p_area_aana'], 5);
      expect(params['p_area_paisa'], 4);
      expect(params['p_area_dam'], isNull);
      expect(params['p_area_bigha'], 2);
      expect(params['p_area_kattha'], isNull);
      expect(params['p_area_dhur'], isNull);
    });

    test('sends the requested status', () {
      expect(
        ListingRepository.buildCreateParams(_listing(), ListingStatus.draft)[
            'p_status'],
        'draft',
      );
      expect(
        ListingRepository.buildCreateParams(
          _listing(),
          ListingStatus.pendingReview,
        )['p_status'],
        'pending_review',
      );
    });

    test('sends the kitta number when present, null when absent', () {
      // HYA-300: feeds the duplicate/missing-kitta signals. Absent is null,
      // never '', so the server reads it as "not provided".
      expect(
        ListingRepository.buildCreateParams(
          _listing(kittaNumber: '12-A'),
          ListingStatus.draft,
        )['p_kitta_number'],
        '12-A',
      );
      expect(
        ListingRepository.buildCreateParams(
          _listing(),
          ListingStatus.draft,
        )['p_kitta_number'],
        isNull,
      );
    });

    test('sends the kitta number when present, null when absent', () {
      // HYA-300: feeds the duplicate/missing-kitta signals. Absent is null,
      // never '', so the server reads it as "not provided".
      expect(
        ListingRepository.buildCreateParams(
          _listing(kittaNumber: '12-A'),
          ListingStatus.draft,
        )['p_kitta_number'],
        '12-A',
      );
      expect(
        ListingRepository.buildCreateParams(
          _listing(),
          ListingStatus.draft,
        )['p_kitta_number'],
        isNull,
      );
    });

    test('covers every writable column on the table', () {
      // The regression guard. G-12 and G-13 both survived for months because a
      // column existed with no matching parameter, and nothing failed loudly:
      // PostgREST ignores extra params and the RPC silently defaulted.
      final params = ListingRepository.buildCreateParams(
        _listing(),
        ListingStatus.draft,
      );

      expect(
        params.keys.toSet(),
        <String>{
          'p_property_type',
          'p_listing_purpose',
          'p_title',
          'p_description',
          'p_price_npr',
          'p_area_sqm',
          'p_area_ropani',
          'p_area_aana',
          'p_area_paisa',
          'p_area_dam',
          'p_area_bigha',
          'p_area_kattha',
          'p_area_dhur',
          'p_district',
          'p_city',
          'p_ward',
          'p_road_access_ft',
          'p_kitta_number',
          'p_bedrooms',
          'p_bathrooms',
          'p_status',
        },
      );
    });
  });

  group('buildUpdateParams', () {
    test('sends bedrooms and bathrooms', () {
      final params = ListingRepository.buildUpdateParams(
        'l1',
        _listing(),
        null,
      );

      expect(params['p_bedrooms'], 3);
      expect(params['p_bathrooms'], 2);
    });

    test('sends the seven local area units', () {
      // The whole point of G-13 being fixed: these were unreachable before.
      final params = ListingRepository.buildUpdateParams(
        'l1',
        _listing(areaBigha: 3),
        null,
      );

      expect(params['p_area_aana'], 5);
      expect(params['p_area_paisa'], 4);
      expect(params['p_area_bigha'], 3);
    });

    test('a null listing sends nulls so the server leaves fields alone', () {
      // Every parameter follows coalesce(p_x, x) server-side, so null means
      // "do not change". A status-only transition must not blank the title.
      final params = ListingRepository.buildUpdateParams(
        'l1',
        null,
        ListingStatus.pendingReview,
      );

      expect(params['p_listing_id'], 'l1');
      expect(params['p_title'], isNull);
      expect(params['p_bedrooms'], isNull);
      expect(params['p_area_aana'], isNull);
      expect(params['p_status'], 'pending_review');
    });

    test('a null status means the status is untouched', () {
      // Deliberate: a title-only edit must not move a live listing. The server
      // treats an unchanged status as a no-op, and null guarantees unchanged.
      final params = ListingRepository.buildUpdateParams(
        'l1',
        _listing(),
        null,
      );

      expect(params['p_status'], isNull);
    });

    test('sends the kitta number when present, null when absent', () {
      final params = ListingRepository.buildUpdateParams(
        'l1',
        _listing(kittaNumber: '12-A'),
        null,
      );

      expect(params['p_kitta_number'], '12-A');
      expect(
        ListingRepository.buildUpdateParams('l1', _listing(), null)[
            'p_kitta_number'],
        isNull,
      );
    });

    test('sends the kitta number when present, null when absent', () {
      final params = ListingRepository.buildUpdateParams(
        'l1',
        _listing(kittaNumber: '12-A'),
        null,
      );

      expect(params['p_kitta_number'], '12-A');
      expect(
        ListingRepository.buildUpdateParams('l1', _listing(), null)[
            'p_kitta_number'],
        isNull,
      );
    });

    test('sends exactly the fields the update RPC can change, plus the id', () {
      // Not the same as create: v1_update_listing has no p_property_type or
      // p_listing_purpose, because a listing's type and purpose are fixed once
      // created. Asserting the real set rather than a superset relationship, so
      // a parameter invented here is caught too.
      final update = ListingRepository.buildUpdateParams(
        'l1',
        _listing(),
        null,
      ).keys.toSet();

      expect(
        update,
        <String>{
          'p_listing_id',
          'p_title',
          'p_description',
          'p_price_npr',
          'p_area_sqm',
          'p_area_ropani',
          'p_area_aana',
          'p_area_paisa',
          'p_area_dam',
          'p_area_bigha',
          'p_area_kattha',
          'p_area_dhur',
          'p_district',
          'p_city',
          'p_ward',
          'p_road_access_ft',
          'p_kitta_number',
          'p_bedrooms',
          'p_bathrooms',
          'p_status',
        },
      );
    });

    test('omits the immutable type and purpose', () {
      // Changing a house into land after the fact would invalidate the
      // listing's whole context; the RPC does not allow it and neither do we.
      final update = ListingRepository.buildUpdateParams(
        'l1',
        _listing(),
        null,
      );

      expect(update.containsKey('p_property_type'), isFalse);
      expect(update.containsKey('p_listing_purpose'), isFalse);
    });
  });

  group('Listing model', () {
  test('wire names match the Postgres listing_status enum', () {
    // The values below are copied from the live database, not from the Dart
    // names. If the enum ever changes, this fails rather than sending a value
    // the RPC will reject.
    expect(ListingStatus.draft.wireName, 'draft');
    expect(ListingStatus.pendingReview.wireName, 'pending_review');
    expect(ListingStatus.live.wireName, 'live');
    expect(ListingStatus.rejected.wireName, 'rejected');
  });

  test('wire name is never the camelCase Dart name', () {
    // The bug this guards: `status.name` was sent straight to the RPC, so
    // submitting a listing for review failed with
    // 'VALIDATION_ERROR: status must be draft or pending_review'.
    for (final status in ListingStatus.values) {
      if (status == ListingStatus.pendingReview) {
        expect(status.name, isNot(status.wireName));
      } else {
        expect(status.name, status.wireName);
      }
    }
  });

  test('fromWire parses what the database actually returns', () {
    // The mirror bug: values.byName('pending_review') throws, because byName
    // matches the Dart name 'pendingReview'.
    expect(ListingStatus.fromWire('pending_review'),
        ListingStatus.pendingReview);
    expect(ListingStatus.fromWire('draft'), ListingStatus.draft);
    expect(ListingStatus.fromWire('live'), ListingStatus.live);
    expect(ListingStatus.fromWire('rejected'), ListingStatus.rejected);
  });

  test('fromWire throws on an unknown value rather than defaulting', () {
    // Defaulting to draft would silently misreport a listing's state.
    expect(
      () => ListingStatus.fromWire('archived'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('every value round-trips through fromWire(wireName)', () {
    for (final status in ListingStatus.values) {
      expect(ListingStatus.fromWire(status.wireName), status);
    }
  });

  test('JSON encoding still uses the wire name', () {
    // @JsonValue and wireName must not drift apart.
    final json = _listing().toJson()..['status'] = 'pending_review';
    expect(Listing.fromJson(json).status, ListingStatus.pendingReview);
  });

  test('serialises bedrooms and bathrooms', () {
      final json = _listing().toJson();
      expect(json['bedrooms'], 3);
      expect(json['bathrooms'], 2);
    });

    test('parses bedrooms and bathrooms back', () {
      final listing = Listing.fromJson(_listing().toJson());
      expect(listing.bedrooms, 3);
      expect(listing.bathrooms, 2);
    });

    test('round-trips', () {
      final listing = _listing();
      expect(Listing.fromJson(listing.toJson()), listing);
    });
  });

  group('buildReportListingParams', () {
    test('pins all three parameter names', () {
      expect(
        ListingRepository.buildReportListingParams(
          listingId: 'l1',
          reason: ReportReason.duplicateListing,
          details: 'Same house is listed twice',
        ),
        <String, Object?>{
          'p_listing_id': 'l1',
          'p_reason': 'duplicate_listing',
          'p_details': 'Same house is listed twice',
        },
      );
    });

    test('sends the enum label, not the Dart name', () {
      // `duplicateListing` would be rejected by the RPC's own enum cast with a
      // 22023. Every multi-word reason is wrong in the same way, so this
      // enumerates all of them rather than sampling one.
      final wrong = <String>[];
      for (final reason in ReportReason.values) {
        final sent = ListingRepository.buildReportListingParams(
          listingId: 'l1',
          reason: reason,
        )['p_reason'];
        if (sent != reason.wireName) wrong.add('${reason.name} -> $sent');
        // And the wire value must be one the database actually has.
        expect(
          _databaseReportReasons,
          contains(reason.wireName),
          reason: '${reason.name} has no report_reason enum label',
        );
      }

      expect(wrong, isEmpty);
    });

    test('every Dart reason has a database label', () {
      // The other direction: a label in the database with no Dart enum value
      // would be a reason the app can neither file nor read. Not a failure
      // today, but worth a test that fails loudly when it happens.
      expect(ReportReason.values.map((r) => r.wireName).toSet(),
          _databaseReportReasons.toSet());
    });

    test('sends null details when the buyer gave none', () {
      expect(
        ListingRepository.buildReportListingParams(
          listingId: 'l1',
          reason: ReportReason.alreadySold,
        )['p_details'],
        isNull,
      );
    });

    test('the builder passes the description through verbatim', () {
      // Trimming belongs to `reportListing`, which owns the user-facing
      // validation and runs before this builder. Asserting trimming here would
      // pin a contract this function does not have, and the end-to-end trim is
      // covered in `report_listing_test.dart` against the real request body.
      final params = ListingRepository.buildReportListingParams(
        listingId: 'l1',
        reason: ReportReason.other,
        details: '  The pin is 3 km away  ',
      );

      expect(params['p_details'], '  The pin is 3 km away  ');
    });
  });
}

/// The `report_reason` enum labels as they exist in the database.
///
/// Read out of migration `20261006055202_listing_reports.sql` and asserted
/// against rather than duplicated: two lists that agree today can drift, and
/// the direction that actually breaks a release — a Dart reason the database
/// has no label for — is only caught if the expected set is written down
/// independently.
const Set<String> _databaseReportReasons = <String>{
  'duplicate_listing',
  'photos_misleading',
  'price_suspicious',
  'wrong_location',
  'already_sold',
  'seller_asked_offsite',
  'fake_listing',
  'other',
};
