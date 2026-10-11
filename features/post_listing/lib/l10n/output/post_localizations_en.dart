// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'post_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get stepType => 'Property type';

  @override
  String get stepLocation => 'Location';

  @override
  String get stepSpecs => 'Size & rooms';

  @override
  String get stepPrice => 'Price & photos';

  @override
  String get stepReview => 'Review';

  @override
  String get navBack => 'Back';

  @override
  String get navNext => 'Next';

  @override
  String get navSubmit => 'Submit';

  @override
  String progressOf(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String get districtsUnavailableTitle => 'Could not load districts';

  @override
  String get districtsUnavailableBody => 'Check your connection and try again.';

  @override
  String get sentForReview => 'Sent for review. It will appear once approved.';

  @override
  String get typeQuestion => 'What are you listing?';

  @override
  String get purposeQuestion => 'How do you want to sell it?';

  @override
  String get purposeSell => 'Sell';

  @override
  String get purposeRentOut => 'Rent out';

  @override
  String get purposeLeaseTx => 'Lease';

  @override
  String get locationTitle => 'Where is it?';

  @override
  String get locationSubtitle =>
      'The district decides whether area is entered in ropani or in bigha.';

  @override
  String get fieldDistrict => 'District';

  @override
  String get fieldMunicipality => 'Municipality';

  @override
  String get fieldWard => 'Ward (optional)';

  @override
  String get wardNone => 'No ward';

  @override
  String wardNumber(int number) {
    return 'Ward $number';
  }

  @override
  String get wardHint =>
      'Ward numbers run from 1 to 33. Pokhara Metropolitan City has the most wards of any local body in Nepal, at 33.';

  @override
  String get wardNoMunicipality =>
      'Choose a municipality first, then pick its ward.';

  @override
  String get municipalitiesLoading => 'Municipalities';

  @override
  String loadingSuffix(String label) {
    return 'Loading $label…';
  }

  @override
  String get municipalitiesError =>
      'Could not load municipalities. Check your connection.';

  @override
  String get retryAction => 'Retry';

  @override
  String get fieldRoadAccess => 'Road access';

  @override
  String get fieldKitta => 'Kitta number';

  @override
  String get fieldKittaHint =>
      'As on your lalpurja. Helps verify your listing faster.';

  @override
  String get fieldOptional => 'Optional';

  @override
  String get unitRopani => 'Ropani';

  @override
  String get unitAana => 'Aana';

  @override
  String get unitPaisa => 'Paisa';

  @override
  String get unitDam => 'Dam';

  @override
  String get unitBigha => 'Bigha';

  @override
  String get unitKattha => 'Kattha';

  @override
  String get unitDhur => 'Dhur';

  @override
  String get specsAreaTitle => 'Area';

  @override
  String specsAreaHill(String district) {
    return '$district is a hill district. Enter ropani, aana, paisa or dam.';
  }

  @override
  String specsAreaTerai(String district) {
    return '$district is a terai district. Enter bigha, kattha or dhur.';
  }

  @override
  String get specsNoDistrict =>
      'Choose a district first. Area is entered in ropani for hill districts and in bigha for terai districts.';

  @override
  String get specsRooms => 'Rooms';

  @override
  String get fieldBedrooms => 'Bedrooms';

  @override
  String get fieldBathrooms => 'Bathrooms';

  @override
  String derivedArea(String sqm) {
    return 'About $sqm sqm in total. Listings are stored in sqm and shown to buyers in the units you entered.';
  }

  @override
  String get priceTitle => 'Asking price';

  @override
  String get fieldPrice => 'Price';

  @override
  String buyersWillSee(String amount) {
    return 'Buyers will see $amount';
  }

  @override
  String get photosTitle => 'Photos';

  @override
  String get photosSubtitle =>
      'Add at least one. Listings with photos get far more enquiries.';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get reviewTitle => 'Check your listing';

  @override
  String get reviewSubtitle =>
      'It will be reviewed before it appears publicly.';

  @override
  String get reviewType => 'Type';

  @override
  String get reviewTitleRow => 'Title';

  @override
  String get reviewLocation => 'Location';

  @override
  String get reviewArea => 'Area';

  @override
  String get reviewRooms => 'Rooms';

  @override
  String get reviewPrice => 'Price';

  @override
  String get reviewPhotos => 'Photos';

  @override
  String get reviewDescription => 'Description';

  @override
  String get reviewNotSet => 'Not set';

  @override
  String get reviewNotApplicable => 'Not applicable';

  @override
  String reviewPhotosAdded(int count) {
    return '$count added';
  }

  @override
  String get reviewContactNote =>
      'Buyers see your contact details only after signing in and requesting them, so your number is never published on the listing.';

  @override
  String get reviewSubmit => 'Submit for review';

  @override
  String get fieldPropertyType => 'Property type';

  @override
  String get fieldPurpose => 'Sale, rent or lease';

  @override
  String requiredField(String label) {
    return '$label is required';
  }

  @override
  String crossDistrict(String name, String district) {
    return '$name is not in $district';
  }

  @override
  String wardRange(int max) {
    return 'Ward must be a number from 1 to $max';
  }

  @override
  String wardCount(String name, int count) {
    return '$name has $count wards';
  }

  @override
  String numberInvalid(String label) {
    return '$label must be a number';
  }

  @override
  String numberNegative(String label) {
    return '$label cannot be negative';
  }

  @override
  String get areaWrongHill =>
      'This district measures area in hill units (ropani, aana, paisa, dam), not bigha';

  @override
  String get areaWrongTerai =>
      'This district measures area in terai units (bigha, kattha, dhur), not ropani';

  @override
  String get areaHillEmpty => 'Enter the area in ropani, aana, paisa or dam';

  @override
  String get areaTeraiEmpty => 'Enter the area in bigha, kattha or dhur';

  @override
  String get bedroomsMin => 'Bedrooms must be 1 or more';

  @override
  String get bathroomsMin => 'Bathrooms must be 1 or more';

  @override
  String get priceInvalid => 'Price must be more than zero';

  @override
  String get photosRequired => 'Add at least one photo';

  @override
  String get chipLand => 'Land';

  @override
  String get chipHouse => 'House';

  @override
  String get chipApartment => 'Apartment';

  @override
  String get chipVilla => 'Villa';

  @override
  String get chipCommercial => 'Commercial';

  @override
  String get chipBusiness => 'Business';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldTitleHint => 'e.g. Sunny 3BHK house in Sitapaila';

  @override
  String get fieldDescription => 'Description (optional)';

  @override
  String get fieldDescriptionHint => 'Land, road, water and surroundings';

  @override
  String get sectionLeaseTerms => 'Lease terms';

  @override
  String get leaseTermsExplanation =>
      'A lease needs a term. Buyers filter on it, and a lease without one cannot be actioned.';

  @override
  String get fieldLeaseTerm => 'Lease term';

  @override
  String get fieldLeaseTermHint => 'Months';

  @override
  String get leaseTermMin => 'Lease term must be at least 1 month';

  @override
  String get fieldLeaseRenewable => 'Can the lease be renewed?';

  @override
  String get leaseRenewableYes => 'Yes';

  @override
  String get leaseRenewableNo => 'No';

  @override
  String get leaseRenewableUnset => 'Not stated';

  @override
  String get sectionRentalTerms => 'Rental terms';

  @override
  String get fieldDeposit => 'Security deposit';

  @override
  String get fieldDepositHint => 'NPR, usually one to three months of rent';

  @override
  String get fieldAvailableFrom => 'Available from';

  @override
  String get fieldAvailableFromPick => 'Choose a date';

  @override
  String get fieldAvailableFromClear => 'Clear date';

  @override
  String get availableFromPast => 'Availability date cannot be in the past';

  @override
  String get fieldFurnishing => 'Furnishing';

  @override
  String get furnishingUnfurnished => 'Unfurnished';

  @override
  String get furnishingSemiFurnished => 'Partly furnished';

  @override
  String get furnishingFurnished => 'Fully furnished';

  @override
  String get fieldUtilities => 'Utilities included';

  @override
  String get fieldUtilitiesHint => 'e.g. Water and building maintenance';

  @override
  String get utilitiesTooLong => 'Keep the utilities note under 200 characters';

  @override
  String get fieldPetPolicy => 'Pets';

  @override
  String get petNotAllowed => 'No pets';

  @override
  String get petCatsOk => 'Cats allowed';

  @override
  String get petDogsOk => 'Dogs allowed';

  @override
  String get petAllPets => 'All pets allowed';

  @override
  String get petNegotiable => 'Negotiable';

  @override
  String get sectionBuilding => 'Building';

  @override
  String get fieldParking => 'Parking spaces';

  @override
  String get parkingMin => 'Parking must be 1 or more';

  @override
  String get fieldFloor => 'Floor';

  @override
  String get fieldFloorHint => 'Ground floor is 0';

  @override
  String get fieldTotalFloors => 'Total floors';

  @override
  String get totalFloorsMin => 'Total floors must be 1 or more';

  @override
  String get fieldPropertyAge => 'Building age';

  @override
  String get fieldPropertyAgeHint => 'Years since construction, 0 if new';

  @override
  String get fieldConstructionStatus => 'Status';

  @override
  String get constructionNew => 'New build';

  @override
  String get constructionUnderConstruction => 'Under construction';

  @override
  String get constructionResale => 'Resale';

  @override
  String get reviewLease => 'Lease';

  @override
  String reviewLeaseMonths(String months) {
    return '$months months';
  }

  @override
  String get reviewRental => 'Rental';

  @override
  String reviewDeposit(String amount) {
    return 'Deposit $amount';
  }

  @override
  String reviewAvailableFrom(String date) {
    return 'From $date';
  }

  @override
  String get reviewBuilding => 'Building';

  @override
  String reviewFloor(String floor, String total) {
    return 'Floor $floor of $total';
  }

  @override
  String reviewAge(String years) {
    return '$years years old';
  }
}
