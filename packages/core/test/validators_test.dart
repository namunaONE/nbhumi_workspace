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

    test('isValidEmail validates correctly', () {
      expect(Validators.isValidEmail('test@example.com'), isTrue);
      expect(Validators.isValidEmail('invalid-email'), isFalse);
    });

    test('isValidPrice validates correctly', () {
      expect(Validators.isValidPrice(1000), isTrue);
      expect(Validators.isValidPrice(0), isFalse);
      expect(Validators.isValidPrice(-100), isFalse);
    });
  });
}
