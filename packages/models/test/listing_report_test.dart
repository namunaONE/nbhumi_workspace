import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// The payload `v1_admin_get_reports` actually returns, verified against the
/// live database in the HYA-263 acceptance run.
Map<String, dynamic> _entry({
  String id = 'r1',
  String reason = 'price_suspicious',
  String status = 'open',
  String createdAt = '2026-10-06T05:00:00+00:00',
  String? resolvedAt,
  String? details = 'NPR 2 crore for 300 sqm',
}) =>
    <String, dynamic>{
      'id': id,
      'listing_id': 'b1',
      'reason': reason,
      'details': details,
      'status': status,
      'created_at': createdAt,
      'resolved_at': resolvedAt,
      'listing': <String, dynamic>{
        'id': 'b1',
        'title': 'House in Kirtipur',
        'price_npr': 25000000,
        'status': 'live',
        'district': 'Kathmandu',
        'city': 'Kirtipur',
        'seller_id': 's1',
      },
      'reporter': <String, dynamic>{
        'id': 'u1',
        'full_name': 'Sita Kumari',
        'role': 'buyer',
        'is_verified': false,
      },
    };

/// The payload `v1_admin_get_reports` wraps its page in.
Map<String, dynamic> _page({
  List<Map<String, dynamic>> entries = const <Map<String, dynamic>>[],
  Map<String, dynamic> counts = const <String, dynamic>{},
  Map<String, dynamic>? nextCursor,
}) =>
    <String, dynamic>{
      'entries': entries,
      'counts': counts,
      'next_cursor': nextCursor,
    };

