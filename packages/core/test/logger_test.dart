import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// HYA-239 flavor contract: dev and staging log everything, prod only
/// warnings and errors. Unknown environments fail open to verbose — a
/// misconfigured build must never swallow an error.
void main() {
  group('AppLogger.minLevelFor', () {
    test('dev emits everything from debug up', () {
      expect(AppLogger.minLevelFor('dev'), 500);
    });

    test('staging is verbose like dev', () {
      expect(AppLogger.minLevelFor('staging'), 500);
    });

    test('prod is minimal: warning and error only', () {
      expect(AppLogger.minLevelFor('prod'), 900);
    });

    test('unknown environments fail open to verbose', () {
      expect(AppLogger.minLevelFor(''), 500);
      expect(AppLogger.minLevelFor('production'), 500);
      expect(AppLogger.minLevelFor('PROD'), 500);
    });
  });
}
