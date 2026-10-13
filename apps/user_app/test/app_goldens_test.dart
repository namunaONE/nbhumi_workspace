import 'dart:convert';

import 'package:alchemist/alchemist.dart';
import 'package:auth/auth.dart';
import 'package:auth/l10n/output/auth_localizations.dart' as auth_strings;
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyc/kyc.dart';
import 'package:kyc/l10n/output/kyc_localizations.dart' as kyc_strings;
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
import 'package:listing_detail/listing_detail.dart';
import 'package:models/models.dart';
import 'package:notifications/l10n/output/notifications_localizations.dart'
    as notif_strings;
import 'package:notifications/notifications.dart';
import 'package:post_listing/l10n/output/post_localizations.dart'
    as post_strings;
import 'package:post_listing/post_listing.dart';
import 'package:search/l10n/output/search_localizations.dart' as search_strings;
import 'package:search/search.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/onboarding/onboarding_gate.dart';
import 'package:user_app/screens/activity_screen.dart';
import 'package:user_app/screens/home_screen.dart';
import 'package:user_app/screens/onboarding_screen.dart';
import 'package:user_app/screens/profile_screen.dart';
import 'package:user_app/screens/settings_screen.dart';

/// Design-system regression goldens (HYA-267):
/// 12 screens × light/dark × compact/expanded/large = 72 images.
/// 5 original screens (home, search, detail, post, profile) plus 7 capped in
/// the web-width migration (onboarding, login, settings, activity,
/// notifications, kyc, auth_callback).
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
  const large = Size(1200, 900);

  // Warm the bundled brand fonts before the first pump. AppTheme's getters
  // rebuild per access and every first-use load is async: without warming,
  // a load can finish mid-capture and change text metrics between runs,
  // making goldens flaky. Evaluating the getters fires every load the
  // themes use; pendingFonts drains them (they resolve from bundled
  // assets, so this succeeds offline). Afterwards every load
  // early-returns from google_fonts' cache and rendering is deterministic.
  // Lives here rather than in flutter_test_config: that hook can run
  // before the test binding swaps in TestAssetBundle, and the lookup
  // would miss.
  setUpAll(
    () => GoogleFonts.pendingFonts([AppTheme.light, AppTheme.dark]),
  );

  for (final theme in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
    final themeName = theme == ThemeMode.light ? 'light' : 'dark';
    for (final entry in <({String name, Size size})>[
      (name: 'compact', size: compact),
      (name: 'expanded', size: expanded),
      (name: 'large', size: large),
    ]) {
      // --- Original 5 screens ---
      await _golden(
        'home $themeName ${entry.name}',
        'home_${themeName}_${entry.name}',
        entry.size,
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

      await _golden(
        'search $themeName ${entry.name}',
        'search_${themeName}_${entry.name}',
        entry.size,
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

      await _golden(
        'detail $themeName ${entry.name}',
        'detail_${themeName}_${entry.name}',
        entry.size,
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

      await _golden(
        'post $themeName ${entry.name}',
        'post_${themeName}_${entry.name}',
        entry.size,
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            overrides: [
              districtsProvider.overrideWith((ref) async => const <District>[]),
            ],
            child: const PostListingScreen(),
          ),
        ),
      );

      await _golden(
        'profile $themeName ${entry.name}',
        'profile_${themeName}_${entry.name}',
        entry.size,
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            overrides: [sessionProvider.overrideWithValue(null)],
            child: const ProfileScreen(),
          ),
        ),
      );

      // --- Newly-capped simple screens ---
      await _golden(
        'onboarding $themeName ${entry.name}',
        'onboarding_${themeName}_${entry.name}',
        entry.size,
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            overrides: [
              onboardingGateProvider.overrideWithValue(
                OnboardingGate(seen: false),
              ),
            ],
            child: const OnboardingScreen(),
          ),
        ),
      );

      await _golden(
        'login $themeName ${entry.name}',
        'login_${themeName}_${entry.name}',
        entry.size,
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            overrides: [sessionProvider.overrideWithValue(null)],
            child: const LoginScreen(),
          ),
        ),
      );

      await _golden(
        'settings $themeName ${entry.name}',
        'settings_${themeName}_${entry.name}',
        entry.size,
        builder: () => _Harness(
          theme: theme,
          // No overrides: the controllers read defaults until the user taps,
          // and render-only never writes (settings_screen_test covers taps
          // with mocked prefs).
          child: const ProviderScope(child: SettingsScreen()),
        ),
      );

      await _golden(
        'activity $themeName ${entry.name}',
        'activity_${themeName}_${entry.name}',
        entry.size,
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            // Guest state: deterministic sign-in prompt, no repositories.
            overrides: [sessionProvider.overrideWithValue(null)],
            child: const ActivityScreen(),
          ),
        ),
      );

      await _golden(
        'notifications $themeName ${entry.name}',
        'notifications_${themeName}_${entry.name}',
        entry.size,
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            // Same seam as notifications_screen_test: empty inbox plus a
            // no-op Realtime subscription, never the network (Rule 33).
            overrides: [
              notificationsProvider().overrideWith(
                (ref) async => const <AppNotification>[],
              ),
              notificationsRealtimeProvider.overrideWith((ref) {}),
            ],
            child: const NotificationsScreen(),
          ),
        ),
      );

      await _golden(
        'kyc $themeName ${entry.name}',
        'kyc_${themeName}_${entry.name}',
        entry.size,
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            // Same seam as kyc_screen_test: empty document list (Rule 33).
            overrides: [
              myKycDocumentsProvider.overrideWith(
                (ref) async => const <KycDocument>[],
              ),
              sessionProvider.overrideWithValue(null),
            ],
            child: const KycScreen(),
          ),
        ),
      );

      await _golden(
        'auth_callback $themeName ${entry.name}',
        'auth_callback_${themeName}_${entry.name}',
        entry.size,
        pump: pumpOnce,
        builder: () => _Harness(
          theme: theme,
          child: ProviderScope(
            // Signed-out signing-in branch: deterministic progress copy.
            overrides: [isSignedInProvider.overrideWithValue(false)],
            child: const AuthCallbackScreen(),
          ),
        ),
      );
    }
  }
}

/// Helper to run a golden test with consistent setup.
Future<void> _golden(
  String name,
  String fileName,
  Size size, {
  required Widget Function() builder,
  // Most screens settle. The auth_callback signing-in state shows an
  // indeterminate LinearProgressIndicator, so settling would time out —
  // one pump captures its deterministic first frame instead.
  PumpAction pump = onlyPumpAndSettle,
}) async {
  await goldenTest(
    name,
    fileName: fileName,
    constraints: BoxConstraints.tight(size),
    builder: builder,
    pumpBeforeTest: pump,
  );
}

/// Pumps [child] the way the real app does: the app theme pair with [theme]
/// forced, all localization delegates, and an English locale.
class _Harness extends StatelessWidget {
  const _Harness({required this.theme, required this.child});

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
  }) async => const ListingPage(
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
      ListingDetail.fromJson(jsonDecode(_detailJson) as Map<String, dynamic>);

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
  }) async => true;

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
