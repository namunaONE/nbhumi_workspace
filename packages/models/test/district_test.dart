import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

void main() {
  group('District', () {
    test('parses the wire shape', () {
      // Row shape copied from the live `districts` table.
      final district = District.fromJson(<String, dynamic>{
        'id': 'd-ktm',
        'name': 'Kathmandu',
        'province': 'Bagmati',
        'region': 'hill',
      });

      expect(district.name, 'Kathmandu');
      expect(district.province, 'Bagmati');
      expect(district.region, Region.hill);
      expect(district.isHill, isTrue);
    });

    test('round-trips', () {
      const district = District(
        id: 'd-chi',
        name: 'Chitwan',
        province: 'Bagmati',
        region: Region.terai,
      );
      expect(District.fromJson(district.toJson()), district);
    });

    test('isHill is false for terai', () {
      const terai = District(
        id: 'd',
        name: 'Jhapa',
        province: 'Koshi',
        region: Region.terai,
      );
      expect(terai.isHill, isFalse);
    });
  });

  group('Region.fromWire', () {
    test('parses the two values present in the database', () {
      expect(Region.fromWire('hill'), Region.hill);
      expect(Region.fromWire('terai'), Region.terai);
    });

    test('throws on anything else rather than defaulting', () {
      // Defaulting to hill would silently show ropani inputs to a Terai seller,
      // which misstates their plot by a factor of about 12.
      expect(() => Region.fromWire('plain'), throwsArgumentError);
      expect(() => Region.fromWire(''), throwsArgumentError);
      expect(() => Region.fromWire('Hill'), throwsArgumentError);
    });
  });
}
