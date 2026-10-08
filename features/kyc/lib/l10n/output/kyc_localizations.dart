import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'kyc_localizations_en.dart';
import 'kyc_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'output/kyc_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// Identity verification screen app bar.
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get title;

  /// Disclaimer card heading.
  ///
  /// In en, this message translates to:
  /// **'How verification works'**
  String get howItWorks;

  /// Doc-check disclaimer (HYA-265 copy rule: never legal/title language).
  ///
  /// In en, this message translates to:
  /// **'Our team checks that your document photo is readable and matches your account. This is an identity check only — never a legal or land-title verification. Ownership transfers are completed at Malpot.'**
  String get howItWorksBody;

  /// Button opening the submit sheet.
  ///
  /// In en, this message translates to:
  /// **'Submit a document'**
  String get submitDocument;

  /// Shown when no documents submitted yet.
  ///
  /// In en, this message translates to:
  /// **'No documents yet. Submit your citizenship to earn the verified badge buyers look for.'**
  String get emptyBody;

  /// Submit sheet heading.
  ///
  /// In en, this message translates to:
  /// **'Choose a document'**
  String get chooseDocument;

  /// Submit sheet action.
  ///
  /// In en, this message translates to:
  /// **'Pick photo and submit'**
  String get pickAndSubmit;

  /// Submit sheet action while uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// Confirmation after a successful submission.
  ///
  /// In en, this message translates to:
  /// **'Submitted — we review within 48 hours.'**
  String get submitted;

  /// Citizenship document option.
  ///
  /// In en, this message translates to:
  /// **'Citizenship'**
  String get docCitizenship;

  /// Lalpurja document option.
  ///
  /// In en, this message translates to:
  /// **'Lalpurja (land ownership)'**
  String get docLalpurja;

  /// Agency registration option.
  ///
  /// In en, this message translates to:
  /// **'Agency registration'**
  String get docAgencyReg;

  /// Pending review row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get statusPending;

  /// Verified row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified — identity checked'**
  String get statusVerified;

  /// Rejected row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Rejected — submit a clearer photo'**
  String get statusRejected;

  /// Retry action (mirrors the app common strings; features cannot import them per Rule 10).
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Fallback when the failure carries no message.
  ///
  /// In en, this message translates to:
  /// **'Could not load your documents.'**
  String get loadFailed;

  /// Tier-3 submit sheet note (HYA-265).
  ///
  /// In en, this message translates to:
  /// **'This check attaches lalpurja to the listing you came from. Citizenship stays identity-only.'**
  String get tier3Hint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
