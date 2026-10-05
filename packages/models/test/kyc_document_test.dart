import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Tier 2/3 fields added in HYA-264 A2: `listing_id` + `updated_at` plus the
/// `KycDocType.wireName` that stops the `.name`-vs-wire slip
/// (`agencyReg` vs `agency_reg`) documented on [ListingStatus].
void main() {
  group('KycDocType.wireName', () {
    test('agencyReg arrives as agency_reg', () {
      expect(KycDocType.agencyReg.wireName, 'agency_reg');
      expect(KycDocType.citizenship.wireName, 'citizenship');
      expect(KycDocType.lalpurja.wireName, 'lalpurja');
    });

    test('fromWire round-trips every value', () {
      for (final type in KycDocType.values) {
        expect(KycDocType.fromWire(type.wireName), type);
      }
    });

    test('fromWire throws on unknown values instead of defaulting', () {
      expect(() => KycDocType.fromWire('passport'), throwsArgumentError);
    });
  });

  group('KycDocument Tier 3 fields', () {
    test('Tier 2 row has null listingId', () {
      const doc = KycDocument(
        id: 'doc-1',
        profileId: 'user-1',
        docType: KycDocType.citizenship,
        storagePath: 'user-1/123_citizenship.jpg',
      );

      expect(doc.listingId, isNull);
      final json = doc.toJson();
      expect(json['listing_id'], isNull);
    });

    test('Tier 3 round-trip preserves listingId and updatedAt', () {
      final doc = KycDocument(
        id: 'doc-2',
        profileId: 'user-1',
        docType: KycDocType.lalpurja,
        storagePath: 'user-1/124_lalpurja.pdf',
        listingId: 'listing-9',
        updatedAt: DateTime.utc(2026, 10, 6, 12),
      );

      expect(KycDocument.fromJson(doc.toJson()), doc);
      expect(doc.toJson()['listing_id'], 'listing-9');
    });

    test('pre-A2 rows without the new keys still parse', () {
      final doc = KycDocument.fromJson(<String, dynamic>{
        'id': 'doc-old',
        'profile_id': 'user-1',
        'doc_type': 'citizenship',
        'storage_path': 'user-1/old.jpg',
        'status': 'pending',
      });

      expect(doc.listingId, isNull);
      expect(doc.updatedAt, isNull);
    });
  });
}
