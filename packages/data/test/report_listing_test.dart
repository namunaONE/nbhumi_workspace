import 'dart:convert';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tests for [ListingRepository.reportListing] — the buyer-side report path.
///
/// Structure follows `admin_repository_test.dart`: parameter building is
/// asserted directly, and the error cases drive the real PostgREST path through
/// an injected `http.Client` so the SQLSTATE becomes a real
/// `PostgrestException` rather than a shape the SDK might never produce.
void main() {
  group('reportListing validation, before any round trip', () {
    test("'other' with no description is refused locally", () {
      final repo = _repo(_alwaysSucceeds());

      expect(
        () => repo.reportListing(
          listingId: 'l1',
          reason: ReportReason.other,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.reportDetailsRequired',
          ),
        ),
      );
    });

    test("'other' with whitespace-only details is refused locally", () {
      // The RPC nullif's the trimmed value, so '   ' is indistinguishable from
      // absent there. Catching it here is the same Rule 6 ordering: complain
      // against the field the buyer typed into.
      final repo = _repo(_alwaysSucceeds());

      expect(
        () => repo.reportListing(
          listingId: 'l1',
          reason: ReportReason.other,
          details: '    \n\t ',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('the complaint carries a Nepali message', () {
      final repo = _repo(_alwaysSucceeds());

      expect(
        () => repo.reportListing(
          listingId: 'l1',
          reason: ReportReason.other,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.messageNe,
            'messageNe',
            isNotEmpty,
          ),
        ),
      );
    });

    test('a specific reason needs no description', () async {
      final repo = _repo(
        _alwaysSucceeds(
          jsonEncode(<String, Object?>{
            'report_id': 'r1',
            'listing_id': 'l1',
            'reason': 'fake_listing',
            'details': null,
            'status': 'open',
          }),
        ),
      );

      final report = await repo.reportListing(
        listingId: 'l1',
        reason: ReportReason.fakeListing,
      );

      expect(report.reportId, 'r1');
      expect(report.reason, ReportReason.fakeListing);
    });

    test('details are trimmed before the call', () async {
      final transport = _Recording(
        body: jsonEncode(<String, Object?>{
          'report_id': 'r1',
          'listing_id': 'l1',
          'reason': 'other',
          'details': 'The pin is 3 km away',
        }),
      );
      final repo = _repo(transport);

      final report = await repo.reportListing(
        listingId: 'l1',
        reason: ReportReason.other,
        details: '  The pin is 3 km away  ',
      );

      expect(report.details, 'The pin is 3 km away');
      final sent =
          (jsonDecode(transport.bodies.single) as Map<String, dynamic>)
              ['p_details'];
      expect(sent, 'The pin is 3 km away');
    });
  });

  group('reportListing error mapping through the real PostgREST path', () {
    test('42501 on an unauthenticated call is an auth failure', () {
      final repo = _repo(_alwaysFails('42501', 'AUTH_REQUIRED: sign in'));

      expect(
        () => repo.reportListing(
          listingId: 'l1',
          reason: ReportReason.fakeListing,
        ),
        throwsA(isA<AuthFailureException>()),
      );
    });

    test('22023 for a duplicate report is a validation failure', () {
      // The common case: the buyer taps Report twice, or reported this listing
      // on a previous visit.
      final repo = _repo(
        _alwaysFails(
          '22023',
          'VALIDATION_ERROR: you have already reported this listing',
        ),
      );

      expect(
        () => repo.reportListing(
          listingId: 'l1',
          reason: ReportReason.priceSuspicious,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.rejected',
          ),
        ),
      );
    });

    test('22023 for a self-report is a validation failure', () {
      final repo = _repo(
        _alwaysFails(
          '22023',
          'VALIDATION_ERROR: you cannot report your own listing',
        ),
      );

      expect(
        () => repo.reportListing(
          listingId: 'l1',
          reason: ReportReason.duplicateListing,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('a 5xx is a server failure, not a retryable network error', () {
      // PostgREST answering 500 means the server was reached and failed. A
      // dropped connection arrives as a network error instead — a different
      // HTTP status, and one where a retry button genuinely helps.
      final repo = _repo(_alwaysFails('50000', 'internal error'));

      expect(
        () => repo.reportListing(
          listingId: 'l1',
          reason: ReportReason.fakeListing,
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('a connection failure is retryable', () {
      // The mapper reads the message text, because PostgREST has no SQLSTATE
      // for a transport failure — this is the shape a dropped connection takes.
      final repo = _repo(
        _alwaysFails('50000', 'TypeError: Failed to fetch. Connection lost'),
      );

      expect(
        () => repo.reportListing(
          listingId: 'l1',
          reason: ReportReason.fakeListing,
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.isRetryable,
            'isRetryable',
            isNot(false),
          ),
        ),
      );
    });

    test('no Postgres text reaches the buyer', () {
      final repo = _repo(
        _alwaysFails(
          '42501',
          'AUTH_REQUIRED: sign in to report a listing, uid=abc-123',
        ),
      );

      expect(
        () => repo.reportListing(
          listingId: 'l1',
          reason: ReportReason.fakeListing,
        ),
        throwsA(
          isA<AuthFailureException>().having(
            (e) => e.messageEn,
            'messageEn',
            allOf(
              isNot(contains('42501')),
              isNot(contains('abc-123')),
            ),
          ),
        ),
      );
    });
  });

  group('the report the server stored', () {
    test('reads back the reason the database recorded', () async {
      // Not the reason the client asked for. A client that echoed its own
      // argument would show the buyer "price is wrong" for a report filed as
      // fake, if the server had normalised or rejected the value.
      final repo = _repo(
        _alwaysSucceeds(
          jsonEncode(<String, Object?>{
            'report_id': 'r1',
            'listing_id': 'l1',
            'reason': 'photos_misleading',
          }),
        ),
      );

      final report = await repo.reportListing(
        listingId: 'l1',
        reason: ReportReason.fakeListing,
      );

      expect(report.reason, ReportReason.photosMisleading);
    });

    test('an unknown reason label throws rather than defaulting', () {
      // Defaulting to `other` here would put a specific complaint in the bucket
      // that requires a description, and the CHECK constraint would then reject
      // a report the buyer filed correctly.
      //
      // The throw is an ArgumentError from json_serializable's enum decoder,
      // not the FormatException a hand-written parser would raise. The type
      // is asserted loosely on purpose: what matters is that it fails loudly,
      // and pinning the decoder's exception type would break on a
      // json_serializable upgrade without any behaviour having changed.
      final repo = _repo(
        _alwaysSucceeds(
          '{"report_id":"r1","listing_id":"l1","reason":"spam"}',
        ),
      );

      expect(
        () => repo.reportListing(
          listingId: 'l1',
          reason: ReportReason.fakeListing,
        ),
        throwsA(anything),
      );
    });

    test('the confirmation carries no listing or reporter', () {
      // Belt and braces on a design decision: the response to "I reported this"
      // has no business echoing back who else looked at it.
      expect(
        _listedFieldNames,
        isNot(contains('listing')),
      );
      expect(_listedFieldNames, isNot(contains('reporter')));
    });
  });
}

/// The wire field names of `ListingReport`, asserted without a live database.
///
/// Taken from `toJson` rather than a hand-written list so a field added to the
/// model is caught here instead of leaking a new key to the database.
final Set<String> _listedFieldNames = const ListingReport(
  reportId: 'r1',
  listingId: 'l1',
  reason: ReportReason.other,
).toJson().keys.toSet();

ListingRepository _repo(http.Client client) => ListingRepository(
      SupabaseClient(
        'https://project.supabase.co',
        'test-key',
        httpClient: client,
      ),
    );

/// Answers every request with [body] and a 200.
http.Client _alwaysSucceeds([
  String body = '{"report_id":"r1","listing_id":"l1","reason":"other"}',
]) =>
    _Recording(body: body);

/// Answers every request with the HTTP status PostgREST returns for [sqlState].
///
/// The SQLSTATE is not the HTTP status: PostgREST maps `42501` to 403, `22023`
/// to 400 and a server fault to 500. Sending the SQLSTATE as the HTTP status
/// would produce `99999`, which is not a valid code.
http.Client _alwaysFails(String sqlState, String message) =>
    _Recording(sqlState: sqlState, message: message);

/// Records request bodies and answers with a canned response.
class _Recording extends http.BaseClient {
  _Recording({this.body = '{}', this.sqlState, this.message});

  final String body;
  final String? sqlState;
  final String? message;

  /// Bodies of every request seen, in order.
  final List<String> bodies = <String>[];

  static const Map<String, int> _httpFor = <String, int>{
    '42501': 403,
    '22023': 400,
    'P0002': 404,
    '50000': 500,
  };

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request) bodies.add(request.body);

    final state = sqlState;
    if (state != null) {
      return http.StreamedResponse(
        Stream<List<int>>.value(
          utf8.encode(
            jsonEncode(<String, Object?>{
              'code': state,
              'message': message,
              'details': null,
              'hint': null,
            }),
          ),
        ),
        _httpFor[state] ?? 400,
        // `request` must be set: the SDK reads `response.request!.method`
        // before parsing and null-crashes without it. Every real response
        // carries one.
        request: request,
        headers: <String, String>{'content-type': 'application/json'},
      );
    }

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(body)),
      200,
      request: request,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }
}
