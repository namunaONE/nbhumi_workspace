import 'package:admin_queue/admin_queue.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Tests for the verification queue's ViewModel.
///
/// Stands in at the Repository seam so these exercise the queue logic — cursor
/// handling, appending, tab switching, error retention, count adjustment —
/// without a network or a real Supabase client (Rule 31).
void main() {
  final now = DateTime.utc(2026, 10, 5, 12);

  AdminQueueEntry entry(
    String id, {
    Duration? waited,
    ListingStatus status = ListingStatus.pendingReview,
    int photoCount = 3,
    String? rejectionReason,
  }) =>
      AdminQueueEntry(
        id: id,
        title: 'Listing $id',
        district: 'Kathmandu',
        city: 'Kathmandu',
        priceNpr: 2500000,
        propertyType: PropertyType.land,
        listingPurpose: ListingPurpose.sale,
        status: status,
        photoCount: photoCount,
        rejectionReason: rejectionReason,
        seller: const QueueSeller(id: 'seller-1', fullName: 'Ram Bahadur'),
        submittedAt: waited == null ? null : now.subtract(waited),
      );

  QueuePage page(
    List<AdminQueueEntry> entries, {
    QueueCounts counts = const QueueCounts(pendingReview: 3, live: 45),
    QueueCursor? nextCursor,
  }) =>
      QueuePage(entries: entries, counts: counts, nextCursor: nextCursor);

  /// Overrides the repository with a stub that returns scripted pages.
  ///
  /// [failWith] makes the next call throw instead, which is how the error paths
  /// are exercised: the ViewModel has to turn a transport failure into state.
  ///
  /// Builds a container whose repository provider is overridden (Rule 33).
  ///
  /// The tab is pinned with `overrideWithValue` rather than by subclassing the
  /// notifier: the generated `build` cannot be replaced from a subclass without
  /// reaching into generated code, and overriding the provider's value is both
  /// shorter and stable against codegen changes.
  ProviderContainer containerWith(
    FakeAdminRepository repo, {
    ListingStatus tab = ListingStatus.pendingReview,
  }) {
    final container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repo),
        adminQueueTabProvider.overrideWithValue(tab),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('QueueViewStateX derived facts', () {
    test('an empty queue has no pages and is empty', () {
      const state = QueueViewState();

      expect(state.hasMore, isFalse);
      expect(state.isEmpty, isTrue);
    });

    test('a failed load is never reported as empty', () {
      // This is the assertion that matters most in the whole file: an admin who
      // sees "nothing to review" on a network error will stop checking, and a
      // real listing goes unreviewed.
      const state = QueueViewState(
        loadError: ServerException(
          code: 'server.failure',
          messageEn: 'x',
          messageNe: 'x',
        ),
      );

      expect(state.isEmpty, isFalse);
    });

    test('hasMore follows the cursor', () {
      final state = QueueViewState(
        entries: [entry('a')],
        cursor: QueueCursor(submittedAt: now, id: 'a'),
      );

      expect(state.hasMore, isTrue);
    });

    test('worstSla reports a breach when any row is past the SLA', () {
      final state = QueueViewState(
        entries: [
          entry('a', waited: const Duration(hours: 2)),
          entry('b', waited: const Duration(hours: 60)),
        ],
      );

      final worst = state.worstSla(asOf: now);

      expect(worst?.sla, QueueSla.breached);
      expect(worst?.asOf, now);
    });

    test('worstSla reports at-risk when nothing is breached', () {
      final state = QueueViewState(
        entries: [
          entry('a', waited: const Duration(hours: 2)),
          entry('b', waited: const Duration(hours: 40)),
        ],
      );

      expect(state.worstSla(asOf: now)?.sla, QueueSla.atRisk);
    });

    test('worstSla is null when every row is fresh', () {
      final state = QueueViewState(
        entries: [entry('a', waited: const Duration(hours: 1))],
      );

      expect(state.worstSla(asOf: now), isNull);
    });

    test('worstSla is null when nothing has been submitted', () {
      final state = QueueViewState(entries: [entry('a')]);

      expect(state.worstSla(asOf: now), isNull);
    });

    test('every row is judged against one instant, not the wall clock', () {
      // The reason sla resolution lives on the state, not in the model:
      // a list rendered over several frames must not show one row as fresh
      // neighbour as at-risk for no visible reason.
      final asOf = now;
      final state = QueueViewState(
        entries: [
          entry('a', waited: const Duration(hours: 36)),
          entry('b', waited: const Duration(hours: 36)),
        ],
      );

      final first = state.worstSla(asOf: asOf);
      final second = state.worstSla(asOf: asOf);

      expect(first?.sla, QueueSla.atRisk);
      expect(second?.sla, first?.sla);
      expect(first?.asOf, second?.asOf);
    });

    test('breachedCount counts every row past the SLA', () {
      final state = QueueViewState(
        entries: [
          entry('a', waited: const Duration(hours: 2)),
          entry('b', waited: const Duration(hours: 60)),
          entry('c', waited: const Duration(hours: 72)),
          entry('d'),
        ],
      );

      expect(state.breachedCount(asOf: now), 2);
    });

    test('breachedCount is zero for an empty queue', () {
      expect(const QueueViewState().breachedCount(asOf: now), 0);
    });
  });

  group('AdminQueue loading', () {
    test('build returns the first page for the selected tab', () async {
      final repo = FakeAdminRepository([
        page([entry('a'), entry('b')]),
      ]);
      final container = containerWith(repo);

      final state = await container.read(adminQueueProvider.future);

      expect(state.entries, hasLength(2));
      expect(repo.calls.single.status, ListingStatus.pendingReview);
      expect(repo.calls.single.cursor, isNull);
    });

    test('a failed load becomes state, not a thrown error', () async {
      // Rule 36 wants a retry button, which needs the failure to be state.
      final repo = FakeAdminRepository([])..failWith = networkFailure;
      final container = containerWith(repo);

      final state = await container.read(adminQueueProvider.future);

      expect(state.loadError, isNotNull);
      expect(state.isEmpty, isFalse);
    });

    test('loadMore appends the next page', () async {
      final repo = FakeAdminRepository([
        page(
          [entry('a'), entry('b')],
          nextCursor: QueueCursor(submittedAt: now, id: 'b'),
        ),
        page([entry('c')]),
      ]);
      final container = containerWith(repo);
      final container0 = container;
      await container.read(adminQueueProvider.future);

      await container0.read(adminQueueProvider.notifier).loadMore();

      final state = container0.read(adminQueueProvider).value!;
      expect(state.entries.map((e) => e.id), <String>['a', 'b', 'c']);
      expect(state.hasMore, isFalse);
    });

    test('loadMore sends the cursor from the previous page', () async {
      final repo = FakeAdminRepository([
        page(
          [entry('a')],
          nextCursor: QueueCursor(submittedAt: now, id: 'a'),
        ),
        page([entry('b')]),
      ]);
      final container = containerWith(repo);
      await container.read(adminQueueProvider.future);

      await container.read(adminQueueProvider.notifier).loadMore();

      expect(repo.calls.last.cursor?.id, 'a');
    });

    test('loadMore is a no-op when the queue is exhausted', () async {
      final repo = FakeAdminRepository([page([entry('a')])]);
      final container = containerWith(repo);
      await container.read(adminQueueProvider.future);

      await container.read(adminQueueProvider.notifier).loadMore();

      expect(repo.calls, hasLength(1));
    });

    test('loadMore keeps existing rows when the next page fails', () async {
      final repo = FakeAdminRepository([
        page(
          [entry('a'), entry('b')],
          nextCursor: QueueCursor(submittedAt: now, id: 'b'),
        ),
      ]);
      final container = containerWith(repo);
      await container.read(adminQueueProvider.future);

      repo.failWith = networkFailure;
      await container.read(adminQueueProvider.notifier).loadMore();

      final state = container.read(adminQueueProvider).value!;
      expect(state.entries, hasLength(2));
      expect(state.loadError, isNotNull);
      expect(state.isLoadingMore, isFalse);
    });

    test('counts refresh across pages without a second call', () async {
      final repo = FakeAdminRepository([
        page(
          [entry('a')],
          counts: const QueueCounts(pendingReview: 12),
          nextCursor: QueueCursor(submittedAt: now, id: 'a'),
        ),
        page([entry('b')], counts: const QueueCounts(pendingReview: 11)),
      ]);
      final container = containerWith(repo);
      await container.read(adminQueueProvider.future);

      await container.read(adminQueueProvider.notifier).loadMore();

      final state = container.read(adminQueueProvider).value!;
      expect(state.counts.pendingReview, 11);
    });
  });

  group('AdminQueueTab', () {
    test('defaults to pending_review', () {
      final container = ProviderContainer(
        overrides: [
          adminRepositoryProvider.overrideWithValue(
            FakeAdminRepository([page(const <AdminQueueEntry>[])]),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(adminQueueTabProvider.notifier).tab,
        ListingStatus.pendingReview,
      );
    });

    test('offers exactly the three statuses the RPC pages', () {
      // Drafts are excluded: a draft is private work in progress and the RPC
      // deliberately serves no page for it.
      expect(AdminQueueTab.tabs, <ListingStatus>[
        ListingStatus.pendingReview,
        ListingStatus.live,
        ListingStatus.rejected,
      ]);
      expect(AdminQueueTab.tabs, isNot(contains(ListingStatus.draft)));
    });

    test('assigning the tab is the whole refetch mechanism', () async {
      // Not pinned: the tab has to be the real provider here, because the test
      // is about what assigning its state causes. Overriding it with a plain
      // value would bypass the notifier this test drives.
      final repo = FakeAdminRepository([
        page([entry('a')]),
        page([entry('live-1', status: ListingStatus.live)]),
      ]);
      final container = ProviderContainer(
        overrides: [adminRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(adminQueueProvider.future);

      container.read(adminQueueTabProvider.notifier).tab = ListingStatus.live;
      await container.read(adminQueueProvider.future);

      expect(repo.calls.last.status, ListingStatus.live);
    });
  });

  group('AdminQueue optimistic updates', () {
    test('removeRow drops the acted-on listing', () async {
      final repo = FakeAdminRepository([
        page([entry('a'), entry('b')]),
      ]);
      final container = containerWith(repo);
      await container.read(adminQueueProvider.future);

      container.read(adminQueueProvider.notifier).removeRow('a');

      final state = container.read(adminQueueProvider).value!;
      expect(state.entries.map((e) => e.id), <String>['b']);
    });

    test('removeRow is a no-op for an id that is not loaded', () async {
      final repo = FakeAdminRepository([page([entry('a')])]);
      final container = containerWith(repo);
      await container.read(adminQueueProvider.future);

      container.read(adminQueueProvider.notifier).removeRow('nope');

      expect(container.read(adminQueueProvider).value!.entries, hasLength(1));
    });

    test('an approval moves one count from pending to live', () async {
      final repo = FakeAdminRepository([
        page(
          [entry('a')],
          counts: const QueueCounts(pendingReview: 5, live: 2),
        ),
      ]);
      final container = containerWith(repo);
      await container.read(adminQueueProvider.future);

      container.read(adminQueueProvider.notifier).applyReviewOutcome(
            const ReviewOutcome(
              listingId: 'a',
              decision: ReviewDecision.approve,
              serverStatus: ListingStatus.live,
            ),
          );

      final state = container.read(adminQueueProvider).value!;
      expect(state.counts.pendingReview, 4);
      expect(state.counts.live, 3);
    });

    test('a rejection moves one count from pending to rejected', () async {
      final repo = FakeAdminRepository([
        page(
          [entry('a')],
          counts: const QueueCounts(pendingReview: 5, rejected: 1),
        ),
      ]);
      final container = containerWith(repo);
      await container.read(adminQueueProvider.future);

      container.read(adminQueueProvider.notifier).applyReviewOutcome(
            const ReviewOutcome(
              listingId: 'a',
              decision: ReviewDecision.reject,
              serverStatus: ListingStatus.rejected,
            ),
          );

      final state = container.read(adminQueueProvider).value!;
      expect(state.counts.pendingReview, 4);
      expect(state.counts.rejected, 2);
    });

    test('counts never go negative on a double submit', () async {
      // A count below zero is a worse bug than one briefly too high, and
      // the next authoritative load corrects either.
      final repo = FakeAdminRepository([
        page([entry('a')], counts: const QueueCounts()),
      ]);
      final container = containerWith(repo);
      await container.read(adminQueueProvider.future);

      container.read(adminQueueProvider.notifier).applyReviewOutcome(
            const ReviewOutcome(
              listingId: 'a',
              decision: ReviewDecision.approve,
              serverStatus: ListingStatus.live,
            ),
          );

      expect(container.read(adminQueueProvider).value!.counts.pendingReview, 0);
    });
  });

  group('withClearedError', () {
    test('drops the error and keeps everything else', () {
      final state = QueueViewState(
        entries: [entry('a')],
        cursor: QueueCursor(submittedAt: now, id: 'a'),
        isLoadingMore: true,
        loadError: networkFailure,
      );

      final cleared = state.withClearedError(
        cursor: state.cursor,
        isLoadingMore: false,
      );

      expect(cleared.loadError, isNull);
      expect(cleared.entries, state.entries);
      expect(cleared.cursor, state.cursor);
      expect(cleared.isLoadingMore, isFalse);
    });

    test('a copyWith cannot clear the error, which is why this exists', () {
      // Documents the constraint rather than the behaviour: passing
      // loadError: null to the generated copyWith is read as "argument omitted"
      // and silently keeps the stale error.
      const state = QueueViewState(loadError: networkFailure);

      expect(state.copyWith().loadError, isNotNull);
      expect(state.withClearedError(cursor: null).loadError, isNull);
    });

    test('the cursor is required, so an exhausted queue really clears it', () {
      // The bug this signature exists to prevent: an optional `cursor`
      // defaulting to null would keep the old cursor through `?? this.cursor`,
      // leaving hasMore true forever after the last page.
      final state = QueueViewState(
        cursor: QueueCursor(submittedAt: now, id: 'a'),
      );

      final cleared = state.withClearedError(cursor: null);

      expect(cleared.cursor, isNull);
      expect(cleared.hasMore, isFalse);
    });
  });

  group('ReviewOutcome', () {
    test('compares by value', () {
      const a = ReviewOutcome(
        listingId: 'l1',
        decision: ReviewDecision.approve,
        serverStatus: ListingStatus.live,
      );
      const b = ReviewOutcome(
        listingId: 'l1',
        decision: ReviewDecision.approve,
        serverStatus: ListingStatus.live,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('carries the server status, not the requested one', () {
      // A listing already actioned by someone else comes back `live` even
      // the admin asked to reject it. Keeping both values distinct is what lets
      // the UI notice.
      const outcome = ReviewOutcome(
        listingId: 'l1',
        decision: ReviewDecision.reject,
        serverStatus: ListingStatus.live,
      );

      expect(outcome.decision, ReviewDecision.reject);
      expect(outcome.serverStatus, ListingStatus.live);
    });
  });

  group('AdminSelectedListing', () {
    test('starts closed, so the list is full width on open', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(adminSelectedListingProvider), isNull);
    });

    test('opens and closes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(adminSelectedListingProvider.notifier)
        ..listingId = 'l1';

      expect(container.read(adminSelectedListingProvider), 'l1');

      notifier.clear();
      expect(container.read(adminSelectedListingProvider), isNull);
    });
  });
}

/// A network failure, used wherever a test needs one.
const AppException networkFailure = NetworkException(
  code: 'network.timeout',
  messageEn: 'Timed out',
  messageNe: 'समय सकिएको छैन',
);

/// Repository stub that records the calls it received.
///
/// Stands in at the Repository seam (Rule 31) so the tests exercise ViewModel
/// logic without a network or a real Supabase client.
class FakeAdminRepository implements AdminRepository {
  FakeAdminRepository(this._responses);

  final List<QueuePage> _responses;
  final List<({ListingStatus status, QueueCursor? cursor})> calls = [];
  int _next = 0;

  /// When set, thrown by the next call instead of returning a page.
  AppException? failWith;

  @override
  Future<QueuePage> getQueue({
    ListingStatus status = ListingStatus.pendingReview,
    QueueCursor? cursor,
    int pageSize = 50,
  }) async {
    calls.add((status: status, cursor: cursor));
    final failure = failWith;
    if (failure != null) {
      failWith = null;
      throw failure;
    }
    if (_next >= _responses.length) return QueuePage.empty;
    return _responses[_next++];
  }

  @override
  Future<ListingStatus> approveListing(String listingId) async =>
      ListingStatus.live;

  @override
  Future<ListingStatus> rejectListing(String listingId, String reason) async =>
      ListingStatus.rejected;

  @override
  Future<List<AuditLogEntry>> auditTrail({
    required String entityId,
    String entityType = 'listing',
    int limit = 50,
  }) async =>
      const <AuditLogEntry>[];

  /// KYC methods added by HYA-264. Not exercised by these tests, but the
  /// interface requires them, so they are stubs rather than `noSuchMethod`.
  ///
  /// A `noSuchMethod` stub would make the fake silently accept a call it
  /// cannot handle, which turns a wrong test into a passing one. Stubs that
  /// throw would break any future test that reaches for them. These do
  /// neither: they answer with an empty result, the honest answer for
  /// "not set up here".
  @override
  Future<List<KycDocument>> pendingKycDocuments({int limit = 50}) async =>
      const <KycDocument>[];

  @override
  Future<KycDocument> verifyKyc(String docId) async =>
      throw UnimplementedError('verifyKyc is not covered by these tests');

  @override
  Future<KycDocument> rejectKyc(String docId, String reason) async =>
      throw UnimplementedError('rejectKyc is not covered by these tests');

  /// Report methods added by HYA-263. Not exercised here either, and stubbed
  /// on the same reasoning as the KYC pair above: the reports queue lives in
  /// `reports_tab.dart` and is tested there.
  @override
  Future<ReportPage> getReports({
    ReportStatus status = ReportStatus.open,
    ReportCursor? cursor,
    int pageSize = 50,
  }) async =>
      ReportPage.empty;

  @override
  Future<ReportStatus> resolveReport(
    String reportId,
    ReportResolution resolution,
  ) async =>
      throw UnimplementedError(
        'resolveReport is not covered by these tests',
      );

  /// Moderation methods added by HYA-262. Same stub reasoning: the
  /// unpublish/suspend actions live on the detail screen and are tested in
  /// `moderation_actions_test.dart`.
  @override
  Future<AdminUser> suspendUser(String userId, String reason) async =>
      throw UnimplementedError(
        'suspendUser is not covered by these tests',
      );

  @override
  Future<AdminUser> unsuspendUser(String userId) async =>
      throw UnimplementedError(
        'unsuspendUser is not covered by these tests',
      );

  @override
  Future<ListingStatus> unpublishListing(
    String listingId,
    String reason,
  ) async =>
      throw UnimplementedError(
        'unpublishListing is not covered by these tests',
      );

  @override
  Future<ListingStatus> republishListing(String listingId) async =>
      throw UnimplementedError(
        'republishListing is not covered by these tests',
      );

  @override
  Future<AdminUser> getUser(String userId) async => throw UnimplementedError(
        'getUser is not covered by these tests',
      );

  /// Fraud signals added by HYA-261. Stubbed on the same reasoning as the
  /// moderation methods above: the signals panel overrides
  /// `fraudSignalsProvider` directly in its own tests.
  @override
  Future<ListingFraudSignals> fraudSignals(String listingId) async =>
      throw UnimplementedError(
        'fraudSignals is not covered by these tests',
      );
}
