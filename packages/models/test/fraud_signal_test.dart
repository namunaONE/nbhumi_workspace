import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Parsing tests for the HYA-261 fraud signals wire shape.
///
/// The RPC answers `{"listing_id": ..., "signals": [...]}`. Refusals matter
/// here: a new check the app does not know must fail loudly (an admin acting
/// on a mislabeled signal is worse than a crash in a test).
void main() {
  Map<String, dynamic> signalJson({
    String code = 'duplicate_photo',
    String severity = 'warning',
    Map<String, dynamic>? detail,
  }) =>
      <String, dynamic>{
        'code': code,
        'severity': severity,
        'message_en': 'Same photo appears on another listing.',
        'message_ne': 'उही फोटो अर्को लिस्टिङमा पनि देखिन्छ।',
        'detail': detail ?? <String, dynamic>{},
      };

  group('FraudSignalCode', () {
    test('wire names match the RPC codes exactly', () {
      expect(FraudSignalCode.duplicatePhoto.wireName, 'duplicate_photo');
      expect(FraudSignalCode.duplicateKitta.wireName, 'duplicate_kitta');
      expect(FraudSignalCode.missingKitta.wireName, 'missing_kitta');
      expect(
        FraudSignalCode.samePhoneAccounts.wireName,
        'same_phone_accounts',
      );
      expect(FraudSignalCode.priceArea.wireName, 'price_area');
    });

    test('fromWire round-trips every value', () {
      for (final code in FraudSignalCode.values) {
        expect(FraudSignalCode.fromWire(code.wireName), code);
      }
    });

    test('fromWire refuses an unknown code rather than guessing', () {
      expect(
        () => FraudSignalCode.fromWire('deepfake_seller'),
        throwsArgumentError,
      );
    });
  });

  group('FraudSeverity', () {
    test('fromWire refuses an unknown severity rather than downgrading', () {
      expect(() => FraudSeverity.fromWire('critical'), throwsArgumentError);
    });
  });

  group('FraudSignal.fromJson', () {
    test('parses a warning with its evidence', () {
      final signal = FraudSignal.fromJson(
        signalJson(
          detail: <String, dynamic>{
            'other_listing_ids': ['l2'],
          },
        ),
      );

      expect(signal.code, FraudSignalCode.duplicatePhoto);
      expect(signal.severity, FraudSeverity.warning);
      expect(signal.messageEn, isNotEmpty);
      expect(signal.messageNe, isNotEmpty);
      expect(signal.detail['other_listing_ids'], ['l2']);
    });

    test('severity defaults to info when absent', () {
      final json = signalJson()..remove('severity');

      expect(FraudSignal.fromJson(json).severity, FraudSeverity.info);
    });

    test('detail defaults to empty rather than null', () {
      final json = signalJson()..remove('detail');

      expect(FraudSignal.fromJson(json).detail, isEmpty);
    });

    test('an unknown code refuses rather than defaulting', () {
      expect(
        () => FraudSignal.fromJson(signalJson(code: 'poltergeist')),
        throwsA(anyOf([isArgumentError, isA<TypeError>()])),
      );
    });

    test('round-trips through toJson', () {
      final signal = FraudSignal.fromJson(signalJson());

      expect(FraudSignal.fromJson(signal.toJson()), signal);
    });
  });

  group('ListingFraudSignals.fromJson', () {
    test('parses the RPC envelope', () {
      final set = ListingFraudSignals.fromJson(<String, dynamic>{
        'listing_id': 'l1',
        'signals': <Map<String, dynamic>>[
          signalJson(),
          signalJson(code: 'missing_kitta', severity: 'info'),
        ],
      });

      expect(set.listingId, 'l1');
      expect(set.signals, hasLength(2));
    });

    test('an empty signals array is a successful answer', () {
      final set = ListingFraudSignals.fromJson(<String, dynamic>{
        'listing_id': 'l1',
        'signals': <Map<String, dynamic>>[],
      });

      expect(set.signals, isEmpty);
      expect(set.hasWarnings, isFalse);
    });

    test('hasWarnings is true when any check warns', () {
      final set = ListingFraudSignals.fromJson(<String, dynamic>{
        'listing_id': 'l1',
        'signals': [
          signalJson(code: 'missing_kitta', severity: 'info'),
          signalJson(),
        ],
      });

      expect(set.hasWarnings, isTrue);
      expect(
        set.warnings.map((s) => s.code),
        [FraudSignalCode.duplicatePhoto],
      );
    });
  });
}
