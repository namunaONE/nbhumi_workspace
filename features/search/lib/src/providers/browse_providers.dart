import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'browse_providers.g.dart';

/// The active browse query.
///
/// Grouping every filter into one immutable value means the feed can watch the
/// whole query as a single dependency: changing any field produces a new
/// instance, which invalidates the feed exactly once instead of once per field.
class BrowseState {
  /// Creates a browse state.
  const BrowseState({
    this.filter = const ListingFilter(),
    this.listings = const <ListingSummary>[],
    this.cursor,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.totalCount,
    this.loadError,
  });

  /// Filters currently applied.
  final ListingFilter filter;

  /// Listings accumulated so far, oldest page first.
  final List<ListingSummary> listings;

  /// Cursor for the next page, or null once exhausted.
  final ListingCursor? cursor;

  /// Whether another page exists.
  final bool hasMore;

  /// Whether a further page is in flight.
  ///
  /// Tracked separately from the provider's own loading state so a scroll can
  /// show a footer spinner while the existing rows stay on screen, instead of
  /// blanking the list.
  final bool isLoadingMore;

  /// Total matching listings, for the "showing N of M" line.
  final int? totalCount;

  /// Failure from the most recent load, if any.
  final AppException? loadError;

  /// Whether the feed is empty and the load succeeded.
  ///
  /// False whenever [loadError] is set: a failed request must never be reported
  /// as "no listings found".
  bool get isEmpty =>
      loadError == null && listings.isEmpty && !hasMore && cursor == null;

  /// Returns a copy with the given fields replaced.
  BrowseState copyWith({
    ListingFilter? filter,
    List<ListingSummary>? listings,
    ListingCursor? cursor,
    bool? hasMore,
    bool? isLoadingMore,
    int? totalCount,
    AppException? loadError,
    bool clearError = false,
    bool clearCursor = false,
  }) =>
      BrowseState(
        filter: filter ?? this.filter,
        listings: listings ?? this.listings,
        cursor: clearCursor ? null : (cursor ?? this.cursor),
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        totalCount: totalCount ?? this.totalCount,
        loadError: clearError ? null : (loadError ?? this.loadError),
      );
}

/// Browse feed, paginated with a keyset cursor.
///
/// ### Why the cursor, not a page number
///
/// `v1_get_listings` is keyset paginated, so cost is constant at any depth.
/// OFFSET scans every skipped row, which is fine at 20 per page and painful at
/// page 100. HYA-203 wants infinite scroll from day one.
///
/// ### Why retry is disabled
///
/// Riverpod 3.0 retries a failing provider up to 10 times with exponential
/// backoff (200ms to 6.4s), so `provider.future` takes roughly 40 seconds to
/// reject. A user on a bad mobile network would watch a spinner for the best
/// part of a minute instead of seeing an error with a retry button (Rule 36).
///
/// ### Why retry is disabled again
///
/// The default backoff is why. Setting `retry: (count, error) => null` turns it
/// off so a failure surfaces immediately with the retry button below.
@riverpod
class Browse extends _$Browse {
  @override
  Future<BrowseState> build() async {
    final filter = ref.watch(browseFilterProvider);

    try {
      final page = await ref
          .watch(listingRepositoryProvider)
          .getListings(filter: filter);

      return BrowseState(
        filter: filter,
        listings: page.listings,
        cursor: _cursorFor(page, filter),
        hasMore: page.hasMore,
        totalCount: page.totalCount,
      );
    } on AppException catch (e) {
      // The failure becomes state rather than a thrown error, so the feed can
      // show an inline retry instead of an error page. Re-throwing here would
      // also lose the already-loaded rows on any refetch.
      return BrowseState(filter: filter, loadError: e);
    }
  }

  /// Loads the next page and appends it.
  ///
  /// No-op when the feed is exhausted or a load is already in flight, which is
  /// what stops a fast scroll from firing the same request repeatedly.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null) return;
    if (!current.hasMore || current.cursor == null) return;
    if (current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final page = await ref
          .read(listingRepositoryProvider)
          .getListings(filter: current.filter, cursor: current.cursor);

      final nextCursor = _cursorFor(page, current.filter);

      state = AsyncData(
        current.copyWith(
          listings: <ListingSummary>[...current.listings, ...page.listings],
          hasMore: page.hasMore,
          totalCount: page.totalCount,
          isLoadingMore: false,
          clearError: true,
          // Passing a null cursor through copyWith would keep the previous one,
          // because `cursor ?? this.cursor` cannot tell "not supplied" from
          // "explicitly null". An exhausted feed must drop its cursor or it
          // holds a stale key to a page that can never arrive.
          cursor: nextCursor,
          clearCursor: nextCursor == null,
        ),
      );
    } on AppException catch (e) {
      // Keeps the rows already on screen. Blanking a 40-item list because page
      // three failed is worse than showing a retry under the existing items.
      state = AsyncData(current.copyWith(isLoadingMore: false, loadError: e));
    }
  }

  /// Retries a failed load, or refetches after a pull-to-refresh.
  ///
  /// There is deliberately no `applyFilter`. New filters reach this provider
  /// through `BrowseFilter`, which it watches; a method here that set the
  /// filter would create the dependency cycle described on that class.
  void retry() => ref.invalidateSelf();

  /// Cursor for the page just fetched.
  ///
  /// [ListingPage.nextCursor] hardcodes a newest sort, which would silently
  /// paginate wrongly the moment the user switches to price ordering. The
  /// cursor has to be built against the sort that produced the page.
  ListingCursor? _cursorFor(ListingPage page, ListingFilter filter) {
    if (!page.hasMore || page.listings.isEmpty) return null;
    return ListingCursor.after(page.listings.last, filter.sort);
  }
}

/// The filters currently applied to the feed.
///
/// Separate from [Browse] so a widget can watch and edit the filters without
/// also rebuilding on every page load.
@riverpod
class BrowseFilter extends _$BrowseFilter {
  @override
  ListingFilter build() => const ListingFilter();

  /// The filters currently applied.
  ///
  /// Exposed as a plain property rather than a `set(...)` method so callers
  /// write `notifier.filter = ...`, which is what assigning state means here.
  ListingFilter get filter => state;

  /// Replaces the filter set.
  ///
  /// Assigning state is the entire refetch mechanism. `Browse` watches this
  /// provider, so a new [ListingFilter] rebuilds the feed by itself. It must
  /// not also invalidate the feed here: reading `browseProvider` from inside
  /// this provider's scope is a dependency cycle, because that is precisely
  /// the provider watching this one.
  set filter(ListingFilter value) => state = value;

  /// Clears every filter.
  void clear() => filter = const ListingFilter();
}
