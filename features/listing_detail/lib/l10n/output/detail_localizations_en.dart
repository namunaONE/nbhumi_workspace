// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'detail_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sectionLocation => 'Location';

  @override
  String get sectionDetails => 'Details';

  @override
  String get sectionDescription => 'Description';

  @override
  String get sectionSeller => 'Seller';

  @override
  String specRoadAccess(int feet) {
    return '$feet ft road access';
  }

  @override
  String specBedrooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bedrooms',
      one: '1 bedroom',
    );
    return '$_temp0';
  }

  @override
  String specBathrooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bathrooms',
      one: '1 bathroom',
    );
    return '$_temp0';
  }

  @override
  String specWard(String city, String ward) {
    return '$city, Ward $ward';
  }

  @override
  String get sellerUnavailable => 'Seller details unavailable';

  @override
  String get favoriteSave => 'Save this property';

  @override
  String get favoriteRemove => 'Remove from saved';

  @override
  String get favoriteSaved => 'Saved to your list.';

  @override
  String get favoriteRemoved => 'Removed from your saved list.';

  @override
  String get notAvailableTitle => 'This property is no longer available';

  @override
  String get notAvailableBody =>
      'It may have been sold, withdrawn by the seller, or the link may be wrong.';

  @override
  String get browseOthers => 'Browse other properties';

  @override
  String get tryAgain => 'Try again';

  @override
  String get loadRetryHint => 'Check your connection and try again.';

  @override
  String get contactLoading => 'Loading…';

  @override
  String get contactSignIn => 'Sign in to contact';

  @override
  String get contactSeller => 'Contact seller';

  @override
  String get contactPhone => 'Phone';

  @override
  String get contactEmail => 'Email';

  @override
  String get contactCopy => 'Copy';

  @override
  String contactCopied(String label) {
    return '$label copied';
  }

  @override
  String get reportTooltip => 'Report this listing';

  @override
  String get reportFiled => 'Report filed. Our team will review it.';

  @override
  String get reportTitle => 'Report this listing';

  @override
  String get reportReasonLabel => 'Reason';

  @override
  String get reportDetailsRequired => 'Details *';

  @override
  String get reportDetailsOptional => 'Details (optional)';

  @override
  String get reportDetailsError =>
      'Please describe the problem so our team can act on it.';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reasonDuplicate => 'Duplicate listing';

  @override
  String get reasonPhotos => 'Photos are misleading';

  @override
  String get reasonPrice => 'Price looks wrong';

  @override
  String get reasonLocation => 'Wrong location';

  @override
  String get reasonSold => 'Already sold';

  @override
  String get reasonOffsite => 'Seller asked to deal off-site';

  @override
  String get reasonFake => 'Fake listing';

  @override
  String get reasonOther => 'Other';

  @override
  String get typeLand => 'Land';

  @override
  String get typeHouse => 'House';

  @override
  String get typeApartment => 'Apartment';

  @override
  String get typeVilla => 'Villa';

  @override
  String get typeCommercial => 'Commercial';

  @override
  String get typeBusiness => 'Business';

  @override
  String get purposeSale => 'Sale';

  @override
  String get purposeRent => 'Rent';

  @override
  String get purposeLease => 'Lease';

  @override
  String get verifiedListing => 'Verified Listing';

  @override
  String get verifiedListingBody =>
      'Our admin team checked the lalpurja attached to this listing. This is a document check only — never a legal opinion on ownership or title. Ownership transfers are completed at Malpot.';

  @override
  String get verifiedListingUnderstood => 'Understood';

  @override
  String get detailPageTitle => 'Property details';

  @override
  String get verifyThisListing => 'Verify this listing';
}
