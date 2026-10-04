import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:search/search.dart' show BrowseFeed;
import 'package:search/src/widgets/browse_feed.dart' show BrowseFeed;

import '../providers/browse_providers.dart';
import '../widgets/browse_feed.dart';
import 'filter_sheet.dart';

/// Search listings.
///
/// Composes the filter bar with [BrowseFeed], so results, empty state and
/// errors behave identically to the Home feed. Filtering state lives in
/// `BrowseFilter` rather than in widget state, which is what lets Home and
/// Search share one feed.
class SearchScreen extends ConsumerWidget {
  /// Creates the search screen.
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(browseFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: <Widget>[
          _SortButton(filter: filter),
          _FilterButton(activeCount: filter.activeCount),
          const SizedBox(width: 4),
        ],
      ),
      body: BrowseFeed(
        // `context.push`, not `Navigator.pushNamed`: the detail route sits on
        // the root navigator, which a plain Navigator lookup from this branch
        // cannot reach.
        onListingTap: (id) => context.push('/listing/$id'),
        header: _QueryField(filter: filter),
        emptyTitle: 'No listings match',
        emptyBody: 'Try removing a filter or widening the price range.',
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by title or location',
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
    return Badge(
      isLabelVisible: activeCount > 0,
      label: Text('$activeCount'),
      child: IconButton(
        icon: const Icon(Icons.tune),
        tooltip: 'Filters',
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
    return PopupMenuButton<ListingSort>(
      icon: const Icon(Icons.swap_vert),
      tooltip: 'Sort',
      initialValue: filter.sort,
      onSelected: (sort) => ref
              .read(browseFilterProvider.notifier)
              .filter = filter.copyWith(sort: sort),
      itemBuilder: (context) => <PopupMenuEntry<ListingSort>>[
        for (final sort in ListingSort.values)
          PopupMenuItem<ListingSort>(value: sort, child: Text(sort.wireName)),
      ],
    );
  }
}
