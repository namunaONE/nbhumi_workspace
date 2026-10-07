// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'search_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get title => 'खोज्नुहोस्';

  @override
  String get sortTooltip => 'क्रमबद्ध गर्नुहोस्';

  @override
  String get filtersTooltip => 'फिल्टरहरू';

  @override
  String get searchHint => 'शीर्षक वा स्थानबाट खोज्नुहोस्';

  @override
  String get saveSearchTooltip => 'यो खोजी सेभ गर्नुहोस्';

  @override
  String get signInToSave => 'खोजी सेभ गर्न साइन इन गर्नुहोस्।';

  @override
  String savedToast(String name) {
    return '\"$name\" सेभ भयो।';
  }

  @override
  String get noMatchTitle => 'कुनै विज्ञापन मिलेन';

  @override
  String get noMatchBody => 'फिल्टर हटाएर वा मूल्य दायरा फराकिलो पारी प्रयास गर्नुहोस्।';

  @override
  String get tryAgain => 'पुनः प्रयास गर्नुहोस्';

  @override
  String get feedRetryHint => 'इन्टरनेट जडान जाँच गरी पुनः प्रयास गर्नुहोस्।';

  @override
  String get feedLaterHint => 'तान्नुहोस् वा केही बेरपछि प्रयास गर्नुहोस्।';

  @override
  String get sheetTitle => 'फिल्टरहरू';

  @override
  String sheetClear(int count) {
    return '$count हटाउनुहोस्';
  }

  @override
  String get sheetCancel => 'रद्द गर्नुहोस्';

  @override
  String get sheetApply => 'लागू गर्नुहोस्';

  @override
  String get labelType => 'घरजग्गाको किसिम';

  @override
  String get labelPurpose => 'उद्देश्य';

  @override
  String get labelPrice => 'मूल्य दायरा (रू.)';

  @override
  String get labelArea => 'क्षेत्रफल (व.मि.)';

  @override
  String get labelSort => 'क्रम';

  @override
  String get labelDistrict => 'जिल्ला';

  @override
  String get fieldMin => 'न्यूनतम';

  @override
  String get fieldMax => 'अधिकतम';

  @override
  String get sortNewest => 'नयाँ पहिले';

  @override
  String get sortOldest => 'पुरानो पहिले';

  @override
  String get sortPriceAsc => 'मूल्य: कमदेखि बढी';

  @override
  String get sortPriceDesc => 'मूल्य: बढीदेखि कम';

  @override
  String get typeLand => 'जग्गा';

  @override
  String get typeHouse => 'घरहरू';

  @override
  String get typeApartment => 'अपार्टमेन्टहरू';

  @override
  String get typeVilla => 'भिल्लाहरू';

  @override
  String get typeCommercial => 'व्यावसायिक';

  @override
  String get typeBusiness => 'व्यवसायहरू';

  @override
  String get purposeSale => 'बिक्री';

  @override
  String get purposeRent => 'भाडा';

  @override
  String get purposeLease => 'लिज';

  @override
  String savedNameInDistrict(String district) {
    return '$districtमा';
  }

  @override
  String savedNameUnderPrice(String price) {
    return '$price मुनि';
  }

  @override
  String get savedNameFallback => 'अनुकूल खोजी';
}
