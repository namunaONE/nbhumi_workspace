import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

void main() {
  group('District', () {
    test('parses the wire shape', () {
      // Row shape copied from the live `districts` table: `id` and
      // `province` are smallint, not text. A previous revision of this test
      // used strings here, which is exactly how the model shipped with
      // `String` fields and the wizard's district dropdown never loaded.
      final district = District.fromJson(<String, dynamic>{
        'id': 29,
        'name': 'Kathmandu',
        'province': 3,
        'region': 'hill',
      });

      expect(district.id, 29);
      expect(district.name, 'Kathmandu');
      expect(district.province, 3);
      expect(district.provinceName, 'Bagmati');
      expect(district.region, Region.hill);
      expect(district.isHill, isTrue);
    });

    test('round-trips', () {
      const district = District(
        id: 35,
        name: 'Chitwan',
        province: 3,
        region: Region.terai,
      );
      expect(District.fromJson(district.toJson()), district);
    });

    test('isHill is false for terai', () {
      const terai = District(
        id: 12,
        name: 'Jhapa',
        province: 1,
        region: Region.terai,
      );
      expect(terai.isHill, isFalse);
      expect(terai.provinceName, 'Koshi');
    });

    test('provinceName covers all seven provinces', () {
      const expected = <int, String>{
        1: 'Koshi',
        2: 'Madhesh',
        3: 'Bagmati',
        4: 'Gandaki',
        5: 'Lumbini',
        6: 'Karnali',
        7: 'Sudurpashchim',
      };
      for (final entry in expected.entries) {
        expect(
          District(
            id: entry.key,
            name: 'probe',
            province: entry.key,
            region: Region.hill,
          ).provinceName,
          entry.value,
        );
      }
    });

    test('provinceName throws outside 1-7 rather than defaulting', () {
      // Defaulting would group a corrupt row under a wrong province name.
      expect(
        () => const District(
          id: 0,
          name: 'probe',
          province: 0,
          region: Region.hill,
        ).provinceName,
        throwsArgumentError,
      );
      expect(
        () => const District(
          id: 0,
          name: 'probe',
          province: 8,
          region: Region.hill,
        ).provinceName,
        throwsArgumentError,
      );
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
