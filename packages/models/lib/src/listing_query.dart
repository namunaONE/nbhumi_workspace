import 'package:freezed_annotation/freezed_annotation.dart';
import 'listing.dart';
import 'listing_summary.dart';

part 'listing_query.freezed.dart';
part 'listing_query.g.dart';

/// Sort orders supported by `v1_get_listings`.
///
/// The wire values match the `p_sort` enum exactly, so [wireName] can go
/// straight into the RPC params.
enum ListingSort {
  /// Newest first. Uses `created_at` as the keyset key.
  newest('newest'),

  /// Oldest first.
  oldest('oldest'),

  /// Cheapest first.
  priceAsc('price_asc'),

  /// Most expensive first.
  priceDesc('price_desc');

  ListingSort(this.wireName);

  /// The value expected by the `p_sort` RPC parameter.
  final String wireName;
}

/// Opaque keyset cursor.
///
/// `v1_get_listings` uses keyset pagination rather than OFFSET, so it is O(1)
/// at any depth — important because HYA-203 wants infinite scroll from day one.
/// The server returns the sort key and the row id; [k] is a string because the
/// key is a timestamptz for date sorts and a bigint for price sorts.
@freezed
sealed class ListingCursor with _$ListingCursor {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ListingCursor({
    required String k,
    required String id,
  }) = _ListingCursor;

  factory ListingCursor.fromJson(Map<String, dynamic> json) =>
      _$ListingCursorFromJson(json);

  /// Cursor pointing immediately past the supplied listing.
  ///
  /// Throws [ArgumentError] when [last] did not come from a browse response —
  /// silently building a wrong cursor would skip or duplicate rows.
  factory ListingCursor.after(ListingSummary last, ListingSort sort) {
    final k = switch (sort) {
      ListingSort.priceAsc || ListingSort.priceDesc =>
        last.priceNpr.toString(),
      ListingSort.newest || ListingSort.oldest =>
        last.createdAt?.toUtc().toIso8601String() ??
          (throw ArgumentError.value(
            last,
            'last',
            'needs createdAt to build a date-sort cursor',
          )),
    };
    return ListingCursor(k: k, id: last.id);
  }
}

/// Every browse filter, in one immutable value.
///
/// Grouping them means Riverpod can watch the whole query as a single
/// dependency: changing any field produces a new instance and therefore a new
/// equality, which invalidates the feed provider exactly once.
@freezed
sealed class ListingFilter with _$ListingFilter {
  const factory ListingFilter({
    PropertyType? propertyType,
    ListingPurpose? listingPurpose,
    String? district,
    String? municipality,
    int? minPriceNpr,
    int? maxPriceNpr,
    double? minAreaSqm,
    double? maxAreaSqm,

    /// Free-text search. Accepted by the model for UI state; the RPC does not
    /// expose a text filter until a `tsvector` index exists (see SCHEMA.md
    /// "Indexes"). Passing one is a no-op rather than an error so the search
    /// field can ship ahead of the backend.
    String? query,
    @Default(ListingSort.newest) ListingSort sort,
    @Default(20) int pageSize,
  }) = _ListingFilter;

  const ListingFilter._();

  /// True when nothing is narrowing the result set.
  ///
  /// Drives the "clear all" affordance in the filter sheet.
  bool get isEmpty =>
      propertyType == null &&
      listingPurpose == null &&
      district == null &&
      minPriceNpr == null &&
      maxPriceNpr == null &&
      minAreaSqm == null &&
      maxAreaSqm == null;

  /// Number of active filters, for the "Filters (3)" badge on the sheet.
  int get activeCount => [
        propertyType,
        listingPurpose,
        district,
        minPriceNpr,
        maxPriceNpr,
        minAreaSqm,
        maxAreaSqm,
      ].where((v) => v != null).length;

  /// Resets every filter, returning the unfiltered browse query.
  ListingFilter cleared() => const ListingFilter();
}

/// One page of browse results.
@freezed
sealed class ListingPage with _$ListingPage {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ListingPage({
    @Default(<ListingSummary>[]) List<ListingSummary> listings,
    @Default(0) int totalCount,
    @Default(20) int pageSize,
    @Default(false) bool hasMore,
  }) = _ListingPage;

  const ListingPage._();

  factory ListingPage.fromJson(Map<String, dynamic> json) =>
      _$ListingPageFromJson(json);

  /// Cursor for the next page, or null when the feed is exhausted.
  ListingCursor? get nextCursor {
    if (!hasMore || listings.isEmpty) return null;
    return ListingCursor.after(listings.last, ListingSort.newest);
  }

  /// True when the server returned nothing at all.
  ///
  /// Distinct from "the request failed" — the feed shows an empty state for the
  /// former and an error state with retry for the latter.
  bool get isEmpty => listings.isEmpty;
}
