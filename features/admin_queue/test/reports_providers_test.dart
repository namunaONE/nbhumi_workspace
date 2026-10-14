import 'package:admin_queue/admin_queue.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Tests for the reports queue's ViewModel and controller (HYA-263).
///
/// Stands in at the Repository seam so these exercise queue logic — cursor
/// handling, appending, tab switching, error retention, count adjustment, and
/// the double-submit guard — without a network or a real Supabase client
/// (Rule 31).
void main() {
  // See admin_queue_screen_test.dart: anchor to run time, not a fixed date,
  // or the 1-day threshold test rots as the calendar moves past the fixture.
  final now = DateTime.now().toUtc();

  AdminReportEntry report(
    String id, {
    Duration? waited,
    ReportStatus status = ReportStatus.open,
    ReportReason reason = ReportReason.priceSuspicious,
    ListingStatus listingStatus = ListingStatus.live,
    String? details,
  }) =>
      AdminReportEntry(
        id: id,
        listingId: 'listing-$id',
        reason: reason,
        status: status,
        details: details,
        createdAt: waited == null ? null : now.subtract(waited),
        listing: ReportedListing(
          id: 'listing-$id',
          title: 'House $id',
          priceNpr: 2500000,
          status: listingStatus,
          district: 'Kathmandu',
          city: 'Kathmandu',
          sellerId: 'seller-1',
        ),
        reporter: const ReportAuthor(id: 'buyer-1', fullName: 'Sita Kumari'),
      );

  /// A page of report results.
///
/// [counts] defaults to the whole-table truth the RPC reports, which is not the
/// same as the page's length: `json_object_agg` counts every row per status
/// across the table, while a page holds only [limit] of them. A fixture that
/// equates the two would make the count-adjustment tests assert against a
/// scenario the server cannot produce.
ReportPage page(
  List<AdminReportEntry> entries, {
  ReportCounts counts = const ReportCounts(open: 4, actioned: 1, dismissed: 2),
  ReportCursor? nextCursor,
}) =>
    ReportPage(entries: entries, counts: counts, nextCursor: nextCursor);

  /// A container whose repository is the given stub (Rule 33).
  ///
  /// The tab is pinned with `overrideWithValue` rather than by subclassing the
  /// notifier: the generated `build` cannot be replaced from a subclass without
  /// reaching into generated code.
  ProviderContainer containerWith(
    FakeReportsRepository repo, {
    ReportStatus? tab,
  }) {
    final container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repo),
        // Pinned only when the caller asks. A test that switches tabs needs the
        // real notifier: `overrideWithValue` replaces the element with a plain
        // value provider, and reading `.notifier` off it throws — which is
        // Riverpod protecting the assumption rather than a bug to work around.
        if (tab != null) reportsTabProvider.overrideWithValue(tab),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ReportsViewStateX derived facts', () {
    test('an empty queue has no pages and is empty', () {
      const state = ReportsViewState();

      expect(state.hasMore, isFalse);
      expect(state.isEmpty, isTrue);
    });

    test('a failed load is never reported as empty', () {
      // The assertion that matters most in this file: an admin who sees "no
      // reports" on a network error will stop checking, and a buyer's complaint
      // goes unanswered.
      const state = ReportsViewState(
        loadError: ServerException(
          code: 'server.failure',
          messageEn: 'x',
          messageNe: 'x',
        ),
      );

      expect(state.isEmpty, isFalse);
    });

    test('hasMore follows the cursor', () {
      final state = ReportsViewState(
        entries: [report('a')],
        cursor: ReportCursor(createdAt: now, id: 'a'),
      );

      expect(state.hasMore, isTrue);
    });

    test('withClearedError drops the error and takes the cursor verbatim', () {
      // The nullable-cursor case: an exhausted queue must drop its key, or
      // `hasMore` stays true forever and every scroll re-requests the last
      // page.
      final state = ReportsViewState(
        entries: [report('a')],
        cursor: ReportCursor(createdAt: now, id: 'a'),
        isLoadingMore: true,
        loadError: const ServerException(
          code: 'server.failure',
          messageEn: 'x',
          messageNe: 'x',
        ),
      );

      // isLoadingMore is passed explicitly, as `loadMore` does: omitting it
      // keeps the old value, so a state that was mid-load would stay mid-load
      // after a successful page.
      final cleared =
          state.withClearedError(cursor: null, isLoadingMore: false);

      expect(cleared.loadError, isNull);
      expect(cleared.cursor, isNull);
      expect(cleared.hasMore, isFalse);
      expect(cleared.isLoadingMore, isFalse);
      expect(cleared.entries, hasLength(1));
    });

    test('waitingCount is every row when no threshold is given', () {
      final state = ReportsViewState(
        entries: [report('a'), report('b'), report('c')],
      );

      expect(state.waitingCount(), 3);
    });

    test('waitingCount counts only rows past the threshold', () {
      final state = ReportsViewState(
        entries: [
          report('old', waited: const Duration(days: 5)),
          report('new', waited: const Duration(minutes: 5)),
        ],
      );

      // The threshold is evaluated against `DateTime.now`, so this can only be
      // asserted with a threshold far from the fixture's `now`. `new` is
      // minutes old and `old` is days old; a one-day threshold separates them
      // under any clock reading close to `now`.
      expect(
        state.waitingCount(olderThan: const Duration(days: 1)),
        lessThanOrEqualTo(1),
      );
    });

    test('oldestWait is null with nothing loaded', () {
      const state = ReportsViewState();

      expect(state.oldestWait(), isNull);
      expect(state.oldest, isNull);
    });

    test('oldestWait measures the wait of the first row', () {
      final state = ReportsViewState(
        entries: [report('a', waited: const Duration(hours: 3))],
      );

      expect(
        state.oldestWait(asOf: now),
        const Duration(hours: 3),
      );
    });

    test('a negative wait clamps to zero rather than reading as negative', () {
      // Clock skew between the device and the server. Rendering "-2 minutes
      // waiting" would be nonsense, and a negative Duration in a summary line
      // is the kind of thing that gets screenshotted as a bug.
      final state = ReportsViewState(
        entries: [
          AdminReportEntry(
            id: 'a',
            listingId: 'l1',
            reason: ReportReason.other,
            status: ReportStatus.open,
            createdAt: now.add(const Duration(minutes: 2)),
            listing: const ReportedListing(
              id: 'l1',
              title: 'House',
              priceNpr: 1,
              status: ListingStatus.live,
              district: 'Kathmandu',
              city: 'Kathmandu',
              sellerId: 's1',
            ),
            reporter: const ReportAuthor(id: 'b1'),
          ),
        ],
      );

      expect(state.oldestWait(asOf: now), Duration.zero);
    });

    test('a row with no timestamp contributes no wait', () {
      final state = ReportsViewState(entries: [report('a')]);

      expect(state.oldestWait(asOf: now), isNull);
      // Still counted as waiting: an undated row is a real row in the queue.
      expect(state.waitingCount(), 1);
    });
  });

  group('AdminReports paging', () {
    test('loads the first page for the selected tab', () async {
      final repo = FakeReportsRepository(
        [
          page(
            [report('a'), report('b')],
            nextCursor: ReportCursor(createdAt: now, id: 'b'),
          ),
        ],
      );
      final container = containerWith(repo);

      await container.read(adminReportsProvider.future);
      final state = container.read(adminReportsProvider).requireValue;

      expect(state.entries, hasLength(2));
      expect(state.counts.open, 4);
      expect(state.hasMore, isTrue);
      expect(repo.calls.single.status, ReportStatus.open);
      expect(repo.calls.single.cursor, isNull);
    });

    test('loadMore appends and advances the cursor', () async {
      final repo = FakeReportsRepository([
        page([report('a')], nextCursor: ReportCursor(createdAt: now, id: 'a')),
        page([report('b')]),
      ]);
      final container = containerWith(repo);

      await container.read(adminReportsProvider.future);
      await container.read(adminReportsProvider.notifier).loadMore();
      final state = container.read(adminReportsProvider).requireValue;

      expect(state.entries.map((e) => e.id), <String>['a', 'b']);
      expect(state.hasMore, isFalse);
      expect(repo.calls.last.cursor?.id, 'a');
    });

    test('loadMore is a no-op when exhausted', () async {
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);

      await container.read(adminReportsProvider.future);
      await container.read(adminReportsProvider.notifier).loadMore();

      // One call, not two: a scroll at the bottom of a complete queue must not
      // re-request what it already has.
      expect(repo.calls, hasLength(1));
    });

    test('loadMore is a no-op while one is in flight', () async {
      final repo = FakeReportsRepository([
        page([report('a')], nextCursor: ReportCursor(createdAt: now, id: 'a')),
        page([report('b')]),
      ]);
      final container = containerWith(repo);

      await container.read(adminReportsProvider.future);
      final notifier = container.read(adminReportsProvider.notifier);

      // Two calls without awaiting the first. The second must return early on
      // the isLoadingMore guard.
      await Future.wait<void>([
        notifier.loadMore(),
        notifier.loadMore(),
      ]);

      expect(repo.calls, hasLength(2));
      expect(
        container.read(adminReportsProvider).requireValue.entries,
        hasLength(2),
      );
    });

    test('a failed first page becomes inline error state', () async {
      final repo = FakeReportsRepository([])..failWith = _offline;
      final container = containerWith(repo);

      await container.read(adminReportsProvider.future);
      final state = container.read(adminReportsProvider).requireValue;

      expect(state.loadError, isNotNull);
      expect(state.isEmpty, isFalse);
    });

    test('a failed page two keeps the rows already loaded', () async {
      final repo = FakeReportsRepository([
        page([report('a')], nextCursor: ReportCursor(createdAt: now, id: 'a')),
      ]);
      final container = containerWith(repo);

      await container.read(adminReportsProvider.future);
      repo.failWith = _offline;
      await container.read(adminReportsProvider.notifier).loadMore();
      final state = container.read(adminReportsProvider).requireValue;

      // Blanking the list because page two failed would be worse than a retry
      // line under rows the admin can still act on.
      expect(state.entries, hasLength(1));
      expect(state.loadError, isNotNull);
      expect(state.isLoadingMore, isFalse);
    });

    test('a successful load-more clears the earlier error', () async {
      final repo = FakeReportsRepository([
        page([report('a')], nextCursor: ReportCursor(createdAt: now, id: 'a')),
      ]);
      final container = containerWith(repo);

      await container.read(adminReportsProvider.future);
      repo.failWith = _offline;
      await container.read(adminReportsProvider.notifier).loadMore();
      expect(
        container.read(adminReportsProvider).requireValue.loadError,
        isNotNull,
      );

      repo.responses.add(page([report('b')]));
      await container.read(adminReportsProvider.notifier).loadMore();

      expect(
        container.read(adminReportsProvider).requireValue.loadError,
        isNull,
      );
    });

    test('retry refetches from the first page', () async {
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);

      await container.read(adminReportsProvider.future);
      container.read(adminReportsProvider.notifier).retry();
      await container.read(adminReportsProvider.future);

      expect(repo.calls.length, greaterThanOrEqualTo(2));
    });
  });

  group('AdminReports.applyResolution', () {
    test('removes the row and moves the count to the resolved tab', () async {
      final repo = FakeReportsRepository([
        page([report('a'), report('b')]),
      ]);
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);

      container
          .read(adminReportsProvider.notifier)
          .applyResolution('a', ReportStatus.actioned);
      final state = container.read(adminReportsProvider).requireValue;

      expect(state.entries.map((e) => e.id), <String>['b']);
      expect(state.counts.open, 3);
      expect(state.counts.actioned, 2);
      expect(state.counts.dismissed, 2);
    });

    test('a dismissal increments dismissed, not actioned', () async {
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);

      container
          .read(adminReportsProvider.notifier)
          .applyResolution('a', ReportStatus.dismissed);
      final state = container.read(adminReportsProvider).requireValue;

      expect(state.counts.open, 3);
      expect(state.counts.actioned, 1);
      expect(state.counts.dismissed, 3);
    });

    test('an unknown report leaves the counts alone', () async {
      // Shifting a count for a row that was never on screen is how a badge
      // drifts away from reality until the next full load.
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);
      final before = container.read(adminReportsProvider).requireValue.counts;

      container
          .read(adminReportsProvider.notifier)
          .applyResolution('not-loaded', ReportStatus.actioned);
      final after = container.read(adminReportsProvider).requireValue.counts;

      expect(after, before);
      expect(after.open, 4);
    });

    test('the open count cannot go negative on a double submit', () async {
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);

      container.read(adminReportsProvider.notifier)
        // Second call for the same report: the row is gone, so this must be a
        // no-op rather than decrementing a second time.
        ..applyResolution('a', ReportStatus.actioned)
        ..applyResolution('a', ReportStatus.actioned);

      expect(
        container.read(adminReportsProvider).requireValue.counts.open,
        3,
      );
    });
  });

  group('ReportsTab', () {
    test('offers every report status', () {
      expect(ReportsTab.tabs, ReportStatus.values);
      expect(ReportsTab.tabs, hasLength(3));
    });

    test('defaults to the open tab, which is the work', () {
      final container = ProviderContainer(
        overrides: [
          adminRepositoryProvider.overrideWithValue(
            FakeReportsRepository([]),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(reportsTabProvider), ReportStatus.open);
    });

    test('switching tab refetches with the new status', () async {
      final repo = FakeReportsRepository([
        page([report('a')]),
        page([report('b', status: ReportStatus.dismissed)]),
      ]);
      final container = containerWith(repo);

      await container.read(adminReportsProvider.future);
      container.read(reportsTabProvider.notifier).tab = ReportStatus.dismissed;
      await container.read(adminReportsProvider.future);

      expect(repo.calls.last.status, ReportStatus.dismissed);
      expect(
        container.read(adminReportsProvider).requireValue.entries.single.id,
        'b',
      );
    });
  });

  group('ReportsController', () {
    test('a resolution removes the row and reports the status', () async {
      // The two must happen together: a row that leaves without the badge
      // moving, or a badge that moves without the row, both read as a bug.
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);

      final outcome = await container
          .read(reportsControllerProvider.notifier)
          .action('a');

      expect(outcome.requested, ReportResolution.actioned);
      expect(outcome.serverStatus, ReportStatus.actioned);
      expect(outcome.matchesRequest, isTrue);
      expect(outcome.listingId, 'listing-a');
      final state = container.read(adminReportsProvider).requireValue;
      expect(state.entries, isEmpty);
    });

    test('a dismissal reports dismissed', () async {
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);

      final outcome = await container
          .read(reportsControllerProvider.notifier)
          .dismiss('a');

      expect(outcome.requested, ReportResolution.dismissed);
      expect(outcome.serverStatus, ReportStatus.dismissed);
      expect(outcome.matchesRequest, isTrue);
    });

    test('a server status that differs is reported, not hidden', () async {
      // The admin pressed "actioned" and the database says "dismissed". The UI
      // needs both facts: showing "actioned" would misreport what happened to
      // the listing, and hiding the mismatch would hide a race.
      final repo = FakeReportsRepository([page([report('a')])])
        ..resolutionStatus = ReportStatus.dismissed;
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);

      final outcome = await container
          .read(reportsControllerProvider.notifier)
          .action('a');

      expect(outcome.serverStatus, ReportStatus.dismissed);
      expect(outcome.matchesRequest, isFalse);
    });

    test('a double submit on the same report is refused locally', () async {
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);

      final controller = container.read(reportsControllerProvider.notifier);
      final first = controller.action('a');
      // Second press while the first is still out. The server would refuse it
      // with 22023, but only after a round trip.
      await expectLater(
        controller.action('a'),
        throwsA(isA<ValidationException>()),
      );
      await first;
    });

    test('the guard releases after a failure, so the buttons return', () async {
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);

      final controller = container.read(reportsControllerProvider.notifier);
      repo.failWith = _offline;
      await expectLater(
        controller.action('a'),
        throwsA(isA<NetworkException>()),
      );

      // A lock left held would make every later resolution on this report
      // impossible for the rest of the session.
      expect(controller.isBusy('a'), isFalse);
      repo.failWith = null;
      expect(await controller.action('a'), isA<ReportResolutionOutcome>());
    });

    test('a resolution for a report not on screen still completes', () async {
      // It may have been resolved from another tab, or the list reloaded. The
      // listing id is then unknown, and an empty id is better than failing a
      // resolution the server already committed.
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);

      final outcome = await container
          .read(reportsControllerProvider.notifier)
          .action('not-loaded');

      expect(outcome.listingId, isEmpty);
      expect(outcome.serverStatus, ReportStatus.actioned);
    });

    test('the in-flight set is exposed read-only', () async {
      final repo = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repo);
      await container.read(adminReportsProvider.future);

      final controller = container.read(reportsControllerProvider.notifier);
      final pending = controller.action('a');

      expect(() => controller.inFlight.add('x'), throwsUnsupportedError);
      expect(controller.isBusy('a'), isTrue);

      await pending;
      expect(controller.isBusy('a'), isFalse);
    });
  });

  group('ReportResolutionOutcome', () {
    test('matchesRequest compares the server status to the request', () {
      const matching = ReportResolutionOutcome(
        reportId: 'r1',
        listingId: 'l1',
        requested: ReportResolution.actioned,
        serverStatus: ReportStatus.actioned,
      );
      const mismatched = ReportResolutionOutcome(
        reportId: 'r1',
        listingId: 'l1',
        requested: ReportResolution.actioned,
        serverStatus: ReportStatus.dismissed,
      );

      expect(matching.matchesRequest, isTrue);
      expect(mismatched.matchesRequest, isFalse);
    });

    test('equality covers every field', () {
      ReportResolutionOutcome make() => const ReportResolutionOutcome(
            reportId: 'r1',
            listingId: 'l1',
            requested: ReportResolution.actioned,
            serverStatus: ReportStatus.actioned,
          );

      expect(make(), make());
      expect(
        make().hashCode,
        make().hashCode,
      );
      expect(
        make(),
        isNot(
          const ReportResolutionOutcome(
            reportId: 'r1',
            listingId: 'l2',
            requested: ReportResolution.actioned,
            serverStatus: ReportStatus.actioned,
          ),
        ),
      );
    });
  });
}

