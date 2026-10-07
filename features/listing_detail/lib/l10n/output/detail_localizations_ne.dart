// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'detail_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get sectionLocation => 'स्थान';

  @override
  String get sectionDetails => 'विवरण';

  @override
  String get sectionDescription => 'वर्णन';

  @override
  String get sectionSeller => 'विक्रेता';

  @override
  String specRoadAccess(int feet) {
    return '$feet फिट बाटो';
  }

  @override
  String specBedrooms(int count) {
    return '$count शयनकक्ष';
  }

  @override
  String specBathrooms(int count) {
    return '$count स्नानगृह';
  }

  @override
  String specWard(String city, String ward) {
    return '$city, वडा $ward';
  }

  @override
  String get sellerUnavailable => 'विक्रेता विवरण उपलब्ध छैन';

  @override
  String get favoriteSave => 'यो घरजग्गा सेभ गर्नुहोस्';

  @override
  String get favoriteRemove => 'सेभबाट हटाउनुहोस्';

  @override
  String get favoriteSaved => 'तपाईंको सूचीमा सेभ भयो।';

  @override
  String get favoriteRemoved => 'सेभ सूचीबाट हटाइयो।';

  @override
  String get notAvailableTitle => 'यो घरजग्गा अब उपलब्ध छैन';

  @override
  String get notAvailableBody => 'यो बिकिसकेको, विक्रेताले फिर्ता लिएको वा लिङ्क गलत हुन सक्छ।';

  @override
  String get browseOthers => 'अन्य घरजग्गा हेर्नुहोस्';

  @override
  String get tryAgain => 'पुनः प्रयास गर्नुहोस्';

  @override
  String get loadRetryHint => 'इन्टरनेट जडान जाँच गरी पुनः प्रयास गर्नुहोस्।';

  @override
  String get contactLoading => 'लोड हुँदैछ…';

  @override
  String get contactSignIn => 'सम्पर्क गर्न साइन इन गर्नुहोस्';

  @override
  String get contactSeller => 'विक्रेता सम्पर्क';

  @override
  String get contactPhone => 'फोन';

  @override
  String get contactEmail => 'इमेल';

  @override
  String get contactCopy => 'प्रतिलिपि';

  @override
  String contactCopied(String label) {
    return '$label प्रतिलिपि भयो';
  }

  @override
  String get reportTooltip => 'रिपोर्ट गर्नुहोस्';

  @override
  String get reportFiled => 'रिपोर्ट गरियो। हाम्रो टोलीले हेर्नेछ।';

  @override
  String get reportTitle => 'यो लिस्टिङ रिपोर्ट गर्नुहोस्';

  @override
  String get reportReasonLabel => 'कारण';

  @override
  String get reportDetailsRequired => 'विवरण *';

  @override
  String get reportDetailsOptional => 'विवरण (वैकल्पिक)';

  @override
  String get reportDetailsError => 'कृपया समस्या बयान गर्नुहोस्, हाम्रो टोलीले कारबाही लिन सक्नेछ।';

  @override
  String get reportSubmit => 'रिपोर्ट पठाउनुहोस्';

  @override
  String get reasonDuplicate => 'डुप्लिकेट लिस्टिङ';

  @override
  String get reasonPhotos => 'फोटोहरू भ्रामक';

  @override
  String get reasonPrice => 'मूल्य शंकास्पद';

  @override
  String get reasonLocation => 'गलत ठेगाना';

  @override
  String get reasonSold => 'पहिल्यै बिकाइसक्यो';

  @override
  String get reasonOffsite => 'विक्रेताले बाहिर कारोबार गर्न भनेको';

  @override
  String get reasonFake => 'नक्कली लिस्टिङ';

  @override
  String get reasonOther => 'अन्य';

  @override
  String get typeLand => 'जग्गा';

  @override
  String get typeHouse => 'घर';

  @override
  String get typeApartment => 'अपार्टमेन्ट';

  @override
  String get typeVilla => 'भिल्ला';

  @override
  String get typeCommercial => 'व्यावसायिक';

  @override
  String get typeBusiness => 'व्यवसाय';

  @override
  String get purposeSale => 'बिक्री';

  @override
  String get purposeRent => 'भाडा';

  @override
  String get purposeLease => 'लिज';
}
