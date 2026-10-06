import 'package:admin_queue/admin_queue.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Widget tests for the queue list (HYA-260).
///
/// Every provider the list touches is overridden (Rule 33), so nothing here
/// reaches the network. The assertions concentrate on the one class of bug that
/// would cost a real listing its review: a state that *reads* as "nothing to
/// review" when the truth is that the load failed.
void main() {
  final now = DateTime.utc(2026, 10, 5, 12);

  AdminQueueEntry entry(
    String id, {
    Duration? waited,
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
        status: ListingStatus.pendingReview,
        photoCount: photoCount,
        rejectionReason: rejectionReason,
        seller: const QueueSeller(id: 's1', fullName: 'Ram Bahadur'),
        submittedAt: waited == null ? null : now.subtract(waited),
      );

  /// A single pending listing, for the tests that do not care which one.
  ///
  /// Named rather than inlined because the inline form
  /// `FakeAdminRepository([page([entry('a')])])` runs past 80 columns at every
  /// call site, and a shorter name is the only fix that does not reformat six
  /// unrelated tests.
  AdminQueueEntry row() => entry('a');

  QueuePage page(
    List<AdminQueueEntry> entries, {
    QueueCounts counts = const QueueCounts(pendingReview: 3),
    QueueCursor? nextCursor,
  }) =>
      QueuePage(entries: entries, counts: counts, nextCursor: nextCursor);

  /// A container with the repository overridden.
  ///
  /// The tab is *not* set here, and that is load-bearing.
  /// `AdminQueueTab` is not `keepAlive`, so reading its notifier
  /// before anything listens creates it and immediately disposes
  /// it. The state is gone, and the provider rebuilds to
  /// `pendingReview` the moment the screen watches it. [pumpList]
  /// therefore sets the tab after the first pump, while a
  /// listener exists.
  ///
  /// It is also deliberately not overridden with
  /// `overrideWithValue`: that would swap the element for a plain
  /// value element, and the tab bar writes through `.notifier`,
  /// so the first tap would throw a cast error, not switch tabs.
  ProviderContainer containerWith(FakeAdminRepository repository) {
    final container = ProviderContainer(
      overrides: [adminRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Pumps the list at a given width, optionally on a given tab.
  ///
  /// The tab is applied after the first pump rather than before it — see
  /// [containerWith] for why.
  Future<void> pumpList(
    WidgetTester tester,
    ProviderContainer container, {
    Size size = const Size(1200, 900),
    ListingStatus? tab,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AdminQueueScreen()),
      ),
    );
    await tester.pump();

    if (tab != null) {
      container.read(adminQueueTabProvider.notifier).tab = tab;
    }

    await tester.pumpAndSettle();
  }

  group('empty states', () {
    testWidgets('an empty pending queue says so, and offers no retry', (
      tester,
    ) async {
      final container = containerWith(FakeAdminRepository([page([])]));

      await pumpList(tester, container);

      expect(find.text('Nothing waiting for review.'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('a failed load never reads as nothing to review', (
      tester,
    ) async {
      // The assertion that matters most in this file. An admin who sees
      // "nothing waiting" on a network error stops checking, and a real
      // listing goes unreviewed for good.
      final repository = FakeAdminRepository([page(const [])])
        ..failWith = networkFailure;
      final container = containerWith(repository);

      await pumpList(tester, container);

      expect(find.text('Nothing waiting for review.'), findsNothing);
      expect(find.textContaining('Timed out'), findsOneWidget);
    });

    testWidgets('each tab gets its own empty wording', (tester) async {
      final container = containerWith(FakeAdminRepository([page([])]));

      await pumpList(tester, container, tab: ListingStatus.live);

      expect(find.text('No listings have gone live yet.'), findsOneWidget);
    });
  });

  group('rows', () {
    testWidgets('a loaded queue lists its rows', (tester) async {
      final container = containerWith(
        FakeAdminRepository([
          page([entry('a'), entry('b', waited: const Duration(hours: 60))]),
        ]),
      );

      await pumpList(tester, container);

      expect(find.text('Listing a'), findsOneWidget);
      expect(find.text('Listing b'), findsOneWidget);
    });

    testWidgets('an overdue row is marked overdue with its hours', (
      tester,
    ) async {
      final container = containerWith(
        FakeAdminRepository([
          page([entry('a', waited: const Duration(hours: 72))]),
        ]),
      );

      await pumpList(tester, container);

      // The chip carries an icon as well as a colour, so the state does not
      // depend on hue alone.
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('Overdue'), findsOneWidget);
    });

    testWidgets('a thin photo count is flagged on the row', (tester) async {
      final container = containerWith(
        FakeAdminRepository([page([entry('a', photoCount: 1)])]),
      );

      await pumpList(tester, container);

      expect(find.text('1 photos'), findsOneWidget);
    });

    testWidgets('a full photo count is not flagged', (tester) async {
      final container = containerWith(
        // photoCount at the default of 3: the point of the test is that the
        // floor is not breached, so passing it explicitly would be the thing
        // under test rather than a given.
        FakeAdminRepository([page([entry('a')])]),
      );

      await pumpList(tester, container);

      expect(find.textContaining('photos'), findsNothing);
    });

    testWidgets('a previous rejection reason is surfaced on the row', (
      tester,
    ) async {
      final container = containerWith(
        FakeAdminRepository([
          page([entry('a', rejectionReason: 'Photos were unclear')]),
        ]),
      );

      await pumpList(tester, container);

      expect(find.textContaining('Previously rejected'), findsOneWidget);
    });
  });

  group('the SLA summary', () {
    testWidgets('counts the overdue rows above the list', (tester) async {
      final container = containerWith(
        FakeAdminRepository([
          page([
            entry('a', waited: const Duration(hours: 2)),
            entry('b', waited: const Duration(hours: 60)),
            entry('c', waited: const Duration(hours: 72)),
          ]),
        ]),
      );

      await pumpList(tester, container);

      expect(
        find.textContaining('2 listings past the 48h review SLA'),
        findsOneWidget,
      );
    });

    testWidgets('says nothing when every row is inside the SLA', (
      tester,
    ) async {
      final container = containerWith(
        FakeAdminRepository([
          page([entry('a', waited: const Duration(hours: 1))]),
        ]),
      );

      await pumpList(tester, container);

      expect(find.textContaining('review SLA'), findsNothing);
    });

    testWidgets('uses the singular for one overdue row', (tester) async {
      final container = containerWith(
        FakeAdminRepository([
          page([entry('a', waited: const Duration(hours: 60))]),
        ]),
      );

      await pumpList(tester, container);

      expect(find.textContaining('1 listing past'), findsOneWidget);
    });
  });

  group('responsive layout', () {
    testWidgets('a wide window shows the empty detail prompt', (tester) async {
      final container = containerWith(FakeAdminRepository([page([row()])]));

      await pumpList(tester, container);

      // 1200 is past narrowBreakpoint, so both panes exist.
      expect(find.text('Select a listing to review it.'), findsOneWidget);
    });

    testWidgets('a narrow window shows the list alone', (tester) async {
      final container = containerWith(FakeAdminRepository([page([row()])]));

      await pumpList(tester, container, size: const Size(500, 900));

      expect(find.text('Verification Queue'), findsOneWidget);
      expect(find.text('Select a listing to review it.'), findsNothing);
    });

    testWidgets('the breakpoint itself still counts as wide', (tester) async {
      final container = containerWith(FakeAdminRepository([page([row()])]));

      await pumpList(
        tester,
        container,
        size: const Size(narrowBreakpoint, 900),
      );

      expect(find.text('Select a listing to review it.'), findsOneWidget);
    });

    testWidgets('one pixel narrower collapses to the single pane', (
      tester,
    ) async {
      final container = containerWith(FakeAdminRepository([page([row()])]));

      await pumpList(
        tester,
        container,
        size: const Size(narrowBreakpoint - 1, 900),
      );

      expect(find.text('Select a listing to review it.'), findsNothing);
    });
  });

  group('pagination', () {
    testWidgets('an exhausted queue says so at the end', (tester) async {
      final container = containerWith(
        FakeAdminRepository([page([entry('a')])]),
      );

      await pumpList(tester, container);

      expect(find.textContaining('end of queue'), findsOneWidget);
    });

    testWidgets('a queue with more pages says scroll for more', (
      tester,
    ) async {
      final container = containerWith(
        FakeAdminRepository([
          page(
            [entry('a')],
            nextCursor: QueueCursor(submittedAt: now, id: 'a'),
          ),
        ]),
      );

      await pumpList(tester, container);

      expect(find.text('Scroll for more'), findsOneWidget);
    });
  });

  group('tabs', () {
    testWidgets('offers pending, live and rejected, and no drafts', (
      tester,
    ) async {
      final container = containerWith(FakeAdminRepository([page([row()])]));

      await pumpList(tester, container);

      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
      expect(find.text('Drafts'), findsNothing);
    });

    testWidgets('switching tabs refetches for the new status', (tester) async {
      final repository = FakeAdminRepository([
        page([entry('a')]),
        page([entry('live-1')]),
      ]);
      final container = containerWith(repository);

      await pumpList(tester, container);
      await tester.tap(find.text('Live'));
      await tester.pumpAndSettle();

      expect(repository.calls.last.status, ListingStatus.live);
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
/// Stands in at the Repository seam (Rule 31) so the tests exercise the screen
/// and the ViewModel without a network or a real Supabase client.
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
  /// A `noSuchMethod` stub would make the fake silently accept a call
  /// it cannot handle, which turns a wrong test into a passing one. Stubs
  /// that throw would break any future test that reaches for them. These
  /// do neither: they answer with an empty result, the honest answer for
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

  /// Report methods added by HYA-263, stubbed on the same reasoning as the KYC
  /// pair above. The reports tab is tested in `reports_tab_test.dart`.
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
}
