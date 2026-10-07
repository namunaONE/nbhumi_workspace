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
  String get locationSubtitle => 'The district decides whether area is entered in ropani or in bigha.';

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
  String get wardHint => 'Ward numbers run from 1 to 33. Pokhara Metropolitan City has the most wards of any local body in Nepal, at 33.';

  @override
  String get municipalitiesLoading => 'Municipalities';

  @override
  String loadingSuffix(String label) {
    return 'Loading $label…';
  }

  @override
  String get municipalitiesError => 'Could not load municipalities. Check your connection.';

  @override
  String get fieldRoadAccess => 'Road access';

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
  String get specsNoDistrict => 'Choose a district first. Area is entered in ropani for hill districts and in bigha for terai districts.';

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
  String get photosSubtitle => 'Add at least one. Listings with photos get far more enquiries.';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get reviewTitle => 'Check your listing';

  @override
  String get reviewSubtitle => 'It will be reviewed before it appears publicly.';

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
  String get reviewContactNote => 'Buyers see your contact details only after signing in and requesting them, so your number is never published on the listing.';

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
  String get areaWrongHill => 'This district measures area in hill units (ropani, aana, paisa, dam), not bigha';

  @override
  String get areaWrongTerai => 'This district measures area in terai units (bigha, kattha, dhur), not ropani';

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
}
