import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'search_localizations_en.dart';
import 'search_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'output/search_localizations.dart';
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

  /// Search screen app bar.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get title;

  /// Sort menu button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// Filter sheet button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTooltip;

  /// Results layout toggle tooltip when showing the grid.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get viewListTooltip;

  /// Results layout toggle tooltip when showing the list.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get viewGridTooltip;

  /// Featured newest-listings row heading on Explore.
  ///
  /// In en, this message translates to:
  /// **'Latest listings'**
  String get featuredTitle;

  /// Title/location query field hint.
  ///
  /// In en, this message translates to:
  /// **'Search by title or location'**
  String get searchHint;

  /// Save-search button tooltip (HYA-268 C2b).
  ///
  /// In en, this message translates to:
  /// **'Save this search'**
  String get saveSearchTooltip;

  /// Prompt when a guest taps save-search.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save searches.'**
  String get signInToSave;

  /// Confirmation naming the stored search.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{name}\".'**
  String savedToast(String name);

  /// Empty feed heading.
  ///
  /// In en, this message translates to:
  /// **'No listings match'**
  String get noMatchTitle;

  /// Empty feed explanation.
  ///
  /// In en, this message translates to:
  /// **'Try removing a filter or widening the price range.'**
  String get noMatchBody;

  /// Feed retry action.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Hint under a retryable feed failure.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get feedRetryHint;

  /// Hint under a non-retryable feed failure.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh, or try again in a moment.'**
  String get feedLaterHint;

  /// Filter sheet heading.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get sheetTitle;

  /// Clear-all action with the active count.
  ///
  /// In en, this message translates to:
  /// **'Clear {count}'**
  String sheetClear(int count);

  /// Sheet cancel action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sheetCancel;

  /// Sheet apply action.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get sheetApply;

  /// Property-type section label.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get labelType;

  /// Purpose section label.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get labelPurpose;

  /// Price range section label.
  ///
  /// In en, this message translates to:
  /// **'Price range (NPR)'**
  String get labelPrice;

  /// Area section label.
  ///
  /// In en, this message translates to:
  /// **'Area (sqm)'**
  String get labelArea;

  /// Sort section label.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get labelSort;

  /// District section label.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get labelDistrict;

  /// Range minimum field label.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get fieldMin;

  /// Range maximum field label.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get fieldMax;

  /// Newest-first sort chip.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// Oldest-first sort chip.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOldest;

  /// Cheapest-first sort chip.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceAsc;

  /// Most-expensive-first sort chip.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceDesc;

  /// Land type chip and saved-name word.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get typeLand;

  /// House type chip and saved-name word.
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get typeHouse;

  /// Apartment type chip and saved-name word.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get typeApartment;

  /// Villa type chip and saved-name word.
  ///
  /// In en, this message translates to:
  /// **'Villas'**
  String get typeVilla;

  /// Commercial type chip and saved-name word.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get typeCommercial;

  /// Business type chip and saved-name word.
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get typeBusiness;

  /// Sale purpose chip.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get purposeSale;

  /// Rent purpose chip.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get purposeRent;

  /// Lease purpose chip.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get purposeLease;

  /// District segment of a generated saved-search name.
  ///
  /// In en, this message translates to:
  /// **'in {district}'**
  String savedNameInDistrict(String district);

  /// Price-cap segment of a generated saved-search name.
  ///
  /// In en, this message translates to:
  /// **'under {price}'**
  String savedNameUnderPrice(String price);

  /// Name when the filter has no describable part.
  ///
  /// In en, this message translates to:
  /// **'Custom search'**
  String get savedNameFallback;
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
