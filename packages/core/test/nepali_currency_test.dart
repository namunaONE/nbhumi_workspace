import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NepaliCurrency.full', () {
    test('uses Indian lakh/crore grouping, not Western', () {
      // The whole point of Rule 27. Western grouping would give 15,000,000.
      expect(NepaliCurrency.fullBare(15000000), '1,50,00,000');
      expect(NepaliCurrency.fullBare(2500000), '25,00,000');
      expect(NepaliCurrency.fullBare(10000000), '1,00,00,000');
    });

    test('groups small numbers in threes', () {
      expect(NepaliCurrency.fullBare(0), '0');
      expect(NepaliCurrency.fullBare(999), '999');
      expect(NepaliCurrency.fullBare(1000), '1,000');
      expect(NepaliCurrency.fullBare(99999), '99,999');
      expect(NepaliCurrency.fullBare(100000), '1,00,000');
    });

    test('handles the crore threshold exactly', () {
      expect(NepaliCurrency.fullBare(9999999), '99,99,999');
      expect(NepaliCurrency.fullBare(10000000), '1,00,00,000');
    });

    test('prefixes with NPR', () {
      expect(NepaliCurrency.full(2500000), 'NPR 25,00,000');
    });

    test('keeps the sign outside the digits for negatives', () {
      expect(NepaliCurrency.fullBare(-2500000), '-25,00,000');
      expect(NepaliCurrency.full(-2500000), 'NPR -25,00,000');
    });
  });

  group('NepaliCurrency.compact', () {
    test('leaves amounts below one lakh fully written', () {
      // "NPR 0.85 Lakh" is worse than "NPR 85,000" for a 45k rent.
      expect(NepaliCurrency.compact(45000), 'NPR 45,000');
      expect(NepaliCurrency.compact(99999), 'NPR 99,999');
    });

    test('compacts lakhs with one decimal below ten', () {
      expect(NepaliCurrency.compact(100000), 'NPR 1 Lakh');
      expect(NepaliCurrency.compact(250000), 'NPR 2.5 Lakh');
      expect(NepaliCurrency.compact(850000), 'NPR 8.5 Lakh');
    });

    test('drops a trailing zero decimal', () {
      // 3.0 Cr is noise; 3 Cr is not.
      expect(NepaliCurrency.compact(30000000), 'NPR 3 Cr');
      expect(NepaliCurrency.compact(3000000), 'NPR 30 Lakh');
    });

    test('compacts crores with one decimal below ten', () {
      expect(NepaliCurrency.compact(10000000), 'NPR 1 Cr');
      expect(NepaliCurrency.compact(15000000), 'NPR 1.5 Cr');
      expect(NepaliCurrency.compact(850000000), 'NPR 85 Cr');
    });

    test('rounds to whole units above ten', () {
      expect(NepaliCurrency.compact(125000000), 'NPR 13 Cr');
      expect(NepaliCurrency.compact(12500000), 'NPR 1.3 Cr');
    });

    test('puts the sign after the currency, not before it', () {
      // "-NPR 1.5 Cr" reads as a deduction; "NPR -1.5 Cr" reads as a price.
      expect(NepaliCurrency.compact(-15000000), 'NPR -1.5 Cr');
      expect(NepaliCurrency.compact(-45000), 'NPR -45,000');
    });

    test('compactBare drops the prefix', () {
      expect(NepaliCurrency.compactBare(15000000), '1.5 Cr');
      expect(NepaliCurrency.compactBare(45000), '45,000');
      expect(NepaliCurrency.compactBare(-15000000), '-1.5 Cr');
    });

    test('a compact value is always shorter than the full one', () {
      // Cards are narrow; if this ever inverts, the compact format is wrong for
      // the place it is being used.
      const amounts = <int>[1000, 45000, 100000, 2500000, 15000000, 850000000];
      for (final amount in amounts) {
        expect(
          NepaliCurrency.compact(amount).length,
          lessThanOrEqualTo(NepaliCurrency.full(amount).length),
          reason: 'amount $amount',
        );
      }
    });
  });
}
