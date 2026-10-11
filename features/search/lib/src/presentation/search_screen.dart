import 'dart:async';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:search/l10n/output/search_localizations.dart'
    as search_strings;

import '../providers/browse_providers.dart';
import '../utils/search_labels.dart';
import '../widgets/browse_feed.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/listing_grid.dart';
import 'filter_sheet.dart';

/// Search listings.
///
/// Composes the filter bar with [BrowseFeed], so results, empty state and
/// errors behave identically to the Home feed. Filtering state lives in
/// `BrowseFilter` rather than in widget state, which is what lets Home and
/// Search share one feed.
class SearchScreen extends ConsumerStatefulWidget {
  /// Creates the search screen.
  const SearchScreen({
    this.title,
    this.actions,
    this.detailPaneBuilder,
    super.key,
  });

  /// Overrides the app-bar title. Null keeps the feature string; the app
  /// passes its tab title when hosting this screen as Explore.
  final String? title;

  /// Extra app-bar actions appended after the built-in ones. The app injects
  /// chrome the feature must not own (e.g. the notification bell) here.
  final List<Widget>? actions;

  /// Builds the wide-layout detail side pane for a listing id.
  ///
  /// A seam, not a feature import: `search` may not import `listing_detail`
  /// (Rule 10), so the app wires the real pane through the router while
  /// tests pump the screen bare (a tap pushes the full route, as on phones).
  /// Null disables the side pane on all widths.
  final Widget Function(String listingId, VoidCallback onClose)?
      detailPaneBuilder;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  /// Grid or list results. Local UI state: unlike the filter, the layout
  /// choice is presentation-only and must not leak into the shared browse
  /// session that Home reads.
  ListingLayout _layout = ListingLayout.grid;

  /// Listing shown in the side pane on wide windows. Null keeps the
  /// single-pane feed; the pane's close button clears it.
  String? _selectedId;

  /// Whether a tap selects into the side pane rather than pushing a route.
  ///
  /// The threshold is the shell's own `twoPane`, read from `core` because
  /// features cannot import an app (Rule 10) and the shell reads the same one.
  bool _selectsInPlace(BuildContext context) =>
      widget.detailPaneBuilder != null &&
      MediaQuery.sizeOf(context).width >= AppBreakpoints.twoPane;

  /// Opens a listing in place on wide windows, or pushes the route.
  void _openListing(String id) {
    if (_selectsInPlace(context)) {
      setState(() => _selectedId = id);
    } else {
      unawaited(context.push('/listing/$id'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(browseFilterProvider);
    final strings = search_strings.AppLocalizations.of(context);
    final showingList = _layout == ListingLayout.list;
    final selectedId = _selectedId;

    final feed = BrowseFeed(
      // `context.push`, not `Navigator.pushNamed`: the detail route sits on
      // the root navigator, which a plain Navigator lookup from this branch
      // cannot reach.
      onListingTap: _openListing,
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _QueryField(filter: filter),
          // Featured row only for the unfiltered browse-all surface: above
          // narrowed results it would push the matches down the screen.
          if (filter.isEmpty) FeaturedCarousel(onListingTap: _openListing),
        ],
      ),
      layout: _layout,
      emptyTitle: strings.noMatchTitle,
      emptyBody: strings.noMatchBody,
    );

    return PageTitle(
      title: widget.title ?? strings.title,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? strings.title),
        actions: <Widget>[
          _SortButton(filter: filter),
          _FilterButton(activeCount: filter.activeCount),
          IconButton(
            icon: Icon(showingList ? Icons.grid_view : Icons.view_list),
            tooltip: showingList
                ? strings.viewGridTooltip
                : strings.viewListTooltip,
            onPressed: () => setState(() {
              _layout =
                  showingList ? ListingLayout.grid : ListingLayout.list;
            }),
          ),
          _SaveSearchButton(filter: filter),
          ...?widget.actions,
          const SizedBox(width: 4),
        ],
      ),
      body: selectedId != null && _selectsInPlace(context)
          ? Row(
              children: <Widget>[
                Expanded(child: feed),
                const VerticalDivider(width: 1),
                Expanded(
                  child: widget.detailPaneBuilder!(
                    selectedId,
                    () => setState(() => _selectedId = null),
                  ),
                ),
              ],
            )
          : feed,
      ),
    );
  }
}

/// Free-text query field.
///
/// The RPC exposes no text filter until a `tsvector` index exists, so this
/// records intent without pretending to filter. Wired to be enabled the moment
/// that index lands, rather than being removed and re-added later.
class _QueryField extends ConsumerStatefulWidget {
  const _QueryField({required this.filter});

