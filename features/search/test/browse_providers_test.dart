import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:search/search.dart';

ListingSummary _listing(String id, {int price = 1000000}) => ListingSummary(
      id: id,
      sellerId: 'seller-1',
      title: 'House $id',
      district: 'Kathmandu',
      city: 'Kathmandu',
      priceNpr: price,
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      createdAt: DateTime.utc(2026),
    );

ListingPage _page(List<ListingSummary> rows, {bool hasMore = false}) =>
    ListingPage(
      listings: rows,
      totalCount: rows.length,
      hasMore: hasMore,
    );

/// Repository stub that records the filters and cursors it was called with.
///
/// Stands in at the Repository seam so the test exercises the ViewModel logic —
/// cursor construction, appending, dedupe, error retention — without a network
/// or a real Supabase client (Rule 31).
class _FakeListingRepository implements ListingRepository {
  _FakeListingRepository(this._responses);

  final List<ListingPage> _responses;
  final List<({ListingFilter filter, ListingCursor? cursor})> calls = [];
  int _next = 0;

  /// When set, thrown by the next call instead of returning a page.
  AppException? failWith;

  @override
  Future<ListingPage> getListings({
    ListingFilter filter = const ListingFilter(),
    ListingCursor? cursor,
  }) async {
    calls.add((filter: filter, cursor: cursor));

    final failure = failWith;
    if (failure != null) {
      failWith = null;
      throw failure;
    }

    // Repeats the final page once the script runs out, so an unexpected extra
    // request shows up as duplicate rows rather than a range error.
    final index = _next < _responses.length ? _next++ : _responses.length - 1;
    return _responses[index];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Builds a container whose repository provider is overridden (Rule 33).
ProviderContainer _container(_FakeListingRepository repository) {
  final container = ProviderContainer(
    overrides: [listingRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

NetworkException _offline() => const NetworkException(
      code: 'network.offline',
      messageEn: 'No connection',
      messageNe: 'इन्टरनेट जडान छैन',
    );

void main() {
  group('BrowseState', () {
    test('a feed awaiting its first page is not empty', () {
      // Loading is carried by the AsyncValue wrapper, not by this state, so a
      // default state is still "nothing to show yet" rather than "no results".
      const state = BrowseState();
      expect(state.isEmpty, isFalse);
      expect(state.hasMore, isTrue);
    });

    test('an exhausted feed with no rows is empty', () {
      const state = BrowseState(hasMore: false);
      expect(state.isEmpty, isTrue);
    });

    test('a failed load is not empty', () {
      // Otherwise the error would be reported as "no listings found", which is
      // the one thing a failed request must never claim.
      final state = BrowseState(loadError: _offline(), hasMore: false);
      expect(state.isEmpty, isFalse);
    });

    test('a feed with rows is not empty even when exhausted', () {
      final state = BrowseState(
        listings: [_listing('a')],
        hasMore: false,
      );
      expect(state.isEmpty, isFalse);
    });

    test('copyWith can clear the error', () {
      final state = BrowseState(loadError: _offline());
      expect(state.copyWith(clearError: true).loadError, isNull);
    });

    test('copyWith can clear the cursor', () {
      const state = BrowseState(
        cursor: ListingCursor(k: '1', id: 'a'),
      );
      expect(state.copyWith(clearCursor: true).cursor, isNull);
    });
  });

  group('Browse paging', () {
    test('loads the first page with no cursor', () async {
      final repository = _FakeListingRepository([_page([_listing('a')])]);
      final container = _container(repository);

      final state = await container.read(browseProvider.future);

      expect(state.listings.map((l) => l.id), <String>['a']);
      expect(repository.calls.single.cursor, isNull);
      expect(repository.calls.single.filter, const ListingFilter());
    });

    test('builds a cursor from the last row of the page',
        () async {
      final repository = _FakeListingRepository([
        _page([_listing('a'), _listing('b')], hasMore: true),
      ]);
      final container = _container(repository);

      final state = await container.read(browseProvider.future);

      // Keyset pagination is only correct if the cursor names the last row
      // actually returned, or rows get skipped or repeated.
      expect(state.cursor?.id, 'b');
      expect(state.hasMore, isTrue);
    });

    test('appends the next page and advances the cursor',
        () async {
      final repository = _FakeListingRepository([
        _page([_listing('a'), _listing('b')], hasMore: true),
        _page([_listing('c')]),
      ]);
      final container = _container(repository);
      await container.read(browseProvider.future);

      await container.read(browseProvider.notifier).loadMore();
      final state = container.read(browseProvider).value!;

      expect(state.listings.map((l) => l.id), <String>['a', 'b', 'c']);
      expect(repository.calls.last.cursor?.id, 'b');
      expect(state.hasMore, isFalse);
      // An exhausted feed must drop its cursor, or the grid would keep asking
      // for a page that can never exist.
      expect(state.cursor, isNull);
      expect(state.isLoadingMore, isFalse);
    });

    test('ignores loadMore once the feed is exhausted',
        () async {
      final repository = _FakeListingRepository([
        _page([_listing('a')]),
      ]);
      final container = _container(repository);
      await container.read(browseProvider.future);

      await container.read(browseProvider.notifier).loadMore();
      await container.read(browseProvider.notifier).loadMore();

      expect(repository.calls.length, 1);
    });

    test('ignores a second loadMore while one is in flight',
        () async {
      // A fast scroll fires the threshold repeatedly. Without the in-flight
      // guard the same page is requested several times and appended twice.
      final repository = _FakeListingRepository([
        _page([_listing('a')], hasMore: true),
        _page([_listing('b')]),
      ]);
      final container = _container(repository);
      await container.read(browseProvider.future);

      final notifier = container.read(browseProvider.notifier);
      await Future.wait<void>([notifier.loadMore(), notifier.loadMore()]);

      expect(repository.calls.length, 2);
      expect(
        container.read(browseProvider).value!.listings.map((l) => l.id),
        <String>['a', 'b'],
      );
    });

    test('builds a price cursor when sorting by price',
        () async {
      // ListingPage.nextCursor hardcodes the newest sort, which would paginate
      // wrongly the moment the user chose price ordering.
      final repository = _FakeListingRepository([
        _page([_listing('a', price: 500), _listing('b', price: 900)],
            hasMore: true),
      ]);
      final container = _container(repository);
      container.read(browseFilterProvider.notifier).filter =
          const ListingFilter(sort: ListingSort.priceAsc);
      await container.read(browseProvider.future);

      expect(container.read(browseProvider).value!.cursor?.k, '900');
    });

    test('passes the active filter through to the repository',
        () async {
      final repository =
          _FakeListingRepository([_page(const <ListingSummary>[])]);
      final container = _container(repository);

      container.read(browseFilterProvider.notifier).filter =
          const ListingFilter(district: 'Lalitpur');
      await container.read(browseProvider.future);

      expect(repository.calls.last.filter.district, 'Lalitpur');
    });
  });

  group('Browse failures', () {
    test('surfaces a first-load failure as state, not a throw',
        () async {
      final repository =
          _FakeListingRepository([_page(const <ListingSummary>[])])
        ..failWith = _offline();
      final container = _container(repository);

      // Reaching `.future` at all is the assertion: a thrown error would leave
      // the feed showing nothing but a spinner with no retry.
      final state = await container.read(browseProvider.future);

      expect(state.loadError, isNotNull);
      expect(state.isEmpty, isFalse);
    });

    test('keeps already-loaded rows when a later page fails',
        () async {
      final repository = _FakeListingRepository([
        _page([_listing('a'), _listing('b')], hasMore: true),
        _page(const <ListingSummary>[]),
      ])..failWith = _offline();
      final container = _container(repository);

      // Fail only the second call, so page one is present and page two is not.
      repository.failWith = null;
      await container.read(browseProvider.future);
      repository.failWith = _offline();

      await container.read(browseProvider.notifier).loadMore();
      final state = container.read(browseProvider).value!;

      // Blanking two visible rows because page two failed is the bug this
      // guards against.
      expect(state.listings.map((l) => l.id), <String>['a', 'b']);
      expect(state.loadError, isNotNull);
      expect(state.isLoadingMore, isFalse);
    });

    test('retry clears the error and refetches', () async {
      final repository = _FakeListingRepository([
        _page(const <ListingSummary>[]),
        _page([_listing('a')]),
      ]);
      final container = _container(repository);
      await container.read(browseProvider.future);

      container.read(browseProvider.notifier).retry();
      final state = await container.read(browseProvider.future);

      expect(state.loadError, isNull);
      expect(state.listings, hasLength(1));
    });
  });

  group('BrowseFilter', () {
    test('starts unfiltered', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(browseFilterProvider).isEmpty, isTrue);
      expect(container.read(browseFilterProvider).sort, ListingSort.newest);
    });

    test('clear removes every filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(browseFilterProvider.notifier)
        ..filter = const ListingFilter(
          district: 'Bhaktapur',
          minPriceNpr: 100,
          listingPurpose: ListingPurpose.rent,
        );
      expect(container.read(browseFilterProvider).activeCount, 3);

      notifier.clear();
      expect(container.read(browseFilterProvider).isEmpty, isTrue);
    });

    test('setting the same filter does not refetch', () {
      // Otherwise tapping Apply twice on an unchanged sheet fires two requests.
      final repository =
          _FakeListingRepository([_page(const <ListingSummary>[])]);
      final container = _container(repository);
      container.read(browseFilterProvider.notifier)
        ..filter = const ListingFilter(district: 'Bhaktapur')
        ..filter = const ListingFilter(district: 'Bhaktapur');

      container.read(browseProvider); // builds once
      expect(repository.calls.length, 1);
    });
  });
}
