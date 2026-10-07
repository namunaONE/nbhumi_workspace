import 'dart:async';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:search/l10n/output/search_localizations.dart'
    as search_strings;
import 'package:search/search.dart';

ListingSummary _listing(String id) => ListingSummary(
      id: id,
      sellerId: 'seller-1',
      title: 'House $id',
      district: 'Kathmandu',
      city: 'Kathmandu',
      priceNpr: 2500000,
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      createdAt: DateTime.utc(2026),
    );

class _FakeListingRepository implements ListingRepository {
  _FakeListingRepository(this._pages);

  final List<ListingPage> _pages;
  int _calls = 0;

  AppException? failWith;

  /// When set, `getListings` waits on this instead of returning.
  ///
  /// Needed to observe the loading state at all: an `async` body resolves in a
  /// microtask, so by the second frame the feed has already loaded and the
  /// spinner has gone.
  Completer<ListingPage>? gate;

  @override
  Future<ListingPage> getListings({
    ListingFilter filter = const ListingFilter(),
    ListingCursor? cursor,
  }) async {
    _calls++;
    final held = gate;
    if (held != null) await held.future;

    final failure = failWith;
    if (failure != null) {
      failWith = null;
      throw failure;
    }
    final index = _calls <= _pages.length ? _calls - 1 : _pages.length - 1;
    return _pages[index];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

NetworkException _offline() => const NetworkException(
      code: 'network.offline',
      messageEn: 'No connection',
      messageNe: 'इन्टरनेट जडान छैन',
    );

/// Pumps [child] with the feed backed by [repository] (Rule 33).
///
/// [locale] is explicit because the error copy is bilingual (Rule 36) and the
/// default MaterialApp locale is English, which is not what `message()`
/// defaults to on its own.
Future<ProviderContainer> _pump(
  WidgetTester tester,
  _FakeListingRepository repository,
  Widget child, {
  Size size = const Size(360, 800),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [listingRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);

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
        home: Scaffold(body: child),
      ),
    ),
  );
  return container;
}

void main() {
  testWidgets('shows a spinner while the first page loads', (tester) async {
    final repository = _FakeListingRepository([
      ListingPage(listings: [_listing('a')]),
    ])..gate = Completer<ListingPage>();

    await _pump(tester, repository, const BrowseFeed());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.gate!.complete(ListingPage(listings: [_listing('a')]));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('renders the loaded listings', (tester) async {
    final repository = _FakeListingRepository([
      ListingPage(listings: [_listing('a'), _listing('b')], hasMore: true),
    ]);

    await _pump(
      tester,
      repository,
      const BrowseFeed(),
      size: const Size(360, 1200),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListingCard), findsNWidgets(2));
    expect(find.text('House a'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no listings',
      (tester) async {
    final repository = _FakeListingRepository([
      const ListingPage(),
    ]);

    await _pump(tester, repository, const BrowseFeed());
    await tester.pumpAndSettle();

    expect(find.text('No listings found'), findsOneWidget);
    expect(find.byType(ListingCard), findsNothing);
  });

  testWidgets('uses the caller-supplied empty copy', (tester) async {
    final repository = _FakeListingRepository([
      const ListingPage(),
    ]);

    await _pump(
      tester,
      repository,
      const BrowseFeed(
        emptyTitle: 'No properties listed yet',
        emptyBody: 'Be the first to post one.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No properties listed yet'), findsOneWidget);
    expect(find.text('Be the first to post one.'), findsOneWidget);
  });

  testWidgets('shows a retryable error instead of the empty state',
      (tester) async {
    // The critical distinction: a failed request must never render "no
    // listings found", which would claim the search worked and matched nothing.
    final repository = _FakeListingRepository([const ListingPage()])
      ..failWith = _offline();

    await _pump(tester, repository, const BrowseFeed());
    await tester.pumpAndSettle();

    expect(find.text('No listings found'), findsNothing);
    expect(find.text('No connection'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
  });

  testWidgets('retry recovers from an error', (tester) async {
    final repository = _FakeListingRepository([
      ListingPage(listings: [_listing('a')]),
    ])
      ..failWith = _offline();

    await _pump(
      tester,
      repository,
      const BrowseFeed(),
      size: const Size(360, 1200),
    );
    await tester.pumpAndSettle();
    expect(find.text('No connection'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    await tester.pumpAndSettle();

    expect(find.text('No connection'), findsNothing);
    expect(find.text('House a'), findsOneWidget);
  });

  testWidgets('shows the error in Nepali when the locale is Nepali',
      (tester) async {
    // Rule 36 requires both languages. Calling AppException.message() directly
    // would show Nepali here *and* to an English user; this asserts the locale
    // is actually respected.
    final repository = _FakeListingRepository([const ListingPage()])
      ..failWith = _offline();

    await _pump(
      tester,
      repository,
      const BrowseFeed(),
      locale: const Locale('ne'),
    );
    await tester.pumpAndSettle();

    expect(find.text('इन्टरनेट जडान छैन'), findsOneWidget);
    expect(find.text('No connection'), findsNothing);
  });

  testWidgets('an auth failure is distinguished from a network failure',
      (tester) async {
    final repository = _FakeListingRepository([const ListingPage()])
      ..failWith = const AuthFailureException(
        code: 'auth.sessionExpired',
        messageEn: 'Your session has expired.',
        messageNe: 'तपाईंको सत्र समाप्त भयो।',
      );

    await _pump(tester, repository, const BrowseFeed());
    await tester.pumpAndSettle();

    expect(find.text('Your session has expired.'), findsOneWidget);
  });

  testWidgets('keeps loaded rows visible when a later page fails',
      (tester) async {
    final repository = _FakeListingRepository([
      ListingPage(listings: [_listing('a'), _listing('b')], hasMore: true),
      const ListingPage(),
    ]);

    final container = await _pump(
      tester,
      repository,
      const BrowseFeed(),
      size: const Size(360, 1200),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ListingCard), findsNWidgets(2));

    repository.failWith = _offline();
    await container.read(browseProvider.notifier).loadMore();
    await tester.pumpAndSettle();

    // Two visible rows must not be replaced by a full-page error.
    expect(find.byType(ListingCard), findsNWidgets(2));
    expect(find.text('No connection'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);
  });
}
