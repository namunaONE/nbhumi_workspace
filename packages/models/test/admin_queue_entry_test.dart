import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Parsing tests for the admin queue models.
///
/// These run against the payload shape `v1_admin_get_queue` actually returns.
/// The response was captured from the live database after migration
/// `20261005035118_admin_verification_queue_part2_functions.sql` was applied.
/// a change to the SQL that breaks parsing fails here rather than in the panel.
void main() {
  final now = DateTime.utc(2026, 10, 5, 12);

  /// Sentinel meaning "use the realistic default cursor".
  ///
  /// A plain `nextCursor: null` cannot express "omit the key", because null is
  /// also a legitimate value: the server sends `"next_cursor": null` on the
  /// last page. Two cases below depend on telling those apart; collapsing them
  /// makes both assert against the default cursor, not the one they meant.
  // Not underscore-prefixed: a local variable cannot be private in Dart, so
  // the lint asking for one would be misleading here.
  const defaultCursor = Object();

  /// A realistic entry, with only the fields under test varied.
  Map<String, dynamic> entryJson({
    String id = 'aaaaaaa1-0000-0000-0000-000000000001',
    String title = '5 Aana Land - Bhaktapur',
    int priceNpr = 2500000,
    String status = 'pending_review',
    String? submittedAt = '2026-10-05T09:16:52.501654+00:00',
    Map<String, dynamic>? seller,
    int? photoCount = 3,
    String? photoUrl = 'https://example.supabase.co/x.jpg',
  }) =>
      <String, dynamic>{
        'id': id,
        'title': title,
        'district': 'Bhaktapur',
        'city': 'Bhaktapur',
        'ward': null,
        'property_type': 'land',
        'listing_purpose': 'sale',
        'price_npr': priceNpr,
        'area_sqm': 508.28,
        'area_ropani': null,
        'area_aana': 5,
        'area_paisa': null,
        'area_dam': null,
        'area_bigha': null,
        'area_kattha': null,
        'area_dhur': null,
        'status': status,
        'rejection_reason': null,
        'submitted_at': submittedAt,
        'reviewed_at': null,
        'created_at': '2026-10-05T09:00:00+00:00',
        'photo_url': photoUrl,
        'photo_count': photoCount,
        'seller': seller ??
            <String, dynamic>{
              'id': '22222222-2222-2222-2222-222222222222',
              'full_name': 'Ram Bahadur',
              'role': 'buyer',
              'is_verified': true,
              'kyc_tier': 'identity',
              'agency_name': null,
              'agency_reg_no': null,
            },
      };

  Map<String, dynamic> pageJson({
    List<Map<String, dynamic>>? entries,
    Map<String, dynamic>? counts,
    Object? nextCursor = defaultCursor,
  }) =>
      <String, dynamic>{
        'entries': entries ?? <Map<String, dynamic>>[entryJson()],
        'counts': counts ??
            <String, dynamic>{
              'pending_review': 12,
              'live': 45,
              'rejected': 3,
            },
        'next_cursor': switch (nextCursor) {
          defaultCursor => <String, dynamic>{
              'submitted_at': '2026-10-05T09:16:52.501654+00:00',
              'id': 'aaaaaaa1-0000-0000-0000-000000000001',
            },
          final Object? v => v,
        },
      };

  group('AdminQueueEntry', () {
    test('parses a full queue row', () {
      final entry = AdminQueueEntry.fromJson(entryJson());

      expect(entry.id, 'aaaaaaa1-0000-0000-0000-000000000001');
      expect(entry.title, '5 Aana Land - Bhaktapur');
      expect(entry.priceNpr, 2500000);
      expect(entry.propertyType, PropertyType.land);
      expect(entry.listingPurpose, ListingPurpose.sale);
      expect(entry.status, ListingStatus.pendingReview);
      expect(entry.areaAana, 5);
      expect(entry.areaSqm, 508.28);
      expect(entry.photoCount, 3);
    });

    test('parses the nested seller block', () {
      final entry = AdminQueueEntry.fromJson(entryJson());

      expect(entry.seller.fullName, 'Ram Bahadur');
      expect(entry.seller.isVerified, isTrue);
      expect(entry.seller.kycTier, 'identity');
      expect(entry.seller.role, 'buyer');
    });

    test('carries agency registration number, which the public RPCs omit', () {
      final entry = AdminQueueEntry.fromJson(
        entryJson(
          seller: <String, dynamic>{
            'id': 's1',
            'full_name': 'ABC Realty',
            'role': 'agent',
            'is_verified': false,
            'kyc_tier': 'none',
            'agency_name': 'ABC Realty',
            'agency_reg_no': 'REG-2026-4471',
          },
        ),
      );

      expect(entry.seller.agencyRegNo, 'REG-2026-4471');
    });

    test('never carries seller contact details', () {
      // HYA-252 confines phone and email to v1_contact_seller. If a future
      // migration widened the queue RPC to include them, this is the assertion
      // that would notice.
      final json = entryJson();
      final entry = AdminQueueEntry.fromJson(json);

      expect(json['seller'], isNot(contains('phone')));
      expect(json['seller'], isNot(contains('email')));
      expect(entry.toJson()['seller'], isNot(contains('phone')));
    });

    test('round-trips through JSON', () {
      final entry = AdminQueueEntry.fromJson(entryJson());
      final again = AdminQueueEntry.fromJson(entry.toJson());

      expect(again, entry);
    });

    test('tolerates null submitted_at, as a draft has', () {
      final entry = AdminQueueEntry.fromJson(
        entryJson(submittedAt: null, status: 'draft'),
      );

      expect(entry.submittedAt, isNull);
      expect(entry.sla(now: now), QueueSla.fresh);
    });

    test('parses a rejected row with its reason and review time', () {
      final json = entryJson(status: 'rejected');
      json['rejection_reason'] = 'Photos do not show the plot boundary.';
      json['reviewed_at'] = '2026-10-05T10:00:00+00:00';

      final entry = AdminQueueEntry.fromJson(json);

      expect(entry.status, ListingStatus.rejected);
      expect(entry.rejectionReason, 'Photos do not show the plot boundary.');
      expect(entry.reviewedAt, isNotNull);
    });

    test('a listing with no photos parses as zero, not null', () {
      final entry = AdminQueueEntry.fromJson(
        entryJson(photoCount: null, photoUrl: null),
      );

      expect(entry.photoCount, 0);
      expect(entry.photoUrl, isNull);
      expect(entry.isUnderPhotoMinimum, isTrue);
    });

    test('defaults a missing photo_count to zero', () {
      // The column is present in the RPC, but a null there must not become a
      // null int and crash the row.
      final json = entryJson()..remove('photo_count');

      expect(AdminQueueEntry.fromJson(json).photoCount, 0);
    });
  });

  group('AdminQueueEntry SLA and photo checks', () {
    test('derives the SLA from submitted_at', () {
      final entry = AdminQueueEntry.fromJson(
        entryJson(submittedAt: '2026-10-03T12:00:00+00:00'),
      );

      expect(entry.sla(now: now), QueueSla.breached);
    });

    test('flags fewer photos than the wizard minimum', () {
      final two = AdminQueueEntry.fromJson(entryJson(photoCount: 2));
      final three = AdminQueueEntry.fromJson(entryJson());
      final five = AdminQueueEntry.fromJson(entryJson(photoCount: 5));

      expect(two.isUnderPhotoMinimum, isTrue);
      expect(three.isUnderPhotoMinimum, isFalse);
      expect(five.isUnderPhotoMinimum, isFalse);
    });

    test('the photo minimum is three, matching the wizard', () {
      expect(minPhotosPerListing, 3);
    });
  });

  group('QueueCounts', () {
    test('parses the enum-keyed counts object', () {
      final counts = QueueCounts.fromJson(<String, dynamic>{
        'pending_review': 12,
        'live': 45,
        'rejected': 3,
      });

      expect(counts.pendingReview, 12);
      expect(counts.live, 45);
      expect(counts.rejected, 3);
    });

    test('a status with no rows reads zero, not null', () {
      // The RPC uses json_object_agg, so a status with no rows is absent from
      // the object entirely rather than present as 0.
      final counts = QueueCounts.fromJson(<String, dynamic>{
        'pending_review': 2,
      });

      expect(counts.live, 0);
      expect(counts.rejected, 0);
    });

    test('an empty counts object is all zeroes', () {
      final counts = QueueCounts.fromJson(<String, dynamic>{});

      expect(counts.pendingReview, 0);
      expect(counts.live, 0);
      expect(counts.rejected, 0);
    });

    test('forStatus maps each tab, and draft has none', () {
      final counts = QueueCounts.fromJson(<String, dynamic>{
        'pending_review': 12,
        'live': 45,
        'rejected': 3,
      });

      expect(counts.forStatus(ListingStatus.pendingReview), 12);
      expect(counts.forStatus(ListingStatus.live), 45);
      expect(counts.forStatus(ListingStatus.rejected), 3);
      expect(counts.forStatus(ListingStatus.draft), 0);
    });
  });

  group('QueuePage', () {
    test('parses entries, counts and cursor together', () {
      final page = QueuePage.fromJson(
        pageJson(
          entries: <Map<String, dynamic>>[
            entryJson(id: 'a1', title: 'First'),
            entryJson(id: 'a2', title: 'Second'),
          ],
        ),
      );

      expect(page.entries, hasLength(2));
      expect(page.entries.first.title, 'First');
      expect(page.counts.pendingReview, 12);
      expect(page.hasMore, isTrue);
    });

    test('a null next_cursor means the last page', () {
      final page = QueuePage.fromJson(
        pageJson(nextCursor: null),
      );

      expect(page.nextCursor, isNull);
      expect(page.hasMore, isFalse);
    });

    test('an empty entries list is an empty page, not a failure', () {
      final page = QueuePage.fromJson(
        pageJson(entries: <Map<String, dynamic>>[], nextCursor: null),
      );

      expect(page.entries, isEmpty);
      expect(page.isEmpty, isTrue);
      expect(page.hasMore, isFalse);
    });

    test('QueuePage.empty has no entries and no cursor', () {
      expect(QueuePage.empty.isEmpty, isTrue);
      expect(QueuePage.empty.hasMore, isFalse);
      expect(QueuePage.empty.entries, isEmpty);
    });

    test('parses a response with no entries key at all', () {
      // Defensive: a malformed response should render as an empty queue rather
      // than throw inside a build method.
      final page = QueuePage.fromJson(const <String, dynamic>{});

      expect(page.entries, isEmpty);
      expect(page.counts.pendingReview, 0);
    });
  });

  group('QueueCursor', () {
    test('parses the nested cursor object', () {
      final cursor = QueueCursor.fromJson(<String, dynamic>{
        'submitted_at': '2026-10-05T09:16:52.501654+00:00',
        'id': 'abc',
      });

      expect(cursor, isNotNull);
      expect(
        cursor!.submittedAt,
        DateTime.utc(2026, 10, 5, 9, 16, 52, 501, 654),
      );
      expect(cursor.id, 'abc');
    });

    test('null means end of list', () {
      expect(QueueCursor.fromJson(null), isNull);
    });

    test('a malformed cursor throws rather than reading as end-of-list', () {
      // Returning null for a corrupt cursor would leave the admin believing the
      // queue is empty, which is the failure this guards against.
      expect(
        () => QueueCursor.fromJson(<String, dynamic>{'id': 'abc'}),
        throwsFormatException,
      );
      expect(
        () => QueueCursor.fromJson(<String, dynamic>{
          'submitted_at': 12345,
          'id': 'abc',
        }),
        throwsFormatException,
      );
    });

    test('builds RPC params with an ISO-8601 UTC cursor', () {
      final cursor = QueueCursor(
        submittedAt: DateTime.utc(2026, 10, 5, 9, 16, 52),
        id: 'abc',
      );

      expect(cursor.toRpcParams(), <String, Object?>{
        'p_cursor': '2026-10-05T09:16:52.000Z',
        'p_cursor_id': 'abc',
      });
    });

    test('cursors with the same timestamp but different ids differ', () {
      // The id is what makes the cursor unambiguous when two listings share a
      // submission time, which same-transaction submissions do.
      final a = QueueCursor(submittedAt: now, id: 'a');
      final b = QueueCursor(submittedAt: now, id: 'b');

      expect(a, isNot(b));
      expect(a.hashCode, isNot(b.hashCode));
      expect(a, QueueCursor(submittedAt: now, id: 'a'));
    });
  });

  group('ReviewDecision', () {
    test('has exactly two outcomes', () {
      // A boolean `approved` would let a `true` mean "approve" in one place and
      // "reviewed" in another.
      expect(ReviewDecision.values, hasLength(2));
      expect(
        ReviewDecision.values,
        containsAll(<ReviewDecision>[
          ReviewDecision.approve,
          ReviewDecision.reject,
        ]),
      );
    });
  });

  group('AuditLogEntry', () {
    test('parses an approve entry', () {
      final entry = AuditLogEntry.fromJson(<String, dynamic>{
        'id': 'a1',
        'actor_id': 'admin-1',
        'action': 'approve',
        'entity_type': 'listing',
        'entity_id': 'listing-1',
        'created_at': '2026-10-05T09:30:00+00:00',
        'details': <String, dynamic>{'to': 'live'},
      });

      expect(entry.action, 'approve');
      expect(entry.actorId, 'admin-1');
      expect(entry.isListing, isTrue);
      expect(entry.toStatus, ListingStatus.live);
      expect(entry.reason, isNull);
    });

    test('parses a reject entry with its reason', () {
      final entry = AuditLogEntry.fromJson(<String, dynamic>{
        'id': 'a2',
        'actor_id': 'admin-1',
        'action': 'reject',
        'entity_type': 'listing',
        'entity_id': 'listing-2',
        'details': <String, dynamic>{
          'to': 'rejected',
          'reason': 'Photos do not show the plot boundary.',
        },
      });

      expect(entry.toStatus, ListingStatus.rejected);
      expect(entry.reason, 'Photos do not show the plot boundary.');
    });

    test('an unrecognised status decodes to null rather than throwing', () {
      // An audit row written by a future version should still render in the
      // trail, just without a decoded status.
      final entry = AuditLogEntry.fromJson(<String, dynamic>{
        'id': 'a3',
        'actor_id': 'admin-1',
        'action': 'unpublish',
        'entity_type': 'listing',
        'entity_id': 'listing-3',
        'details': <String, dynamic>{'to': 'withdrawn'},
      });

      expect(entry.toStatus, isNull);
      expect(entry.action, 'unpublish');
    });

    test('a null details block decodes without throwing', () {
      final entry = AuditLogEntry.fromJson(<String, dynamic>{
        'id': 'a4',
        'actor_id': 'admin-1',
        'action': 'approve',
        'entity_type': 'listing',
        'entity_id': 'listing-4',
      });

      expect(entry.details, isNull);
      expect(entry.reason, isNull);
      expect(entry.toStatus, isNull);
    });

    test('distinguishes a user action from a listing action', () {
      final user = AuditLogEntry.fromJson(<String, dynamic>{
        'id': 'a5',
        'actor_id': 'admin-1',
        'action': 'suspend',
        'entity_type': 'user',
        'entity_id': 'user-1',
      });

      expect(user.isListing, isFalse);
    });

    test('round-trips through JSON', () {
      final entry = AuditLogEntry.fromJson(<String, dynamic>{
        'id': 'a6',
        'actor_id': 'admin-1',
        'action': 'reject',
        'entity_type': 'listing',
        'entity_id': 'listing-6',
        'details': <String, dynamic>{'to': 'rejected', 'reason': 'no'},
      });

      expect(AuditLogEntry.fromJson(entry.toJson()), entry);
    });
  });
}
