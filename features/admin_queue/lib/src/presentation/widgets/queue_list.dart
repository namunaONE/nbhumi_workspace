import 'dart:async';

import 'package:admin_queue/admin_queue.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';

import 'queue_row.dart';

/// The queue list pane: tabs, SLA summary, rows and pagination.
///
/// Separate from the screen that places it, because the two layouts put it in
/// different places — beside a detail pane on a wide window, as the whole
/// screen
/// on a narrow one — and because the rows need a scroll listener and a header
/// that neither layout should own.
class QueueList extends ConsumerStatefulWidget {
  /// Creates the list pane.
  ///
  /// [onOpenReports] is wired by the admin panel's router to the second admin
  /// queue (buyer reports). The feature deliberately has no go_router
  /// dependency, so this is the seam; when null the affordance is hidden
  /// rather than dead, and tests that don't care about reports never see it.
  const QueueList({super.key, this.onOpenReports});

  /// Called when the admin asks to switch to the reports queue.
  final VoidCallback? onOpenReports;

  @override
  ConsumerState<QueueList> createState() => _QueueListState();
}

class _QueueListState extends ConsumerState<QueueList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Requests the next page when the admin scrolls near the end.
  ///
  /// A threshold rather than exact-end, because the last row is often taller
  /// than the viewport on a narrow window, so an exact-end trigger would never
  /// fire. 80% is far enough from the end that the request usually lands before
  /// the admin reaches the bottom, which is the point of pre-fetching.
  ///
  /// `unawaited` rather than `async`: this is a scroll callback, and awaiting
  /// would mean every scroll notification returned a Future the framework
  /// ignores. The controller's own `isLoadingMore` guard is what stops a repeat
  /// request.
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent * 0.8) return;

    unawaited(ref.read(adminQueueProvider.notifier).loadMore());
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(adminQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Queue'),
        actions: <Widget>[
          if (widget.onOpenReports != null)
            IconButton(
              onPressed: widget.onOpenReports,
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Open the reports queue',
            ),
          IconButton(
            onPressed: () => ref.read(adminQueueProvider.notifier).retry(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload the queue',
          ),
        ],
      ),
      // Rule 19: sealed pattern matching on AsyncValue, with a typed binding.
      body: switch (queue) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        // Map rather than pass through: an error that reached this far is raw,
        // and `unmapped` gives it safe bilingual wording instead of leaking
        // whatever the transport threw (Rule 38).
        AsyncError(:final error) =>
          _QueueLoadError(error: AppException.unmapped(error)),
        AsyncData(value: final state) => _QueueBody(
            state: state,
            scrollController: _scrollController,
            onScroll: _onScroll,
          ),
      },
      bottomNavigationBar: switch (queue) {
        AsyncData(value: final state) => _QueueTabs(counts: state.counts),
        _ => null,
      },
    );
  }
}

/// The list itself, once the first page has loaded.
///
/// Guarded by [QueueViewStateX.isEmpty] rather than `entries.isEmpty`: a failed
/// load must not read as "nothing to review", which is the one message in this
/// screen that would cause a real listing to go unreviewed.
class _QueueBody extends ConsumerWidget {
  const _QueueBody({
    required this.state,
    required this.scrollController,
    required this.onScroll,
  });

  final QueueViewState state;
  final ScrollController scrollController;
  final VoidCallback onScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(adminSelectedListingProvider);

    // One instant for the whole list, so every chip and the summary line above
    // it agree. See QueueViewStateX.worstSla.
    final worst = state.worstSla();
    final asOf = worst?.asOf ?? DateTime.now().toUtc();

    if (state.isEmpty) return const _QueueEmpty();

