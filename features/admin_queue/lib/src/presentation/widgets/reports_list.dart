/// The reports queue for nBhumi (HYA-263).
library;

import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';

import '../../providers/reports_controller.dart';
import '../../providers/reports_providers.dart';

/// Human wording for the values on a report.
///
/// Exhaustive over every enum on purpose: a new reason or status that nobody
/// worded becomes a compile error here rather than an empty string in the UI.
///
/// Not bilingual, and that is deliberate. The admin panel is operator-facing
/// and every other admin string in this feature — the queue tabs, the SLA
/// chip, the empty states — is English-only, so a Nepali half-measure here
/// would be inconsistent in the wrong direction. Rule 36 covers user-facing
/// marketplace
/// copy; the seller-facing half of a report outcome is written when HYA-262
/// lands, and that is where the bilingual pair belongs.

/// Label for a report reason, as a moderator reads it.
String reasonLabel(ReportReason reason) => switch (reason) {
  ReportReason.duplicateListing => 'Duplicate listing',
  ReportReason.photosMisleading => 'Photos are misleading',
  ReportReason.priceSuspicious => 'Price looks wrong',
  ReportReason.wrongLocation => 'Wrong location',
  ReportReason.alreadySold => 'Already sold',
  ReportReason.sellerAskedOffsite => 'Seller asked to deal off-site',
  ReportReason.fakeListing => 'Fake listing',
  ReportReason.other => 'Other',
};

/// Label for a report status, naming the tab or the outcome.
String reportStatusLabel(ReportStatus status) => switch (status) {
  ReportStatus.open => 'Open',
  ReportStatus.actioned => 'Actioned',
  ReportStatus.dismissed => 'Dismissed',
};

/// Label for a listing status, in a sentence about a report.
String listingStatusLabel(ListingStatus status) => switch (status) {
  ListingStatus.draft => 'draft',
  ListingStatus.pendingReview => 'awaiting review',
  ListingStatus.live => 'live',
  ListingStatus.rejected => 'rejected',
  ListingStatus.unpublished => 'unpublished',
};

/// The reports queue: tabs, backlog summary, rows, pagination and the two
/// resolution actions.
///
/// Structurally a sibling of `QueueList` rather than a reuse of it: the rows
/// answer different questions (who reported what, and why) and the actions are
/// not approve/reject, so sharing one widget would mean a widget with two
/// unrelated shapes and a field-by-field null check on every row. What is
/// genuinely shared — pagination, error handling, tab counts, empty
/// wording — already lives in the providers, so nothing is duplicated here
/// that could disagree.
///
/// Reports have no SLA. Nothing in HYA-263 sets a review deadline, so the
/// summary line reports elapsed waiting rather than a breach, and deliberately
/// avoids the SLA language the listing queue uses. Inventing a threshold here
/// would put a number in front of an admin that no policy backs.
class ReportsList extends ConsumerStatefulWidget {
  /// Creates the reports list.
  const ReportsList({super.key});

  @override
  ConsumerState<ReportsList> createState() => _ReportsListState();
}

