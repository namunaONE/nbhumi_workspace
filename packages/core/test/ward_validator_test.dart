import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// The constraint this must agree with, copied from the live database:
///
///   check (ward is null or ward ~ '^([1-9]|[12][0-9]|3[0-2])$')
///
/// Anything this accepts must survive that expression, or the user fills the
/// wizard in and then gets a server error for input the app called valid.
void main() {
  group('Validators.isValidWard agrees with the ward_valid CHECK', () {
    test('accepts every ward the constraint accepts', () {
      // Exhaustive over 1-32: cheaper to be certain here than to find the
      // boundary by hand.
      for (var ward = 1; ward <= Validators.maxWard; ward++) {
        expect(
          Validators.isValidWard('$ward'),
          isTrue,
          reason: 'ward $ward should be accepted',
        );
      }
    });

    test('rejects everything above the ceiling', () {
      for (final ward in <String>['33', '34', '36', '40', '99', '100']) {
        expect(
          Validators.isValidWard(ward),
          isFalse,
          reason: 'ward $ward should be rejected',
        );
      }
    });

    test('rejects zero and negatives', () {
      for (final ward in <String>['0', '-1', '-32']) {
        expect(Validators.isValidWard(ward), isFalse, reason: ward);
      }
    });

    test('rejects a leading zero, as the constraint does', () {
      // The subtle one. int.tryParse('01') is 1, so a parse-based check would
      // pass this and the database would then reject it with 23514.
      expect(Validators.isValidWard('01'), isFalse);
      expect(Validators.isValidWard('09'), isFalse);
      expect(Validators.isValidWard('032'), isFalse);
      // ...while the bare numbers are fine.
      expect(Validators.isValidWard('1'), isTrue);
      expect(Validators.isValidWard('9'), isTrue);
    });

    test('rejects surrounding and internal whitespace', () {
      for (final ward in <String>[' 5', '5 ', '1 2', '\t5']) {
        expect(Validators.isValidWard(ward), isFalse, reason: '"$ward"');
      }
    });

    test('rejects non-numeric and empty input', () {
      for (final ward in <String>['', ' ', 'abc', '5a', '5.0', '१२']) {
        expect(Validators.isValidWard(ward), isFalse, reason: '"$ward"');
      }
    });

    test('does not accept a value with a trailing newline', () {
      // A text field can produce this and the constraint would reject it.
      expect(Validators.isValidWard('5\n'), isFalse);
    });

    test('boundary values 1, 32 and the neighbours are exact', () {
      expect(Validators.isValidWard('1'), isTrue);
      expect(Validators.isValidWard('2'), isTrue);
      expect(Validators.isValidWard('31'), isTrue);
      expect(Validators.isValidWard('32'), isTrue);
      expect(Validators.isValidWard('33'), isFalse);
    });

    test('32 is the national maximum, not a round number', () {
      // Verified rather than assumed, after an earlier version of this suite
      // asserted KMC had 53 wards and used it to argue the ceiling was wrong.
      // It does not: Kathmandu Metropolitan City has 32 wards, the most of any
      // local body in Nepal, and the Local Government Act 2017 caps ordinary
      // municipalities and rural municipalities at 19.
      //
      // If a future ward-boundary reform creates a body with more than 32, this
      // test is the one that should fail first, along with the ward_valid
      // CHECK.
      expect(Validators.maxWard, 32);
      expect(Validators.isValidWard('32'), isTrue);
      expect(Validators.isValidWard('33'), isFalse);
    });
  });
}
