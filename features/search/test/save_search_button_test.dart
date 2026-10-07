import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:search/l10n/output/search_localizations.dart'
    as search_strings;
import 'package:search/search.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A signed-in session, built by hand (Rule 33: no network for a session).
Session _session() => Session(
      accessToken: 'token',
      refreshToken: 'refresh',
      tokenType: 'bearer',
      user: const User(
        id: 'buyer-1',
        appMetadata: <String, dynamic>{},
        userMetadata: <String, dynamic>{},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
      ),
    );

/// Records saved searches without touching the network.
class _FakeSavedSearchRepository implements SavedSearchRepository {
  /// Names stored, in order.
  final List<String> names = <String>[];

  @override
  Future<List<SavedSearch>> savedSearches() async =>
      const <SavedSearch>[];

  @override
  Future<SavedSearch> saveSearch({
    required String userId,
    required String name,
    required ListingFilter filter,
  }) async {
    names.add(name);
    return SavedSearch(
      id: 's${names.length}',
      userId: userId,
      name: name,
      district: filter.district,
    );
  }

  @override
  Future<void> deleteSearch(String id) async {}
}

/// Empty feed backend: the save button never depends on rows.
class _EmptyListingRepository implements ListingRepository {
  @override
  Future<ListingPage> getListings({
    ListingFilter filter = const ListingFilter(),
    ListingCursor? cursor,
  }) async =>
      const ListingPage();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Widget tests for the save-search button (HYA-268 C2b, HYA-266 D2).
///
/// Rule 33: the filter comes from the real [BrowseFilter] notifier (no I/O
/// in it), the session and repository are fakes.
void main() {
  group('SaveSearchButton', () {
    Future<ProviderContainer> pump(
      WidgetTester tester, {
      required Session? session,
      Locale locale = const Locale('en'),
    }) async {
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWithValue(session),
          savedSearchRepositoryProvider.overrideWithValue(
            _FakeSavedSearchRepository(),
          ),
          listingRepositoryProvider.overrideWithValue(
            _EmptyListingRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      // An empty filter hides the button; every test here saves something.
      container.read(browseFilterProvider.notifier).filter =
          const ListingFilter(district: 'Kathmandu');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              search_strings.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
            home: const SearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('hidden while no filter is active', (tester) async {
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWithValue(_session()),
          listingRepositoryProvider.overrideWithValue(
            _EmptyListingRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              search_strings.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: <Locale>[Locale('en'), Locale('ne')],
            home: SearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Save this search'), findsNothing);
    });

    testWidgets('saves with a generated name and confirms', (tester) async {
      final container = await pump(tester, session: _session());
      final repository = container.read(savedSearchRepositoryProvider)
          as _FakeSavedSearchRepository;

      await tester.tap(find.byTooltip('Save this search'));
      await tester.pumpAndSettle();

      expect(repository.names, hasLength(1));
      expect(repository.names.single, contains('Kathmandu'));
      expect(find.textContaining('Saved'), findsOneWidget);
    });

    testWidgets('guests get a sign-in prompt', (tester) async {
      await pump(tester, session: null);

      await tester.tap(find.byTooltip('Save this search'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to save searches.'), findsOneWidget);
    });

    testWidgets('Nepali locale renders Nepali chrome', (tester) async {
      await pump(tester, session: _session(), locale: const Locale('ne'));

      expect(find.text('खोज्नुहोस्'), findsOneWidget);
      expect(find.byTooltip('यो खोजी सेभ गर्नुहोस्'), findsOneWidget);
    });
  });
}
