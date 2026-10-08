// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'kyc_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get title => 'पहिचान प्रमाणित गर्नुहोस्';

  @override
  String get howItWorks => 'प्रमाणीकरण कसरी हुन्छ';

  @override
  String get howItWorksBody =>
      'हाम्रो टोलीले तपाईंको कागजातको फोटो पढ्न सकिने र तपाईंको खातासँग मिलेको छ कि छैन भनेर जाँच्छ। यो पहिचान जाँच मात्र हो — कानुनी वा जग्गा-स्वामित्व प्रमाणीकरण कहिल्यै होइन। स्वामित्व हस्तान्तरण मालपोतमा हुन्छ।';

  @override
  String get submitDocument => 'कागजात पेस गर्नुहोस्';

  @override
  String get emptyBody =>
      'अहिलेसम्म कागजात छैन। खरीददारले खोज्ने प्रमाणित ब्याजका लागि आफ्नो नागरिकता पेस गर्नुहोस्।';

  @override
  String get chooseDocument => 'कागजात छान्नुहोस्';

  @override
  String get pickAndSubmit => 'फोटो छानेर पेस गर्नुहोस्';

  @override
  String get uploading => 'अपलोड हुँदैछ…';

  @override
  String get submitted => 'पेस भयो — हामी ४८ घण्टाभित्र समीक्षा गर्छौं।';

  @override
  String get docCitizenship => 'नागरिकता';

  @override
  String get docLalpurja => 'लालपुर्जा (जग्गा स्वामित्व)';

  @override
  String get docAgencyReg => 'एजेन्सी दर्ता';

  @override
  String get statusPending => 'समीक्षामा छ';

  @override
  String get statusVerified => 'प्रमाणित — पहिचान जाँच भयो';

  @override
  String get statusRejected => 'अस्वीकृत — स्पष्ट फोटो पेस गर्नुहोस्';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get loadFailed => 'तपाईंका कागजात लोड गर्न सकिएन।';

  @override
  String get tier3Hint =>
      'यो जाँच तपाईं आएको विज्ञापनमा लालपुर्जा जोड्छ। नागरिकता पहिचानका लागि मात्र हो।';
}
