import 'dart:convert';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tests for [SavedSearchRepository].
///
/// Validation is pure logic; error mapping drives the real PostgREST path
/// (Rule 31); the one success path asserts the row maps back with its
/// filter fields intact.
void main() {
  group('validation (no round trip)', () {
    test('blank user, name and id are refused client-side', () {
      final repo = _failingRepo(status: '42501', message: 'must not call');
      const filter = ListingFilter(district: 'Kathmandu');

      expect(
        () => repo.saveSearch(userId: '  ', name: 'N', filter: filter),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.savedSearchSignInRequired',
          ),
        ),
      );
      expect(
        () => repo.saveSearch(userId: 'u1', name: '  ', filter: filter),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.savedSearchNameRequired',
          ),
        ),
      );
      expect(
        () => repo.deleteSearch('  '),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.savedSearchIdRequired',
          ),
        ),
      );
    });

    test('an unfiltered search is refused: it would alert on everything', () {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      expect(
        () => repo.saveSearch(
          userId: 'u1',
          name: 'Everything',
          filter: const ListingFilter(),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.savedSearchEmptyFilter',
          ),
        ),
      );
    });

    test('lopsided ranges are refused with the field at fault', () {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      expect(
        () => repo.saveSearch(
          userId: 'u1',
          name: 'N',
          filter: const ListingFilter(minPriceNpr: 5, maxPriceNpr: 1),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.savedSearchPriceRange',
          ),
        ),
      );
      expect(
        () => repo.saveSearch(
          userId: 'u1',
          name: 'N',
          filter: const ListingFilter(minAreaSqm: 9, maxAreaSqm: 2),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.savedSearchAreaRange',
          ),
        ),
      );
    });

    test('every refusal is bilingual and not retryable', () async {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      try {
        await repo.saveSearch(
          userId: 'u1',
          name: 'N',
          filter: const ListingFilter(),
        );
        fail('expected a throw');
      } on ValidationException catch (e) {
        expect(e.messageEn, isNotEmpty);
        expect(e.messageNe, isNotEmpty);
        expect(e.isRetryable, isFalse);
      }
    });
  });

  group('error mapping through the real PostgREST path', () {
    test('42501 becomes a permission failure', () {
      final repo = _failingRepo(status: '42501', message: 'FORBIDDEN');

      expect(
        repo.savedSearches,
        throwsA(
          isA<AuthFailureException>().having(
            (e) => e.code,
            'code',
            'auth.forbidden',
          ),
        ),
      );
    });

    test('no Postgres text reaches the user-facing message', () async {
      final repo = _failingRepo(
        status: '42501',
        message: 'FORBIDDEN: uid=abc-123',
      );

      try {
        await repo.deleteSearch('s1');
        fail('expected a throw');
      } on AuthFailureException catch (e) {
        expect(e.messageEn, isNot(contains('abc-123')));
        expect(e.cause, isNotNull);
        expect(e.messageNe, isNotEmpty);
      }
    });
  });

  group('saveSearch success', () {
    test('the stored row maps back with filter fields intact', () async {
      final repo = SavedSearchRepository(
        SupabaseClient(
          'https://project.supabase.co',
          'test-key',
          httpClient: _FixedClient(
            body: jsonEncode(<String, Object?>{
              'id': 's1',
              'user_id': 'u1',
              'name': 'Houses in Kathmandu',
              'district': 'Kathmandu',
              'property_type': 'house',
              'listing_purpose': null,
              'min_price_npr': null,
              'max_price_npr': 5000000,
              'min_area_sqm': null,
              'max_area_sqm': null,
              'created_at': '2026-10-06T12:00:00.000Z',
            }),
          ),
        ),
      );

      final saved = await repo.saveSearch(
        userId: 'u1',
        name: 'Houses in Kathmandu',
        filter: const ListingFilter(
          district: 'Kathmandu',
          propertyType: PropertyType.house,
          maxPriceNpr: 5000000,
        ),
      );

      expect(saved.id, 's1');
      expect(saved.district, 'Kathmandu');
      expect(saved.propertyType, PropertyType.house);
      expect(saved.maxPriceNpr, 5000000);
    });
  });
}

/// A repository over a client whose every call fails with [status]/[message].
SavedSearchRepository _failingRepo({
  required String status,
  required String message,
}) =>
    SavedSearchRepository(
      SupabaseClient(
        'https://project.supabase.co',
        'test-key',
        httpClient: _FailingHttpClient(sqlState: status, message: message),
      ),
    );

/// Answers every request with [body] and a 200.
class _FixedClient extends http.BaseClient {
  _FixedClient({required this.body});

  final String body;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(body)),
      200,
      request: request,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }
}

/// Answers every request with the HTTP status PostgREST would return for
/// [sqlState], carrying that state in the body.
class _FailingHttpClient extends http.BaseClient {
  _FailingHttpClient({required this.sqlState, required this.message});

  final String sqlState;
  final String message;

  static const Map<String, int> _httpFor = <String, int>{
    '42501': 403,
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
