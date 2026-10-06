import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reports_providers.freezed.dart';
part 'reports_providers.g.dart';

/// The buyer reports queue as the admin sees it.
///
/// Structurally the same shape as `QueueViewState`, and deliberately so: the
/// two queues are read the same way (tabs, counts, keyset paging, inline
/// error) and a second shape would mean a second set of decisions about when
/// an error replaces the list and when a stale error survives a retry.
///
/// What differs is the work order, which the server owns. Reports come back
/// oldest first rather than newest, because an open report is a piece of work
/// waiting for a person and the oldest is the one a buyer has been waiting
/// longest on. A steady trickle of new reports against an unworked backlog
/// would starve it indefinitely if the newest came first.
@freezed
sealed class ReportsViewState with _$ReportsViewState {
  const factory ReportsViewState({
    /// Rows loaded so far, oldest report first.
    @Default(<AdminReportEntry>[]) List<AdminReportEntry> entries,

    /// Tab counts for every status the queue shows.
    ///
    /// Authoritative from the server on each response, so the badges stay fresh
    /// across pages without a second round trip.
    @Default(ReportCounts()) ReportCounts counts,

    /// Cursor for the next page, or null once exhausted.
    ReportCursor? cursor,

    /// Whether a further page is in flight.
    ///
    /// Separate from the provider's loading state so a scroll can show a footer
    /// spinner while existing rows stay on screen.
    @Default(false) bool isLoadingMore,

    /// Failure from the most recent load, if any.
    AppException? loadError,
  }) = _ReportsViewState;
}

/// Derived, non-wire facts about a [ReportsViewState].
extension ReportsViewStateX on ReportsViewState {
  /// Whether another page exists.
  bool get hasMore => cursor != null;

  /// Returns a copy with the given fields replaced, and no error.
  ///
  /// Dropping [loadError] is the point, for the same reason as
  /// `QueueViewStateX.withClearedError`: Freezed's generated `copyWith`
  /// cannot distinguish an explicit null from an omitted argument for a
  /// nullable field, so there is no way to clear an error through it — and a
  /// stale error surviving a successful retry is a banner that never goes.
  ///
  /// [cursor] is required rather than optional for the same reason, plus one
  /// more: an optional `ReportCursor? cursor` defaulting to null would keep the
  /// previous cursor via `cursor ?? this.cursor`, so an exhausted queue would
  /// hold a key to a page that can never arrive.
  ReportsViewState withClearedError({
    required ReportCursor? cursor,
    List<AdminReportEntry>? entries,
    ReportCounts? counts,
    bool? isLoadingMore,
  }) =>
      ReportsViewState(
        entries: entries ?? this.entries,
        counts: counts ?? this.counts,
        cursor: cursor,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  /// Whether the queue is empty and the load succeeded.
  ///
  /// False whenever [loadError] is set. A failed request must never render
  /// as "no reports", which is the message that would let a buyer's
  /// complaint go unanswered — the same argument as the listing queue, where
  /// the equivalent message would let a listing go unreviewed.
  bool get isEmpty =>
      loadError == null && entries.isEmpty && cursor == null;

  /// How many loaded reports have gone stale.
  ///
  /// Unlike the listing queue there is no SLA here — HYA-263 defines no
  /// review deadline for a report — so this counts waiting rather than
  /// overdue, and the UI words it as elapsed time rather than as a breach.
  /// The count is what an admin acts on: one report is a decision, five is
  /// a backlog.
  int waitingCount({Duration? olderThan}) {
    if (olderThan == null) return entries.length;
    final cutoff = DateTime.now().toUtc().subtract(olderThan);
    return entries
        .where((e) => e.createdAt != null && e.createdAt!.isBefore(cutoff))
        .length;
  }

  /// The oldest loaded report, which is the one an admin should open first.
  ///
  /// Null when nothing has loaded, or when the page somehow arrived out of
  /// order. Returns null rather than the first element because the server's
  /// ordering is what makes this meaningful, and a row that is not oldest is
  /// better described as "no answer" than as a confident wrong one.
  AdminReportEntry? get oldest =>
      entries.isEmpty ? null : entries.first;

  /// How long the oldest report has been waiting.
  ///
  /// Null when there is no oldest report. Used for the summary line; the value
  /// is computed once per build by the widget rather than per row.
  Duration? oldestWait({DateTime? asOf}) {
    final entry = oldest;
    final createdAt = entry?.createdAt;
    if (entry == null || createdAt == null) return null;

    final reference = asOf ?? DateTime.now().toUtc();
    final wait = reference.difference(createdAt.toUtc());
    // A report cannot have been filed in the future. A negative duration means
    // clock skew between the device and the server, and rendering "-2 minutes
    // waiting" would be nonsense, so it clamps to zero.
    return wait.isNegative ? Duration.zero : wait;
  }
}

/// The reports queue, paginated with a keyset cursor.
///
/// Retry is disabled for the same reason as the listing queue: Riverpod retries
/// a provider whose `build` returns a Future, so a failure would take roughly
/// forty seconds to surface. Moderation is where waiting costs most.
@riverpod
class AdminReports extends _$AdminReports {
  /// Rebuilds when the selected tab changes. Watching the tab provider is the
  /// whole refetch mechanism, mirroring how the listing queue works.
  @override
  Future<ReportsViewState> build() {
    final tab = ref.watch(reportsTabProvider);
    return _loadFirstPage(tab);
  }

