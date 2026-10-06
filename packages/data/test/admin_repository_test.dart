import 'dart:convert';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tests for [AdminRepository].
///
/// Three layers, deliberately separated:
///
/// * **Parameter building** is asserted directly, because a wrong RPC key or a
///   dropped cursor is invisible from the outside.
/// * **Error mapping** drives the real PostgREST path through an injected
///   `http.Client`, so the SQLSTATE in the response becomes a real
///   `PostgrestException`. Rule 31 keeps a live Supabase out of the unit loop,
///   and a hand-built fake would have meant asserting against a shape the SDK
///   might never produce — the exact failure this file exists to catch.
/// * **Status reading** is pure logic, and it is the layer where a silent wrong
///   answer would do the most damage.
void main() {
  group('buildQueueParams', () {
    test('defaults to the pending_review tab with no cursor', () {
      final params = SupabaseAdminRepository.buildQueueParams();

      expect(params['p_status'], 'pending_review');
      expect(params.containsKey('p_cursor'), isFalse);
      expect(params.containsKey('p_cursor_id'), isFalse);
      expect(params['p_page_size'], 50);
    });

    test('sends each tab as its wire name', () {
      expect(
        SupabaseAdminRepository.buildQueueParams(status: ListingStatus.live)
            ['p_status'],
        'live',
      );
      expect(
        SupabaseAdminRepository.buildQueueParams(
          status: ListingStatus.rejected,
        )['p_status'],
        'rejected',
      );
    });

    test('includes both cursor keys when a cursor is supplied', () {
      final params = SupabaseAdminRepository.buildQueueParams(
        cursor: QueueCursor(
          submittedAt: DateTime.utc(2026, 10, 5, 9, 16, 52),
          id: 'abc',
        ),
      );

      expect(params['p_cursor'], '2026-10-05T09:16:52.000Z');
      expect(params['p_cursor_id'], 'abc');
    });

    test('omits the cursor keys entirely rather than sending null', () {
      // This matters: the RPC needs a coalesce because PostgREST sends every
      // declared parameter, and an explicit null defeats a SQL default.
      // Omitting the keys cannot have that failure mode at all.
      final params = SupabaseAdminRepository.buildQueueParams();

      expect(params.keys, isNot(contains('p_cursor')));
      expect(params.keys, isNot(contains('p_cursor_id')));
    });

    test('passes the page size through for the server to clamp', () {
      // Clamping is the RPC's job. Clamping again on the client would hide a
      // disagreement about the bound rather than surfacing it.
      expect(
        SupabaseAdminRepository.buildQueueParams(pageSize: 500)['p_page_size'],
        500,
      );
    });
  });

  group('error mapping through the real PostgREST path', () {
    test('42501 becomes a permission failure, not a server fault', () {
      final repo = failingRepo(
        status: '42501',
        message: 'FORBIDDEN: admin only',
      );

      expect(
        repo.getQueue,
        throwsA(
          isA<AuthFailureException>().having(
            (e) => e.code,
            'code',
            'auth.forbidden',
          ),
        ),
      );
    });

    test('42501 from approve reads the same way', () {
      final repo = failingRepo(status: '42501', message: 'FORBIDDEN');

      expect(
        () => repo.approveListing('listing-1'),
        throwsA(isA<AuthFailureException>()),
      );
    });

    test('42501 from reject reads the same way', () {
      final repo = failingRepo(status: '42501', message: 'FORBIDDEN');

      expect(
        () => repo.rejectListing('listing-1', 'Photos are unclear'),
        throwsA(isA<AuthFailureException>()),
      );
    });

    test('22023 from approve becomes a validation failure', () {
      // Raised when the listing is not in pending_review, the common case being
      // another admin having already actioned it.
      final repo = failingRepo(
        status: '22023',
        message: 'VALIDATION_ERROR: listing not in pending_review',
      );

      expect(
        () => repo.approveListing('listing-1'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.rejected',
          ),
        ),
      );
    });

    test('no Postgres text reaches the user-facing message', () {
      final repo = failingRepo(
        status: '42501',
        message: 'FORBIDDEN: admin only, role=buyer, uid=abc-123',
      );

      expect(
        repo.getQueue,
        throwsA(
          isA<AuthFailureException>()
              .having((e) => e.messageEn, 'messageEn', isNot(contains('42501')))
              .having(
                (e) => e.messageEn,
                'messageEn',
                isNot(contains('abc-123')),
              ),
        ),
      );
    });

    test('every mapped failure carries a Nepali message', () {
      final repo = failingRepo(status: '22023', message: 'x');

      expect(
        () => repo.approveListing('listing-1'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.messageNe,
            'messageNe',
            isNotEmpty,
          ),
        ),
      );
    });

    test('a 5xx is a server failure and is not retryable', () {
      final repo = failingRepo(status: '50000', message: 'internal error');

      expect(
        repo.getQueue,
        throwsA(
          isA<ServerException>().having(
            (e) => e.isRetryable,
            'isRetryable',
            false,
          ),
        ),
      );
    });
  });

  group('the status the server reports', () {
    test('an approve returning live yields live', () async {
      final repo = succeedingRepo('{"id":"l1","status":"live"}');

      expect(await repo.approveListing('l1'), ListingStatus.live);
    });

    test('a reject returning rejected yields rejected', () async {
      final repo = succeedingRepo('{"id":"l1","status":"rejected"}');

      expect(
        await repo.rejectListing('l1', 'Photos are unclear'),
        ListingStatus.rejected,
      );
    });

    test('a response with no status throws rather than guessing', () async {
      // The failure this guards: defaulting to `live` would report a rejection
      // as an approval, and the admin would leave believing the listing was
      // published.
      final repo = succeedingRepo('{"id":"l1"}');

      expect(
        () => repo.approveListing('l1'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.code,
            'code',
            'server.unexpectedResponse',
          ),
        ),
      );
    });

    test('an unrecognised status value throws too', () {
      // A response from a newer server must not be read as a known status.
      final repo = succeedingRepo('{"id":"l1","status":"archived"}');

      expect(() => repo.approveListing('l1'), throwsA(isA<ServerException>()));
    });

    test('the failure is not retryable, since retrying changes nothing', () {
      final repo = succeedingRepo('{"id":"l1"}');

      expect(
        () => repo.approveListing('l1'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.isRetryable,
            'isRetryable',
            false,
          ),
        ),
      );
    });
  });

  group('rejectListing reason validation', () {
    test('a blank reason is refused without a round trip', () {
      // Rule 6: validate client-side as well as server-side. The RPC would
      // refuse this with 22023, but catching it here means the complaint
      // lands against the field the admin typed into.
      final repo = failingRepo(
        status: '42501',
        message: 'the client should not have called',
      );

      expect(
        () => repo.rejectListing('listing-1', ''),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.rejectionReasonRequired',
          ),
        ),
      );
    });

    test('a whitespace-only reason is refused too', () {
      final repo = failingRepo(
        status: '42501',
        message: 'the client should not have called',
      );

      expect(
        () => repo.rejectListing('listing-1', '   \n\t '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('the blank-reason message is bilingual and not retryable', () {
      final repo = failingRepo(
        status: '42501',
        message: 'the client should not have called',
      );

      expect(
        () => repo.rejectListing('listing-1', '  '),
        throwsA(
          isA<ValidationException>()
              .having((e) => e.messageNe, 'messageNe', isNotEmpty)
              .having((e) => e.isRetryable, 'isRetryable', isFalse),
        ),
      );
    });

    test('the reason is trimmed on the wire', () async {
      // A seller should never read leading and trailing whitespace in the
      // rejection notice. Asserted on the request body rather than on a
      // reimplementation of the trim, so the assertion is on real behaviour.
      // Answers with a usable status, so the call reaches the trim and then
      // completes; the assertion is about the request body, not the outcome.
      final transport = RecordingHttpClient(
        body: '{"id":"l1","status":"rejected"}',
      );
      final repo = SupabaseAdminRepository(
        SupabaseClient(
          'https://project.supabase.co',
          'test-key',
          httpClient: transport,
        ),
      );

      await repo.rejectListing('listing-1', '  Photos are unclear  ');

      expect(transport.requestBodies, hasLength(1));
      expect(
        transport.requestBodies.single,
        contains('"p_reason":"Photos are unclear"'),
      );
    });
  });

  group('KYC verdicts (HYA-264 Tier 2, HYA-265 Tier 3)', () {
    test('buildVerifyKycParams sends the doc id', () {
      final params = SupabaseAdminRepository.buildVerifyKycParams(
        docId: 'doc-1',
      );

      expect(params, <String, Object?>{'p_doc_id': 'doc-1'});
    });

    test('buildRejectKycParams names both keys', () {
      final params = SupabaseAdminRepository.buildRejectKycParams(
        docId: 'doc-1',
        reason: 'Blurry scan',
      );

      expect(params['p_doc_id'], 'doc-1');
      expect(params['p_reason'], 'Blurry scan');
    });

    test('a blank doc id is refused without a round trip', () {
      final repo = failingRepo(
        status: '42501',
        message: 'the client should not have called',
      );

      expect(
        () => repo.verifyKyc('  '),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.kycDocIdRequired',
          ),
        ),
      );
      expect(
        () => repo.rejectKyc('', 'Blurry scan'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('a blank KYC reason is refused without a round trip', () {
      final repo = failingRepo(
        status: '42501',
        message: 'the client should not have called',
      );

      expect(
        () => repo.rejectKyc('doc-1', '   \n\t '),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.kycRejectionReasonRequired',
          ),
        ),
      );
    });

    test('the blank-reason refusal is bilingual and not retryable', () async {
      final repo = failingRepo(
        status: '42501',
        message: 'the client should not have called',
      );

      try {
        await repo.rejectKyc('doc-1', '  ');
        fail('expected a throw');
      } on ValidationException catch (e) {
        expect(e.messageEn, isNotEmpty);
        expect(e.messageNe, isNotEmpty);
        expect(e.isRetryable, isFalse);
      }
    });

    test('42501 from verifyKyc reads as a permission failure', () {
      final repo = failingRepo(status: '42501', message: 'FORBIDDEN');

      expect(
        () => repo.verifyKyc('doc-1'),
        throwsA(
          isA<AuthFailureException>().having(
            (e) => e.code,
            'code',
            'auth.forbidden',
          ),
        ),
      );
    });

    test('an already-reviewed document reads as a duplicate', () {
      // The RPC raises 23505 CONFLICT when status is no longer pending —
      // most often because another admin actioned it first.
      final repo = failingRepo(
        status: '23505',
        message: 'CONFLICT: document is already reviewed',
      );

      expect(
        () => repo.verifyKyc('doc-1'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.duplicate',
          ),
        ),
      );
    });

    test('the reason is trimmed on the wire and the row is re-read', () async {
      final transport = _KycRecordingClient();
      final repo = SupabaseAdminRepository(
        SupabaseClient(
          'https://project.supabase.co',
          'test-key',
          httpClient: transport,
        ),
      );

      final doc = await repo.rejectKyc('doc-1', '  Blurry scan  ');

      expect(transport.requestBodies, hasLength(2));
      expect(
        transport.requestBodies.first,
        contains('"p_reason":"Blurry scan"'),
      );
      // The RPC answers a summary; what the admin sees is the re-read row.
      expect(doc.id, 'doc-1');
      expect(doc.status, KycDocStatus.verified);
      expect(doc.docType, KycDocType.citizenship);
    });

    test('a vanished row reads as no-longer-pending, not not-found', () async {
      // RPC succeeded, then the read-back found nothing: another admin acted
      // between the two calls, or the 30-day purge removed a rejected row.
      // The generic mapper would word that as a missing *listing*.
      final repo = SupabaseAdminRepository(
        SupabaseClient(
          'https://project.supabase.co',
          'test-key',
          httpClient: _MissingRowClient(),
        ),
      );

      try {
        await repo.verifyKyc('doc-1');
        fail('expected a throw');
      } on ValidationException catch (e) {
        expect(e.code, 'validation.kycNotFound');
        expect(e.messageNe, isNotEmpty);
      }
    });

    test('pendingKycDocuments clamps the page bound both ways', () async {
      final transport = _KycRecordingClient();
      final repo = SupabaseAdminRepository(
        SupabaseClient(
          'https://project.supabase.co',
          'test-key',
          httpClient: transport,
        ),
      );

      await repo.pendingKycDocuments(limit: 500);
      await repo.pendingKycDocuments(limit: 0);

      expect(transport.requestUrls, hasLength(2));
      expect(transport.requestUrls[0].queryParameters['limit'], '100');
      expect(transport.requestUrls[1].queryParameters['limit'], '1');
    });
  });

  group('buildReportParams', () {
    test('defaults to the open tab with no cursor', () {
      expect(SupabaseAdminRepository.buildReportParams(), <String, Object?>{
        'p_status': 'open',
        'p_page_size': 50,
      });
    });

    test('sends the enum label, not the Dart name', () {
      // Both are single words today, so this cannot fail by accident. It exists
      // so that adding a multi-word status breaks here rather than as a 400
      // from PostgREST with an admin waiting on a queue.
      expect(
        SupabaseAdminRepository.buildReportParams(
          status: ReportStatus.actioned,
        )['p_status'],
        'actioned',
      );
    });

    test('spreads the cursor into the same keys the queue uses', () {
      final params = SupabaseAdminRepository.buildReportParams(
        cursor: ReportCursor(
          createdAt: DateTime.utc(2026, 10, 6, 5, 30),
          id: 'r9',
        ),
        pageSize: 2,
      );

      expect(params['p_cursor'], '2026-10-06T05:30:00.000Z');
      expect(params['p_cursor_id'], 'r9');
      expect(params['p_page_size'], 2);
      expect(params['p_status'], 'open');
    });

    test('the report cursor is not the queue cursor', () {
      // Both call the parameter names p_cursor/p_cursor_id, so a swapped type
      // would compile and then silently restart pagination. The types are
      // distinct precisely so this cannot happen.
      expect(
        SupabaseAdminRepository.buildReportParams().containsKey('p_cursor'),
        isFalse,
      );
      expect(
        SupabaseAdminRepository.buildQueueParams().containsKey('p_cursor'),
        isFalse,
      );
    });
  });

  group('buildResolveReportParams', () {
    test('pins both parameter names', () {
      expect(
        SupabaseAdminRepository.buildResolveReportParams(
          reportId: 'r1',
          resolution: ReportResolution.dismissed,
        ),
        <String, Object?>{'p_report_id': 'r1', 'p_resolution': 'dismissed'},
      );
    });

    test('actioned and dismissed stay distinguishable', () {
      // A single boolean would collapse these two, and they are different
      // judgements with different consequences for the seller.
      final actioned = SupabaseAdminRepository.buildResolveReportParams(
        reportId: 'r1',
        resolution: ReportResolution.actioned,
      );
      final dismissed = SupabaseAdminRepository.buildResolveReportParams(
        reportId: 'r1',
        resolution: ReportResolution.dismissed,
      );

      expect(actioned['p_resolution'], isNot(dismissed['p_resolution']));
    });
  });

  group('getReports through the real PostgREST path', () {
    test('reads entries, counts and the cursor', () async {
      final repo = succeedingRepo(
        jsonEncode(<String, Object?>{
          'entries': <Object?>[
            <String, Object?>{
              'id': 'r1',
              'listing_id': 'l1',
              'reason': 'price_suspicious',
              'status': 'open',
              'created_at': '2026-10-06T05:00:00+00:00',
              'resolved_at': null,
              'details': '2 crore for 300 sqm',
              'listing': <String, Object?>{
                'id': 'l1',
                'title': 'House in Kirtipur',
                'price_npr': 25000000,
                'status': 'live',
                'district': 'Kathmandu',
                'city': 'Kathmandu',
                'seller_id': 's1',
              },
              'reporter': <String, Object?>{
                'id': 'b1',
                'full_name': 'Buyer One',
                'role': 'buyer',
                'is_verified': false,
              },
            },
          ],
          'counts': <String, Object?>{'open': 4, 'actioned': 1},
          'next_cursor': <String, Object?>{
            'created_at': '2026-10-06T05:00:00+00:00',
            'id': 'r1',
          },
        }),
      );

      final page = await repo.getReports();

      expect(page.entries, hasLength(1));
      expect(page.entries.single.reason, ReportReason.priceSuspicious);
      expect(page.entries.single.status, ReportStatus.open);
      expect(page.entries.single.details, '2 crore for 300 sqm');
      expect(page.entries.single.listing.priceNpr, 25000000);
      expect(page.entries.single.listing.status, ListingStatus.live);
      expect(page.entries.single.reporter.fullName, 'Buyer One');
      expect(page.counts.open, 4);
      expect(page.counts.actioned, 1);
      // Absent from the counts object rather than present as 0, because the
      // RPC builds it with json_object_agg keyed by enum label.
      expect(page.counts.dismissed, 0);
      expect(page.nextCursor?.id, 'r1');
      expect(page.hasMore, isTrue);
    });

    test('a null next_cursor ends the walk', () async {
      final repo = succeedingRepo(
        jsonEncode(<String, Object?>{
          'entries': <Object?>[],
          'counts': <String, Object?>{},
          'next_cursor': null,
        }),
      );

      final page = await repo.getReports();

      expect(page.isEmpty, isTrue);
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
    });

    test('42501 becomes a permission failure', () {
      final repo = failingRepo(
        status: '42501',
        message: 'FORBIDDEN: admin only',
      );

      expect(
        repo.getReports,
        throwsA(
          isA<AuthFailureException>().having(
            (e) => e.code,
            'code',
            'auth.forbidden',
          ),
        ),
      );
    });
  });

  group('resolveReport', () {
    test('returns the status the server stored', () async {
      final repo = succeedingRepo(
        '{"report_id":"r1","listing_id":"l1","status":"actioned"}',
      );

      expect(
        await repo.resolveReport('r1', ReportResolution.actioned),
        ReportStatus.actioned,
      );
    });

    test('a dismissed resolution reads back as dismissed', () async {
      final repo = succeedingRepo(
        '{"report_id":"r1","listing_id":"l1","status":"dismissed"}',
      );

      expect(
        await repo.resolveReport('r1', ReportResolution.dismissed),
        ReportStatus.dismissed,
      );
    });

    test('a response with no status throws rather than guessing', () async {
      // The failure this guards: defaulting to `dismissed` after an *actioned*
      // resolution would tell the admin the seller was cleared when the listing
      // was actually pulled.
      final repo = succeedingRepo('{"report_id":"r1"}');

      expect(
        () => repo.resolveReport('r1', ReportResolution.actioned),
        throwsA(
          isA<ServerException>().having(
            (e) => e.code,
            'code',
            'server.unexpectedResponse',
          ),
        ),
      );
    });

    test('an unrecognised status throws rather than defaulting', () {
      final repo = succeedingRepo('{"report_id":"r1","status":"archived"}');

      expect(
        () => repo.resolveReport('r1', ReportResolution.actioned),
        throwsA(isA<ServerException>()),
      );
    });

    test('open is refused, though it is a real status', () async {
      // A resolve can never legitimately leave a report open. This response is
      // the exact signature of the SQL bug that used to live in
      // v1_admin_resolve_report: one variable for both the requested
      // resolution and the row's current status, so the UPDATE wrote 'open'
      // while stamping resolved_at. Accepting it here would show the admin a
      // success for work that did not happen.
      final repo = succeedingRepo('{"report_id":"r1","status":"open"}');

      expect(
        () => repo.resolveReport('r1', ReportResolution.actioned),
        throwsA(
          isA<ServerException>().having(
            (e) => e.code,
            'code',
            'server.unexpectedResponse',
          ),
        ),
      );
    });

    test('the reported status is not echoed back from the request', () async {
      // The server is the only authority on what it did. Asking for
      // `dismissed` and having the response say `actioned` must surface as
      // actioned, because the audit row records what actually happened.
      final repo = succeedingRepo(
        '{"report_id":"r1","listing_id":"l1","status":"actioned"}',
      );

      expect(
        await repo.resolveReport('r1', ReportResolution.dismissed),
        ReportStatus.actioned,
      );
    });

    test('a blank report id fails before a round trip', () {
      final repo = succeedingRepo('{"status":"actioned"}');

      expect(
        () => repo.resolveReport('   ', ReportResolution.actioned),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.reportIdRequired',
          ),
        ),
      );
    });

    test('22023 from an already-resolved report is a validation failure', () {
      // The common case being another admin resolving it first.
      final repo = failingRepo(
        status: '22023',
        message: 'VALIDATION_ERROR: this report is already actioned',
      );

      expect(
        () => repo.resolveReport('r1', ReportResolution.dismissed),
        throwsA(isA<ValidationException>()),
      );
    });

    test('42501 from resolve reads as a permission failure', () {
      final repo = failingRepo(status: '42501', message: 'FORBIDDEN');

      expect(
        () => repo.resolveReport('r1', ReportResolution.actioned),
        throwsA(isA<AuthFailureException>()),
      );
    });

    test('the failure carries a Nepali message', () {
      final repo = failingRepo(status: '22023', message: 'already actioned');

      expect(
        () => repo.resolveReport('r1', ReportResolution.dismissed),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.messageNe,
            'messageNe',
            isNotEmpty,
          ),
        ),
      );
    });
  });
}

