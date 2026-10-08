import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'output/app_localizations.dart';
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

  /// App name shown in the expanded drawer header.
  ///
  /// In en, this message translates to:
  /// **'nBhumi'**
  String get appTitle;

  /// Bottom navigation: browse feed tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation: search tab.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Bottom navigation: saved listings tab.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// Bottom navigation: account tab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Retry action on error snackbars and cards (Rule 36).
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Dialog cancel action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Dialog close action.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Sign-in button for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get commonSignIn;

  /// Profile screen app bar.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Account row when no session exists.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get profileSignedOut;

  /// Prompt under the signed-out account row.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a magic link to post a property'**
  String get profileSignedOutHint;

  /// Subtitle of the account row with an active session.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get profileSignedIn;

  /// Entry tile to the post-listing wizard.
  ///
  /// In en, this message translates to:
  /// **'Post a property'**
  String get profilePostTitle;

  /// Subtitle of the post-listing entry tile.
  ///
  /// In en, this message translates to:
  /// **'Create a listing for review'**
  String get profilePostSubtitle;

  /// Entry tile to identity verification (HYA-264).
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get profileKycTitle;

  /// Subtitle of the verification entry tile.
  ///
  /// In en, this message translates to:
  /// **'Citizenship check for the seller badge'**
  String get profileKycSubtitle;

  /// Entry tile to the notification inbox (HYA-242).
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifTitle;

  /// Subtitle of the notifications entry tile.
  ///
  /// In en, this message translates to:
  /// **'Approvals, rejections and contact views'**
  String get profileNotifSubtitle;

  /// Saved tab app bar.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// Shown to signed-out visitors of the Saved tab.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save properties'**
  String get savedGuestPrompt;

  /// Empty shelf heading.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedEmptyTitle;

  /// Empty shelf explanation.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any property to keep it here.'**
  String get savedEmptyBody;

  /// Saved-searches section header in the Saved tab.
  ///
  /// In en, this message translates to:
  /// **'Saved searches'**
  String get savedSearchesTitle;

  /// Tooltip of the saved-search delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete saved search'**
  String get savedSearchDelete;

  /// Profile loading row.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get profileLoading;

  /// Subtitle of the guest sign-in tile.
  ///
  /// In en, this message translates to:
  /// **'We email you a link, no password needed'**
  String get profileSignInHint;

  /// About section heading.
  ///
  /// In en, this message translates to:
  /// **'About nBhumi'**
  String get profileAboutTitle;

  /// About section copy.
  ///
  /// In en, this message translates to:
  /// **'We facilitate listings only. Ownership transfers are completed at Malpot.'**
  String get profileAboutBody;

  /// Privacy Act footnote.
  ///
  /// In en, this message translates to:
  /// **'nBhumi collects the minimum information needed to operate a marketplace, in line with the Privacy Act 2075 (2018).'**
  String get profilePrivacyNote;

  /// Edit-profile dialog title and entry tile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// Full-name field label.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileEditName;

  /// Phone field label.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get profileEditPhone;

  /// Phone field hint.
  ///
  /// In en, this message translates to:
  /// **'98XXXXXXXX'**
  String get profileEditPhoneHint;

  /// Invalid phone message.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit mobile starting 97 or 98'**
  String get profileEditPhoneError;

  /// Agency name field label.
  ///
  /// In en, this message translates to:
  /// **'Agency name (optional)'**
  String get profileEditAgency;

  /// Agency registration number field label.
  ///
  /// In en, this message translates to:
  /// **'Agency registration no. (optional)'**
  String get profileEditRegNo;

  /// Dialog save action.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Copy-to-clipboard action.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// Export-data entry tile.
  ///
  /// In en, this message translates to:
  /// **'Download my data'**
  String get profileDownloadTitle;

  /// Export-data subtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile, listings and reveal history as JSON'**
  String get profileDownloadSubtitle;

  /// Snackbar while the export assembles.
  ///
  /// In en, this message translates to:
  /// **'Preparing your data…'**
  String get profilePreparingData;

  /// Export dialog title.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get profileExportTitle;

  /// Confirmation after copying the export.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get profileCopied;

  /// Sign-out entry tile.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutTitle;

  /// Sign-out subtitle.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in with a magic link any time'**
  String get profileSignOutSubtitle;

  /// Delete-account entry tile, confirm button and dialog action.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get profileDeleteTitle;

  /// Delete-account subtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanent. Listings stay up without your name'**
  String get profileDeleteSubtitle;

  /// First delete-confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get profileDeleteConfirmTitle;

  /// First deletion consequence.
  ///
  /// In en, this message translates to:
  /// **'Your profile and sign-in are removed permanently.'**
  String get profileDeleteC1;

  /// Second deletion consequence.
  ///
  /// In en, this message translates to:
  /// **'Your listings stay up, but without your name on them.'**
  String get profileDeleteC2;

  /// Third deletion consequence.
  ///
  /// In en, this message translates to:
  /// **'Your contact-reveal history is kept without your identity, as required for marketplace safety records.'**
  String get profileDeleteC3;

  /// Irreversibility warning.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get profileDeleteFinal;

  /// First dialog continue action.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get profileDeleteContinue;

  /// Type-to-confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get profileTypeDeleteTitle;

  /// Profile-saved confirmation without a name.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profileSaved;

  /// Profile-saved confirmation with the saved name.
  ///
  /// In en, this message translates to:
  /// **'Saved — {name}'**
  String profileSavedAs(String name);

  /// Onboarding headline.
  ///
  /// In en, this message translates to:
  /// **'Buy and sell property across Nepal'**
  String get onboardingTagline;

  /// First onboarding feature.
  ///
  /// In en, this message translates to:
  /// **'Search in your own units'**
  String get onboardingSearchTitle;

  /// First onboarding feature body.
  ///
  /// In en, this message translates to:
  /// **'Filter by district, price and area in ropani, aana or bigha depending on the region.'**
  String get onboardingSearchBody;

  /// Second onboarding feature.
  ///
  /// In en, this message translates to:
  /// **'Verified sellers'**
  String get onboardingVerifiedTitle;

  /// Second onboarding feature body.
  ///
  /// In en, this message translates to:
  /// **'Sellers who have had their identity documents checked carry a verified badge.'**
  String get onboardingVerifiedBody;

  /// Third onboarding feature.
  ///
  /// In en, this message translates to:
  /// **'Post your property'**
  String get onboardingPostTitle;

  /// Third onboarding feature body.
  ///
  /// In en, this message translates to:
  /// **'Add photos and details. A reviewer checks each listing before it goes live.'**
  String get onboardingPostBody;

  /// Legal disclaimer (DATA.md requires it visible).
  ///
  /// In en, this message translates to:
  /// **'nBhumi helps people advertise and find property. It is not a broker and does not handle money. Ownership transfers are completed at Malpot with the concerned authorities.'**
  String get onboardingDisclaimer;

  /// Onboarding primary action.
  ///
  /// In en, this message translates to:
  /// **'Browse listings'**
  String get onboardingBrowse;

  /// Profile identity section heading.
  ///
  /// In en, this message translates to:
  /// **'Contact details'**
  String get profileContactTitle;

  /// Email row helper: email is auth-owned and read-only.
  ///
  /// In en, this message translates to:
  /// **'Managed by sign-in · cannot be changed here'**
  String get profileContactEmailLocked;

  /// Phone row when no phone is set.
  ///
  /// In en, this message translates to:
  /// **'Add phone'**
  String get profileContactPhoneMissing;

  /// Phone row helper with the Nepali mobile rule.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile starting 97 or 98'**
  String get profileContactAddPhoneHint;

  /// Role chip label.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get profileRoleBuyer;

  /// Role chip label.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get profileRoleAgent;

  /// Role chip label.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get profileRoleAdmin;

  /// KYC tier chip label.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get profileKycNone;

  /// KYC tier chip label.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileKycAccount;

  /// KYC tier chip label.
  ///
  /// In en, this message translates to:
  /// **'Identity verified'**
  String get profileKycIdentity;

  /// KYC tier chip label.
  ///
  /// In en, this message translates to:
  /// **'Property verified'**
  String get profileKycProperty;

  /// Agency section heading.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get profileAgencyTitle;

  /// Agency section subtitle when no agency is set.
  ///
  /// In en, this message translates to:
  /// **'Optional · shown on your listings'**
  String get profileAgencySubtitle;

  /// What agency fields mean and what they do not prove.
  ///
  /// In en, this message translates to:
  /// **'Your agency name appears on listings you post. Filling this in does not verify you — upload your registration certificate in Verify identity to earn the agency badge.'**
  String get profileAgencyExplainer;

  /// CTA from the agency card to the KYC screen.
  ///
  /// In en, this message translates to:
  /// **'Verify agency documents'**
  String get profileAgencyVerifyCta;

  /// Hint when agency text exists but no agency_reg doc is verified.
  ///
  /// In en, this message translates to:
  /// **'Not yet verified'**
  String get profileAgencyUnverifiedHint;

  /// Entry tile to the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsTitle;

  /// Settings entry subtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, theme and about'**
  String get profileSettingsSubtitle;

  /// Settings screen app bar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Language section heading.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// English option.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// Nepali option.
  ///
  /// In en, this message translates to:
  /// **'नेपाली'**
  String get settingsLanguageNe;

  /// Theme section heading.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsThemeTitle;

  /// Follow-system theme option.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;
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
