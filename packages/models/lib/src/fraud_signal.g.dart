// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fraud_signal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FraudSignal _$FraudSignalFromJson(Map<String, dynamic> json) => _FraudSignal(
  code: $enumDecode(_$FraudSignalCodeEnumMap, json['code']),
  messageEn: json['message_en'] as String,
  messageNe: json['message_ne'] as String,
  severity:
      $enumDecodeNullable(_$FraudSeverityEnumMap, json['severity']) ??
      FraudSeverity.info,
  detail: json['detail'] as Map<String, dynamic>? ?? const <String, dynamic>{},
);

Map<String, dynamic> _$FraudSignalToJson(_FraudSignal instance) =>
    <String, dynamic>{
      'code': _$FraudSignalCodeEnumMap[instance.code]!,
      'message_en': instance.messageEn,
      'message_ne': instance.messageNe,
      'severity': _$FraudSeverityEnumMap[instance.severity]!,
      'detail': instance.detail,
    };

const _$FraudSignalCodeEnumMap = {
  FraudSignalCode.duplicatePhoto: 'duplicate_photo',
  FraudSignalCode.duplicateKitta: 'duplicate_kitta',
  FraudSignalCode.missingKitta: 'missing_kitta',
  FraudSignalCode.samePhoneAccounts: 'same_phone_accounts',
  FraudSignalCode.priceArea: 'price_area',
  FraudSignalCode.citizenshipReuse: 'citizenship_reuse',
};

const _$FraudSeverityEnumMap = {
  FraudSeverity.info: 'info',
  FraudSeverity.warning: 'warning',
};

_ListingFraudSignals _$ListingFraudSignalsFromJson(Map<String, dynamic> json) =>
    _ListingFraudSignals(
      listingId: json['listing_id'] as String,
      signals:
          (json['signals'] as List<dynamic>?)
              ?.map((e) => FraudSignal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FraudSignal>[],
    );

Map<String, dynamic> _$ListingFraudSignalsToJson(
  _ListingFraudSignals instance,
) => <String, dynamic>{
  'listing_id': instance.listingId,
  'signals': instance.signals,
};