class _ReportsListState extends ConsumerState<ReportsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Requests the next page when the admin scrolls near the end.
  ///
  /// A threshold rather than exact-end, for the reason `QueueList` uses one:
  /// the last row is often taller than the viewport on a narrow window, so an
  /// exact-end trigger would never fire.
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent * 0.8) return;

    // `unawaited` rather than `async`: this is a scroll callback, and awaiting
    // would mean every scroll notification returned a Future the framework
    // ignores. The controller's own `isLoadingMore` guard stops the repeat.
    unawaited(ref.read(adminReportsProvider.notifier).loadMore());
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(adminReportsProvider);

    // The Scaffold lives here rather than in [AdminReportsScreen] so this
    // widget can be embedded in a shell that already provides one, the same
    // split `QueueList` makes. The AppBar carries a back button because the
    // reports queue is a destination rather than the panel's front page, and
    // arriving at `/reports` directly is legitimate, so an admin with no way
    // back would be stranded there.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
        actions: <Widget>[
          IconButton(
            onPressed: () => ref.read(adminReportsProvider.notifier).retry(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload reports',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Rule 19: sealed pattern matching on AsyncValue, typed bindings.
          Expanded(
            child: switch (reports) {
              AsyncLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              // Map rather than pass through: an error reaching this far is
              // raw, and `unmapped` gives it safe bilingual wording instead of
              // leaking whatever the transport threw (Rule 38).
              AsyncError(:final error) => _ReportsLoadError(
                error: AppException.unmapped(error),
              ),
              AsyncData(value: final state) => _ReportsBody(
                state: state,
                scrollController: _scrollController,
                onScroll: _onScroll,
              ),
            },
          ),
          switch (reports) {
            AsyncData(value: final state) => _ReportsTabs(counts: state.counts),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}

/// The list itself, once the first page has loaded.
class _ReportsBody extends ConsumerWidget {
  const _ReportsBody({
    required this.state,
    required this.scrollController,
    required this.onScroll,
  });

  final ReportsViewState state;
  final ScrollController scrollController;
  final VoidCallback onScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // One instant for the whole list, so every row and the summary line above
    // them agree.
    final asOf = DateTime.now().toUtc();

    if (state.isEmpty) return const _ReportsEmpty();

    return Column(
      children: <Widget>[
        if (state.loadError != null || state.oldest != null)
          _ReportsSummary(state: state, asOf: asOf),
        Expanded(
          // A notification listener rather than a controller callback:
          // reading the position from the notification is the same number with
          // one fewer moving part.
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
                  return _ReportsFooter(state: state);
                }
                return _ReportRow(entry: state.entries[index], asOf: asOf);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// The strip above the rows: how long the backlog has been waiting, and any
/// load error.
class _ReportsSummary extends ConsumerWidget {
  const _ReportsSummary({required this.state, required this.asOf});

  final ReportsViewState state;
  final DateTime asOf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final error = state.loadError;

    // A load-more failure shows here rather than replacing the list: the rows
    // already on screen are still valid, and blanking them because page two
    // failed would be worse than a retry line.
    if (error != null && state.entries.isEmpty) {
      return Material(
        color: theme.colorScheme.surfaceContainerHighest,
        child: _ErrorBanner(
          message: error.localizedForContext(context),
          onRetry: () => ref.read(adminReportsProvider.notifier).retry(),
        ),
      );
    }

    final wait = state.oldestWait(asOf: asOf);
    final waiting = state.waitingCount();

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
                onRetry: () => ref.read(adminReportsProvider.notifier).retry(),
              ),
            if (wait != null)
              Text(
                // "Waiting" rather than "overdue": there is no SLA, so calling
                // this a breach would assert a deadline nobody set.
                '$waiting report${waiting == 1 ? '' : 's'} open, oldest '
                'waiting ${_formatWait(wait)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: waiting > 10
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Elapsed time, in the largest unit that stays readable.
  ///
  /// Hand-rolled rather than via a formatting helper because the app has no
  /// relative-time package (Rule 39) and the admin needs an order of magnitude,
  /// not a precise figure: "3 days" is the actionable part of "3 days 4 hours".
  static String _formatWait(Duration wait) {
    if (wait.inDays >= 1) {
      final days = wait.inDays;
      return '$days day${days == 1 ? '' : 's'}';
    }
    if (wait.inHours >= 1) {
      final hours = wait.inHours;
      return '$hours hour${hours == 1 ? '' : 's'}';
    }
    return '${wait.inMinutes} min';
  }
}

/// One report in the queue list.
///
/// Shows the complaint, who made it, and what it is about — the three
/// things a moderator needs before deciding whether the report stands up.
/// The listing's own details are deliberately not here: the decision is
/// about whether the report is valid, which is answerable from the row plus
/// the listing page.
class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.entry, required this.asOf});

  final AdminReportEntry entry;
  final DateTime asOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wait = entry.createdAt == null
        ? null
        : asOf.difference(entry.createdAt!.toUtc());

    return Material(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  _reasonIcon(entry.reason),
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        reasonLabel(entry.reason),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.listing.title} — '
                        '${entry.listing.district}, ${entry.listing.city}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (entry.details case final details?
                when details.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              _ReportDetails(details: details),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  'by ${entry.reporter.fullName ?? 'a buyer'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (wait != null) _WaitedChip(wait: wait),
                _PriceLabel(priceNpr: entry.listing.priceNpr),
                // A report against a listing that is no longer live is history,
                // not work. Shown so the admin does not spend the decision.
                if (entry.listing.status != ListingStatus.live)
                  _ListingStatusChip(status: entry.listing.status),
              ],
            ),
            const SizedBox(height: 10),
            _ResolutionActions(entry: entry),
          ],
        ),
      ),
    );
  }

  /// Icon per reason, so a scan of the list reads the shape of the backlog.
  static IconData _reasonIcon(ReportReason reason) => switch (reason) {
    ReportReason.duplicateListing => Icons.copy_all_outlined,
    ReportReason.photosMisleading => Icons.photo_camera_back_outlined,
    ReportReason.priceSuspicious => Icons.payments_outlined,
    ReportReason.wrongLocation => Icons.place_outlined,
    ReportReason.alreadySold => Icons.sell_outlined,
    ReportReason.sellerAskedOffsite => Icons.report_gmailerrorred_outlined,
    ReportReason.fakeListing => Icons.help_outline,
    ReportReason.other => Icons.more_horiz,
  };
}

