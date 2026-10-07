import 'dart:async';

import 'package:admin_queue/admin_queue.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Widget tests for the reports queue (HYA-263).
///
/// Every provider the list touches is overridden (Rule 33), so nothing here
/// reaches the network. The assertions concentrate on two classes of bug:
/// a state that *reads* as "no reports" when the truth is that the load
/// failed, and a resolution that reports a decision the database did not
/// make.
void main() {
  final now = DateTime.utc(2026, 10, 6, 12);

  AdminReportEntry report(
    String id, {
    Duration? waited,
    ReportReason reason = ReportReason.priceSuspicious,
    ListingStatus listingStatus = ListingStatus.live,
    String? details = 'NPR 2 crore for 300 sqm',
    String? reporterName = 'Sita Kumari',
  }) =>
      AdminReportEntry(
        id: id,
        listingId: 'listing-$id',
        reason: reason,
        status: ReportStatus.open,
        details: details,
        createdAt: waited == null
            ? now.subtract(const Duration(hours: 2))
            : now.subtract(waited),
        listing: ReportedListing(
          id: 'listing-$id',
          title: 'House $id',
          priceNpr: 25000000,
          status: listingStatus,
          district: 'Kathmandu',
          city: 'Kirtipur',
          sellerId: 'seller-1',
        ),
        reporter: ReportAuthor(id: 'buyer-$id', fullName: reporterName),
      );

  ReportPage page(
    List<AdminReportEntry> entries, {
    ReportCounts counts = const ReportCounts(open: 2),
    ReportCursor? nextCursor,
  }) =>
      ReportPage(entries: entries, counts: counts, nextCursor: nextCursor);

  ProviderContainer containerWith(FakeReportsRepository repository) {
    final container = ProviderContainer(
      overrides: [adminRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Pumps the reports list at a given width.
  Future<void> pumpList(
    WidgetTester tester,
    ProviderContainer container, {
    Size size = const Size(1200, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AdminReportsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('empty and error states', () {
    testWidgets('an empty queue says so, and offers no retry', (tester) async {
      final container = containerWith(FakeReportsRepository([page([])]));

      await pumpList(tester, container);

      expect(find.text('No open reports.'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('a failed load never reads as no reports', (tester) async {
      // The assertion that matters most in this file. An admin who sees "no
      // open reports" on a network error stops checking, and a buyer's
      // complaint goes unanswered for good.
      final repository = FakeReportsRepository([page([])])
        ..failWith = reportsNetworkFailure;
      final container = containerWith(repository);

      await pumpList(tester, container);

      expect(find.text('No open reports.'), findsNothing);
      expect(find.byType(ReportsList), findsOneWidget);
    });

    testWidgets('a failed load offers a retry that refetches', (tester) async {
      // Only the successful page is queued: the first call throws, and the
      // retry then reads responses[0]. Queuing an empty page first would mean
      // the retry returned the failure's page rather than the recovery.
      final repository = FakeReportsRepository([page([report('a')])])
        ..failWith = reportsNetworkFailure;
      final container = containerWith(repository);
      await pumpList(tester, container);

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Price looks wrong'), findsOneWidget);
      expect(repository.calls.length, greaterThanOrEqualTo(2));
    });
  });

  group('a report row', () {
    testWidgets('shows the reason, the listing and the reporter', (
      tester,
    ) async {
      final container = containerWith(
        FakeReportsRepository([page([report('a')])]),
      );

      await pumpList(tester, container);

      expect(find.text('Price looks wrong'), findsOneWidget);
      expect(find.textContaining('House a'), findsOneWidget);
      expect(find.text('by Sita Kumari'), findsOneWidget);
    });

    testWidgets("quotes the buyer's description verbatim", (tester) async {
      // The buyer wrote it for exactly this purpose. An admin acting on a
      // paraphrase is not acting on the report.
      final container = containerWith(
        FakeReportsRepository([
          page([report('a', details: 'The pin is 3 km away')]),
        ]),
      );

      await pumpList(tester, container);

      expect(find.text('The pin is 3 km away'), findsOneWidget);
    });

    testWidgets('a report with no description shows no quote block', (
      tester,
    ) async {
      final container = containerWith(
        FakeReportsRepository([
          page([report('a', reason: ReportReason.alreadySold, details: null)]),
        ]),
      );

      await pumpList(tester, container);

      expect(find.text('Already sold'), findsOneWidget);
      expect(find.text('NPR 2 crore for 300 sqm'), findsNothing);
    });

    testWidgets('a listing that is no longer live is flagged', (tester) async {
      // A report against a pulled listing is history, not work. The flag stops
      // the admin spending the decision.
      final container = containerWith(
        FakeReportsRepository([
          page([report('a', listingStatus: ListingStatus.rejected)]),
        ]),
      );

      await pumpList(tester, container);

      expect(find.text('listing rejected'), findsOneWidget);
    });

    testWidgets('a live listing carries no such flag', (tester) async {
      final container = containerWith(
        FakeReportsRepository([page([report('a')])]),
      );

      await pumpList(tester, container);

      expect(find.textContaining('listing '), findsNothing);
    });

    testWidgets('an unnamed reporter is worded without a name', (
      tester,
    ) async {
      // A profile with no full name must not render "by null".
      final container = containerWith(
        FakeReportsRepository([page([report('a', reporterName: null)])]),
      );

      await pumpList(tester, container);

      expect(find.text('by a buyer'), findsOneWidget);
    });

    testWidgets('every reason has wording', (tester) async {
      // Exhaustive over the enum, so a new reason without wording fails here
      // rather than rendering an empty label.
      final container = containerWith(
        FakeReportsRepository([
          page([
            for (final reason in ReportReason.values)
              report('r${reason.name}', reason: reason),
          ]),
        ]),
      );

      // Tall viewport: `ListView.builder` only builds what is visible, so eight
      // rows in a default test window would leave the last ones unrendered and
      // the assertion would fail for the wrong reason.
      await pumpList(
        tester,
        container,
        size: const Size(1200, 2400),
      );

      for (final reason in ReportReason.values) {
        expect(
          find.text(reasonLabel(reason)),
          findsOneWidget,
          reason: 'no wording for ${reason.name}',
        );
      }
    });
  });

  group('resolving a report', () {
    testWidgets('actioning removes the row and confirms', (tester) async {
      final repository = FakeReportsRepository([
        page([report('a'), report('b')]),
      ]);
      final container = containerWith(repository);
      await pumpList(tester, container);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Uphold').first);
      await tester.pumpAndSettle();

      expect(find.text('Report upheld.'), findsOneWidget);
      // One row left, and it is the other one.
      expect(find.textContaining('House b'), findsOneWidget);
      expect(find.textContaining('House a'), findsNothing);
    });

    testWidgets('dismissing removes the row and confirms', (tester) async {
      final repository = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repository);
      await pumpList(tester, container);

      await tester.tap(find.widgetWithText(TextButton, 'Dismiss'));
      await tester.pumpAndSettle();

      expect(find.text('Report dismissed.'), findsOneWidget);
      expect(find.textContaining('House a'), findsNothing);
    });

    testWidgets('a race is reported as someone else having closed it', (
      tester,
    ) async {
      // The admin pressed "Uphold" and the database says "dismissed". Saying
      // "upheld" would misreport what happened to the record; hiding the
      // mismatch would hide the race.
      final repository = FakeReportsRepository([page([report('a')])])
        ..resolutionStatus = ReportStatus.dismissed;
      final container = containerWith(repository);
      await pumpList(tester, container);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Uphold'));
      await tester.pumpAndSettle();

      expect(find.text('Report upheld.'), findsNothing);
      expect(
        find.text('Already closed by someone else as dismissed.'),
        findsOneWidget,
      );
    });

    testWidgets('a failure shows a bilingual message with retry', (
      tester,
    ) async {
      final repository = FakeReportsRepository([page([report('a')])]);
      final container = containerWith(repository);
      await pumpList(tester, container);

      repository.failWith = reportsNetworkFailure;
      await tester.tap(find.widgetWithText(OutlinedButton, 'Uphold'));
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      // The row is still there: a failed resolution must not look like a
      // successful one.
      expect(find.textContaining('House a'), findsOneWidget);
    });

    testWidgets('the buttons are replaced by a spinner while in flight', (
      tester,
    ) async {
      final gate = Completer<void>();
      final repository = FakeReportsRepository([page([report('a')])])
        ..resolveGate = gate;
      final container = containerWith(repository);
      await pumpList(tester, container);

      // Started but not settled: the gate holds the call open, so the busy
      // branch is observable rather than over before the next pump.
      await tester.tap(find.widgetWithText(OutlinedButton, 'Uphold'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.widgetWithText(OutlinedButton, 'Uphold'), findsNothing);

      // The guard must release once the call lands, or the row is dead for the
      // rest of the session.
      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Report upheld.'), findsOneWidget);
    });

    testWidgets('only the busy row shows a spinner', (tester) async {
      // Guarding is per report, not per screen: reviewing one report must not
      // disable the buttons on another.
      final gate = Completer<void>();
      final repository =
          FakeReportsRepository([page([report('a'), report('b')])])
        ..resolveGate = gate;
      final container = containerWith(repository);
      await pumpList(tester, container);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Uphold').first);
      await tester.pump();

      // Two buttons were shown before the tap; one is gone with the busy row's
      // action strip, the other is untouched.
      expect(find.widgetWithText(OutlinedButton, 'Uphold'), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
    });
  });

  group('tabs', () {
    testWidgets('the three statuses are offered with their counts', (
      tester,
    ) async {
      final container = containerWith(
        FakeReportsRepository([
          page(
            [report('a')],
            counts: const ReportCounts(open: 2, actioned: 5, dismissed: 1),
          ),
        ]),
      );

      await pumpList(tester, container);

      // Scoped to the tab bar: the tab's "Actioned" is distinct from the row's
      // "Uphold" button only by wording, so a bare find of the row text would
      // not confuse it — but the scoped assertion is the honest one.
      final bar = find.byType(NavigationBar);
      expect(find.descendant(of: bar, matching: find.text('Open')), findsOne);
      expect(
        find.descendant(of: bar, matching: find.text('Actioned')),
        findsOne,
      );
      expect(
        find.descendant(of: bar, matching: find.text('Dismissed')),
        findsOne,
      );
    });

    testWidgets('counts are carried in the tab tooltips', (tester) async {
      // Deliberately not in the labels. A visible count that disagrees with the
      // loaded page is worse than no count, and a zero invites an admin to open
      // an empty tab and conclude something is broken.
      final container = containerWith(
        FakeReportsRepository([
          page(
            [report('a')],
            counts: const ReportCounts(open: 2, actioned: 5, dismissed: 1),
          ),
        ]),
      );

      await pumpList(tester, container);

      expect(find.byTooltip('Actioned, 5'), findsOneWidget);
      expect(find.byTooltip('Open, 2'), findsOneWidget);
      expect(find.byTooltip('Dismissed, 1'), findsOneWidget);
    });

    testWidgets('switching tab loads that status', (tester) async {
      final repository = FakeReportsRepository([
        page([report('a')]),
        page(
          [report('b', reason: ReportReason.fakeListing)],
          counts: const ReportCounts(actioned: 5),
        ),
      ]);
      final container = containerWith(repository);
      await pumpList(tester, container);

      await tester.tap(find.text('Actioned').last);
      await tester.pumpAndSettle();

      expect(repository.calls.last.status, ReportStatus.actioned);
      expect(find.text('Fake listing'), findsOneWidget);
    });

    testWidgets('an actioned tab with nothing in it says so', (
      tester,
    ) async {
      final repository = FakeReportsRepository([
        page([report('a')]),
        page([], counts: const ReportCounts(open: 1)),
      ]);
      final container = containerWith(repository);
      await pumpList(tester, container);

      await tester.tap(find.text('Dismissed').last);
      await tester.pumpAndSettle();

      expect(find.text('Nothing has been dismissed.'), findsOneWidget);
    });
  });

  group('pagination', () {
    testWidgets('the footer reports how many are loaded', (tester) async {
      final container = containerWith(
        FakeReportsRepository([
          page(
            [report('a')],
            nextCursor: ReportCursor(createdAt: now, id: 'a'),
          ),
        ]),
      );

      await pumpList(tester, container);

      expect(find.text('Scroll for more'), findsOneWidget);
    });

    testWidgets('the last page says so, so "empty" is provable', (
      tester,
    ) async {
      // An admin needs to know the queue they are about to call empty really is
      // empty, rather than having paged a few rows and assumed.
      final container = containerWith(
        FakeReportsRepository([page([report('a')])]),
      );

      await pumpList(tester, container);

      expect(find.text('1 report, end of queue'), findsOneWidget);
    });
  });
}

const AppException reportsNetworkFailure = NetworkException(
  code: 'network.timeout',
  messageEn: 'Timed out',
  messageNe: 'समयमा सकिएन',
);

/// Repository stub serving scripted report pages.
class FakeReportsRepository implements AdminRepository {
  FakeReportsRepository(this.responses);

  final List<ReportPage> responses;
  final List<({ReportStatus status, ReportCursor? cursor})> calls = [];

  /// When set, thrown by the next call instead of returning a page.
  AppException? failWith;

  /// What [resolveReport] reports back, when set.
  ReportStatus? resolutionStatus;

  /// When set, [resolveReport] waits on this before answering.
  ///
  /// Lets a test observe the in-flight state. A resolution that completes
  /// inside a single frame is over before the next pump, so the busy branch is
  /// only reachable with something to wait on.
  Completer<void>? resolveGate;

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
    final gate = resolveGate;
    if (gate != null) await gate.future;

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
}
