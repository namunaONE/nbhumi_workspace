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
  String get notAvailableBody =>
      'यो बिकिसकेको, विक्रेताले फिर्ता लिएको वा लिङ्क गलत हुन सक्छ।';

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
  String get reportDetailsError =>
      'कृपया समस्या बयान गर्नुहोस्, हाम्रो टोलीले कारबाही लिन सक्नेछ।';

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

  @override
  String get verifiedListing => 'प्रमाणित विज्ञापन';

  @override
  String get verifiedListingBody =>
      'हाम्रो प्रशासक टोलीले यस विज्ञापनसँग सम्बन्धित लालपुर्जा जाँचेको छ। यो कागजात जाँच मात्र हो — स्वामित्व वा मोहियानी हकको कानुनी प्रमाणीकरण होइन। स्वामित्व हस्तान्तरण मालपोतमा हुन्छ।';

  @override
  String get verifiedListingUnderstood => 'बुझें';

  @override
  String get detailPageTitle => 'सम्पत्ति विवरण';

  @override
  String get verifyThisListing => 'यो विज्ञापन प्रमाणित गर्नुहोस्';

  @override
  String specParking(int count) {
    return '$count पार्किङ स्थान';
  }

  @override
  String get sectionLeaseTerms => 'लिजका सर्तहरू';

  @override
  String specLeaseTerm(int months) {
    return '$months महिना';
  }

  @override
  String get termRenewable => 'नवीकरण हुन सक्छ';

  @override
  String get termNotRenewable => 'नवीकरण हुन सक्दैन';

  @override
  String get sectionRentalTerms => 'भाडाका सर्तहरू';

  @override
  String specDeposit(String amount) {
    return 'जमानत $amount';
  }

  @override
  String specAvailableFrom(String date) {
    return '$date देखि उपलब्ध';
  }

  @override
  String specFurnishing(String level) {
    return '$level';
  }

  @override
  String get furnishingUnfurnished => 'खाली';

  @override
  String get furnishingSemiFurnished => 'आंशिक सुसज्जित';

  @override
  String get furnishingFurnished => 'पूर्ण सुसज्जित';

  @override
  String specPetPolicy(String policy) {
    return 'पाल्तु जनावर: $policy';
  }

  @override
  String get petNotAllowed => 'पाल्तु जनावर छैन';

  @override
  String get petCatsOk => 'बिरालो चल्छ';

  @override
  String get petDogsOk => 'कुकुर चल्छ';

  @override
  String get petAllPets => 'सबै पाल्तु चल्छ';

  @override
  String get petNegotiable => 'मिलाउन सकिन्छ';

  @override
  String get sectionBuilding => 'भवन';

  @override
  String specFloor(int floor) {
    return 'तला $floor';
  }

  @override
  String specFloorOf(int floor, int total) {
    return '$total तलामध्ये तला $floor';
  }

  @override
  String specAge(int years) {
    return '$years वर्ष पुरानो';
  }

  @override
  String specConstruction(String status) {
    return '$status';
  }

  @override
  String get constructionNew => 'नयाँ निर्माण';

  @override
  String get constructionUnderConstruction => 'निर्माणाधीन';

  @override
  String get constructionResale => 'पुनर्विक्रय';

  @override
  String get title => 'पहिचान प्रमाणित गर्नुहोस्';

  @override
  String get howItWorks => 'यसरी काम गर्छ';

  @override
  String get howItWorksBody =>
      'हाम्रो प्रशासक टोली तपाईंको नागरिकता र जमिन कागजात जाँच गर्छ। अनुमोदन भएपछि तपाईंको लिस्टिङमा प्रमाणित ब्याज देखिनेछ।';

  @override
  String get chooseDocument => 'कागजात प्रकार छान्नुहोस्';

  @override
  String get docCitizenship => 'नागरिकता';

  @override
  String get docLalpurja => 'लालपुर्जा (जमिन स्वामित्व)';

  @override
  String get docAgencyReg => 'एजेन्सी दर्ता';

  @override
  String get pickAndSubmit => 'फाइल छान्न र पेश गर्नुहोस्';

  @override
  String get uploading => 'अपलोड हुँदैछ…';

  @override
  String get submitted => 'समीक्षाका लागि पेश गरियो';

  @override
  String get emptyTitle => 'कागजात छैनन्';

  @override
  String get emptyBody =>
      'प्रमाणीकरण सुरु गर्न आफ्नो नागरिकता र जमिन कागजात अपलोड गर्नुहोस्।';

  @override
  String get loadFailed => 'कागजात लोड गर्न सकिएन';

  @override
  String get retry => 'पुनः प्रयास गर्नुहोस्';

  @override
  String get statusPending => 'समीक्षा बाँकी';

  @override
  String get statusVerified => 'प्रमाणित';

  @override
  String get statusRejected => 'अस्वीकृत';

  @override
  String get tier3Hint =>
      'यस विज्ञापन प्रमाणित गर्न लालपुर्जा + तिरो रसिद जोड्नुहोस्';

  @override
  String get submitDocument => 'कागजात पेश गर्नुहोस्';

  @override
  String get facingNorth => 'उत्तर';

  @override
  String get facingNorthEast => 'उत्तर-पूर्व';

  @override
  String get facingEast => 'पूर्व';

  @override
  String get facingSouthEast => 'दक्षिण-पूर्व';

  @override
  String get facingSouth => 'दक्षिण';

  @override
  String get facingSouthWest => 'दक्षिण-पश्चिम';

  @override
  String get facingWest => 'पश्चिम';

  @override
  String get facingNorthWest => 'उत्तर-पश्चिम';

  @override
  String specFacing(String direction) {
    return '$direction मोहोडा';
  }

  @override
  String get sectionAmenities => 'सुविधाहरू';
}