  final ListingFilter filter;

  @override
  ConsumerState<_QueryField> createState() => _QueryFieldState();
}

class _QueryFieldState extends ConsumerState<_QueryField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.filter.query ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = search_strings.AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: strings.searchHint,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                  },
                ),
        ),
        onChanged: (value) => setState(() {}),
        onSubmitted: (value) => ref.read(browseFilterProvider.notifier).filter =
            widget.filter.copyWith(query: value),
      ),
    );
  }
}

class _FilterButton extends ConsumerWidget {
  const _FilterButton({required this.activeCount});

  final int activeCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = search_strings.AppLocalizations.of(context);
    return Badge(
      isLabelVisible: activeCount > 0,
      label: Text('$activeCount'),
      child: IconButton(
        icon: const Icon(Icons.tune),
        tooltip: strings.filtersTooltip,
        onPressed: () => _open(context, ref),
      ),
    );
  }

  /// Opens the sheet and applies the result.
  ///
  /// Takes [WidgetRef] rather than reading it from a field: a ConsumerWidget
  /// has no persistent ref, it only exists for the duration of `build`, and
  /// this continuation runs long after `build` has returned.
  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final applied = await FilterSheet.show(context);
    // The sheet's own route may outlive this screen.
    if (applied == null || !context.mounted) return;
    ref.read(browseFilterProvider.notifier).filter = applied;
  }
}

class _SortButton extends ConsumerWidget {
  const _SortButton({required this.filter});

  final ListingFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = search_strings.AppLocalizations.of(context);
    return PopupMenuButton<ListingSort>(
      icon: const Icon(Icons.swap_vert),
      tooltip: strings.sortTooltip,
      initialValue: filter.sort,
      onSelected: (sort) => ref
              .read(browseFilterProvider.notifier)
              .filter = filter.copyWith(sort: sort),
      itemBuilder: (context) => <PopupMenuEntry<ListingSort>>[
        for (final sort in ListingSort.values)
          PopupMenuItem<ListingSort>(
            value: sort,
            child: Text(searchSortLabel(context, sort)),
          ),
      ],
    );
  }
}

/// Stores the current filter set as a named saved search.
///
/// Hidden while no filter is active: an unfiltered "everything" search would
/// alert on every listing in the country, and the repository refuses it, so
/// offering the button there would only ever error.
class _SaveSearchButton extends ConsumerWidget {
  const _SaveSearchButton({required this.filter});

  final ListingFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filter.isEmpty) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.bookmark_add_outlined),
      tooltip:
          search_strings.AppLocalizations.of(context).saveSearchTooltip,
      onPressed: () => _save(context, ref),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = search_strings.AppLocalizations.of(context);
    final session = ref.read(sessionProvider);
    if (session == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.signInToSave),
        ),
      );
      return;
    }

    try {
      await ref.read(savedSearchRepositoryProvider).saveSearch(
            userId: session.user.id,
            name: _describeFilter(context, filter),
            filter: filter,
          );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.savedToast(_describeFilter(context, filter))),
        ),
      );
    } on AppException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.localizedForContext(context)),
          action: e.isRetryable
              ? SnackBarAction(
                  label: 'Retry',
                  onPressed: () => _save(context, ref),
                )
              : null,
        ),
      );
    }
  }
}

/// Human name for a filter set, for the saved-search row.
///
/// Localized per HYA-266 D2: parts are translated individually and composed
/// in a fixed [type, district, price] order that reads naturally in both
/// languages. Built from the same fields the matcher will compare, so the
/// name always describes what the alert actually watches.
String _describeFilter(BuildContext context, ListingFilter filter) {
  final strings = search_strings.AppLocalizations.of(context);
  final parts = <String>[
    if (filter.propertyType case final type?)
      '${searchTypeLabel(context, type)} ${searchPurposeLabel(
        context,
        filter.listingPurpose,
      )}',
    if (filter.propertyType == null)
      if (filter.listingPurpose case final purpose?)
        'Properties ${searchPurposeLabel(context, purpose)}',
    if (filter.district case final district?)
      strings.savedNameInDistrict(district),
    if (filter.maxPriceNpr case final max?)
      strings.savedNameUnderPrice(NepaliCurrency.compact(max)),
  ];
  if (parts.isEmpty) return strings.savedNameFallback;
  return parts.join(' ');
}
