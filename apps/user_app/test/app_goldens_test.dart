import 'dart:convert';

import 'package:alchemist/alchemist.dart';
import 'package:auth/l10n/output/auth_localizations.dart' as auth_strings;
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyc/l10n/output/kyc_localizations.dart' as kyc_strings;
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
import 'package:listing_detail/listing_detail.dart';
import 'package:models/models.dart';
import 'package:notifications/l10n/output/notifications_localizations.dart'
    as notif_strings;
import 'package:post_listing/l10n/output/post_localizations.dart'
    as post_strings;
import 'package:post_listing/post_listing.dart';
import 'package:search/l10n/output/search_localizations.dart'
    as search_strings;
import 'package:search/search.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/screens/home_screen.dart';
import 'package:user_app/screens/profile_screen.dart';

/// Design-system regression goldens (HYA-267): 5 key screens x light/dark x
/// compact/expanded = 20 images.
///
/// CI-mode goldens render text as Ahem blocks, so the committed PNGs compare
/// identically on any host. Regenerate deliberately with
/// `flutter test --update-goldens` and review the diff like code — a changed
/// golden is either an intended redesign or a regression, never noise.
///
/// Every screen pumps against fakes (Rule 33): no network, no Supabase, no
/// device plugins. Photo URLs are absent on purpose — `Image.network` never
/// resolves in tests, so fixtures use the placeholder path, which is itself
/// part of what the goldens pin.
Future<void> main() async {
  const compact = Size(400, 800);
  const expanded = Size(1280, 800);

  for (final theme in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
    final themeName = theme == ThemeMode.light ? 'light' : 'dark';
    for (final entry in <({String name, Size size})>[
      (name: 'compact', size: compact),
      (name: 'expanded', size: expanded),
    ]) {
      await goldenTest(
        'home $themeName ${entry.name}',
        fileName: 'home_${themeName}_${entry.name}',
        constraints: BoxConstraints.tight(entry.size),
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            overrides: [
              listingRepositoryProvider.overrideWithValue(
                _FakeListingRepository(),
              ),
            ],
            child: const HomeScreen(),
          ),
        ),
      );

      await goldenTest(
        'search $themeName ${entry.name}',
        fileName: 'search_${themeName}_${entry.name}',
        constraints: BoxConstraints.tight(entry.size),
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            overrides: [
              listingRepositoryProvider.overrideWithValue(
                _FakeListingRepository(),
              ),
            ],
            child: const SearchScreen(),
          ),
        ),
      );

      await goldenTest(
        'detail $themeName ${entry.name}',
        fileName: 'detail_${themeName}_${entry.name}',
        constraints: BoxConstraints.tight(entry.size),
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            overrides: [
              listingRepositoryProvider.overrideWithValue(
                _FixedListingRepository(),
              ),
              favoritesRepositoryProvider.overrideWithValue(
                _FakeFavoritesRepository(),
              ),
              sessionProvider.overrideWithValue(null),
            ],
            child: const ListingDetailScreen(listingId: 'l1'),
          ),
        ),
      );

      await goldenTest(
        'post $themeName ${entry.name}',
        fileName: 'post_${themeName}_${entry.name}',
        constraints: BoxConstraints.tight(entry.size),
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            overrides: [
              districtsProvider.overrideWith(
                (ref) async => const <District>[],
              ),
            ],
            child: const PostListingScreen(),
          ),
        ),
      );

      await goldenTest(
        'profile $themeName ${entry.name}',
        fileName: 'profile_${themeName}_${entry.name}',
        constraints: BoxConstraints.tight(entry.size),
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            overrides: [sessionProvider.overrideWithValue(null)],
            child: const ProfileScreen(),
          ),
        ),
      );
    }
  }
}

/// Pumps [child] the way the real app does: the app theme pair with [theme]
/// forced, all localization delegates, and an English locale.
class _Harness extends StatelessWidget {
  const _Harness({
    required this.theme,
    required this.child,
  });

  final ThemeMode theme;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        auth_strings.AppLocalizations.delegate,
        kyc_strings.AppLocalizations.delegate,
        detail_strings.AppLocalizations.delegate,
        notif_strings.AppLocalizations.delegate,
        post_strings.AppLocalizations.delegate,
        search_strings.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme,
      home: Scaffold(body: child),
    );
  }
}

/// Browse feed backend: two photo-less listings, so cards render their
/// placeholder covers deterministically with no network.
class _FakeListingRepository implements ListingRepository {
  @override
  Future<ListingPage> getListings({
    ListingFilter filter = const ListingFilter(),
    ListingCursor? cursor,
  }) async =>
      const ListingPage(
        listings: <ListingSummary>[
          ListingSummary(
            id: 'l1',
            sellerId: 's1',
            title: 'Shanti Villa',
            priceNpr: 25000000,
            district: 'Kathmandu',
            city: 'Kirtipur',
            propertyType: PropertyType.house,
            listingPurpose: ListingPurpose.sale,
          ),
          ListingSummary(
            id: 'l2',
            sellerId: 's1',
            title: 'Ropani Plot',
            priceNpr: 5000000,
            district: 'Kathmandu',
            city: 'Kirtipur',
            propertyType: PropertyType.land,
            listingPurpose: ListingPurpose.sale,
          ),
        ],
        totalCount: 2,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Detail backend: one canned response, no RPC.
class _FixedListingRepository implements ListingRepository {
  @override
  Future<ListingDetail?> getListingById(String id) async =>
      ListingDetail.fromJson(
        jsonDecode(_detailJson) as Map<String, dynamic>,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Favorites backend for goldens: nothing saved, toggles go nowhere.
///
/// A hand fake rather than an HTTP client so golden runs stay timer-free
/// (a real client starts GoTrue timers that fail teardown).
class _FakeFavoritesRepository implements FavoritesRepository {
  @override
  Future<Set<String>> favoriteIds() async => const <String>{};

  @override
  Future<List<ListingSummary>> savedListings() async =>
      const <ListingSummary>[];

  @override
  Future<bool> toggleFavorite({
    required String userId,
    required String listingId,
  }) async =>
      true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Minimal valid `v1_get_listing_detail` row.
const String _detailJson = '''
{
  "id": "l1",
  "seller_id": "s1",
  "title": "Shanti Villa",
  "description": "A well-kept three-storey house.",
  "price_npr": 25000000,
  "district": "Kathmandu",
  "city": "Kirtipur",
  "ward": "16",
  "property_type": "house",
  "listing_purpose": "sale",
  "status": "live",
  "bedrooms": 3,
  "bathrooms": 2,
  "photos": [],
  "seller": {
    "id": "s1",
    "full_name": "Ram Bahadur",
    "is_verified": true,
    "kyc_tier": "identity",
    "role": "agent",
    "agency_name": "Himal Realtors"
  },
  "is_favorite": false,
  "area_display": "5 aana 4 paisa",
  "created_at": "2026-10-06T12:00:00.000Z",
  "updated_at": "2026-10-06T12:00:00.000Z"
}
''';
