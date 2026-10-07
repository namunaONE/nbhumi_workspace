// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'search_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Search';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get filtersTooltip => 'Filters';

  @override
  String get searchHint => 'Search by title or location';

  @override
  String get saveSearchTooltip => 'Save this search';

  @override
  String get signInToSave => 'Sign in to save searches.';

  @override
  String savedToast(String name) {
    return 'Saved \"$name\".';
  }

  @override
  String get noMatchTitle => 'No listings match';

  @override
  String get noMatchBody => 'Try removing a filter or widening the price range.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get feedRetryHint => 'Check your connection and try again.';

  @override
  String get feedLaterHint => 'Pull to refresh, or try again in a moment.';

  @override
  String get sheetTitle => 'Filters';

  @override
  String sheetClear(int count) {
    return 'Clear $count';
  }

  @override
  String get sheetCancel => 'Cancel';

  @override
  String get sheetApply => 'Apply';

  @override
  String get labelType => 'Property type';

  @override
  String get labelPurpose => 'Purpose';

  @override
  String get labelPrice => 'Price range (NPR)';

  @override
  String get labelArea => 'Area (sqm)';

  @override
  String get labelSort => 'Sort';

  @override
  String get labelDistrict => 'District';

  @override
  String get fieldMin => 'Min';

  @override
  String get fieldMax => 'Max';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortPriceAsc => 'Price: low to high';

  @override
  String get sortPriceDesc => 'Price: high to low';

  @override
  String get typeLand => 'Land';

  @override
  String get typeHouse => 'Houses';

  @override
  String get typeApartment => 'Apartments';

  @override
  String get typeVilla => 'Villas';

  @override
  String get typeCommercial => 'Commercial';

  @override
  String get typeBusiness => 'Businesses';

  @override
  String get purposeSale => 'Sale';

  @override
  String get purposeRent => 'Rent';

  @override
  String get purposeLease => 'Lease';

  @override
  String savedNameInDistrict(String district) {
    return 'in $district';
  }

  @override
  String savedNameUnderPrice(String price) {
    return 'under $price';
  }

  @override
  String get savedNameFallback => 'Custom search';
}