    return Column(
      children: <Widget>[
        if (worst != null || state.loadError != null)
          _QueueSummary(state: state, asOf: asOf),
        Expanded(
          // A notification listener rather than a controller callback:
          // attaching to the controller would need the list rebuilt whenever
          // the controller changed, and reading the position from the
          // notification is the same number with one fewer moving part.
          child: NotificationListener<ScrollNotification>(
            onNotification: (_) {
              onScroll();
              // False: this observes, it does not consume. Returning true would
              // swallow the scroll and the list would not move.
              return false;
            },
            child: ListView.builder(
              controller: scrollController,
              // One extra row for the footer spinner or the exhausted marker.
              itemCount: state.entries.length + 1,
              itemBuilder: (context, index) {
                if (index == state.entries.length) {
                  return _QueueFooter(state: state);
                }

                final entry = state.entries[index];
                return QueueRow(
                  entry: entry,
                  selected: entry.id == selectedId,
                  asOf: asOf,
                  onTap: () => ref
                      .read(adminSelectedListingProvider.notifier)
                      .listingId = entry.id,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// The strip above the rows: how bad the queue is, and any load error.
///
/// A single strip rather than a card, because it is status rather than content:
/// it has to stay readable while scrolling without pushing the rows down far
/// enough to change what is on screen.
class _QueueSummary extends ConsumerWidget {
  const _QueueSummary({required this.state, required this.asOf});

  final QueueViewState state;
  final DateTime asOf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final error = state.loadError;

    // A load-more failure is shown here rather than replacing the list: the
    // rows
    // already on screen are still valid, and blanking them because page two
    // failed would be worse than a retry line.
    if (error != null && state.entries.isEmpty) {
      return _ErrorBanner(
        message: error.localizedForContext(context),
        onRetry: () => ref.read(adminQueueProvider.notifier).retry(),
      );
    }

    final breached = state.breachedCount(asOf: asOf);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (error != null)
              _ErrorBanner(
                message: error.localizedForContext(context),
                onRetry: () => ref.read(adminQueueProvider.notifier).retry(),
              ),
            if (breached > 0)
              Text(
                '$breached listing${breached == 1 ? '' : 's'} past the '
                '${QueueSlaThresholds.breachAfter.inHours}h review SLA',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// An error with a retry action.
///
/// Always offered, because every failure reaching here is either transient
/// (Rule 36 wants a retry for those) or a permission problem where retrying is
/// harmless.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

/// The status tabs, with their counts.
class _QueueTabs extends ConsumerWidget {
  const _QueueTabs({required this.counts});

  final QueueCounts counts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The provider's own state, not its notifier: reading the notifier to get
    // a value works until anything overrides the provider with a plain value,
    // at which point the element type no longer matches and the build throws.
    final selected = ref.watch(adminQueueTabProvider);

    return NavigationBar(
      selectedIndex: AdminQueueTab.tabs.indexOf(selected),
      onDestinationSelected: (index) =>
          ref.read(adminQueueTabProvider.notifier).tab =
              AdminQueueTab.tabs[index],
      destinations: <Widget>[
        for (final status in AdminQueueTab.tabs)
          NavigationDestination(
            // The label names the status, not the queue: "Rejected" is a place
            // in this queue, not a queue of rejected listings.
            label: _tabLabel(status),
            icon: Icon(_tabIcon(status)),
            selectedIcon: Icon(_tabIcon(status)),
            // The count goes in the tooltip rather than the label. A zero count
            // is worth hiding — showing "Rejected 0" invites an admin to open
            // an
            // empty tab and conclude something is broken — and a visible count
            // that disagrees with the loaded page is worse.
            tooltip: '${_tabLabel(status)}, ${counts.forStatus(status)}',
          ),
      ],
    );
  }

  /// Label for a tab.
  static String _tabLabel(ListingStatus status) => switch (status) {
        ListingStatus.pendingReview => 'Pending',
        ListingStatus.live => 'Live',
        ListingStatus.rejected => 'Rejected',
        // Not offered. Reaching it means a status was added to the enum without
        // a tab, which the exhaustive switch turns into a compile error.
        ListingStatus.draft => 'Drafts',
      };

  /// Icon for a tab, so the bar is not three identical shapes.
  static IconData _tabIcon(ListingStatus status) => switch (status) {
        ListingStatus.pendingReview => Icons.inbox_outlined,
        ListingStatus.live => Icons.check_circle_outline,
        ListingStatus.rejected => Icons.block_outlined,
        ListingStatus.draft => Icons.edit_outlined,
      };
}

/// The list's last row: a spinner while paging, or an end marker.
class _QueueFooter extends StatelessWidget {
  const _QueueFooter({required this.state});

  final QueueViewState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Says how many are loaded, because an admin needs to know whether the
    // queue they are about to declare empty really is empty.
    final count = state.entries.length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          state.hasMore
              ? 'Scroll for more'
              : '$count listing${count == 1 ? '' : 's'}, end of queue',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Shown when the queue loaded successfully and holds nothing for this tab.
///
/// Exhaustive over [ListingStatus], so a new status without wording becomes a
/// compile error here rather than an empty string in the UI.
class _QueueEmpty extends ConsumerWidget {
  const _QueueEmpty();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Same reasoning as _QueueTabs: watch the state, not the notifier.
    final tab = ref.watch(adminQueueTabProvider);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.task_alt,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            _headline(tab),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _footnote(tab),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// The main line.
  static String _headline(ListingStatus tab) => switch (tab) {
        ListingStatus.pendingReview => 'Nothing waiting for review.',
        ListingStatus.live => 'No listings have gone live yet.',
        ListingStatus.rejected => 'Nothing has been rejected.',
        ListingStatus.draft => 'Drafts are not shown here.',
      };

  /// The explanatory second line.
  static String _footnote(ListingStatus tab) => switch (tab) {
        ListingStatus.pendingReview =>
          'New submissions appear here automatically.',
        ListingStatus.live =>
          'Approved listings appear here once published.',
        ListingStatus.rejected =>
          'Rejected listings appear here with their reason.',
        ListingStatus.draft =>
          'A draft is private work in progress.',
      };
}

/// Shown when the first load failed outright.
class _QueueLoadError extends StatelessWidget {
  const _QueueLoadError({required this.error});

  final AppException error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cloud_off,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              error.localizedForContext(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