/// The buyer's description, quoted.
///
/// Quoted rather than paraphrased because the buyer wrote it for exactly this
/// purpose, and an admin acting on a paraphrase is not acting on the report.
class _ReportDetails extends StatelessWidget {
  const _ReportDetails({required this.details});

  final String details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(color: theme.colorScheme.outline, width: 3),
        ),
      ),
      child: Text(details, style: theme.textTheme.bodySmall),
    );
  }
}

/// How long a report has waited.
class _WaitedChip extends StatelessWidget {
  const _WaitedChip({required this.wait});

  final Duration wait;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.schedule,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Text(
          _formatWait(wait),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Elapsed time in the largest readable unit. See _ReportsSummary._formatWait
  /// for why this is hand-rolled rather than a formatting helper.
  static String _formatWait(Duration wait) {
    if (wait.inDays >= 1) {
      final days = wait.inDays;
      return '${days}d';
    }
    if (wait.inHours >= 1) return '${wait.inHours}h';
    return '${wait.inMinutes}m';
  }
}

/// The listing is no longer live.
class _ListingStatusChip extends StatelessWidget {
  const _ListingStatusChip({required this.status});

  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'listing ${listingStatusLabel(status)}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// Price in Nepali lakh/crore grouping (Rule 27).
class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.priceNpr});

  final int priceNpr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      NepaliCurrency.compact(priceNpr),
      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

/// The two resolution buttons.
///
/// Both are always offered and neither is a default: "Upheld" confirms the
/// complaint, "Dismissed" rejects it, and the certainty of which they need —
/// closing a report wrong way forfeits the trail an audit exists for.
///
/// Neither button auto-resolves the listing. Resolving a report records what an
/// admin concluded about a complaint; it does not remove anyone's property, and
/// HYA-262 owns the admin actions that do. Bundling them would make one tap do
/// two things, one of which the admin did not choose.
///
/// The status value stored is the enum label (`actioned`/`dismissed`); the
/// button text is "Upheld"/"Dismissed" because "actioned" in a queue reads as
/// "we changed the listing", which this server call never does.
class _ResolutionActions extends ConsumerStatefulWidget {
  const _ResolutionActions({required this.entry});

  final AdminReportEntry entry;

  @override
  ConsumerState<_ResolutionActions> createState() => _ResolutionActionsState();
}