void main() {
  group('ReportReason wire names', () {
    test('every reason sends the label the database has', () {
      // The direction that actually breaks a release: a Dart name sent where
      // the database expects a label is rejected by the RPC's enum cast, so a
      // buyer cannot report anything at all.
      expect(ReportReason.duplicateListing.wireName, 'duplicate_listing');
      expect(ReportReason.photosMisleading.wireName, 'photos_misleading');
      expect(ReportReason.priceSuspicious.wireName, 'price_suspicious');
      expect(ReportReason.wrongLocation.wireName, 'wrong_location');
      expect(ReportReason.alreadySold.wireName, 'already_sold');
      expect(ReportReason.sellerAskedOffsite.wireName, 'seller_asked_offsite');
      expect(ReportReason.fakeListing.wireName, 'fake_listing');
      expect(ReportReason.other.wireName, 'other');
    });

    test('every multi-word Dart name differs from its wire name', () {
      // A guard against someone "simplifying" by dropping wireName on the
      // assumption that name and label agree. Seven of the eight reasons are
      // multi-word, so a regression that sent `.name` would break reporting
      // entirely rather than one reason.
      final mismatched = ReportReason.values
          .where((r) => r.name != r.wireName)
          .map((r) => r.name)
          .toList();

      // Every reason except `other`, which is one word and therefore identical
      // in both spellings. So exactly one value can legitimately match, and if
      // that stops being true the enum has grown a single-word reason.
      expect(mismatched, hasLength(7));
      expect(
        ReportReason.values
            .where((r) => r.name == r.wireName)
            .map((r) => r.name),
        <String>['other'],
      );
      expect(mismatched, contains('fakeListing'));
    });

    test('fromWire round-trips every value', () {
      for (final reason in ReportReason.values) {
        expect(ReportReason.fromWire(reason.wireName), reason);
      }
    });

    test('fromWire refuses an unknown label rather than guessing', () {
      // Defaulting to `other` would put a specific complaint in the bucket that
      // requires a description, and the CHECK constraint would then reject a
      // report filed correctly.
      expect(() => ReportReason.fromWire('spam'), throwsArgumentError);
    });

    test('fromWire refuses the empty string', () {
      expect(() => ReportReason.fromWire(''), throwsArgumentError);
    });
  });

  group('ReportReason.requiresDetails', () {
    test('only `other` requires a description', () {
      expect(ReportReason.other.requiresDetails, isTrue);

      final others = ReportReason.values
          .where((r) => r != ReportReason.other)
          .map((r) => r.name);

      for (final name in others) {
        expect(
          ReportReason.values.firstWhere((r) => r.name == name).requiresDetails,
          isFalse,
          reason: '$name should not require details',
        );
      }
    });

    test('the database CHECK agrees with the model', () {
      // `reports_reason_details_check` requires details exactly when the reason
      // is 'other'. If a reason were added to one side only, the form would ask
      // for a description the database accepts without, or reject one it
      // demands.
      const databaseRequiresDetails = <String>{'other'};

      expect(
        ReportReason.values
            .where((r) => r.requiresDetails)
            .map((r) => r.wireName)
            .toSet(),
        databaseRequiresDetails,
      );
    });
  });

  group('AdminReportEntry.fromJson', () {
    test('parses the verified wire shape', () {
      final entry = AdminReportEntry.fromJson(_entry());

      expect(entry.id, 'r1');
      expect(entry.listingId, 'b1');
      expect(entry.reason, ReportReason.priceSuspicious);
      expect(entry.status, ReportStatus.open);
      expect(entry.details, 'NPR 2 crore for 300 sqm');
      expect(entry.createdAt, DateTime.utc(2026, 10, 6, 5));
      expect(entry.resolvedAt, isNull);
    });

    test('parses the nested listing', () {
      final listing = AdminReportEntry.fromJson(_entry()).listing;

      expect(listing.id, 'b1');
      expect(listing.title, 'House in Kirtipur');
      expect(listing.priceNpr, 25000000);
      expect(listing.status, ListingStatus.live);
      expect(listing.district, 'Kathmandu');
      expect(listing.city, 'Kirtipur');
      expect(listing.sellerId, 's1');
    });

    test('parses the nested reporter', () {
      final reporter = AdminReportEntry.fromJson(_entry()).reporter;

      expect(reporter.id, 'u1');
      expect(reporter.fullName, 'Sita Kumari');
      expect(reporter.role, 'buyer');
      expect(reporter.isVerified, isFalse);
    });

    test('a resolved report carries when and that it is resolved', () {
      final entry = AdminReportEntry.fromJson(
        _entry(
          status: 'actioned',
          resolvedAt: '2026-10-06T06:00:03+00:00',
        ),
      );

      expect(entry.status, ReportStatus.actioned);
      expect(entry.resolvedAt, DateTime.utc(2026, 10, 6, 6, 0, 3));
    });

    test('a report with no description parses', () {
      // Every reason but `other` allows null details, so most rows have none.
      final entry = AdminReportEntry.fromJson(
        _entry(reason: 'already_sold', details: null),
      );

      expect(entry.details, isNull);
      expect(entry.reason, ReportReason.alreadySold);
    });

    test('a listing already pulled is still readable', () {
      // A moderation row about a listing that is no longer live is history, not
      // a broken response: the admin needs to know it was resolved by removal.
      final json = _entry();
      (json['listing'] as Map<String, dynamic>)['status'] = 'rejected';
      final entry = AdminReportEntry.fromJson(json);

      expect(entry.listing.status, ListingStatus.rejected);
    });

    test('a reporter with no full name parses', () {
      final json = _entry();
      (json['reporter'] as Map<String, dynamic>)['full_name'] = null;
      final entry = AdminReportEntry.fromJson(json);

      expect(entry.reporter.fullName, isNull);
    });

    test('an unknown reason refuses rather than defaulting', () {
      expect(
        () => AdminReportEntry.fromJson(_entry(reason: 'spam')),
        throwsA(anything),
      );
    });

    test('an unknown status refuses rather than defaulting', () {
      // Defaulting to `open` would show an already-resolved report back in the
      // open queue and invite a second resolution.
      expect(
        () => AdminReportEntry.fromJson(_entry(status: 'archived')),
        throwsA(anything),
      );
    });

    test('round-trips', () {
      final entry = AdminReportEntry.fromJson(_entry());
      final again = AdminReportEntry.fromJson(entry.toJson());

      expect(again, entry);
    });
  });

  group('ReportCounts.fromJson', () {
    test('reads every status present', () {
      final counts = ReportCounts.fromJson(<String, dynamic>{
        'open': 4,
        'actioned': 1,
        'dismissed': 2,
      });

      expect(counts.open, 4);
      expect(counts.actioned, 1);
      expect(counts.dismissed, 2);
    });

    test('a missing status reads as zero, not null', () {
      // The RPC builds counts with json_object_agg keyed by enum label, so a
      // status with no rows is absent from the object entirely.
      final counts = ReportCounts.fromJson(<String, dynamic>{'open': 4});

      expect(counts.open, 4);
      expect(counts.actioned, 0);
      expect(counts.dismissed, 0);
    });

    test('an empty object reads as all zeroes', () {
      final counts = ReportCounts.fromJson(<String, dynamic>{});

      expect(counts.open, 0);
      expect(counts.actioned, 0);
      expect(counts.dismissed, 0);
    });

    test('a numeric string is not silently accepted as a count', () {
      // The RPC sends real numbers. A string means a contract change, and
      // silently coercing it would hide that.
      expect(
        () => ReportCounts.fromJson(<String, dynamic>{'open': '4'}),
        throwsA(anything),
      );
    });

    test('forStatus answers for every status', () {
      const counts = ReportCounts(open: 3, actioned: 1, dismissed: 2);

      expect(counts.forStatus(ReportStatus.open), 3);
      expect(counts.forStatus(ReportStatus.actioned), 1);
      expect(counts.forStatus(ReportStatus.dismissed), 2);
    });
  });

  group('ReportCursor', () {
    test('parses the nested next_cursor', () {
      final cursor = ReportCursor.fromJson(<String, dynamic>{
        'created_at': '2026-10-06T05:30:00+00:00',
        'id': 'r9',
      });

      expect(cursor, isNotNull);
      expect(cursor!.id, 'r9');
      expect(cursor.createdAt, DateTime.utc(2026, 10, 6, 5, 30));
    });

    test('null means end of list', () {
      expect(ReportCursor.fromJson(null), isNull);
    });

    test('a malformed cursor throws rather than reading as end of list', () {
      // Treating a corrupt cursor as the last page would leave the admin
      // believing the queue is empty when it is not.
      expect(
        () => ReportCursor.fromJson(<String, dynamic>{'id': 'r9'}),
        throwsFormatException,
      );
      expect(
        () => ReportCursor.fromJson(<String, dynamic>{
          'created_at': '2026-10-06T05:30:00+00:00',
        }),
        throwsFormatException,
      );
    });

    test('a non-string timestamp throws rather than parsing loosely', () {
      expect(
        () => ReportCursor.fromJson(<String, dynamic>{
          'created_at': 12345,
          'id': 'r9',
        }),
        throwsFormatException,
      );
    });

    test('sends the timestamp as UTC ISO-8601', () {
      final cursor = ReportCursor(
        // Local time with an offset, so this would be wrong if not converted.
        createdAt: DateTime.parse('2026-10-06T11:00:00+05:45'),
        id: 'r9',
      );

      expect(cursor.toRpcParams()['p_cursor'], '2026-10-06T05:15:00.000Z');
      expect(cursor.toRpcParams()['p_cursor_id'], 'r9');
    });

    test('the timestamp is not unique, so the id is part of the cursor', () {
      // Two reports filed in one transaction share a created_at. A cursor of
      // created_at alone would skip one of them, which is the bug the listing
      // queue had before the id was added.
      final shared = DateTime.utc(2026, 10, 6, 5, 30);
      final first = ReportCursor(createdAt: shared, id: 'r1');
      final second = ReportCursor(createdAt: shared, id: 'r2');

      expect(first.createdAt, second.createdAt);
      expect(first, isNot(second));
    });

    test('equality and hashCode agree', () {
      final at = DateTime.utc(2026, 10, 6, 5, 30);

      expect(
        ReportCursor(createdAt: at, id: 'r1'),
        ReportCursor(createdAt: at, id: 'r1'),
      );
      expect(
        ReportCursor(createdAt: at, id: 'r1').hashCode,
        ReportCursor(createdAt: at, id: 'r1').hashCode,
      );
    });

    test('a cursor is not equal to a queue cursor', () {
      // Different types on purpose: passing one where the other is expected
      // would silently restart pagination instead of failing.
      final at = DateTime.utc(2026, 10, 6, 5, 30);

      expect(
        ReportCursor(createdAt: at, id: 'r1'),
        isNot(QueueCursor(submittedAt: at, id: 'r1')),
      );
    });
  });

  group('ReportPage.fromJson', () {
    test('parses entries, counts and the cursor together', () {
      final page = ReportPage.fromJson(
        _page(
          entries: <Map<String, dynamic>>[_entry(), _entry(id: 'r2')],
          counts: <String, dynamic>{'open': 2},
          nextCursor: <String, dynamic>{
            'created_at': '2026-10-06T05:00:00+00:00',
            'id': 'r2',
          },
        ),
      );

      expect(page.entries, hasLength(2));
      expect(page.counts.open, 2);
      expect(page.nextCursor?.id, 'r2');
      expect(page.hasMore, isTrue);
      expect(page.isEmpty, isFalse);
    });

    test('a null next_cursor ends the walk', () {
      final page = ReportPage.fromJson(_page());

      expect(page.nextCursor, isNull);
      expect(page.hasMore, isFalse);
      expect(page.isEmpty, isTrue);
    });

    test('the empty page is a successful answer, not an error', () {
      // Distinct from "nothing loaded yet": an empty page renders as "nothing
      // to review", a not-yet-loaded page as a spinner.
      expect(ReportPage.empty.isEmpty, isTrue);
      expect(ReportPage.empty.counts.open, 0);
      expect(ReportPage.empty.hasMore, isFalse);
    });

    test('a page with rows but no cursor is the last page', () {
      // The RPC returns a cursor whenever a page had rows, including the final
      // one. Walking until entries are empty is therefore the correct loop.
      final page = ReportPage.fromJson(
        _page(entries: <Map<String, dynamic>>[_entry()]),
      );

      expect(page.entries, hasLength(1));
      expect(page.hasMore, isFalse);
    });

    test('two pages of the same rows are not equal', () {
      // Guards the `_sameEntries` helper against a length-only comparison,
      // which would make a re-sorted page look unchanged and skip a refresh.
      // Same length, different row: this is what a length-only comparison
      // would miss.
      final a = ReportPage.fromJson(
        _page(entries: <Map<String, dynamic>>[_entry(id: 'r3')]),
      );
      final b = ReportPage.fromJson(
        _page(entries: <Map<String, dynamic>>[_entry(id: 'r7')]),
      );

      expect(a, isNot(b));
    });

    test('equality compares entries element-wise', () {
      final a = ReportPage.fromJson(
        _page(entries: <Map<String, dynamic>>[_entry()]),
      );
      final b = ReportPage.fromJson(
        _page(entries: <Map<String, dynamic>>[_entry()]),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('counts participate in equality', () {
      final a = ReportPage.fromJson(
        _page(counts: <String, dynamic>{'open': 1}),
      );
      final b = ReportPage.fromJson(
        _page(counts: <String, dynamic>{'open': 2}),
      );

      expect(a, isNot(b));
    });
  });

  group('ListingReport.fromJson', () {
    test('parses what v1_report_listing returns', () {
      final report = ListingReport.fromJson(<String, dynamic>{
        'report_id': '8b473f7b-f609-4866-bcd8-91ffc8045cd4',
        'listing_id': 'b1',
        'reason': 'price_suspicious',
        'details': 'NPR 2 crore for 300 sqm in Kirtipur',
        'status': 'open',
        'created_at': '2026-10-06T05:58:36+00:00',
      });

      expect(
        report.reportId,
        '8b473f7b-f609-4866-bcd8-91ffc8045cd4',
      );
      expect(report.listingId, 'b1');
      expect(report.reason, ReportReason.priceSuspicious);
      expect(report.details, 'NPR 2 crore for 300 sqm in Kirtipur');
      expect(report.createdAt, DateTime.utc(2026, 10, 6, 5, 58, 36));
    });

    test('carries no listing or reporter', () {
      // The response to "I reported this" has no business echoing back the
      // listing, and echoing the reporter would tell the buyer nothing they did
      // not supply. `status` is dropped too: it is always 'open', and a
      // confirmation that carries a status invites callers to read one.
      final keys = const ListingReport(
        reportId: 'r1',
        listingId: 'b1',
        reason: ReportReason.other,
      ).toJson().keys;

      expect(keys, isNot(contains('listing')));
      expect(keys, isNot(contains('reporter')));
      expect(keys, isNot(contains('seller_id')));
      expect(keys, contains('report_id'));
      expect(keys, contains('reason'));
    });

    test('an unknown reason refuses rather than defaulting', () {
      expect(
        () => ListingReport.fromJson(<String, dynamic>{
          'report_id': 'r1',
          'listing_id': 'b1',
          'reason': 'spam',
        }),
        throwsA(anything),
      );
    });
  });

  group('ReportResolution', () {
    test('covers exactly the two resolutions the RPC accepts', () {
      // `v1_admin_resolve_report` refuses anything but 'actioned' or
      // 'dismissed' — including 'open', which would be a no-op that still
      // writes an audit row claiming the report was resolved twice.
      expect(
        ReportResolution.values.map((r) => r.name).toSet(),
        <String>{'actioned', 'dismissed'},
      );
    });

    test('the names are the report_status labels', () {
      expect(ReportResolution.actioned.name, 'actioned');
      expect(ReportResolution.dismissed.name, 'dismissed');
    });

    test('neither value is the open status', () {
      // Open is a status the queue can be in, never a resolution. Keeping them
      // as separate types is what stops a caller passing it.
      expect(ReportStatus.values, contains(ReportStatus.open));
      expect(
        ReportResolution.values.map((r) => r.name),
        isNot(contains('open')),
      );
    });
  });
}
