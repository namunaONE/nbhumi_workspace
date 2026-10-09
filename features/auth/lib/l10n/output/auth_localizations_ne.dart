// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'auth_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get title => 'साइन इन';

  @override
  String get paneLink => 'म्याजिक लिङ्क';

  @override
  String get panePassword => 'पासवर्ड';

  @override
  String get linkTitle => 'म्याजिक लिङ्कबाट साइन इन गर्नुहोस्';

  @override
  String get linkSubtitle =>
      'हामी साइन-इन लिङ्क इमेल गर्छौं। पासवर्ड सम्झनु पर्दैन।';

  @override
  String get passwordSignInTitle => 'आफ्नो पासवर्डबाट साइन इन गर्नुहोस्';

  @override
  String get passwordSignInSubtitle =>
      'पासवर्ड चाहनुहुन्न? लिङ्क ट्याबलाई इमेल मात्र चाहिन्छ।';

  @override
  String get signUpTitle => 'आफ्नो खाता बनाउनुहोस्';

  @override
  String get signUpSubtitle =>
      'पोस्ट गर्न र विक्रेतालाई सम्पर्क गर्न एउटै खाता।';

  @override
  String get resetTitle => 'आफ्नो पासवर्ड रिसेट गर्नुहोस्';

  @override
  String get resetSubtitle => 'नयाँ पासवर्ड छान्ने लिङ्क हामी इमेल गर्छौं।';

  @override
  String get emailLabel => 'इमेल';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get confirmLabel => 'पासवर्ड पुष्टि गर्नुहोस्';

  @override
  String get emailError => 'मान्य इमेल ठेगाना हाल्नुहोस्।';

  @override
  String passwordError(int min) {
    return 'कम्तीमा $min अक्षर।';
  }

  @override
  String get mismatchError => 'पासवर्ड मिलेन।';

  @override
  String get sending => 'पठाउँदैछ…';

  @override
  String resendIn(int seconds) {
    return '$seconds सेकेन्डमा पुनः पठाउनुहोस्';
  }

  @override
  String get sendLink => 'साइन-इन लिङ्क पठाउनुहोस्';

  @override
  String get resendLink => 'लिङ्क पुनः पठाउनुहोस्';

  @override
  String get signInAction => 'साइन इन';

  @override
  String get signUpAction => 'खाता बनाउनुहोस्';

  @override
  String get sendReset => 'रिसेट लिङ्क पठाउनुहोस्';

  @override
  String get resendReset => 'रिसेट लिङ्क पुनः पठाउनुहोस्';

  @override
  String get switchToSignUp => 'नयाँ हुनुहुन्छ? खाता बनाउनुहोस्';

  @override
  String get switchToSignIn => 'खाता छ? साइन इन गर्नुहोस्';

  @override
  String get forgotPassword => 'पासवर्ड बिर्सनुभयो?';

  @override
  String get backToSignIn => 'साइन इनमा फर्कनुहोस्';

  @override
  String sentLink(String email) {
    return 'इनबक्स जाँच गर्नुहोस् — $email मा साइन-इन लिङ्क जाँदैछ।';
  }

  @override
  String accountCreated(String email) {
    return '$email का लागि खाता बन्यो। पुष्टि चलेको छ भने साइन इन पूरा गर्न इमेल गरिएको लिङ्क थिच्नुहोस्।';
  }

  @override
  String resetSent(String email) {
    return 'इनबक्स जाँच गर्नुहोस् — $email मा रिसेट लिङ्क पठायौं।';
  }

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get callbackSignedIn => 'साइन इन भयो। होममा लैजाँदैछ…';

  @override
  String get callbackSigningIn => 'साइन इन हुँदैछ';

  @override
  String get callbackWorking => 'साइन इन गर्दैछ…';

  @override
  String get callbackSlowHint =>
      'केही सेकेन्डभन्दा बढी लागे लिङ्कको म्याद सकिएको वा प्रयोग भइसकेको हुन सक्छ। लगइन स्क्रिनबाट नयाँ माग्नुहोस्।';

  @override
  String get callbackBackToLogin => 'लगइनमा फर्कनुहोस्';

  @override
  String get callbackFailedTitle => 'साइन-इन लिङ्क असफल';

  @override
  String get callbackRequestNew => 'नयाँ लिङ्क माग्नुहोस्';

  @override
  String get newPasswordTitle => 'नयाँ पासवर्ड छान्नुहोस्';

  @override
  String newPasswordIntro(int min) {
    return 'आफ्नो खाताका लागि नयाँ पासवर्ड हाल्नुहोस्। कम्तीमा $min अक्षर।';
  }

  @override
  String get newPasswordLabel => 'नयाँ पासवर्ड';

  @override
  String get confirmNewLabel => 'नयाँ पासवर्ड पुष्टि गर्नुहोस्';

  @override
  String get saving => 'सेभ हुँदैछ…';

  @override
  String get savePassword => 'नयाँ पासवर्ड सेभ गर्नुहोस्';
}