class _ResolutionActionsState extends ConsumerState<_ResolutionActions> {
  /// Whether this widget has a resolution out.
  ///
  /// The busy indicator lives on the widget, not the controller: the
  /// controller's `_inFlight` set is a server-side guard against a double
  /// submit, and nothing of it is reactive, so a spinner driven from it would
  /// never appear. `ReviewActions` keeps the same local flag.
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const SizedBox(
        height: 24,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            // The controller also guards the same call; the local flag is what
            // disables the button ahead of a round trip, so a fast second click
            // is caught before it leaves the screen.
            onPressed: () => _resolve(ref, ReportResolution.actioned),
            icon: const Icon(Icons.gavel_outlined, size: 16),
            label: const Text('Uphold'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextButton.icon(
            onPressed: () => _resolve(ref, ReportResolution.dismissed),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Dismiss'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  /// Runs one resolution and reports the outcome.
  ///
  /// Both success and failure go through a snackbar, because the admin needs to
  /// know either way. A resolution that silently fails leaves the row looking
  /// actionable, and the buyer waits forever.
  Future<void> _resolve(WidgetRef ref, ReportResolution resolution) async {
    if (_busy) return;
    setState(() => _busy = true);

    // The messenger is resolved *before* the await. Reading it after would be a
    // BuildContext across an async gap, which is a real hazard here: the admin
    // can switch tabs while the request is out, which disposes this row.
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(reportsControllerProvider.notifier);
    final reportId = widget.entry.id;

    try {
      final outcome = switch (resolution) {
        ReportResolution.actioned => await controller.action(reportId),
        ReportResolution.dismissed => await controller.dismiss(reportId),
      };

      if (!mounted) return;

      // Wording comes from the server's status, never from `resolution`. The
      // admin pressed a button and the database decided; if the two disagree,
      // saying "upheld" because that was the button would misreport what
      // happened to the record.
      final closed = reportStatusLabel(outcome.serverStatus).toLowerCase();
      final verb = outcome.serverStatus == ReportStatus.actioned
          ? 'upheld'
          : 'dismissed';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            outcome.matchesRequest
                ? 'Report $verb.'
                : 'Already closed by someone else as $closed.',
          ),
          duration: AppDurations.snackBarShort,
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;

      // The bilingual message, with a retry — Rule 36. `localizedForContext`
      // rather than `messageEn`, so a Nepali-locale admin is not shown English.
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.localizedForContext(context)),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _resolve(ref, resolution),
          ),
        ),
      );
    } finally {
      // In a finally, not after the call: a failure about to propagate must
      // still release the flag, or the buttons stay dead for the session.
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// An error with a retry action.
///
/// Always offered: every failure reaching here is either transient (Rule 36
/// wants a retry) or a permission problem where retrying is harmless.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
      ),
    );
  }
}

/// The status tabs, with their counts.
class _ReportsTabs extends ConsumerWidget {
  const _ReportsTabs({required this.counts});

  final ReportCounts counts;

  /// The statuses on offer, in tab order.
  ///
  /// Read from the provider class rather than repeated here, so the tab bar and
  /// the provider can never disagree about what exists.
  static List<ReportStatus> get _tabs => ReportsTab.tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The provider's own state, not its notifier: reading the notifier to get a
    // value works until anything overrides the provider with a plain value, at
    // which point the element type no longer matches and the build throws.
    final selected = ref.watch(reportsTabProvider);

    return NavigationBar(
      selectedIndex: _tabs.indexOf(selected),
      onDestinationSelected: (index) =>
          ref.read(reportsTabProvider.notifier).tab = _tabs[index],
      destinations: <Widget>[
        for (final status in _tabs)
          NavigationDestination(
            label: reportStatusLabel(status),
            icon: Icon(_tabIcon(status)),
            selectedIcon: Icon(_tabIcon(status)),
            // The count goes in the tooltip rather than the label. A zero
            // count is worth hiding — showing "Dismissed 0" invites an admin
            // to open an empty tab and conclude something is broken — and a
            // visible count that disagrees with the loaded page is worse.
            tooltip:
                '${reportStatusLabel(status)}, '
                '${counts.forStatus(status)}',
          ),
      ],
    );
  }

  /// Icon for a tab, so the bar is not three identical shapes.
  static IconData _tabIcon(ReportStatus status) => switch (status) {
    ReportStatus.open => Icons.inbox_outlined,
    ReportStatus.actioned => Icons.gavel_outlined,
    ReportStatus.dismissed => Icons.block_outlined,
  };
}

/// The list's last row: a spinner while paging, or an end marker.
class _ReportsFooter extends StatelessWidget {
  const _ReportsFooter({required this.state});

  final ReportsViewState state;

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

    // Says how many are loaded, because an admin needs to know whether
    // the queue they are about to call empty really is empty.
    final count = state.entries.length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          state.hasMore
              ? 'Scroll for more'
              : '$count report${count == 1 ? '' : 's'}, end of queue',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Shown when the queue loaded successfully and holds nothing for this tab.
class _ReportsEmpty extends ConsumerWidget {
  const _ReportsEmpty();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tab = ref.watch(reportsTabProvider);

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
            switch (tab) {
              ReportStatus.open => 'No open reports.',
              ReportStatus.actioned => 'Nothing has been actioned yet.',
              ReportStatus.dismissed => 'Nothing has been dismissed.',
            },
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            switch (tab) {
              ReportStatus.open =>
                'Buyer reports appear here as they are filed.',
              ReportStatus.actioned => 'Reports you uphold are recorded here.',
              ReportStatus.dismissed =>
                'Reports you find unfounded are recorded here.',
            },
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the first load failed outright.
class _ReportsLoadError extends StatelessWidget {
  const _ReportsLoadError({required this.error});

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
            Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.error),
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
