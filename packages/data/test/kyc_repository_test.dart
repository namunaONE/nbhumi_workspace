import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tests for [KycRepository].
///
/// Mirrors `admin_repository_test.dart`: parameter shaping is asserted
/// directly, error mapping drives the real PostgREST path through an injected
/// `http.Client` (Rule 31: no live Supabase in the unit loop), and pure
/// validation needs no client at all.
void main() {
  group('buildSubmitParams', () {
    test('sends wire names, not Dart names', () {
      final params = KycRepository.buildSubmitParams(
        docType: KycDocType.agencyReg,
        storagePath: 'uid/1_agency_reg.pdf',
      );

      // The bug this guards: `.name` would send `agencyReg` and the RPC
      // would reject it with 22023 INVALID_DOC_TYPE.
      expect(params['p_doc_type'], 'agency_reg');
      expect(params['p_storage_path'], 'uid/1_agency_reg.pdf');
    });

    test('Tier 2 submits a null listing id', () {
      final params = KycRepository.buildSubmitParams(
        docType: KycDocType.citizenship,
        storagePath: 'uid/1_citizenship.jpg',
      );

      expect(params['p_doc_type'], 'citizenship');
      expect(params['p_listing_id'], isNull);
    });

    test('Tier 3 carries the listing id through', () {
      final params = KycRepository.buildSubmitParams(
        docType: KycDocType.lalpurja,
        storagePath: 'uid/2_lalpurja.pdf',
        listingId: 'listing-9',
      );

      expect(params['p_doc_type'], 'lalpurja');
      expect(params['p_listing_id'], 'listing-9');
    });
  });

  group('submitKyc validation (no round trip)', () {
    test('blank storage path is refused client-side', () {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      expect(
        () => repo.submitKyc(
          docType: KycDocType.citizenship,
          storagePath: '  ',
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.kycPathRequired',
          ),
        ),
      );
    });

    test('path traversal is refused client-side', () {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      expect(
        () => repo.submitKyc(
          docType: KycDocType.lalpurja,
          storagePath: 'uid/../../etc.pdf',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('citizenship paired with a listing is refused client-side', () {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      expect(
        () => repo.submitKyc(
          docType: KycDocType.citizenship,
          storagePath: 'uid/1_citizenship.jpg',
          listingId: 'listing-9',
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.kycCitizenshipListing',
          ),
        ),
      );
    });

    test('every client-side refusal is bilingual and not retryable', () async {
      final repo = _failingRepo(status: '42501', message: 'must not call');

      try {
        await repo.submitKyc(docType: KycDocType.lalpurja, storagePath: '');
        fail('expected a throw');
      } on ValidationException catch (e) {
        expect(e.messageEn, isNotEmpty);
        expect(e.messageNe, isNotEmpty);
        expect(e.isRetryable, isFalse);
      }
    });
  });

  group('uploadKycFile validation (no round trip)', () {
    test('blank user id is refused', () {
      final repo = _failingRepo(status: '50000', message: 'must not call');

      expect(
        () => repo.uploadKycFile(
          userId: '  ',
          bytes: Uint8List.fromList(<int>[1, 2, 3]),
          filename: 'citizenship.jpg',
          docType: KycDocType.citizenship,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.kycUserRequired',
          ),
        ),
      );
    });

    test('empty bytes are refused', () {
      final repo = _failingRepo(status: '50000', message: 'must not call');

      expect(
        () => repo.uploadKycFile(
          userId: 'uid',
          bytes: Uint8List(0),
          filename: 'a.pdf',
          docType: KycDocType.lalpurja,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.kycEmptyFile',
          ),
        ),
      );
    });

    test('oversize files are refused at exactly 10 MiB + 1', () {
      final repo = _failingRepo(status: '50000', message: 'must not call');

      expect(
        () => repo.uploadKycFile(
          userId: 'uid',
          bytes: Uint8List(10 * 1024 * 1024 + 1),
          filename: 'a.pdf',
          docType: KycDocType.lalpurja,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.kycTooLarge',
          ),
        ),
      );
    });

    test('executables and extensionless names are refused', () {
      final repo = _failingRepo(status: '50000', message: 'must not call');

      expect(
        () => repo.uploadKycFile(
          userId: 'uid',
          bytes: Uint8List.fromList(<int>[1]),
          filename: 'payload.exe',
          docType: KycDocType.citizenship,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.kycBadType',
          ),
        ),
      );

      expect(
        () => repo.uploadKycFile(
          userId: 'uid',
          bytes: Uint8List.fromList(<int>[1]),
          filename: 'noextension',
          docType: KycDocType.citizenship,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('documentSignedUrl validation', () {
    test('blank paths and out-of-range expiries are refused', () async {
      final repo = _failingRepo(status: '50000', message: 'must not call');

      await expectLater(
        repo.documentSignedUrl('  '),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        repo.documentSignedUrl('uid/a.pdf', expiresIn: 0),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.kycExpiryRange',
          ),
        ),
      );
      await expectLater(
        repo.documentSignedUrl('uid/a.pdf', expiresIn: 3601),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('error mapping through the real PostgREST path', () {
    test('42501 becomes a permission failure', () {
      final repo = _failingRepo(status: '42501', message: 'FORBIDDEN');

      expect(
        repo.myDocuments,
        throwsA(
          isA<AuthFailureException>().having(
            (e) => e.code,
            'code',
            'auth.forbidden',
          ),
        ),
      );
    });

    test('duplicate pending becomes a validation failure (23505)', () {
      final repo = _failingRepo(
        status: '23505',
        message: 'CONFLICT: pending review already exists',
      );

      expect(
        () => repo.submitKyc(
          docType: KycDocType.lalpurja,
          storagePath: 'uid/2_lalpurja.pdf',
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.duplicate',
          ),
        ),
      );
    });

    test('no Postgres text reaches the user-facing message', () async {
      final repo = _failingRepo(
        status: '42501',
        message: 'FORBIDDEN: uid=abc-123, role=buyer',
      );

      try {
        await repo.myDocuments();
        fail('expected a throw');
      } on AuthFailureException catch (e) {
        expect(e.messageEn, isNot(contains('abc-123')));
        expect(e.messageEn, isNot(contains('buyer')));
        expect(e.cause, isNotNull);
        expect(e.messageNe, isNotEmpty);
      }
    });
  });
}

/// A repository over a client whose every RPC fails with [status]/[message].
KycRepository _failingRepo({required String status, required String message}) =>
    KycRepository(
      SupabaseClient(
        'https://project.supabase.co',
        'test-key',
        httpClient: _FailingHttpClient(sqlState: status, message: message),
      ),
    );

/// Answers every request with the HTTP status PostgREST would return for
/// [sqlState]. Copied from `admin_repository_test.dart`: the SQLSTATE rides
/// in the body, not the HTTP status, or the SDK builds the wrong exception.
class _FailingHttpClient extends http.BaseClient {
  _FailingHttpClient({required this.sqlState, required this.message});

  final String sqlState;
  final String message;

  static const Map<String, int> _httpFor = <String, int>{
    '42501': 403,
    '22023': 400,
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