/// A repository whose every RPC fails with [status] / [message].
///
/// Drives the genuine PostgREST request path through an injected `http.Client`,
/// so the SQLSTATE in the body becomes a real `PostgrestException` of the same
/// shape production would see.
SupabaseAdminRepository failingRepo({
  required String status,
  required String message,
}) =>
    SupabaseAdminRepository(
      SupabaseClient(
        'https://project.supabase.co',
        'test-key',
        httpClient: FailingHttpClient(sqlState: status, message: message),
      ),
    );

/// A repository whose every RPC returns [body] with a 200.
SupabaseAdminRepository succeedingRepo(String body) =>
    SupabaseAdminRepository(
      SupabaseClient(
        'https://project.supabase.co',
        'test-key',
        httpClient: RecordingHttpClient(body: body),
      ),
    );

/// Captures request bodies and answers with [body].
///
/// A list rather than a single slot: the repository makes exactly one call
/// per method today, and a list keeps the assertion correct if that ever
/// stops being true. A single slot would silently assert on a stale body.
class RecordingHttpClient extends http.BaseClient {
  RecordingHttpClient({this.body = '{}'});

  /// The body every request is answered with.
  final String body;

  /// Bodies of every request seen, in order.
  final List<String> requestBodies = <String>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request) requestBodies.add(request.body);

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(body)),
      200,
      // `request` must be set: the SDK reads `response.request!.method`
      // before parsing, and null-crashes without it. Every real response
      // carries one.
      request: request,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }
}