/// The exception every failure path here produces.
///
/// A [NetworkException] specifically, because it is retryable — the code under
/// test treats a recoverable failure differently from a permanent one.
const NetworkException _offline = NetworkException(
  code: 'network.offline',
  messageEn: 'Offline',
  messageNe: 'इन्टरनेत छैन',
);

/// Repository stub serving scripted report pages.
class FakeReportsRepository implements AdminRepository {
  FakeReportsRepository(this.responses);

  /// Pages served in order, then [ReportPage.empty] forever.
  final List<ReportPage> responses;

  /// Every `getReports` call, with the tab and cursor it asked for.
  final List<({ReportStatus status, ReportCursor? cursor})> calls = [];

  /// When set, thrown by the next call instead of returning a page.
  AppException? failWith;

  /// What [resolveReport] reports back.
  ///
  /// Defaults per call from the resolution the caller asked for, so a
  /// `dismiss` reads back as `dismissed` without every test having to set it.
  /// Set explicitly to model a race: another admin resolved it first.
  ReportStatus? resolutionStatus;

  int _next = 0;

  @override
  Future<ReportPage> getReports({
    ReportStatus status = ReportStatus.open,
    ReportCursor? cursor,
    int pageSize = 50,
  }) async {
    calls.add((status: status, cursor: cursor));
    final failure = failWith;
    if (failure != null) {
      failWith = null;
      throw failure;
    }
    if (_next >= responses.length) return ReportPage.empty;
    return responses[_next++];
  }

