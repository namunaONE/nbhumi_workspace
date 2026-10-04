import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AreaConverter', () {
    test('hillToSqm converts correctly', () {
      // 1 ropani = 5476 sqm
      expect(AreaConverter.hillToSqm(ropani: 1), closeTo(5476.0, 0.1));
      // 1 aana = 342.25 sqm
      expect(AreaConverter.hillToSqm(aana: 1), closeTo(342.25, 0.1));
    });

    test('teraiToSqm converts correctly', () {
      // 1 bigha = 6772.63 sqm
      expect(AreaConverter.teraiToSqm(bigha: 1), closeTo(6772.63, 0.1));
      // 1 kattha = 338.63 sqm
      expect(AreaConverter.teraiToSqm(kattha: 1), closeTo(338.63, 0.1));
    });

    test('formatHill returns correct format', () {
      final result = AreaConverter.formatHill(5476);
      expect(result, contains('ropani'));
    });

    test('formatTerai returns correct format', () {
      final result = AreaConverter.formatTerai(6772.63);
      expect(result, contains('bigha'));
    });
  });
}