/// Answers every request with the HTTP status PostgREST returns for [sqlState],
/// carrying that state in the body.
///
/// The SQLSTATE is not the HTTP status: PostgREST maps `42501` to 403,
/// `22023` to 400 and a server fault to 500, and the SDK only builds a
/// `PostgrestException` for a non-2xx response. Sending the SQLSTATE as the
/// HTTP status would produce `99999`, which is not valid and would fail for the
/// wrong reason.
class FailingHttpClient extends http.BaseClient {
  FailingHttpClient({required this.sqlState, required this.message});

  final String sqlState;
  final String message;

  /// The HTTP status PostgREST returns for each SQLSTATE used in this file.
  static const Map<String, int> _httpFor = <String, int>{
    '42501': 403,
    '22023': 400,
    '50000': 500,
  };

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = jsonEncode(<String, Object?>{
      'code': sqlState,
      'message': message,
      'details': null,
      'hint': null,
    });

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(body)),
      _httpFor[sqlState] ?? 400,
      request: request,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }
}

/// Answers KYC verdict RPCs with a summary and row reads with a full row.
///
/// `verifyKyc`/`rejectKyc` make two calls: the RPC, then the read-back
/// `.single()`. One fixed body cannot serve both — the RPC needs a summary
/// map and the read needs a complete `kyc_documents` row — so this client
/// answers by endpoint. List reads (no `id` filter) get an empty page.
class _KycRecordingClient extends http.BaseClient {
  /// URLs of every request seen, in order.
  final List<Uri> requestUrls = <Uri>[];

