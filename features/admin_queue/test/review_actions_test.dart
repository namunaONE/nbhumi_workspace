import 'package:admin_queue/admin_queue.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Widget tests for the review actions (HYA-260).
///
/// These exercise the two decisions an admin can make and, more importantly,
/// what the admin is told afterwards. A moderation action that reports a
/// success which did not happen is worse than one that reports a failure: the
/// first leaves a listing unreviewed with nobody looking for it.
void main() {
  /// Builds a listing in the given status.
  ListingDetail listing({ListingStatus status = ListingStatus.pendingReview}) =>
      ListingDetail(
        id: 'l1',
        sellerId: 's1',
        title: 'Shanti Villa',
        priceNpr: 25000000,
        district: 'Kathmandu',
        city: 'Kathmandu',
        status: status,
        propertyType: PropertyType.house,
        listingPurpose: ListingPurpose.sale,
        submittedAt: DateTime.utc(2026, 10, 4),
        seller: const ListingSeller(
          id: 's1',
          fullName: 'Ram Bahadur',
          role: 'agent',
          kycTier: 'identity',
          isVerified: true,
        ),
      );

  /// A repository whose next decision returns [status], or throws [failWith].
  FakeAdminRepository repository({
    ListingStatus status = ListingStatus.live,
    AppException? failWith,
    bool failForever = false,
  }) =>
      FakeAdminRepository([QueuePage.empty])
        ..decisionStatus = status
        ..failWith = failWith
        ..failForever = failForever;

  Future<void> pumpDetail(
    WidgetTester tester, {
    required FakeAdminRepository repository,
    ListingStatus status = ListingStatus.pendingReview,
  }) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Provide a valid admin user for the seller so SellerModeration doesn't
    // show a load error with a Retry button (which would pollute the test).
    const adminUser = AdminUser(
      id: 's1',
      email: 'seller@example.com',
      fullName: 'Ram Bahadur',
      role: UserRole.agent,
      kycTier: KycTier.identity,
      isVerified: true,
    );

    final container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repository),
        adminListingDetailProvider.overrideWith((ref, listingId) async {
          return listing(status: status);
        }),
        adminAuditTrailProvider.overrideWith((ref, listingId) async {
          return const <AuditLogEntry>[];
        }),
        adminUserProvider('s1').overrideWithValue(
          const AsyncValue.data(adminUser),
        ),
        // Empty signals so the fraud panel renders "checked" rather than a
        // load error with a Retry button (which would pollute these tests --
        // same reasoning as the adminUser override above).
        fraudSignalsProvider('l1').overrideWithValue(
          const AsyncValue.data(ListingFraudSignals(listingId: 'l1')),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AdminListingDetailScreen(listingId: 'l1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the action bar', () {
    testWidgets('a pending listing offers both decisions', (tester) async {
      await pumpDetail(tester, repository: repository());

      expect(find.widgetWithText(FilledButton, 'Approve'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Reject'), findsOneWidget);
    });

    testWidgets('a live listing offers unpublish instead', (tester) async {
      await pumpDetail(
        tester,
        repository: repository(),
        status: ListingStatus.live,
      );

      // Approve/reject would produce exactly the 22023 the RPC raises for a
      // listing that is not pending. Unpublish is the moderation action that
      // belongs here instead (HYA-262).
      expect(find.widgetWithText(FilledButton, 'Approve'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Reject'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Unpublish'), findsOneWidget);
    });

    testWidgets('a rejected listing says so instead of offering buttons', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        repository: repository(),
        status: ListingStatus.rejected,
      );

      expect(
        find.text('This listing is rejected.'),
        findsOneWidget,
      );
    });
  });

  group('approving', () {
    testWidgets('reports success when the server moved it to live', (
      tester,
    ) async {
      final repo = repository();

      await pumpDetail(tester, repository: repo);
      await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
      await tester.pumpAndSettle();

      expect(
        find.text('Listing approved and now live.'),
        findsOneWidget,
      );
    });

    testWidgets('says so plainly when the listing was already actioned', (
      tester,
    ) async {
      // The server answered `rejected` to an approve request. Reporting
      // "approved" here would tell the admin something false, and would leave a
      // rejected listing looking reviewed.
      final repo = repository(status: ListingStatus.rejected);

      await pumpDetail(tester, repository: repo);
      await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('already rejected'),
        findsOneWidget,
      );
      expect(find.text('Listing approved and now live.'), findsNothing);
    });

    testWidgets('shows a validation error, with no retry', (tester) async {
      final repo = repository(
        failWith: const ValidationException(
          code: 'validation.rejected',
          messageEn: 'This listing is no longer awaiting review.',
          messageNe: 'यो लिस्टिङ अब समीक्षा हुन बाँकी छैन।',
        ),
      );

      await pumpDetail(tester, repository: repo);
      await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
      await tester.pumpAndSettle();

      expect(
        find.text('This listing is no longer awaiting review.'),
        findsOneWidget,
      );
      // Retrying a validation failure would fail identically, so no retry is
      // offered.
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('offers a retry for a retryable failure', (tester) async {
      final repo = repository(
        failWith: const NetworkException(
          code: 'network.timeout',
          messageEn: 'Timed out. Check your connection.',
          messageNe: 'समय सकिएको छैन। इन्टरनेट जाँच्नुहोस्।',
        ),
      );

      await pumpDetail(tester, repository: repo);
      await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
      await tester.pumpAndSettle();

      expect(find.text('Timed out. Check your connection.'), findsOneWidget);
      expect(find.byType(SnackBarAction), findsOneWidget);
    });
  });

  group('rejecting', () {
    testWidgets('will not submit without a reason', (tester) async {
      await pumpDetail(tester, repository: repository());

      await tester.tap(find.widgetWithText(OutlinedButton, 'Reject'));
      await tester.pumpAndSettle();

      final submit = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Reject listing'),
      );

      // Disabled rather than absent: the button is where the admin expects it,
      // and a disabled state says "fill this in" where a missing one does not.
      expect(
        tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Reject listing'),
        ).onPressed,
        isNull,
      );
      expect(submit.onPressed, isNull);
    });

    testWidgets('a suggestion chip fills the field and enables submit', (
      tester,
    ) async {
      await pumpDetail(tester, repository: repository());

      await tester.tap(find.widgetWithText(OutlinedButton, 'Reject'));
      await tester.pumpAndSettle();
      const suggestion = 'Photos do not show the property clearly.';
      await tester.tap(find.widgetWithText(ActionChip, suggestion));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Reject listing'),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('sends the reason and reports success', (tester) async {
      final repo = repository(status: ListingStatus.rejected);

      await pumpDetail(tester, repository: repo);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Reject'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Photos are unclear');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reject listing'));
      await tester.pumpAndSettle();

      expect(repo.lastRejectReason, 'Photos are unclear');
      expect(
        find.textContaining('Listing rejected'),
        findsOneWidget,
      );
    });

    testWidgets('cancelling sends nothing', (tester) async {
      final repo = repository();

      await pumpDetail(tester, repository: repo);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Reject'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(repo.lastRejectReason, isNull);
      expect(repo.decisions, 0);
    });
  });

  group('the SLA and status', () {
    testWidgets('a listing submitted two days ago reads as overdue', (
      tester,
    ) async {
      await pumpDetail(tester, repository: repository());

      expect(find.textContaining('Overdue'), findsOneWidget);
    });

    testWidgets('the status is shown as its wire name', (tester) async {
      await pumpDetail(tester, repository: repository());

      expect(find.text('pending_review'), findsOneWidget);
    });
  });

  group('a listing that cannot be loaded', () {
    testWidgets('a null detail is not presented as an error', (tester) async {
      // The RPC answers P0002 for missing, unpublished and not-yours alike, so
      // the screen must not pretend to tell them apart.
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          adminRepositoryProvider.overrideWithValue(repository()),
          adminListingDetailProvider.overrideWith((ref, listingId) async {
            return null;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AdminListingDetailScreen(listingId: 'l1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('This listing is not available.'), findsOneWidget);
      expect(find.textContaining('Try again'), findsNothing);
    });
  });
}

/// Repository stub whose decision outcome the test controls.
class FakeAdminRepository implements AdminRepository {
  FakeAdminRepository(this._responses);

  final List<QueuePage> _responses;
  int _next = 0;

  /// What `approve` and `reject` report back.
  ListingStatus decisionStatus = ListingStatus.live;

  /// The reason last passed to `reject`, or null.
  String? lastRejectReason;

  /// How many decisions were submitted.
  int decisions = 0;

  /// When set, thrown by the next decision instead of succeeding.
  AppException? failWith;

  /// When true, [failWith] is not cleared after one throw.
  bool failForever = false;

  @override
  Future<QueuePage> getQueue({
    ListingStatus status = ListingStatus.pendingReview,
    QueueCursor? cursor,
    int pageSize = 50,
  }) async {
    if (_next >= _responses.length) return QueuePage.empty;
    return _responses[_next++];
  }

  @override
  Future<ListingStatus> approveListing(String listingId) => _decide();

  @override
  Future<ListingStatus> rejectListing(String listingId, String reason) {
    lastRejectReason = reason;
    return _decide();
  }

  Future<ListingStatus> _decide() {
    decisions++;
    final failure = failWith;
    if (failure == null) return Future.value(decisionStatus);

    if (!failForever) failWith = null;
    return Future<ListingStatus>.error(failure);
  }

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
  /// cannot handle, which turns a wrong test into a passing one. Stubs
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
