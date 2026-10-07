import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'auth_localizations_en.dart';
import 'auth_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'output/auth_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne')
  ];

  /// Login screen app bar.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get title;

  /// Magic-link pane segment.
  ///
  /// In en, this message translates to:
  /// **'Magic link'**
  String get paneLink;

  /// Password pane segment.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get panePassword;

  /// Magic-link pane heading.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a magic link'**
  String get linkTitle;

  /// Magic-link pane explanation.
  ///
  /// In en, this message translates to:
  /// **'We email you a sign-in link. No password to remember.'**
  String get linkSubtitle;

  /// Password sign-in heading.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your password'**
  String get passwordSignInTitle;

  /// Password sign-in explanation.
  ///
  /// In en, this message translates to:
  /// **'Prefer no password? The link tab needs only email.'**
  String get passwordSignInSubtitle;

  /// Account creation heading.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signUpTitle;

  /// Account creation explanation.
  ///
  /// In en, this message translates to:
  /// **'One account for posting and contacting sellers.'**
  String get signUpSubtitle;

  /// Password reset heading.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetTitle;

  /// Password reset explanation.
  ///
  /// In en, this message translates to:
  /// **'We email you a link to choose a new password.'**
  String get resetSubtitle;

  /// Email field label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Password field label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Confirm-password field label.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmLabel;

  /// Invalid email message.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailError;

  /// Short password message.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters.'**
  String passwordError(int min);

  /// Password mismatch message.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get mismatchError;

  /// Submit button while busy.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get sending;

  /// Cooldown submit button.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// Send magic link action.
  ///
  /// In en, this message translates to:
  /// **'Send sign-in link'**
  String get sendLink;

  /// Resend magic link action.
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get resendLink;

  /// Password sign-in action.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAction;

  /// Account creation action.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpAction;

  /// Send reset link action.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendReset;

  /// Resend reset link action.
  ///
  /// In en, this message translates to:
  /// **'Resend reset link'**
  String get resendReset;

  /// Toggle to account creation.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get switchToSignUp;

  /// Toggle back to sign-in.
  ///
  /// In en, this message translates to:
  /// **'Have an account? Sign in'**
  String get switchToSignIn;

  /// Forgot-password toggle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// Back-to-sign-in toggle.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// Magic link sent confirmation.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox — a sign-in link is on its way to {email}.'**
  String sentLink(String email);

  /// Account created confirmation.
  ///
  /// In en, this message translates to:
  /// **'Account created for {email}. If confirmation is on, tap the emailed link to finish signing in.'**
  String accountCreated(String email);

  /// Reset link sent confirmation.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox — we sent a reset link to {email}.'**
  String resetSent(String email);

  /// Retry action (mirrors the app common strings; features cannot import them per Rule 10).
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Signed-in bounce message.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Taking you home…'**
  String get callbackSignedIn;

  /// Signing-in app bar.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get callbackSigningIn;

  /// Signing-in heading.
  ///
  /// In en, this message translates to:
  /// **'Signing you in…'**
  String get callbackWorking;

  /// Slow-exchange explanation.
  ///
  /// In en, this message translates to:
  /// **'If this takes more than a few seconds, the link may have expired or been used already. Request a fresh one from the login screen.'**
  String get callbackSlowHint;

  /// Back-to-login action.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get callbackBackToLogin;

  /// Failed-link app bar.
  ///
  /// In en, this message translates to:
  /// **'Sign-in link failed'**
  String get callbackFailedTitle;

  /// Request-new-link action.
  ///
  /// In en, this message translates to:
  /// **'Request a new link'**
  String get callbackRequestNew;

  /// Set-new-password app bar.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get newPasswordTitle;

  /// Set-new-password explanation.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password for your account. At least {min} characters.'**
  String newPasswordIntro(int min);

  /// New-password field label.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// Confirm-new-password field label.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewLabel;

  /// Saving state.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// Save-new-password action.
  ///
  /// In en, this message translates to:
  /// **'Save new password'**
  String get savePassword;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ne': return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