  /// Bodies of every request seen, in order.
  final List<String> requestBodies = <String>[];

  /// One verified row, as the read-back returns it.
  static const Map<String, Object?> _row = <String, Object?>{
    'id': 'doc-1',
    'profile_id': 'user-1',
    'doc_type': 'citizenship',
    'storage_path': 'user-1/1_citizenship.jpg',
    'status': 'verified',
    'reviewed_by': 'admin-1',
    'reviewed_at': '2026-10-06T12:00:00.000Z',
    'created_at': '2026-10-06T11:00:00.000Z',
    'listing_id': null,
    'updated_at': null,
  };

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestUrls.add(request.url);
    if (request is http.Request) requestBodies.add(request.body);

    final Object body;
    if (request.url.path.contains('/rpc/')) {
      body = <String, Object?>{'id': 'doc-1', 'status': 'verified'};
    } else if (request.url.queryParameters.containsKey('id')) {
      body = _row;
    } else {
      body = <Object?>[];
    }

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(jsonEncode(body))),
      200,
      request: request,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }
}

/// Succeeds the verdict RPC, then answers the read-back with zero rows.
///
/// PostgREST answers `.single()` on zero rows with 406 + `PGRST116`, which
/// the mapper reports as `server.notFound`. Drives the remap to
/// `validation.kycNotFound` without a live database (Rule 31).
class _MissingRowClient extends http.BaseClient {
  bool _rpcSeen = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.path.contains('/rpc/')) {
      _rpcSeen = true;
      return http.StreamedResponse(
        Stream<List<int>>.value(
          utf8.encode('{"id":"doc-1","status":"verified"}'),
        ),
        200,
        request: request,
        headers: <String, String>{'content-type': 'application/json'},
      );
    }

    assert(_rpcSeen, 'the verdict RPC must run before the read-back');
    final body = jsonEncode(<String, Object?>{
      'code': 'PGRST116',
      'message': 'The result contains 0 rows',
      'details': null,
      'hint': null,
    });
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(body)),
      406,
      request: request,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }
}
