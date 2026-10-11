import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'detail_localizations_en.dart';
import 'detail_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'output/detail_localizations.dart';
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

  /// Location section heading.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get sectionLocation;

  /// Bedrooms/bathrooms section heading.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get sectionDetails;

  /// Description section heading.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get sectionDescription;

  /// Seller section heading.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sectionSeller;

  /// Road frontage spec.
  ///
  /// In en, this message translates to:
  /// **'{feet} ft road access'**
  String specRoadAccess(int feet);

  /// Bedroom count spec.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bedroom} other{{count} bedrooms}}'**
  String specBedrooms(int count);

  /// Bathroom count spec.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bathroom} other{{count} bathrooms}}'**
  String specBathrooms(int count);

  /// City-plus-ward address line.
  ///
  /// In en, this message translates to:
  /// **'{city}, Ward {ward}'**
  String specWard(String city, String ward);

  /// Fallback when the seller has no displayable name.
  ///
  /// In en, this message translates to:
  /// **'Seller details unavailable'**
  String get sellerUnavailable;

  /// Save heart tooltip.
  ///
  /// In en, this message translates to:
  /// **'Save this property'**
  String get favoriteSave;

  /// Unsave heart tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get favoriteRemove;

  /// Confirmation after bookmarking.
  ///
  /// In en, this message translates to:
  /// **'Saved to your list.'**
  String get favoriteSaved;

  /// Confirmation after unbookmarking.
  ///
  /// In en, this message translates to:
  /// **'Removed from your saved list.'**
  String get favoriteRemoved;

  /// Missing/unpublished listing heading.
  ///
  /// In en, this message translates to:
  /// **'This property is no longer available'**
  String get notAvailableTitle;

  /// Missing/unpublished listing explanation.
  ///
  /// In en, this message translates to:
  /// **'It may have been sold, withdrawn by the seller, or the link may be wrong.'**
  String get notAvailableBody;

  /// Back-to-feed action.
  ///
  /// In en, this message translates to:
  /// **'Browse other properties'**
  String get browseOthers;

  /// Load retry action.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Hint under the load error.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get loadRetryHint;

  /// Contact button while revealing.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get contactLoading;

  /// Contact button for guests.
  ///
  /// In en, this message translates to:
  /// **'Sign in to contact'**
  String get contactSignIn;

  /// Contact button for signed-in buyers.
  ///
  /// In en, this message translates to:
  /// **'Contact seller'**
  String get contactSeller;

  /// Phone row label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactPhone;

  /// Email row label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmail;

  /// Copy-to-clipboard tooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get contactCopy;

  /// Confirmation naming the copied row.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String contactCopied(String label);

  /// Report button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Report this listing'**
  String get reportTooltip;

  /// Confirmation after filing a report.
  ///
  /// In en, this message translates to:
  /// **'Report filed. Our team will review it.'**
  String get reportFiled;

  /// Report sheet heading.
  ///
  /// In en, this message translates to:
  /// **'Report this listing'**
  String get reportTitle;

  /// Reason picker label.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reportReasonLabel;

  /// Details field label when required.
  ///
  /// In en, this message translates to:
  /// **'Details *'**
  String get reportDetailsRequired;

  /// Details field label when optional.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get reportDetailsOptional;

  /// Inline error when required details are blank.
  ///
  /// In en, this message translates to:
  /// **'Please describe the problem so our team can act on it.'**
  String get reportDetailsError;

  /// Report submit action.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmit;

  /// Duplicate-listing report reason.
  ///
  /// In en, this message translates to:
  /// **'Duplicate listing'**
  String get reasonDuplicate;

  /// Misleading-photos report reason.
  ///
  /// In en, this message translates to:
  /// **'Photos are misleading'**
  String get reasonPhotos;

  /// Suspicious-price report reason.
  ///
  /// In en, this message translates to:
  /// **'Price looks wrong'**
  String get reasonPrice;

  /// Wrong-location report reason.
  ///
  /// In en, this message translates to:
  /// **'Wrong location'**
  String get reasonLocation;

  /// Already-sold report reason.
  ///
  /// In en, this message translates to:
  /// **'Already sold'**
  String get reasonSold;

  /// Off-site-dealing report reason.
  ///
  /// In en, this message translates to:
  /// **'Seller asked to deal off-site'**
  String get reasonOffsite;

  /// Fake-listing report reason.
  ///
  /// In en, this message translates to:
  /// **'Fake listing'**
  String get reasonFake;

  /// Other report reason.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// Land chip.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get typeLand;

  /// House chip.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get typeHouse;

  /// Apartment chip.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get typeApartment;

  /// Villa chip.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get typeVilla;

  /// Commercial chip.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get typeCommercial;

  /// Business chip.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get typeBusiness;

  /// Sale chip.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get purposeSale;

  /// Rent chip.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get purposeRent;

  /// Lease chip.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get purposeLease;

  /// Tier-3 verified-listing badge (HYA-265).
  ///
  /// In en, this message translates to:
  /// **'Verified Listing'**
  String get verifiedListing;

  /// Badge explainer: doc-check only, never legal verification.
  ///
  /// In en, this message translates to:
  /// **'Our admin team checked the lalpurja attached to this listing. This is a document check only — never a legal opinion on ownership or title. Ownership transfers are completed at Malpot.'**
  String get verifiedListingBody;

  /// Badge dialog dismiss action.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get verifiedListingUnderstood;

  /// Browser tab fallback while the listing is still loading.
  ///
  /// In en, this message translates to:
  /// **'Property details'**
  String get detailPageTitle;

  /// Owner CTA opening the Tier-3 submit flow.
  ///
  /// In en, this message translates to:
  /// **'Verify this listing'**
  String get verifyThisListing;

  /// Parking spaces spec row.
  ///
  /// In en, this message translates to:
  /// **'{count} parking spaces'**
  String specParking(int count);

  /// Lease-specific section heading.
  ///
  /// In en, this message translates to:
  /// **'Lease terms'**
  String get sectionLeaseTerms;

  /// Lease length spec row.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String specLeaseTerm(int months);

  /// Lease can be renewed.
  ///
  /// In en, this message translates to:
  /// **'Can be renewed'**
  String get termRenewable;

  /// Lease cannot be renewed.
  ///
  /// In en, this message translates to:
  /// **'Cannot be renewed'**
  String get termNotRenewable;

  /// Rent-specific section heading.
  ///
  /// In en, this message translates to:
  /// **'Rental terms'**
  String get sectionRentalTerms;

  /// Security deposit spec row.
  ///
  /// In en, this message translates to:
  /// **'Deposit {amount}'**
  String specDeposit(String amount);

  /// Availability date spec row.
  ///
  /// In en, this message translates to:
  /// **'Available from {date}'**
  String specAvailableFrom(String date);

  /// Furnishing level spec row.
  ///
  /// In en, this message translates to:
  /// **'{level}'**
  String specFurnishing(String level);

  /// Unfurnished option.
  ///
  /// In en, this message translates to:
  /// **'Unfurnished'**
  String get furnishingUnfurnished;

  /// Semi-furnished option.
  ///
  /// In en, this message translates to:
  /// **'Partly furnished'**
  String get furnishingSemiFurnished;

  /// Furnished option.
  ///
  /// In en, this message translates to:
  /// **'Fully furnished'**
  String get furnishingFurnished;

  /// Pet policy spec row.
  ///
  /// In en, this message translates to:
  /// **'Pets: {policy}'**
  String specPetPolicy(String policy);

  /// No pets option.
  ///
  /// In en, this message translates to:
  /// **'No pets'**
  String get petNotAllowed;

  /// Cats allowed option.
  ///
  /// In en, this message translates to:
  /// **'Cats allowed'**
  String get petCatsOk;

  /// Dogs allowed option.
  ///
  /// In en, this message translates to:
  /// **'Dogs allowed'**
  String get petDogsOk;

  /// All pets option.
  ///
  /// In en, this message translates to:
  /// **'All pets allowed'**
  String get petAllPets;

  /// Pets negotiable option.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get petNegotiable;

  /// Building-specific section heading.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get sectionBuilding;

  /// Floor number spec row without a total.
  ///
  /// In en, this message translates to:
  /// **'Floor {floor}'**
  String specFloor(int floor);

  /// Floor position within a building.
  ///
  /// In en, this message translates to:
  /// **'Floor {floor} of {total}'**
  String specFloorOf(int floor, int total);

  /// Building age spec row.
  ///
  /// In en, this message translates to:
  /// **'{years} years old'**
  String specAge(int years);

  /// Construction status spec row.
  ///
  /// In en, this message translates to:
  /// **'{status}'**
  String specConstruction(String status);

  /// New build option.
  ///
  /// In en, this message translates to:
  /// **'New build'**
  String get constructionNew;

  /// Under construction option.
  ///
  /// In en, this message translates to:
  /// **'Under construction'**
  String get constructionUnderConstruction;

  /// Resale option.
  ///
  /// In en, this message translates to:
  /// **'Resale'**
  String get constructionResale;
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
