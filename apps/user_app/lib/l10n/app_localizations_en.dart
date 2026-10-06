// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'nBhumi';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navSaved => 'Saved';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSignIn => 'Sign in';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSignedOut => 'Not signed in';

  @override
  String get profileSignedOutHint =>
      'Sign in with a magic link to post a property';

  @override
  String get profileSignedIn => 'Signed in';

  @override
  String get profilePostTitle => 'Post a property';

  @override
  String get profilePostSubtitle => 'Create a listing for review';

  @override
  String get profileKycTitle => 'Verify identity';

  @override
  String get profileKycSubtitle => 'Citizenship check for the seller badge';

  @override
  String get profileNotifTitle => 'Notifications';

  @override
  String get profileNotifSubtitle => 'Approvals, rejections and contact views';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedGuestPrompt => 'Sign in to save properties';

  @override
  String get savedEmptyTitle => 'Nothing saved yet';

  @override
  String get savedEmptyBody => 'Tap the heart on any property to keep it here.';

  @override
  String get savedSearchesTitle => 'Saved searches';

  @override
  String get savedSearchDelete => 'Delete saved search';
}
