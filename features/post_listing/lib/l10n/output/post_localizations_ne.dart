// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'post_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get stepType => 'घरजग्गाको किसिम';

  @override
  String get stepLocation => 'स्थान';

  @override
  String get stepSpecs => 'आकार र कोठाहरू';

  @override
  String get stepPrice => 'मूल्य र फोटोहरू';

  @override
  String get stepReview => 'समीक्षा';

  @override
  String get navBack => 'फर्कनुहोस्';

  @override
  String get navNext => 'अर्को';

  @override
  String get navSubmit => 'पेस गर्नुहोस्';

  @override
  String progressOf(int n, int total) {
    return 'चरण $n / $total';
  }

  @override
  String get districtsUnavailableTitle => 'जिल्ला लोड गर्न सकिएन';

  @override
  String get districtsUnavailableBody => 'इन्टरनेट जडान जाँच गरी पुनः प्रयास गर्नुहोस्।';

  @override
  String get sentForReview => 'समीक्षाका लागि पठाइयो। स्वीकृत भएपछि देखिनेछ।';

  @override
  String get typeQuestion => 'के सूची गर्दै हुनुहुन्छ?';

  @override
  String get purposeQuestion => 'कसरी बेच्न चाहनुहुन्छ?';

  @override
  String get purposeSell => 'बेच्नुहोस्';

  @override
  String get purposeRentOut => 'भाडामा';

  @override
  String get purposeLeaseTx => 'लिजमा';

  @override
  String get locationTitle => 'यो कहाँ छ?';

  @override
  String get locationSubtitle => 'जिल्लाले क्षेत्रफल रोपनी वा बिघामा हाल्ने भन्ने तय गर्छ।';

  @override
  String get fieldDistrict => 'जिल्ला';

  @override
  String get fieldMunicipality => 'नगरपालिका';

  @override
  String get fieldWard => 'वडा (वैकल्पिक)';

  @override
  String get wardNone => 'वडा छैन';

  @override
  String wardNumber(int number) {
    return 'वडा $number';
  }

  @override
  String get wardHint => 'वडा नम्बर १ देखि ३३ सम्म हुन्छ। नेपालमा सबैभन्दा धेरै वडा भएको स्थानीय तह पोखरा महानगरपालिका हो, ३३ वटा।';

  @override
  String get wardNoMunicipality => 'पहिले नगरपालिका छान्नुहोस्, अनि वडा छान्नुहोस्।';

  @override
  String get municipalitiesLoading => 'नगरपालिकाहरू';

  @override
  String loadingSuffix(String label) {
    return '$label लोड हुँदैछ…';
  }

  @override
  String get municipalitiesError => 'नगरपालिका लोड गर्न सकिएन। इन्टरनेट जडान जाँच गर्नुहोस्।';

  @override
  String get retryAction => 'पुनः प्रयास';

  @override
  String get fieldRoadAccess => 'बाटोको पहुँच';

  @override
  String get fieldOptional => 'वैकल्पिक';

  @override
  String get unitRopani => 'रोपनी';

  @override
  String get unitAana => 'आना';

  @override
  String get unitPaisa => 'पैसा';

  @override
  String get unitDam => 'दाम';

  @override
  String get unitBigha => 'बिघा';

  @override
  String get unitKattha => 'कठ्ठा';

  @override
  String get unitDhur => 'धुर';

  @override
  String get specsAreaTitle => 'क्षेत्रफल';

  @override
  String specsAreaHill(String district) {
    return '$district पहाडी जिल्ला हो। रोपनी, आना, पैसा वा दाम हाल्नुहोस्।';
  }

  @override
  String specsAreaTerai(String district) {
    return '$district तराई जिल्ला हो। बिघा, कठ्ठा वा धुर हाल्नुहोस्।';
  }

  @override
  String get specsNoDistrict => 'पहिले जिल्ला छान्नुहोस्। पहाडी जिल्लामा रोपनी र तराईमा बिघामा क्षेत्रफल हालिन्छ।';

  @override
  String get specsRooms => 'कोठाहरू';

  @override
  String get fieldBedrooms => 'शयनकक्ष';

  @override
  String get fieldBathrooms => 'स्नानगृह';

  @override
  String derivedArea(String sqm) {
    return 'जम्मा लगभग $sqm व.मि.। विज्ञापन व.मि.मा भण्डारण हुन्छ र तपाईंले हालेका एकाइमा देखिन्छ।';
  }

  @override
  String get priceTitle => 'माग मूल्य';

  @override
  String get fieldPrice => 'मूल्य';

  @override
  String buyersWillSee(String amount) {
    return 'खरीददारले $amount देख्नेछन्';
  }

  @override
  String get photosTitle => 'फोटोहरू';

  @override
  String get photosSubtitle => 'कम्तीमा एउटा थप्नुहोस्। फोटो भएका विज्ञापनमा धेरै सोधपुछ आउँछ।';

  @override
  String get removePhoto => 'फोटो हटाउनुहोस्';

  @override
  String get reviewTitle => 'आफ्नो विज्ञापन जाँच्नुहोस्';

  @override
  String get reviewSubtitle => 'सार्वजनिक हुनुअघि यसको समीक्षा हुनेछ।';

  @override
  String get reviewType => 'किसिम';

  @override
  String get reviewTitleRow => 'शीर्षक';

  @override
  String get reviewLocation => 'स्थान';

  @override
  String get reviewArea => 'क्षेत्रफल';

  @override
  String get reviewRooms => 'कोठाहरू';

  @override
  String get reviewPrice => 'मूल्य';

  @override
  String get reviewPhotos => 'फोटोहरू';

  @override
  String get reviewDescription => 'वर्णन';

  @override
  String get reviewNotSet => 'छैन';

  @override
  String get reviewNotApplicable => 'लागू हुँदैन';

  @override
  String reviewPhotosAdded(int count) {
    return '$count थपियो';
  }

  @override
  String get reviewContactNote => 'खरीददारले साइन इन गरेर अनुरोध गरेपछि मात्र तपाईंको सम्पर्क विवरण देख्छन्, त्यसैले तपाईंको नम्बर विज्ञापनमा कहिल्यै प्रकाशित हुँदैन।';

  @override
  String get reviewSubmit => 'समीक्षाका लागि पेस गर्नुहोस्';

  @override
  String get fieldPropertyType => 'घरजग्गाको किसिम';

  @override
  String get fieldPurpose => 'बिक्री, भाडा वा लिज';

  @override
  String requiredField(String label) {
    return '$label आवश्यक छ';
  }

  @override
  String crossDistrict(String name, String district) {
    return '$name $districtमा छैन';
  }

  @override
  String wardRange(int max) {
    return 'वडा १ देखि $max सम्मको नम्बर हुनुपर्छ';
  }

  @override
  String wardCount(String name, int count) {
    return '$nameमा $count वडा छन्';
  }

  @override
  String numberInvalid(String label) {
    return '$label संख्या हुनुपर्छ';
  }

  @override
  String numberNegative(String label) {
    return '$label नकारात्मक हुन सक्दैन';
  }

  @override
  String get areaWrongHill => 'यो जिल्लामा क्षेत्रफल पहाडी एकाइ (रोपनी, आना, पैसा, दाम) मा हुन्छ, बिघामा होइन';

  @override
  String get areaWrongTerai => 'यो जिल्लामा क्षेत्रफल तराई एकाइ (बिघा, कठ्ठा, धुर) मा हुन्छ, रोपनीमा होइन';

  @override
  String get areaHillEmpty => 'रोपनी, आना, पैसा वा दाममा क्षेत्रफल हाल्नुहोस्';

  @override
  String get areaTeraiEmpty => 'बिघा, कठ्ठा वा धुरमा क्षेत्रफल हाल्नुहोस्';

  @override
  String get bedroomsMin => 'शयनकक्ष १ वा बढी हुनुपर्छ';

  @override
  String get bathroomsMin => 'स्नानगृह १ वा बढी हुनुपर्छ';

  @override
  String get priceInvalid => 'मूल्य शून्यभन्दा बढी हुनुपर्छ';

  @override
  String get photosRequired => 'कम्तीमा एउटा फोटो थप्नुहोस्';

  @override
  String get chipLand => 'जग्गा';

  @override
  String get chipHouse => 'घर';

  @override
  String get chipApartment => 'अपार्टमेन्ट';

  @override
  String get chipVilla => 'भिल्ला';

  @override
  String get chipCommercial => 'व्यावसायिक';

  @override
  String get chipBusiness => 'व्यवसाय';
}