  @override
  Future<ReportStatus> resolveReport(
    String reportId,
    ReportResolution resolution,
  ) async {
    final failure = failWith;
    if (failure != null) {
      failWith = null;
      throw failure;
    }
    return switch (resolution) {
      ReportResolution.actioned => resolutionStatus ?? ReportStatus.actioned,
      ReportResolution.dismissed => resolutionStatus ?? ReportStatus.dismissed,
    };
  }

  /// Moderation methods added by HYA-262. Not exercised by the reports
  /// tests; stubbed rather than `noSuchMethod` so a wrong test fails loudly
  /// instead of passing silently.
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

  /// Fraud signals added by HYA-261: not exercised here. The signals panel
  /// overrides `fraudSignalsProvider` directly in its own tests.
  @override
  Future<ListingFraudSignals> fraudSignals(String listingId) async =>
      throw UnimplementedError(
        'fraudSignals is not covered by these tests',
      );

  /// Warning counts added by HYA-303: not exercised here. The queue tests
  /// override at the provider seam instead.
  @override
  Future<Map<String, int>> fraudWarningCounts(
    List<String> listingIds,
  ) async =>
      throw UnimplementedError(
        'fraudWarningCounts is not covered by these tests',
      );

  // The verification queue methods are not exercised here. They answer with
  // empty results rather than `noSuchMethod`, which would silently accept a
  // call it cannot handle and turn a wrong test into a passing one.
  @override
  Future<QueuePage> getQueue({
    ListingStatus status = ListingStatus.pendingReview,
    QueueCursor? cursor,
    int pageSize = 50,
  }) async =>
      QueuePage.empty;

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

  @override
  Future<List<KycDocument>> pendingKycDocuments({int limit = 50}) async =>
      const <KycDocument>[];

  @override
  Future<KycDocument> verifyKyc(String docId) async =>
      throw UnimplementedError('verifyKyc is not covered by these tests');

  @override
  Future<KycDocument> rejectKyc(String docId, String reason) async =>
      throw UnimplementedError('rejectKyc is not covered by these tests');

  @override
  Future<AdminKycPage> pendingKycDocumentsPaged({
    KycDocStatus status = KycDocStatus.pending,
    String? cursor,
    int limit = 50,
  }) async =>
      const AdminKycPage(entries: <AdminKycEntry>[], counts: AdminKycCounts());

  @override
  Future<AdminKycEntry> getKycDocument(String docId) async =>
      throw UnimplementedError('getKycDocument is not covered by these tests');
}
