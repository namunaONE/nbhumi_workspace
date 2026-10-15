import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('isValidNepaliPhone validates correctly', () {
      expect(Validators.isValidNepaliPhone('9841234567'), isTrue);
      expect(Validators.isValidNepaliPhone('9741234567'), isTrue);
      expect(Validators.isValidNepaliPhone('1234567890'), isFalse);
      expect(Validators.isValidNepaliPhone('984123456'), isFalse);
    });

    test('canonicalNepaliPhone strips E.164 prefixes', () {
      // Existing rows and pasted numbers carry '+977'; stored values do not.
      expect(
        Validators.canonicalNepaliPhone('+9779841234567'),
        '9841234567',
      );
      expect(
        Validators.canonicalNepaliPhone('  +9779841234567  '),
        '9841234567',
      );
      // Already canonical: untouched.
      expect(
        Validators.canonicalNepaliPhone('9841234567'),
        '9841234567',
      );
    });

    test('canonicalNepaliPhone never mangles a local number', () {
      // '977' is stripped only when exactly 10 digits remain. A 10-digit
      // local number that happens to start in 977 keeps every digit.
      expect(
        Validators.canonicalNepaliPhone('9771234567'),
        '9771234567',
      );
      // And garbage passes through unchanged for the validator to reject.
      expect(Validators.canonicalNepaliPhone('abc'), 'abc');
      expect(Validators.canonicalNepaliPhone(''), '');
    });

    test('canonical output always validates when input is salvageable', () {
      for (final raw in <String>[
        '+9779841234567',
        '9841234567',
        '  9741234567 ',
      ]) {
        expect(
          Validators.isValidNepaliPhone(Validators.canonicalNepaliPhone(raw)),
          isTrue,
          reason: raw,
        );
      }
    });

    test('isValidEmail validates correctly', () {
      expect(Validators.isValidEmail('test@example.com'), isTrue);
      expect(Validators.isValidEmail('invalid-email'), isFalse);
    });

    test('isValidPassword enforces the minimum length', () {
      expect(Validators.isValidPassword('correct horse'), isTrue);
      expect(Validators.isValidPassword('12345678'), isTrue);
      expect(Validators.isValidPassword('1234567'), isFalse);
      expect(Validators.isValidPassword(''), isFalse);
    });

    test('isValidPrice validates correctly', () {
      expect(Validators.isValidPrice(1000), isTrue);
      expect(Validators.isValidPrice(0), isFalse);
      expect(Validators.isValidPrice(-100), isFalse);
    });

    test('amenity tags enforce count and length caps', () {
      expect(Validators.maxAmenities, 20);
      expect(Validators.maxAmenityLength, 40);
      expect(Validators.isValidAmenity('Drinking water'), isTrue);
      expect(Validators.isValidAmenity('  Balcony  '), isTrue);
      expect(Validators.isValidAmenity(''), isFalse);
      expect(Validators.isValidAmenity('   '), isFalse);
      expect(Validators.isValidAmenity('x' * 41), isFalse);
      expect(Validators.isValidAmenity('x' * 40), isTrue);
    });

    test('canonicalAmenities trims and drops empties, keeping order', () {
      expect(
        Validators.canonicalAmenities(['  Water ', '', 'Balcony', '  ']),
        <String>['Water', 'Balcony'],
      );
    });
  });
}
