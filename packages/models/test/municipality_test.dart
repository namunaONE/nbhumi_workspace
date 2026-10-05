import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

void main() {
  group('Municipality', () {
    test('parses the wire shape', () {
      // Row shape copied from the live `municipalities` table.
      final municipality = Municipality.fromJson(<String, dynamic>{
        'id': 'm-ktm',
        'slug': 'kathmandu-kathmandu',
        'district': 'Kathmandu',
        'name': 'Kathmandu',
        'name_ne': 'काठमाडौं ।',
        'type': 'metropolitan',
        'ward_count': 32,
      });

      expect(municipality.slug, 'kathmandu-kathmandu');
      expect(municipality.district, 'Kathmandu');
      expect(municipality.type, MunicipalityType.metropolitan);
      expect(municipality.wardCount, 32);
      expect(municipality.hasMayor, isTrue);
    });

    test('parses the snake_case types', () {
      // The whole reason for explicit wire names: these differ from the Dart
      // names, and matching by `.name` would throw on exactly these two.
      expect(
        Municipality.fromJson(_wire(type: 'sub_metropolitan')).type,
        MunicipalityType.subMetropolitan,
      );
      expect(
        Municipality.fromJson(_wire(type: 'rural_municipality')).type,
        MunicipalityType.ruralMunicipality,
      );
    });

    test('tolerates a missing Nepali name', () {
      final wire = _wire()..remove('name_ne');
      expect(Municipality.fromJson(wire).nameNe, isNull);
    });

    test('rural municipalities have a chairperson, not a mayor', () {
      expect(
        Municipality.fromJson(_wire(type: 'rural_municipality')).hasMayor,
        isFalse,
      );
    });

    test('round-trips', () {
      const municipality = Municipality(
        id: 'm-pok',
        slug: 'kaski-pokhara',
        district: 'Kaski',
        name: 'Pokhara',
        type: MunicipalityType.metropolitan,
        wardCount: 33,
      );
      expect(Municipality.fromJson(municipality.toJson()), municipality);
    });
  });

  group('MunicipalityType.fromWire', () {
    test('parses all four values present in the database', () {
      expect(MunicipalityType.fromWire('metropolitan'),
          MunicipalityType.metropolitan);
      expect(MunicipalityType.fromWire('sub_metropolitan'),
          MunicipalityType.subMetropolitan);
      expect(MunicipalityType.fromWire('municipality'),
          MunicipalityType.municipality);
      expect(MunicipalityType.fromWire('rural_municipality'),
          MunicipalityType.ruralMunicipality);
    });

    test('wire name is never the camelCase Dart name where they differ', () {
      // The bug this guards: sending `status.name`-style values straight to an
      // RPC, which failed HYA-205's submit-for-review until wireName existed.
      expect(MunicipalityType.subMetropolitan.name,
          isNot(MunicipalityType.subMetropolitan.wireName));
      expect(MunicipalityType.ruralMunicipality.name,
          isNot(MunicipalityType.ruralMunicipality.wireName));
    });

    test('throws on anything else rather than defaulting', () {
      expect(() => MunicipalityType.fromWire('metro'), throwsArgumentError);
      expect(() => MunicipalityType.fromWire(''), throwsArgumentError);
    });

    test('every value round-trips through fromWire(wireName)', () {
      for (final type in MunicipalityType.values) {
        expect(MunicipalityType.fromWire(type.wireName), type);
      }
    });

    test('JSON encoding uses the wire name', () {
      // @JsonValue and wireName must not drift apart.
      final json =
          Municipality.fromJson(_wire(type: 'rural_municipality')).toJson();
      expect(json['type'], 'rural_municipality');
    });
  });
}

Map<String, dynamic> _wire({String type = 'metropolitan'}) =>
    <String, dynamic>{
      'id': 'm-1',
      'slug': 'kathmandu-kathmandu',
      'district': 'Kathmandu',
      'name': 'Kathmandu',
      'name_ne': 'काठमाडौं ।',
      'type': type,
      'ward_count': 32,
    };
