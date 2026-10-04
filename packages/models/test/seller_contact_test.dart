import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// The payload `v1_contact_seller` actually returns, verified against the live
/// database in the HYA-252 acceptance run.
Map<String, dynamic> _wire({
  String phone = '+9779841234567',
  String? expiresAt = '2026-10-05T06:30:00+00:00',
}) =>
    <String, dynamic>{
      'listing_id': '61142d04-3e21-4f23-8335-9e546fe3f8cf',
      'seller_id': '11111111-1111-1111-1111-111111111111',
      'seller_name': 'Ram Bahadur',
      'seller_phone': phone,
      'seller_email': 'seller@probe.test',
      'agency_name': 'Himal Realtors',
      'is_verified': true,
      'revealed_at': '2026-10-04T06:30:00+00:00',
      'expires_at': expiresAt,
    };

void main() {
  group('SellerContact.fromJson', () {
    test('parses the verified wire shape', () {
      final contact = SellerContact.fromJson(_wire());

      expect(contact.sellerName, 'Ram Bahadur');
      expect(contact.sellerPhone, '+9779841234567');
      expect(contact.sellerEmail, 'seller@probe.test');
      expect(contact.agencyName, 'Himal Realtors');
      expect(contact.isVerified, isTrue);
      expect(contact.expiresAt, DateTime.utc(2026, 10, 5, 6, 30));
    });

    test('tolerates a seller with no phone or email', () {
      // A seller can have an incomplete profile. The reveal still succeeds
      // server-side, so the client must render it rather than crash.
      final contact = SellerContact.fromJson(
        _wire(phone: '')..['seller_email'] = null,
      );

      expect(contact.sellerPhone, isEmpty);
      expect(contact.sellerEmail, isNull);
    });

    test('defaults isVerified to false when absent', () {
      final wire = _wire()..remove('is_verified');
      expect(SellerContact.fromJson(wire).isVerified, isFalse);
    });
  });

  group('SellerContact.isValidAt', () {
    test('is valid before expiry', () {
      final contact = SellerContact.fromJson(_wire());
      expect(contact.isValidAt(DateTime.utc(2026, 10, 4, 12)), isTrue);
    });

    test('is invalid after expiry', () {
      // The reason this method exists: a phone number cached on device must not
      // be shown indefinitely.
      final contact = SellerContact.fromJson(_wire());
      expect(contact.isValidAt(DateTime.utc(2026, 10, 6, 12)), isFalse);
    });

    test('treats a missing expiry as still valid', () {
      // Only a payload predating the field produces null. Calling that expired
      // would hide a contact the server just handed over.
      final contact = SellerContact.fromJson(_wire(expiresAt: null));
      expect(contact.expiresAt, isNull);
      expect(contact.isValidAt(DateTime.utc(2030)), isTrue);
    });
  });

  group('separation from ListingDetail', () {
    test('ListingDetail cannot carry contact fields', () {
      // The privacy invariant, asserted structurally. If someone later adds
      // phone or email to the detail model, this test fails, because the wire
      // response for detail does not include them and fromJson would drop them.
      final detail = ListingDetail.fromJson(<String, dynamic>{
        'id': 'l',
        'seller_id': 's',
        'title': 'T',
        'price_npr': 1,
        'district': 'Kathmandu',
        'city': 'Kathmandu',
        'property_type': 'house',
        'listing_purpose': 'sale',
        'seller': <String, dynamic>{'id': 's', 'full_name': 'Ram'},
      });

      final json = detail.toJson();
      final seller = json['seller']! as Map<String, dynamic>;

      expect(seller.containsKey('phone'), isFalse);
      expect(seller.containsKey('email'), isFalse);
      expect(json.containsKey('seller_phone'), isFalse);
      expect(json.containsKey('seller_email'), isFalse);
    });

    test('round-trips through toJson', () {
      final contact = SellerContact.fromJson(_wire());
      expect(SellerContact.fromJson(contact.toJson()), contact);
    });
  });
}