  /// Loads the first page for [tab].
  Future<ReportsViewState> _loadFirstPage(ReportStatus tab) async {
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getReports(status: tab);

      return ReportsViewState(
        entries: page.entries,
        counts: page.counts,
        cursor: page.nextCursor,
      );
    } on AppException catch (e) {
      // State rather than a thrown error, so the screen shows an inline retry
      // instead of an error page. Re-throwing would also drop rows already on
      // screen on any refetch.
      return ReportsViewState(loadError: e);
    }
  }

  /// Loads the next page and appends it.
  ///
  /// No-op when exhausted or already in flight, which is what stops a fast
  /// scroll from firing the same request repeatedly.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null) return;
    if (!current.hasMore || current.cursor == null) return;
    if (current.isLoadingMore) return;

    state = AsyncData(
        // copyWith, not withClearedError: a load-more that starts while an
        // earlier error is on screen should keep the error until this load
        // actually succeeds, so the banner does not flicker on every scroll.
        current.copyWith(isLoadingMore: true),
      );

    try {
      final page = await ref.read(adminRepositoryProvider).getReports(
            status: ref.read(reportsTabProvider),
            cursor: current.cursor,
          );

      state = AsyncData(
        current.withClearedError(
          entries: <AdminReportEntry>[...current.entries, ...page.entries],
          counts: page.counts,
          cursor: page.nextCursor,
          isLoadingMore: false,
        ),
      );
    } on AppException catch (e) {
      // Keeps the rows already on screen. Blanking a loaded queue because page
      // two failed would be worse than a retry line under the existing rows.
      state = AsyncData(current.copyWith(isLoadingMore: false, loadError: e));
    }
  }

  /// Retries a failed load, or refetches after a pull-to-refresh.
  void retry() => ref.invalidateSelf();

  /// Applies a resolution to the loaded queue.
  ///
  /// The row leaves the open tab and the count moves to whichever tab the
  /// server put it in. Doing both in one step is what keeps the badge and the
  /// row from disagreeing — the failure mode this exists to prevent.
  ///
  /// [serverStatus] rather than the requested resolution, for the same reason
  /// `AdminQueue.applyReviewOutcome` takes the server's answer: somebody else
  /// may have resolved the report first, and the count must follow the
  /// database rather than the button that was pressed.
  void applyResolution(String reportId, ReportStatus serverStatus) {
    final current = state.value;
    if (current == null) return;

    final remaining =
        current.entries.where((e) => e.id != reportId).toList(growable: false);
    // No change and no count shift when the row was not here: it may have been
    // resolved from another tab, or the list may have been reloaded underneath.
    // Shifting a count for a row that was never counted is how a badge drifts.
    if (remaining.length == current.entries.length) return;

    final counts = current.counts;
    // `open` decrements unconditionally because the row was on screen and the
    // only way out of this method is the server having resolved it. The other
    // two increment conditionally, because only the server's answer says which
    // tab it landed in.
    final resolved = serverStatus == ReportStatus.actioned ? 1 : 0;
    final dismissed = serverStatus == ReportStatus.dismissed ? 1 : 0;
    state = AsyncData(
      current.copyWith(
        entries: remaining,
        counts: ReportCounts(
          open: counts.open - 1,
          actioned: counts.actioned + resolved,
          dismissed: counts.dismissed + dismissed,
        ),
      ),
    );
  }
}

/// Which tab of the reports queue is showing.
///
/// Separate from [AdminReports] so a tab switch does not rebuild the provider
/// that owns the rows, and so reloading the rows does not reset the tab.
@riverpod
class ReportsTab extends _$ReportsTab {
  @override
  ReportStatus build() => ReportStatus.open;

  /// The status currently shown.
  ReportStatus get tab => state;

  /// Switches tab. Assigning state is the entire refetch mechanism.
  set tab(ReportStatus value) => state = value;

  /// The statuses the queue offers, in tab order.
  ///
  /// Every value of [ReportStatus]: unlike the listing queue there is no
  /// excluded state, because a report has no draft equivalent — it is either
  /// filed or it does not exist.
  static List<ReportStatus> get tabs => ReportStatus.values;
}

/// The result of resolving a report.
///
/// A distinct type rather than a bare bool or an echoed status, so a caller
/// cannot mistake "the server accepted it" for "the row left the list", and
/// cannot accidentally present the requested resolution as the outcome.
@immutable
class ReportResolutionOutcome {
  /// Creates the outcome of one report resolution.
  const ReportResolutionOutcome({
    required this.reportId,
    required this.listingId,
    required this.requested,
    required this.serverStatus,
  });

  /// The report acted on.
  final String reportId;

  /// The listing it was about.
  ///
  /// Kept because the audit row the server wrote is keyed by listing, so an
  /// admin moving on to the listing needs to know which one it was.
  final String listingId;

  /// What the admin chose.
  final ReportResolution requested;

  /// The status the server stored afterwards.
  ///
  /// May differ from [requested]: another admin resolving first is refused with
  /// `22023`, so a mismatch means the state moved underneath this call. The
  /// repository refuses an `open` outright, so this is never "not resolved".
  final ReportStatus serverStatus;

  /// Whether the outcome is the one the admin asked for.
  bool get matchesRequest => serverStatus.name == requested.name;

  @override
  bool operator ==(Object other) =>
      other is ReportResolutionOutcome &&
      other.reportId == reportId &&
      other.listingId == listingId &&
      other.requested == requested &&
      other.serverStatus == serverStatus;

  @override
  int get hashCode => Object.hash(reportId, listingId, requested, serverStatus);

  @override
  String toString() => 'ReportResolutionOutcome($reportId, ${requested.name}, '
      'server: ${serverStatus.name})';
}
