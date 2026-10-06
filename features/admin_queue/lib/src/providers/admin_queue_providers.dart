import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_queue_providers.freezed.dart';
part 'admin_queue_providers.g.dart';

/// The verification queue as the admin sees it.
///
/// ### Why the SLA is resolved here and not in the model
///
/// `AdminQueueEntry.sla()` re-evaluates `DateTime.now()` on every call,
/// right for a one-off but wrong for a list: a row rendered at 47h 59m would
/// read `fresh` and a rebuild ten minutes later would read `atRisk`, with no
/// reload in between. Resolving it once per load, on [QueueViewStateX.worstSla]
/// and [QueueViewStateX.breachedCount], makes every row in a frame agree and
/// makes the value reproducible in a test.
/// Sealed, matching every other model in the workspace: Freezed's generated
/// mixin declares the fields abstract, which only works when the concrete class
/// is sealed and the generated subclass supplies them.
@freezed
sealed class QueueViewState with _$QueueViewState {
  const factory QueueViewState({
    /// Rows loaded so far, oldest submission first.
    ///
    /// The queue's work order: a listing that has waited longest is first,
    /// because that is what makes the 48h SLA meaningful rather than
    /// decorative.
    @Default(<AdminQueueEntry>[]) List<AdminQueueEntry> entries,

    /// Tab counts for every status the queue shows.
    ///
    /// Authoritative from the server on every response, so they stay fresh
    /// across pages without a second round trip.
    @Default(QueueCounts()) QueueCounts counts,

    /// Cursor for the next page, or null once exhausted.
    QueueCursor? cursor,

    /// Whether a further page is in flight.
    ///
    /// Separate from the provider's loading state so a scroll can show a footer
    /// spinner while existing rows stay on screen.
    @Default(false) bool isLoadingMore,

    /// Failure from the most recent load, if any.
    AppException? loadError,
  }) = _QueueViewState;
}

/// Derived, non-wire facts about a [QueueViewState].
extension QueueViewStateX on QueueViewState {
  /// Whether another page exists.
  bool get hasMore => cursor != null;

  /// Returns a copy with the given fields replaced, and no error.
  ///
  /// Dropping [loadError] is the whole point of this. Freezed's generated
  /// `copyWith` cannot tell an explicit null from an omitted argument for a
  /// nullable field, so there is no way to clear an error through it — and a
  /// stale error surviving a successful retry is exactly the bug this avoids.
  ///
  /// [cursor] is **required** rather than optional, for the same reason and one
  /// more: an optional `QueueCursor? cursor` defaulting to null would silently
  /// keep the previous cursor via `cursor ?? this.cursor`, so an
  /// would keep a stale key to a page that can never arrive and `hasMore` would
  /// exhausted queue would keep a stale key forever. Making it required
  /// cursor the new state has, including "none".
  QueueViewState withClearedError({
    required QueueCursor? cursor,
    List<AdminQueueEntry>? entries,
    QueueCounts? counts,
    bool? isLoadingMore,
  }) =>
      QueueViewState(
        entries: entries ?? this.entries,
        counts: counts ?? this.counts,
        cursor: cursor,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  /// Whether the queue is empty and the load succeeded.
  ///
  /// False whenever [loadError] is set: a failed request must never render as
  /// "nothing to review", which is the one message an admin would act on. It is
  /// the message that would otherwise cause a real listing to go unreviewed.
  bool get isEmpty =>
      loadError == null && entries.isEmpty && cursor == null;

  /// The most urgent SLA among loaded rows, and the instant it was judged at.
  ///
  /// Every row reads the same [asOf], so a list rendered over several frames
  /// cannot show one row as `fresh` and its neighbour as `atRisk` with no
  /// visible reason. Calling `entry.sla()` per row re-reads the clock,
  /// the chips disagree with each other and with the summary line above them.
  ///
  /// Null when nothing has been submitted, which for a queue page means no rows
  /// loaded yet.
  ({QueueSla sla, DateTime asOf})? worstSla({DateTime? asOf}) {
    final reference = asOf ?? DateTime.now().toUtc();
    QueueSla? worst;

    for (final entry in entries) {
      final sla = QueueSla.fromSubmittedAt(entry.submittedAt, now: reference);
      // Short-circuits: a breach anywhere outranks everything else, so there is
      // no reason to keep walking the remaining rows.
      if (sla == QueueSla.breached) return (sla: sla, asOf: reference);
      if (sla == QueueSla.atRisk) worst = sla;
    }

    return worst == null ? null : (sla: worst, asOf: reference);
  }

  /// How many loaded rows are past the SLA.
  ///
  /// The number an admin acts on, as distinct from [worstSla] which only says
  /// whether one is. Resolved against [asOf] for the same reason.
  int breachedCount({DateTime? asOf}) {
    final reference = asOf ?? DateTime.now().toUtc();
    var count = 0;
    for (final entry in entries) {
      if (QueueSla.fromSubmittedAt(entry.submittedAt, now: reference) ==
          QueueSla.breached) {
        count++;
      }
    }
    return count;
  }
}

/// The queue, paginated with a keyset cursor.
///
/// Retry is disabled for the same reason as the browse feed: Riverpod 3.0
/// up to ten times with exponential backoff, so a failure would take roughly 40
/// seconds to surface. An admin staring at a spinner cannot act on that,
/// queue is the screen where waiting is most expensive.
@riverpod
class AdminQueue extends _$AdminQueue {
  /// Rebuilds when the selected tab changes.
  ///
  /// Watching [adminQueueTabProvider] is the whole refetch mechanism, mirroring
  /// how the browse feed watches its filter provider. Assigning state here is
  /// enough; the dependency does the work.
  @override
  Future<QueueViewState> build() {
    final tab = ref.watch(adminQueueTabProvider);
    return _loadFirstPage(tab);
  }

