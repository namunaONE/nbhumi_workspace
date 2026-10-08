import 'package:freezed_annotation/freezed_annotation.dart';

part 'fraud_signal.freezed.dart';
part 'fraud_signal.g.dart';

/// One fraud signal on a listing, as `v1_admin_fraud_signals` reports it
/// (HYA-261).
///
/// A signal is never a verdict: `warning` means "look closer", `info` means
/// context (a computed fact or a missing input). There is deliberately no
/// `critical` -- nothing in the pipeline concludes fraud, only an admin does.
///
/// [code] names the check; [detail] carries its evidence (other listing ids,
/// computed unit prices) for the admin to judge. Unknown codes and severities
/// throw rather than default: guessing would mislabel the check.
@freezed
sealed class FraudSignal with _$FraudSignal {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory FraudSignal({
    required FraudSignalCode code,
    required String messageEn,
    required String messageNe,
    @Default(FraudSeverity.info) FraudSeverity severity,
    @Default(<String, dynamic>{}) Map<String, dynamic> detail,
  }) = _FraudSignal;

  factory FraudSignal.fromJson(Map<String, dynamic> json) =>
      _$FraudSignalFromJson(json);
}

/// The checks `v1_admin_fraud_signals` can report.
///
/// All six codes are live: `citizenshipReuse` fires when another profile
/// holds a verified citizenship document with the same file (kyc_documents
/// carries files, not numbers -- see the 3/3 migration header).
enum FraudSignalCode {
  /// Another listing shares a photo with this one.
  @JsonValue('duplicate_photo')
  duplicatePhoto('duplicate_photo'),

  /// Another listing carries the same kitta number.
  @JsonValue('duplicate_kitta')
  duplicateKitta('duplicate_kitta'),

  /// No kitta number was provided at all.
  @JsonValue('missing_kitta')
  missingKitta('missing_kitta'),

  /// Other accounts share the seller's normalized phone number.
  @JsonValue('same_phone_accounts')
  samePhoneAccounts('same_phone_accounts'),

  /// Price-per-sqm computed; warning when implausible for the area.
  @JsonValue('price_area')
  priceArea('price_area'),

  /// Live since the 3/3 migration: another profile holds a verified
  /// citizenship document with the same file as this seller. Same verified
  /// file behind two accounts -- kyc_documents carries files, not numbers,
  /// so this is the implementable form of number reuse.
  @JsonValue('citizenship_reuse')
  citizenshipReuse('citizenship_reuse');

  /// Creates a code with its RPC wire value.
  FraudSignalCode(this.wireName);

  /// The value the RPC sends.
  final String wireName;

  /// The code whose [wireName] is [value].
  ///
  /// Throws [ArgumentError] for an unknown value rather than defaulting:
  /// mislabeling a check is worse than failing loudly on a new one.
  static FraudSignalCode fromWire(String value) => values.firstWhere(
        (code) => code.wireName == value,
        orElse: () => throw ArgumentError.value(
          value,
          'value',
          'not a fraud signal code',
        ),
      );
}

/// How hard a [FraudSignal] asks for attention.
enum FraudSeverity {
  /// Context: a computed fact or a missing input. Not evidence.
  @JsonValue('info')
  info('info'),

  /// Look closer: a concrete overlap with another listing or account.
  @JsonValue('warning')
  warning('warning');

  /// Creates a severity with its RPC wire value.
  FraudSeverity(this.wireName);

  /// The value the RPC sends.
  final String wireName;

  /// The severity whose [wireName] is [value].
  ///
  /// Throws [ArgumentError] for an unknown value rather than defaulting to
  /// [info]: a warning downgraded to context would go unread.
  static FraudSeverity fromWire(String value) => values.firstWhere(
        (severity) => severity.wireName == value,
        orElse: () => throw ArgumentError.value(
          value,
          'value',
          'not a fraud signal severity',
        ),
      );
}

/// The signals on one listing: the listing id plus what the checks found.
///
/// An empty [signals] is a successful answer (nothing suspicious), not an
/// error -- the panel renders "no signals" rather than a failure.
@freezed
sealed class ListingFraudSignals with _$ListingFraudSignals {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ListingFraudSignals({
    required String listingId,
    @Default(<FraudSignal>[]) List<FraudSignal> signals,
  }) = _ListingFraudSignals;

  factory ListingFraudSignals.fromJson(Map<String, dynamic> json) =>
      _$ListingFraudSignalsFromJson(json);
}

/// Derived, non-wire facts about a [ListingFraudSignals].
extension ListingFraudSignalsX on ListingFraudSignals {
  /// Whether any check asks for a closer look.
  bool get hasWarnings =>
      signals.any((s) => s.severity == FraudSeverity.warning);

  /// The warnings only, in the order the RPC sent them.
  List<FraudSignal> get warnings => signals
      .where((s) => s.severity == FraudSeverity.warning)
      .toList(growable: false);
}
