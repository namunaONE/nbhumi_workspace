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
  String get navExplore => 'Explore';

  @override
  String get navMyListings => 'My Listings';

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
  String get mineTitle => 'My Listings';

  @override
  String get mineGuestPrompt => 'Sign in to see the properties you posted';

  @override
  String get mineEmptyTitle => 'No listings yet';

  @override
  String get mineEmptyBody =>
      'Tap + below to post your first property for free.';

  @override
  String get postAction => 'Post property';

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

  @override
  String get profileLoading => 'Loading profile…';

  @override
  String get profileSignInHint => 'We email you a link, no password needed';

  @override
  String get profileAboutTitle => 'About nBhumi';

  @override
  String get profileAboutBody =>
      'We facilitate listings only. Ownership transfers are completed at Malpot.';

  @override
  String get profilePrivacyNote =>
      'nBhumi collects the minimum information needed to operate a marketplace, in line with the Privacy Act 2075 (2018).';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileEditName => 'Full name';

  @override
  String get profileEditPhone => 'Phone (optional)';

  @override
  String get profileEditPhoneHint => '98XXXXXXXX';

  @override
  String get profileEditPhoneError =>
      'Enter a 10-digit mobile starting 97 or 98';

  @override
  String get profileEditAgency => 'Agency name (optional)';

  @override
  String get profileEditRegNo => 'Agency registration no. (optional)';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCopy => 'Copy';

  @override
  String get profileDownloadTitle => 'Download my data';

  @override
  String get profileDownloadSubtitle =>
      'Profile, listings and reveal history as JSON';

  @override
  String get profilePreparingData => 'Preparing your data…';

  @override
  String get profileExportTitle => 'Your data';

  @override
  String get profileCopied => 'Copied to clipboard';

  @override
  String get profileSignOutTitle => 'Sign out';

  @override
  String get profileSignOutSubtitle =>
      'You can sign back in with a magic link any time';

  @override
  String get profileDeleteTitle => 'Delete my account';

  @override
  String get profileDeleteSubtitle =>
      'Permanent. Listings stay up without your name';

  @override
  String get profileDeleteConfirmTitle => 'Delete your account?';

  @override
  String get profileDeleteC1 =>
      'Your profile and sign-in are removed permanently.';

  @override
  String get profileDeleteC2 =>
      'Your listings stay up, but without your name on them.';

  @override
  String get profileDeleteC3 =>
      'Your contact-reveal history is kept without your identity, as required for marketplace safety records.';

  @override
  String get profileDeleteFinal => 'This cannot be undone.';

  @override
  String get profileDeleteContinue => 'Continue';

  @override
  String get profileTypeDeleteTitle => 'Type DELETE to confirm';

  @override
  String get profileSaved => 'Saved';

  @override
  String profileSavedAs(String name) {
    return 'Saved — $name';
  }

  @override
  String get onboardingTagline => 'Buy and sell property across Nepal';

  @override
  String get onboardingSearchTitle => 'Search in your own units';

  @override
  String get onboardingSearchBody =>
      'Filter by district, price and area in ropani, aana or bigha depending on the region.';

  @override
  String get onboardingVerifiedTitle => 'Verified sellers';

  @override
  String get onboardingVerifiedBody =>
      'Sellers who have had their identity documents checked carry a verified badge.';

  @override
  String get onboardingPostTitle => 'Post your property';

  @override
  String get onboardingPostBody =>
      'Add photos and details. A reviewer checks each listing before it goes live.';

  @override
  String get onboardingDisclaimer =>
      'nBhumi helps people advertise and find property. It is not a broker and does not handle money. Ownership transfers are completed at Malpot with the concerned authorities.';

  @override
  String get onboardingBrowse => 'Browse listings';

  @override
  String get profileContactTitle => 'Contact details';

  @override
  String get profileContactEmailLocked =>
      'Managed by sign-in · cannot be changed here';

  @override
  String get profileContactPhoneMissing => 'Add phone';

  @override
  String get profileContactAddPhoneHint => '10-digit mobile starting 97 or 98';

  @override
  String get profileRoleBuyer => 'Buyer';

  @override
  String get profileRoleAgent => 'Agent';

  @override
  String get profileRoleAdmin => 'Admin';

  @override
  String get profileSuspendedTitle => 'Account suspended';

  @override
  String get profileSuspendedBody =>
      'You cannot post or edit listings right now.';

  @override
  String get profileKycNone => 'Unverified';

  @override
  String get profileKycAccount => 'Account';

  @override
  String get profileKycIdentity => 'Identity verified';

  @override
  String get profileKycProperty => 'Property verified';

  @override
  String get profileAgencyTitle => 'Agency';

  @override
  String get profileAgencySubtitle => 'Optional · shown on your listings';

  @override
  String get profileAgencyExplainer =>
      'Your agency name appears on listings you post. Filling this in does not verify you — upload your registration certificate in Verify identity to earn the agency badge.';

  @override
  String get profileAgencyVerifyCta => 'Verify agency documents';

  @override
  String get profileAgencyUnverifiedHint => 'Not yet verified';

  @override
  String get profileSettingsTitle => 'Settings';

  @override
  String get profileSettingsSubtitle => 'Language, theme and about';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageNe => 'नेपाली';

  @override
  String get settingsThemeTitle => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activityEntrySubtitle => 'Listings, interest, reveals and updates';

  @override
  String get activityGuestPrompt => 'Sign in to see your activity';

  @override
  String get activityListings => 'My listings';

  @override
  String get activityListingsEmpty =>
      'No listings yet. Post your first property.';

  @override
  String get activityListingsEmptyBuyer => 'Nothing posted yet.';

  @override
  String get activityPostCta => 'Post a property';

  @override
  String get activityInterest => 'Interest in my listings';

  @override
  String get activityReveals => 'My inquiries';

  @override
  String get activityRevealsEmpty => 'No contacts viewed yet.';

  @override
  String activityValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get activityExpired => 'Expired — tap to refresh';

  @override
  String get activityDocs => 'Verifications';

  @override
  String get activityDocsEmpty => 'No documents submitted yet.';

  @override
  String get activityUpdates => 'Updates';

  @override
  String get activityUpdatesEmpty => 'No updates yet.';

  @override
  String get activityRefresh => 'Refresh activity';

  @override
  String get activityUnknownListing => 'Listing no longer available';

  @override
  String activityViews(int count) {
    return '$count views';
  }

  @override
  String activityLastViewed(String date) {
    return 'last viewed $date';
  }

  @override
  String get activityViewAll => 'View all updates';

  @override
  String get activityLoadFailed => 'Could not load your activity.';

  @override
  String get activityStatusDraft => 'Draft';

  @override
  String get activityStatusPending => 'Pending review';

  @override
  String get activityStatusLive => 'Live';

  @override
  String get activityStatusRejected => 'Rejected';

  @override
  String get activityStatusUnpublished => 'Unpublished';
}