  /// Loads the first page for [tab].
  Future<QueueViewState> _loadFirstPage(ListingStatus tab) async {
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getQueue(status: tab);

      return QueueViewState(
        entries: page.entries,
        counts: page.counts,
        cursor: page.nextCursor,
      );
    } on AppException catch (e) {
      // State rather than a thrown error, so the screen shows an inline
      // retry instead of an error page. Re-throwing would also drop the rows
      // screen on any refetch.
      return QueueViewState(loadError: e);
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
      final page = await ref.read(adminRepositoryProvider).getQueue(
            status: ref.read(adminQueueTabProvider),
            cursor: current.cursor,
          );

      state = AsyncData(
        // Built through withClearedError rather than copyWith: the load
        // succeeded, so any previous error must go, and Freezed's generated
        // copyWith cannot express "set this nullable field to null".
        //
        // `cursor` is the exception: Freezed defaults a nullable field to its
        // `freezed` sentinel rather than null, so passing an explicit null here
        // does clear it. That is what makes an exhausted queue drop its cursor
        // instead of holding a stale key to a page that can never arrive.
        current.withClearedError(
          entries: <AdminQueueEntry>[...current.entries, ...page.entries],
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

  /// Drops a row from the loaded list without a refetch.
  ///
  /// Called after approve or reject so the queue updates the instant the admin
  /// decides rather than waiting for a round trip. The server already moved
  /// the listing, so keeping the row would show one that is no longer pending.
  ///
  /// Counts are *not* decremented here: they are authoritative from the server
  /// and adjusting them client-side would let the tab badges drift from reality
  /// until the next load.
  void removeRow(String listingId) {
    final current = state.value;
    if (current == null) return;

    final remaining =
        current.entries.where((e) => e.id != listingId).toList(growable: false);
    if (remaining.length == current.entries.length) return;

    state = AsyncData(current.copyWith(entries: remaining));
  }

  /// Applies the result of an admin decision to the loaded queue.
  ///
  /// Called after the repository call succeeds, so the list and the tab badges
  /// update in the same frame. Two separate calls would leave a window
  /// row is gone but the badge still counts it, which reads as a bug.
  void applyReviewOutcome(ReviewOutcome outcome) {
    removeRow(outcome.listingId);

    switch (outcome.decision) {
      case ReviewDecision.approve:
        _shiftCounts(pendingDelta: -1, liveDelta: 1);
      case ReviewDecision.reject:
        _shiftCounts(pendingDelta: -1, rejectedDelta: 1);
    }
  }

  /// Shifts each tab count by the given deltas.
  ///
  /// Every result is clamped at zero: a negative count is a worse bug
  /// that is briefly too high, and the next authoritative load corrects either.
  /// The clamp matters because a double submit would otherwise produce -1.
  void _shiftCounts({
    int pendingDelta = 0,
    int liveDelta = 0,
    int rejectedDelta = 0,
  }) {
    final current = state.value;
    if (current == null) return;

    const floor = 0;
    final counts = current.counts;
    state = AsyncData(
      current.copyWith(
        counts: QueueCounts(
          pendingReview:
              (counts.pendingReview + pendingDelta).clamp(floor, 1 << 31),
          live: (counts.live + liveDelta).clamp(floor, 1 << 31),
          rejected: (counts.rejected + rejectedDelta).clamp(floor, 1 << 31),
        ),
      ),
    );
  }
}

/// Which tab of the queue is showing.
///
/// Separate from [AdminQueue] so a tab switch does not rebuild the provider
/// that owns the rows, and so reloading the rows does not reset the tab.
@riverpod
class AdminQueueTab extends _$AdminQueueTab {
  @override
  ListingStatus build() => ListingStatus.pendingReview;

  /// The status currently shown.
  ///
  /// A plain property rather than a `set(...)` method, so callers write
  /// `notifier.tab = ...`.
  ListingStatus get tab => state;

  /// Switches tab. Assigning state is the entire refetch mechanism.
  set tab(ListingStatus value) => state = value;

  /// The statuses the queue offers, in tab order.
  ///
  /// Exhaustive by construction, so adding a status to [ListingStatus] surfaces
  /// as a compile error here rather than as a tab nobody can reach. Drafts are
  /// excluded: a draft is private work in progress and has no RPC page.
  static List<ListingStatus> get tabs => const <ListingStatus>[
        ListingStatus.pendingReview,
        ListingStatus.live,
        ListingStatus.rejected,
      ];
}

/// The listing currently open in the detail pane.
///
/// Null means the list is full width, which is what the compact layout shows.
@riverpod
class AdminSelectedListing extends _$AdminSelectedListing {
  @override
  String? build() => null;

  /// The open listing id, or null.
  String? get listingId => state;

  /// Opens [value] in the detail pane.
  ///
  /// A setter rather than a method, so callers write
  /// `notifier.listingId = id`, matching the tab provider's shape.
  set listingId(String? value) => state = value;

  /// Closes the detail pane, returning to a full-width list.
  void clear() => state = null;
}

/// One listing as the admin's detail pane sees it.
///
/// A family keyed on listing id, resolved through the existing detail RPC,
/// than a queue-specific read. That RPC already admits admins to non-live
/// listings and returns everything the pane needs: photos, specs, a seller card
/// with role and KYC tier, and `submitted_at` for the SLA.
///
/// Retry is disabled. The default ten retries with backoff would hold the pane
/// loading for roughly forty seconds, and an admin who just clicked
/// the queue needs either a listing or an explanation.
@riverpod
Future<ListingDetail?> adminListingDetail(Ref ref, String listingId) {
  // Not async, and deliberately: the repository already returns null for a
  // listing that is missing *or* not visible, because the RPC answers both
  // identically so the distinction cannot be probed. Nothing here can fail in a
  // way that differs, so this is a pass-through and the pane handles null.
  return ref.watch(listingRepositoryProvider).getListingById(listingId);
}

/// Admin actions on one listing, newest first.
///
/// Returns an empty list rather than throwing when the trail cannot be read. A
/// missing audit history must not block a reviewer from approving or rejecting:
/// the decision matters more than its annotation, and Rule 8's guarantee is
/// server-side regardless of whether this panel can display it.
@riverpod
Future<List<AuditLogEntry>> adminAuditTrail(Ref ref, String listingId) async {
  try {
    return await ref
        .read(adminRepositoryProvider)
        .auditTrail(entityId: listingId);
  } on AppException {
    return const <AuditLogEntry>[];
  }
}

/// The result of an approve or reject.
///
/// A distinct type rather than a bare bool, so a caller cannot mistake "the
/// server accepted it" for "the row left the list".
///
/// [serverStatus] is what the RPC reported, which may differ from the
/// expected: a listing already actioned by someone else comes back `live` even
/// decision the admin made. Keeping both values is what lets
/// the UI notice and say so.
@immutable
class ReviewOutcome {
  /// Creates the outcome of one admin decision.
  const ReviewOutcome({
    required this.listingId,
    required this.decision,
    required this.serverStatus,
  });

  /// The listing acted on.
  final String listingId;

  /// What the admin chose.
  final ReviewDecision decision;

  /// The status the server reported afterwards.
  final ListingStatus serverStatus;

  @override
  bool operator ==(Object other) =>
      other is ReviewOutcome &&
      other.listingId == listingId &&
      other.decision == decision &&
      other.serverStatus == serverStatus;

  @override
  int get hashCode => Object.hash(listingId, decision, serverStatus);

  @override
  String toString() =>
      'ReviewOutcome($listingId, ${decision.name}, ${serverStatus.wireName})';
}
