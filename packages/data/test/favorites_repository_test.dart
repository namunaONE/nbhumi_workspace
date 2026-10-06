import 'dart:convert';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tests for [FavoritesRepository].
///
/// Pure validation needs no client; error mapping drives the real PostgREST
/// path through an injected `http.Client` (Rule 31); the cover-pick helper
/// is asserted directly because a wrong photo fails silently.
void main() {
  group('validation (no round trip)', () {
    test('blank ids are refused client-side', () {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      expect(
        () => repo.addFavorite(userId: 'u1', listingId: '  '),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.favoriteIdRequired',
          ),
        ),
      );
      expect(
        () => repo.addFavorite(userId: '  ', listingId: 'l1'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.favoriteSignInRequired',
          ),
        ),
      );
      expect(
        () => repo.removeFavorite(userId: 'u1', listingId: ''),
        throwsA(isA<ValidationException>()),
      );
    });

    test('the refusal is bilingual and not retryable', () async {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      try {
        await repo.addFavorite(userId: '', listingId: 'l1');
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
        repo.favoriteIds,
        throwsA(
          isA<AuthFailureException>().having(
            (e) => e.code,
            'code',
            'auth.forbidden',
          ),
        ),
      );
    });

    test('a duplicate bookmark reads as already-saved', () async {
      final repo = _failingRepo(
        status: '23505',
        message: 'duplicate key value violates unique constraint',
      );

      try {
        await repo.addFavorite(userId: 'u1', listingId: 'l1');
        fail('expected a throw');
      } on ValidationException catch (e) {
        expect(e.code, 'validation.alreadySaved');
        expect(e.messageEn, contains('already'));
        expect(e.messageNe, isNotEmpty);
      }
    });

    test('no Postgres text reaches the user-facing message', () async {
      final repo = _failingRepo(
        status: '42501',
        message: 'FORBIDDEN: uid=abc-123',
      );

      try {
        await repo.favoriteIds();
        fail('expected a throw');
      } on AuthFailureException catch (e) {
        expect(e.messageEn, isNot(contains('abc-123')));
        expect(e.cause, isNotNull);
      }
    });
  });

  group('toggleFavorite', () {
    test('adds when absent and reports saved', () async {
      final transport = _SequenceClient(const <_Step>[
        _Step(200, '[]'),
        _Step(201, '[{"user_id":"u1","listing_id":"l1"}]'),
      ]);
      final repo = _clientRepo(transport);

      expect(
        await repo.toggleFavorite(userId: 'u1', listingId: 'l1'),
        isTrue,
      );
      expect(transport.bodies.length, 2);
    });

    test('removes when present and reports unsaved', () async {
      final transport = _SequenceClient(const <_Step>[
        _Step(200, '[{"listing_id":"l1"}]'),
        _Step(200, '[]'),
      ]);
      final repo = _clientRepo(transport);

      expect(
        await repo.toggleFavorite(userId: 'u1', listingId: 'l1'),
        isFalse,
      );
    });
  });

  group('savedListings mapping', () {
    test('skips vanished listings, picks covers by order', () async {
      final transport = _SequenceClient(<_Step>[
        _Step(
          200,
          jsonEncode(<Object?>[
            <String, Object?>{
              'listing_id': 'gone',
              'listing': null,
            },
            <String, Object?>{
              'listing_id': 'l1',
              'listing': <String, Object?>{
                'id': 'l1',
                'seller_id': 's1',
                'title': 'House',
                'price_npr': 1000000,
                'district': 'Kathmandu',
                'city': 'Kirtipur',
                'property_type': 'house',
                'listing_purpose': 'sale',
                'status': 'live',
                'listing_photos': <Object?>[
                  <String, Object?>{'url': 'second.jpg', 'sort_order': 2},
                  <String, Object?>{'url': 'cover.jpg', 'sort_order': 0},
                ],
              },
            },
          ]),
        ),
      ]);
      final repo = _clientRepo(transport);

      final saved = await repo.savedListings();

      expect(saved, hasLength(1));
      expect(saved.single.id, 'l1');
      expect(saved.single.photoUrl, 'cover.jpg');
    });
  });

  group('withCoverForTest', () {
    test('no photos means no cover, not a crash', () {
      final mapped = FavoritesRepository.withCoverForTest(
        <String, dynamic>{'id': 'l1', 'listing_photos': <Object?>[]},
      );

      expect(mapped['photo_url'], isNull);
      expect(mapped.containsKey('listing_photos'), isFalse);
    });
  });
}

/// A repository over a client whose every call fails with [status]/[message].
FavoritesRepository _failingRepo({
  required String status,
  required String message,
}) =>
    _clientRepo(_FailingHttpClient(sqlState: status, message: message));

/// A repository over [client].
FavoritesRepository _clientRepo(http.BaseClient client) =>
    FavoritesRepository(
      SupabaseClient(
        'https://project.supabase.co',
        'test-key',
        httpClient: client,
      ),
    );

/// One scripted answer in request order.
class _Step {
  const _Step(this.status, this.body);

  final int status;
  final String body;
}

/// Answers each request with the next [_Step], then repeats the last.
class _SequenceClient extends http.BaseClient {
  _SequenceClient(this.steps);

  final List<_Step> steps;

  /// Bodies seen, in order.
  final List<String> bodies = <String>[];

  var _at = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request) bodies.add(request.body);
    final step = steps[_at < steps.length ? _at++ : steps.length - 1];

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(step.body)),
      step.status,
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
    '23505': 409,
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
