import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';

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
    this.padding = const EdgeInsets.all(12),
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

  @override
  Widget build(BuildContext context) {
    final grid = LayoutBuilder(
      builder: (context, constraints) {
        final columns = ListingGrid.columnsFor(
          constraints.maxWidth - widget.padding.horizontal,
        );

        return GridView.builder(
          controller: _controller,
          padding: widget.padding,
          // AlwaysScrollable so pull-to-refresh works even when the grid is
          // shorter than the viewport.
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.listings.length + (widget.isLoadingMore ? 1 : 0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: ListingGrid.crossAxisSpacing,
            crossAxisSpacing: ListingGrid.crossAxisSpacing,
            // Tuned for the 160dp cover photo plus the text block beneath it.
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            if (index == widget.listings.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final listing = widget.listings[index];
            return ListingCard(
              listing: listing,
              onTap: widget.onListingTap == null
                  ? null
                  : () => widget.onListingTap!(listing.id),
            );
          },
        );
      },
    );

    if (widget.onRefresh == null) return grid;

    // Wrapped so a synchronous `retry` still satisfies RefreshCallback, which
    // needs a Future to keep the spinner up.
    return RefreshIndicator(
      onRefresh: () async {
        await widget.onRefresh!();
      },
      child: grid,
    );
  }
}
