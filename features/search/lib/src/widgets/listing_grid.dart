import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';

/// Results presentation for [ListingGrid].
///
/// Grid is the default browse surface: vertical cards in adaptive columns.
/// List renders the same rows as dense horizontal cards for fast scanning.
enum ListingLayout {
  /// Vertical cards in adaptive columns.
  grid,

  /// Dense horizontal rows in a single scrolling list.
  list,
}

/// A paginated grid of listing cards that loads more as the user scrolls.
///
/// Takes plain data and callbacks rather than reading providers, so Home and
/// Search share it and it can be tested by pumping rows directly.
class ListingGrid extends StatefulWidget {
  /// Creates a listing grid.
  const ListingGrid({
    required this.listings,
    required this.onLoadMore,
    this.onRefresh,
    this.onListingTap,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.layout = ListingLayout.grid,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.lg,
    ),
    super.key,
  });

  /// Rows to render.
  final List<ListingSummary> listings;

  /// Called when the user scrolls near the end.
  final Future<void> Function() onLoadMore;

  /// Called on pull-to-refresh.
  final FutureOr<void> Function()? onRefresh;

  /// Called with the id of a tapped listing.
  final void Function(String id)? onListingTap;

  /// Whether a further page is in flight.
  final bool isLoadingMore;

  /// Whether another page exists.
  final bool hasMore;

  /// Grid or list presentation. List uses horizontal row cards.
  final ListingLayout layout;

  /// Padding around the grid.
  final EdgeInsets padding;

  /// Cards per row for a given available width.
  ///
  /// Derived from a minimum card width rather than the Material 600/840
  /// breakpoints: a card is about 180 logical px wide, so the column count
  /// should follow how many actually fit rather than stepping at an arbitrary
  /// viewport width. Clamped to 1-3 because WIREFRAMES.md specifies no more.
  ///
  /// The spacing is folded into the divisor. Plain `width / minCardWidth`
  /// overcounts: it ignores that `n` columns need `n - 1` gaps between them, so
  /// at 362px it would return 2 columns and then hand each card 175px — under
  /// [minCardWidth]. Solving `(w + s) / (m + s) >= n` for `n` gives the fit
  /// condition exactly, so no width ever produces a too-narrow card.
  static int columnsFor(double availableWidth) {
    final fit = (availableWidth + crossAxisSpacing) /
        (minCardWidth + crossAxisSpacing);
    return fit.floor().clamp(1, maxColumns);
  }

  /// Narrowest a card may become before a column is dropped.
  static const double minCardWidth = 180;

  /// Gap between cards, matching the grid delegate below.
  static const double crossAxisSpacing = 12;

  /// WIREFRAMES.md specifies at most three cards per row.
  static const int maxColumns = 3;

  @override
  State<ListingGrid> createState() => _ListingGridState();
}

class _ListingGridState extends State<ListingGrid> {
  /// Pixels from the bottom at which the next page starts loading.
  ///
  /// Roughly two rows of runway, enough to cover the round trip on a slow
  /// connection without the user ever seeing the footer spinner while scrolling
  /// deliberately.
  static const double _loadMoreThreshold = 600;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;
    if (!_controller.hasClients) return;

    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      unawaited(widget.onLoadMore());
    }
  }

  /// Single-column list of horizontal row cards with the same pagination.
  Widget _buildList() {
    return ListView.builder(
      controller: _controller,
      padding: widget.padding,
      // AlwaysScrollable so pull-to-refresh works even when the list is
      // shorter than the viewport.
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.listings.length + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.listings.length) {
          return const SizedBox(
            height: AppSizes.loadingRowHeight,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final listing = widget.listings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: HorizontalListingCard(
            listing: listing,
            onTap: widget.onListingTap == null
                ? null
                : () => widget.onListingTap!(listing.id),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final grid = widget.layout == ListingLayout.list
        ? _buildList()
        : LayoutBuilder(
            builder: (context, constraints) {
              final columns = ListingGrid.columnsFor(
                constraints.maxWidth - widget.padding.horizontal,
              );
              // Per-card density: narrow columns get the compact card so
              // text stays legible on phones, tablets, and expanded
              // layouts alike.
              final cardWidth = (constraints.maxWidth -
                      widget.padding.horizontal -
                      (columns - 1) * ListingGrid.crossAxisSpacing) /
                  columns;
              final compact = cardWidth < AppSizes.compactCardThreshold;

              return GridView.builder(
                controller: _controller,
                padding: widget.padding,
                // AlwaysScrollable so pull-to-refresh works even when the
                // grid is shorter than the viewport.
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount:
                    widget.listings.length + (widget.isLoadingMore ? 1 : 0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: ListingGrid.crossAxisSpacing,
                  crossAxisSpacing: ListingGrid.crossAxisSpacing,
                  // Fits the 4:3 cover photo plus the four-row text block
                  // (title, location+area, price, type chip). Was 0.72:
                  // the HYA-267 goldens proved a 0.72 cell clips ~45px of
                  // card on narrow two-column phones (silently in release
                  // via the card's Clip.antiAlias, so the area row simply
                  // vanished). 0.60 held the old five-row card; the rework
                  // merges area into location and drops the duplicate
                  // purpose row, so 0.64 holds the shorter card with slack
                  // left for larger text.
                  childAspectRatio: 0.64,
                ),
                itemBuilder: (context, index) {
                  if (index == widget.listings.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final listing = widget.listings[index];
                  return ListingCard(
                    listing: listing,
                    compact: compact,
                    onTap: widget.onListingTap == null
                        ? null
                        : () => widget.onListingTap!(listing.id),
                  );
                },
              );
            },
          );

    // Wide windows would otherwise stretch the content edge to edge: cap
    // the width and center it, keeping phone layouts untouched. The cap
    // sits outside the scrollable so pull-to-refresh keeps full width.
    final capped = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppSizes.contentMaxWidth,
        ),
        child: grid,
      ),
    );

    if (widget.onRefresh == null) return capped;

    // Wrapped so a synchronous `retry` still satisfies RefreshCallback, which
    // needs a Future to keep the spinner up.
    return RefreshIndicator(
      onRefresh: () async {
        await widget.onRefresh!();
      },
      child: capped,
    );
  }
}
