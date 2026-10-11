import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'post_localizations_en.dart';
import 'post_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'output/post_localizations.dart';
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

  /// Step 1 app-bar title.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get stepType;

  /// Step 2 app-bar title.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get stepLocation;

  /// Step 3 app-bar title.
  ///
  /// In en, this message translates to:
  /// **'Size & rooms'**
  String get stepSpecs;

  /// Step 4 app-bar title.
  ///
  /// In en, this message translates to:
  /// **'Price & photos'**
  String get stepPrice;

  /// Step 5 app-bar title.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// Wizard back action.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get navBack;

  /// Wizard next action.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get navNext;

  /// Wizard submit action on the last step.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get navSubmit;

  /// Linear progress label.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String progressOf(int n, int total);

  /// Heading when reference data fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load districts'**
  String get districtsUnavailableTitle;

  /// Explanation when reference data fails to load.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get districtsUnavailableBody;

  /// Confirmation after submitting.
  ///
  /// In en, this message translates to:
  /// **'Sent for review. It will appear once approved.'**
  String get sentForReview;

  /// Step 1 first question.
  ///
  /// In en, this message translates to:
  /// **'What are you listing?'**
  String get typeQuestion;

  /// Step 1 second question.
  ///
  /// In en, this message translates to:
  /// **'How do you want to sell it?'**
  String get purposeQuestion;

  /// Sell purpose chip.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get purposeSell;

  /// Rent-out purpose chip.
  ///
  /// In en, this message translates to:
  /// **'Rent out'**
  String get purposeRentOut;

  /// Lease purpose chip.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get purposeLeaseTx;

  /// Location section heading.
  ///
  /// In en, this message translates to:
  /// **'Where is it?'**
  String get locationTitle;

  /// Location section explanation.
  ///
  /// In en, this message translates to:
  /// **'The district decides whether area is entered in ropani or in bigha.'**
  String get locationSubtitle;

  /// District picker label and required-field name.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get fieldDistrict;

  /// Municipality picker label and required-field name.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get fieldMunicipality;

  /// Ward picker label.
  ///
  /// In en, this message translates to:
  /// **'Ward (optional)'**
  String get fieldWard;

  /// Ward picker empty choice.
  ///
  /// In en, this message translates to:
  /// **'No ward'**
  String get wardNone;

  /// Ward picker entry.
  ///
  /// In en, this message translates to:
  /// **'Ward {number}'**
  String wardNumber(int number);

  /// Note on ward numbering (Rule 28).
  ///
  /// In en, this message translates to:
  /// **'Ward numbers run from 1 to 33. Pokhara Metropolitan City has the most wards of any local body in Nepal, at 33.'**
  String get wardHint;

  /// Note when the ward picker has no bound yet.
  ///
  /// In en, this message translates to:
  /// **'Choose a municipality first, then pick its ward.'**
  String get wardNoMunicipality;

  /// Municipality loading row.
  ///
  /// In en, this message translates to:
  /// **'Municipalities'**
  String get municipalitiesLoading;

  /// Loading row template.
  ///
  /// In en, this message translates to:
  /// **'Loading {label}…'**
  String loadingSuffix(String label);

  /// Municipality load failure.
  ///
  /// In en, this message translates to:
  /// **'Could not load municipalities. Check your connection.'**
  String get municipalitiesError;

  /// Inline retry action.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// Road frontage field label.
  ///
  /// In en, this message translates to:
  /// **'Road access'**
  String get fieldRoadAccess;

  /// Land parcel (kitta) number field label.
  ///
  /// In en, this message translates to:
  /// **'Kitta number'**
  String get fieldKitta;

  /// Kitta field hint: where to find it.
  ///
  /// In en, this message translates to:
  /// **'As on your lalpurja. Helps verify your listing faster.'**
  String get fieldKittaHint;

  /// Optional-field hint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get fieldOptional;

  /// Ropani field label.
  ///
  /// In en, this message translates to:
  /// **'Ropani'**
  String get unitRopani;

  /// Aana field label.
  ///
  /// In en, this message translates to:
  /// **'Aana'**
  String get unitAana;

  /// Paisa field label.
  ///
  /// In en, this message translates to:
  /// **'Paisa'**
  String get unitPaisa;

  /// Dam field label.
  ///
  /// In en, this message translates to:
  /// **'Dam'**
  String get unitDam;

  /// Bigha field label.
  ///
  /// In en, this message translates to:
  /// **'Bigha'**
  String get unitBigha;

  /// Kattha field label.
  ///
  /// In en, this message translates to:
  /// **'Kattha'**
  String get unitKattha;

  /// Dhur field label.
  ///
  /// In en, this message translates to:
  /// **'Dhur'**
  String get unitDhur;

  /// Area section heading.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get specsAreaTitle;

  /// Hill-district area explanation.
  ///
  /// In en, this message translates to:
  /// **'{district} is a hill district. Enter ropani, aana, paisa or dam.'**
  String specsAreaHill(String district);

  /// Terai-district area explanation.
  ///
  /// In en, this message translates to:
  /// **'{district} is a terai district. Enter bigha, kattha or dhur.'**
  String specsAreaTerai(String district);

  /// Note when no district is chosen yet.
  ///
  /// In en, this message translates to:
  /// **'Choose a district first. Area is entered in ropani for hill districts and in bigha for terai districts.'**
  String get specsNoDistrict;

  /// Rooms section heading.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get specsRooms;

  /// Bedrooms field label.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get fieldBedrooms;

  /// Bathrooms field label.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get fieldBathrooms;

  /// Derived square-metre note.
  ///
  /// In en, this message translates to:
  /// **'About {sqm} sqm in total. Listings are stored in sqm and shown to buyers in the units you entered.'**
  String derivedArea(String sqm);

  /// Asking-price section heading.
  ///
  /// In en, this message translates to:
  /// **'Asking price'**
  String get priceTitle;

  /// Price field label and required-field name.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get fieldPrice;

  /// Formatted-price echo.
  ///
  /// In en, this message translates to:
  /// **'Buyers will see {amount}'**
  String buyersWillSee(String amount);

  /// Photos section heading.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosTitle;

  /// Photos section explanation.
  ///
  /// In en, this message translates to:
  /// **'Add at least one. Listings with photos get far more enquiries.'**
  String get photosSubtitle;

  /// Remove-photo tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// Review step heading.
  ///
  /// In en, this message translates to:
  /// **'Check your listing'**
  String get reviewTitle;

  /// Review step explanation.
  ///
  /// In en, this message translates to:
  /// **'It will be reviewed before it appears publicly.'**
  String get reviewSubtitle;

  /// Type summary row label.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reviewType;

  /// Title summary row label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reviewTitleRow;

  /// Location summary row label.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get reviewLocation;

  /// Area summary row label.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get reviewArea;

  /// Rooms summary row label.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get reviewRooms;

  /// Price summary row label.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get reviewPrice;

  /// Photos summary row label.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get reviewPhotos;

  /// Description summary section label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reviewDescription;

  /// Placeholder for an empty summary value.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get reviewNotSet;

  /// Placeholder when rooms do not apply.
  ///
  /// In en, this message translates to:
  /// **'Not applicable'**
  String get reviewNotApplicable;

  /// Photo count summary.
  ///
  /// In en, this message translates to:
  /// **'{count} added'**
  String reviewPhotosAdded(int count);

  /// Note on contact visibility.
  ///
  /// In en, this message translates to:
  /// **'Buyers see your contact details only after signing in and requesting them, so your number is never published on the listing.'**
  String get reviewContactNote;

  /// Review submit action.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get reviewSubmit;

  /// Property-type required-field name.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get fieldPropertyType;

  /// Purpose required-field name.
  ///
  /// In en, this message translates to:
  /// **'Sale, rent or lease'**
  String get fieldPurpose;

  /// Generic required-field message.
  ///
  /// In en, this message translates to:
  /// **'{label} is required'**
  String requiredField(String label);

  /// Cross-district municipality message.
  ///
  /// In en, this message translates to:
  /// **'{name} is not in {district}'**
  String crossDistrict(String name, String district);

  /// Ward out-of-range message.
  ///
  /// In en, this message translates to:
  /// **'Ward must be a number from 1 to {max}'**
  String wardRange(int max);

  /// Ward exceeds body count message.
  ///
  /// In en, this message translates to:
  /// **'{name} has {count} wards'**
  String wardCount(String name, int count);

  /// Non-numeric input message.
  ///
  /// In en, this message translates to:
  /// **'{label} must be a number'**
  String numberInvalid(String label);

  /// Negative input message.
  ///
  /// In en, this message translates to:
  /// **'{label} cannot be negative'**
  String numberNegative(String label);

  /// Terai units in a hill district.
  ///
  /// In en, this message translates to:
  /// **'This district measures area in hill units (ropani, aana, paisa, dam), not bigha'**
  String get areaWrongHill;

  /// Hill units in a terai district.
  ///
  /// In en, this message translates to:
  /// **'This district measures area in terai units (bigha, kattha, dhur), not ropani'**
  String get areaWrongTerai;

  /// No hill area entered.
  ///
  /// In en, this message translates to:
  /// **'Enter the area in ropani, aana, paisa or dam'**
  String get areaHillEmpty;

  /// No terai area entered.
  ///
  /// In en, this message translates to:
  /// **'Enter the area in bigha, kattha or dhur'**
  String get areaTeraiEmpty;

  /// Bedroom minimum message.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms must be 1 or more'**
  String get bedroomsMin;

  /// Bathroom minimum message.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms must be 1 or more'**
  String get bathroomsMin;

  /// Non-positive price message.
  ///
  /// In en, this message translates to:
  /// **'Price must be more than zero'**
  String get priceInvalid;

  /// Missing photo message.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo'**
  String get photosRequired;

  /// Land type chip.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get chipLand;

  /// House type chip.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get chipHouse;

  /// Apartment type chip.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get chipApartment;

  /// Villa type chip.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get chipVilla;

  /// Commercial type chip.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get chipCommercial;

  /// Business type chip.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get chipBusiness;

  /// Listing title field label and required-field name.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// Listing title placeholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sunny 3BHK house in Sitapaila'**
  String get fieldTitleHint;

  /// Listing description field label.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get fieldDescription;

  /// Listing description placeholder.
  ///
  /// In en, this message translates to:
  /// **'Land, road, water and surroundings'**
  String get fieldDescriptionHint;

  /// Lease-specific section heading on the specs step.
  ///
  /// In en, this message translates to:
  /// **'Lease terms'**
  String get sectionLeaseTerms;

  /// Lease section explanation.
  ///
  /// In en, this message translates to:
  /// **'A lease needs a term. Buyers filter on it, and a lease without one cannot be actioned.'**
  String get leaseTermsExplanation;

  /// Lease length in months field label.
  ///
  /// In en, this message translates to:
  /// **'Lease term'**
  String get fieldLeaseTerm;

  /// Lease term field hint.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get fieldLeaseTermHint;

  /// Lease term minimum message.
  ///
  /// In en, this message translates to:
  /// **'Lease term must be at least 1 month'**
  String get leaseTermMin;

  /// Lease renewal question.
  ///
  /// In en, this message translates to:
  /// **'Can the lease be renewed?'**
  String get fieldLeaseRenewable;

  /// Lease renewable answer.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get leaseRenewableYes;

  /// Lease not renewable answer.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get leaseRenewableNo;

  /// Lease renewal unanswered.
  ///
  /// In en, this message translates to:
  /// **'Not stated'**
  String get leaseRenewableUnset;

  /// Rent-specific section heading on the specs step.
  ///
  /// In en, this message translates to:
  /// **'Rental terms'**
  String get sectionRentalTerms;

  /// Security deposit field label.
  ///
  /// In en, this message translates to:
  /// **'Security deposit'**
  String get fieldDeposit;

  /// Security deposit field hint.
  ///
  /// In en, this message translates to:
  /// **'NPR, usually one to three months of rent'**
  String get fieldDepositHint;

  /// Availability date field label.
  ///
  /// In en, this message translates to:
  /// **'Available from'**
  String get fieldAvailableFrom;

  /// Availability date picker action.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get fieldAvailableFromPick;

  /// Availability date clear action.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get fieldAvailableFromClear;

  /// Availability date in the past message.
  ///
  /// In en, this message translates to:
  /// **'Availability date cannot be in the past'**
  String get availableFromPast;

  /// Furnishing level field label.
  ///
  /// In en, this message translates to:
  /// **'Furnishing'**
  String get fieldFurnishing;

  /// Unfurnished furnishing option.
  ///
  /// In en, this message translates to:
  /// **'Unfurnished'**
  String get furnishingUnfurnished;

  /// Semi-furnished furnishing option.
  ///
  /// In en, this message translates to:
  /// **'Partly furnished'**
  String get furnishingSemiFurnished;

  /// Furnished furnishing option.
  ///
  /// In en, this message translates to:
  /// **'Fully furnished'**
  String get furnishingFurnished;

  /// Utilities included field label.
  ///
  /// In en, this message translates to:
  /// **'Utilities included'**
  String get fieldUtilities;

  /// Utilities included field hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Water and building maintenance'**
  String get fieldUtilitiesHint;

  /// Utilities note over the length cap.
  ///
  /// In en, this message translates to:
  /// **'Keep the utilities note under 200 characters'**
  String get utilitiesTooLong;

  /// Pet policy field label.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get fieldPetPolicy;

  /// Pet policy option: no animals.
  ///
  /// In en, this message translates to:
  /// **'No pets'**
  String get petNotAllowed;

  /// Pet policy option: cats allowed.
  ///
  /// In en, this message translates to:
  /// **'Cats allowed'**
  String get petCatsOk;

  /// Pet policy option: dogs allowed.
  ///
  /// In en, this message translates to:
  /// **'Dogs allowed'**
  String get petDogsOk;

  /// Pet policy option: any animal.
  ///
  /// In en, this message translates to:
  /// **'All pets allowed'**
  String get petAllPets;

  /// Pet policy option: ask the seller.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get petNegotiable;

  /// Building-specific section heading on the specs step.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get sectionBuilding;

  /// Parking spaces field label.
  ///
  /// In en, this message translates to:
  /// **'Parking spaces'**
  String get fieldParking;

  /// Parking minimum message.
  ///
  /// In en, this message translates to:
  /// **'Parking must be 1 or more'**
  String get parkingMin;

  /// Floor number field label.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get fieldFloor;

  /// Floor number field hint.
  ///
  /// In en, this message translates to:
  /// **'Ground floor is 0'**
  String get fieldFloorHint;

  /// Total floors field label.
  ///
  /// In en, this message translates to:
  /// **'Total floors'**
  String get fieldTotalFloors;

  /// Total floors minimum message.
  ///
  /// In en, this message translates to:
  /// **'Total floors must be 1 or more'**
  String get totalFloorsMin;

  /// Building age field label.
  ///
  /// In en, this message translates to:
  /// **'Building age'**
  String get fieldPropertyAge;

  /// Building age field hint.
  ///
  /// In en, this message translates to:
  /// **'Years since construction, 0 if new'**
  String get fieldPropertyAgeHint;

  /// Construction status field label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fieldConstructionStatus;

  /// Construction status option: new build.
  ///
  /// In en, this message translates to:
  /// **'New build'**
  String get constructionNew;

  /// Construction status option: still being built.
  ///
  /// In en, this message translates to:
  /// **'Under construction'**
  String get constructionUnderConstruction;

  /// Construction status option: previously occupied.
  ///
  /// In en, this message translates to:
  /// **'Resale'**
  String get constructionResale;

  /// Review summary row label for lease terms.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get reviewLease;

  /// Lease term summary value.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String reviewLeaseMonths(String months);

  /// Review summary row label for rental terms.
  ///
  /// In en, this message translates to:
  /// **'Rental'**
  String get reviewRental;

  /// Deposit summary value.
  ///
  /// In en, this message translates to:
  /// **'Deposit {amount}'**
  String reviewDeposit(String amount);

  /// Availability summary value.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String reviewAvailableFrom(String date);

  /// Review summary row label for building details.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get reviewBuilding;

  /// Floor summary value.
  ///
  /// In en, this message translates to:
  /// **'Floor {floor} of {total}'**
  String reviewFloor(String floor, String total);

  /// Building age summary value.
  ///
  /// In en, this message translates to:
  /// **'{years} years old'**
  String reviewAge(String years);
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
