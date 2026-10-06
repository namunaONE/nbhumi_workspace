import 'dart:convert';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tests for [NotificationRepository].
///
/// Same three-layer shape as the KYC and admin repository tests: pure
/// validation needs no client, error mapping drives the real PostgREST path
/// through an injected `http.Client` (Rule 31: no live Supabase in the unit
/// loop), and bilingual messages are asserted on every user-facing failure
/// (Rule 36).
void main() {
  group('markRead validation (no round trip)', () {
    test('a blank id is refused client-side', () {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      expect(
        () => repo.markRead('  '),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.notificationIdRequired',
          ),
        ),
      );
    });

    test('the refusal is bilingual and not retryable', () async {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      try {
        await repo.markRead('');
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
        repo.inbox,
        throwsA(
          isA<AuthFailureException>().having(
            (e) => e.code,
            'code',
            'auth.forbidden',
          ),
        ),
      );
    });

    test('a rewritten row is rejected as a constraint failure', () {
      // The immutability trigger raises 23514 when content changes.
      final repo = _failingRepo(
        status: '23514',
        message: 'IMMUTABLE: notification content cannot be changed',
      );

      expect(
        () => repo.markRead('notif-1'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.constraint',
          ),
        ),
      );
    });

    test('a vanished row reads as gone-from-inbox, not not-found', () async {
      final repo = _failingRepo(status: 'PGRST116', message: '0 rows');

      try {
        await repo.markRead('notif-1');
        fail('expected a throw');
      } on ValidationException catch (e) {
        expect(e.code, 'validation.notificationNotFound');
        expect(e.messageNe, isNotEmpty);
      }
    });

    test('no Postgres text reaches the user-facing message', () async {
      final repo = _failingRepo(
        status: '42501',
        message: 'FORBIDDEN: uid=abc-123',
      );

      try {
        await repo.inbox();
        fail('expected a throw');
      } on AuthFailureException catch (e) {
        expect(e.messageEn, isNot(contains('abc-123')));
        expect(e.cause, isNotNull);
        expect(e.messageNe, isNotEmpty);
      }
    });
  });

  group('markAllRead', () {
    test('returns how many rows flipped', () async {
      final repo = NotificationRepository(
        SupabaseClient(
          'https://project.supabase.co',
          'test-key',
          httpClient: _ListingHttpClient(
            body: jsonEncode(<Object?>[
              <String, Object?>{'id': 'a'},
              <String, Object?>{'id': 'b'},
            ]),
          ),
        ),
      );

      expect(await repo.markAllRead(), 2);
    });
  });
}

/// A repository over a client whose every call fails with [status]/[message].
NotificationRepository _failingRepo({
  required String status,
  required String message,
}) =>
    NotificationRepository(
      SupabaseClient(
        'https://project.supabase.co',
        'test-key',
        httpClient: _FailingHttpClient(sqlState: status, message: message),
      ),
    );

/// Answers every request with [body] and a 200.
class _ListingHttpClient extends http.BaseClient {
  _ListingHttpClient({required this.body});

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
    '23514': 400,
    'PGRST116': 406,
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
