import 'dart:async';

import 'package:admin_queue/admin_queue.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Widget and controller tests for listing/user moderation (HYA-262).
///
/// These exercise what unpublish and suspend actually do and, more
/// importantly, what the admin is told afterwards. The two failure modes that
/// matter most: reporting an unpublish that did not happen (the listing stays
/// public with nobody looking), and suspending the wrong account (an
/// irreversible-looking action against the wrong seller).
void main() {
  /// Builds a listing in the given status.
  ListingDetail listing({
    ListingStatus status = ListingStatus.live,
    String? rejectionReason,
  }) =>
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
        rejectionReason: rejectionReason,
        seller: const ListingSeller(
          id: 's1',
          fullName: 'Ram Bahadur',
          role: 'agent',
          kycTier: 'identity',
          isVerified: true,
        ),
      );

  AdminUser user({bool suspended = false}) => AdminUser(
        id: 's1',
        email: 'seller@example.com',
        fullName: 'Ram Bahadur',
        role: UserRole.agent,
        suspended: suspended,
        suspendedReason: suspended ? 'Fake listings' : null,
        listings: const <String, int>{'live': 2},
        openReportsAgainst: 1,
      );

  Future<void> pumpDetail(
    WidgetTester tester, {
    required FakeModerationRepository repository,
    ListingDetail? detail,
    AdminUser? seller,
  }) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repository),
        adminListingDetailProvider.overrideWith((ref, listingId) async {
          return detail ?? listing();
        }),
        adminAuditTrailProvider.overrideWith((ref, listingId) async {
          return const <AuditLogEntry>[];
        }),
      ],
    );
    addTearDown(container.dispose);

    if (seller != null) repository.servedUser = seller;

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
    testWidgets('a live listing offers unpublish, not approve', (tester) async {
      await pumpDetail(
        tester,
        repository: FakeModerationRepository(),
      );

      expect(find.widgetWithText(OutlinedButton, 'Unpublish'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Approve'), findsNothing);
      expect(find.text('This listing is live.'), findsNothing);
    });

    testWidgets('an unpublished listing offers republish', (tester) async {
      await pumpDetail(
        tester,
        repository: FakeModerationRepository(),
        detail: listing(
          status: ListingStatus.unpublished,
          rejectionReason: 'Sold elsewhere',
        ),
      );

      expect(find.widgetWithText(FilledButton, 'Republish'), findsOneWidget);
      // The reason is labelled as an unpublish, not a failed review.
      expect(find.text('Unpublished'), findsOneWidget);
      expect(find.text('Rejected'), findsNothing);
      expect(find.text('Sold elsewhere'), findsOneWidget);
    });

    testWidgets('a pending listing keeps approve and reject', (tester) async {
      await pumpDetail(
        tester,
        repository: FakeModerationRepository(),
        detail: listing(status: ListingStatus.pendingReview),
      );

      expect(find.widgetWithText(FilledButton, 'Approve'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Unpublish'), findsNothing);
    });
  });

  group('unpublishing', () {
    testWidgets('a blank reason cannot be submitted', (tester) async {
      final repository = FakeModerationRepository();
      await pumpDetail(tester, repository: repository);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Unpublish'));
      await tester.pumpAndSettle();

      final submit = find.widgetWithText(FilledButton, 'Unpublish listing');
      expect(submit, findsOneWidget);
      // Disabled until text is entered: the RPC would refuse a blank reason
      // with 22023, and the admin should hear that before a round trip.
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);
      expect(repository.unpublishCalls, isEmpty);
    });

    testWidgets('a reason unpublishes and confirms', (tester) async {
      final repository = FakeModerationRepository();
      await pumpDetail(tester, repository: repository);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Unpublish'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Sold elsewhere');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Unpublish listing'));
      await tester.pumpAndSettle();

      expect(repository.unpublishCalls, ['l1:Sold elsewhere']);
      expect(find.text('Listing unpublished. The seller sees the reason.'),
          findsOneWidget);
    });

    testWidgets(
    'a divergent answer is reported as already moved',
    (tester) async {
      // Defensive: the RPC throws rather than returning anything but the
      // target status, so a divergent answer means the state moved underneath
      // the call. Saying "unpublished" anyway would misreport what happened.
      final repository = FakeModerationRepository()
        ..unpublishStatus = ListingStatus.live;
      await pumpDetail(tester, repository: repository);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Unpublish'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Sold elsewhere');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Unpublish listing'));
      await tester.pumpAndSettle();

      expect(find.textContaining('already live'), findsOneWidget);
    });

    testWidgets('a failure offers a retry only when retryable', (tester) async {
      final repository = FakeModerationRepository()
        ..failWith = const NetworkException(
          code: 'network.timeout',
          messageEn: 'Timed out',
          messageNe: 'समय सकियो',
        );
      await pumpDetail(tester, repository: repository);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Unpublish'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Sold elsewhere');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Unpublish listing'));
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('republishing', () {
    testWidgets('republish confirms and returns to live', (tester) async {
      final repository = FakeModerationRepository()
        ..republishStatus = ListingStatus.live;
      await pumpDetail(
        tester,
        repository: repository,
        detail: listing(
          status: ListingStatus.unpublished,
          rejectionReason: 'Sold elsewhere',
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Republish'));
      await tester.pumpAndSettle();

      expect(repository.republishCalls, ['l1']);
      expect(find.text('Listing republished and now live.'), findsOneWidget);
    });
  });

  group('seller moderation', () {
    testWidgets('an account in good standing offers suspend', (tester) async {
      await pumpDetail(
        tester,
        repository: FakeModerationRepository(),
        seller: user(),
      );

      expect(find.widgetWithText(OutlinedButton, 'Suspend seller'),
          findsOneWidget);
      expect(find.text('Account suspended'), findsNothing);
    });

    testWidgets('a suspended account shows the way back', (tester) async {
      await pumpDetail(
        tester,
        repository: FakeModerationRepository(),
        seller: user(suspended: true),
      );

      expect(find.text('Account suspended'), findsOneWidget);
      expect(find.text('Fake listings'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Lift suspension'),
          findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Suspend seller'),
          findsNothing);
    });

    testWidgets(
    'suspending warns that live listings stay live',
    (tester) async {
      await pumpDetail(
        tester,
        repository: FakeModerationRepository(),
        seller: user(),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Suspend seller'));
      await tester.pumpAndSettle();

      // The dialog states the scope plainly: suspending never hides inventory
      // by itself, so an admin who wants listings down must unpublish them.
      expect(find.textContaining('stay live until each is unpublished'),
          findsOneWidget);
    });

    testWidgets('a suspension lands and confirms', (tester) async {
      final repository = FakeModerationRepository();
      await pumpDetail(
        tester,
        repository: repository,
        seller: user(),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Suspend seller'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Fake listings');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Suspend seller'));
      await tester.pumpAndSettle();

      expect(repository.suspendCalls, ['s1:Fake listings']);
      expect(find.text('Seller suspended.'), findsOneWidget);
    });

    testWidgets('lifting a suspension confirms', (tester) async {
      final repository = FakeModerationRepository();
      await pumpDetail(
        tester,
        repository: repository,
        seller: user(suspended: true),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Lift suspension'));
      await tester.pumpAndSettle();

      expect(repository.unsuspendCalls, ['s1']);
      expect(find.text('Suspension lifted.'), findsOneWidget);
    });
  });

  group('AdminModerationController', () {
    test('a double submit on the same item is refused locally', () async {
      final gate = Completer<void>();
      final repository = FakeModerationRepository()..moderateGate = gate;
      final container = ProviderContainer(
        overrides: [adminRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(adminModerationControllerProvider.notifier);
      final first = controller.unpublish('l1', 'reason');
      await expectLater(
        controller.unpublish('l1', 'reason'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'validation.moderationAlreadyInFlight',
          ),
        ),
      );
      gate.complete();
      await first;
    });

    test('the guard releases after a failure', () async {
      final repository = FakeModerationRepository()
        ..failWith = const NetworkException(
          code: 'network.timeout',
          messageEn: 'Timed out',
          messageNe: 'समय सकियो',
        );
      final container = ProviderContainer(
        overrides: [adminRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(adminModerationControllerProvider.notifier);
      await expectLater(
        controller.republish('l1'),
        throwsA(isA<NetworkException>()),
      );

      // A lock left held would make every later moderation on this item
      // impossible for the rest of the session.
      expect(controller.inFlight, isEmpty);
    });
  });
}

/// Repository stub with scripted moderation answers.
class FakeModerationRepository implements AdminRepository {
  /// Unpublish calls received as `listingId:reason`.
  final List<String> unpublishCalls = <String>[];

  /// Republish calls received.
  final List<String> republishCalls = <String>[];

  /// Suspend calls received as `userId:reason`.
  final List<String> suspendCalls = <String>[];

  /// Unsuspend calls received.
  final List<String> unsuspendCalls = <String>[];

  /// The user [getUser] serves.
  AdminUser servedUser = const AdminUser(
    id: 's1',
    email: 'seller@example.com',
    fullName: 'Ram Bahadur',
  );

  /// What unpublish reports back.
  ListingStatus unpublishStatus = ListingStatus.unpublished;

  /// What republish reports back.
  ListingStatus republishStatus = ListingStatus.live;

  /// When set, thrown by the next moderation call instead of succeeding.
  AppException? failWith;

  /// When set, moderation calls wait on this before answering.
  Completer<void>? moderateGate;

  Future<void> _maybeFail() async {
    final gate = moderateGate;
    if (gate != null) await gate.future;
    final failure = failWith;
    if (failure != null) {
      failWith = null;
      throw failure;
    }
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

  @override
  Future<AdminUser> suspendUser(String userId, String reason) async {
    await _maybeFail();
    suspendCalls.add('$userId:$reason');
    return servedUser;
  }

  @override
  Future<AdminUser> unsuspendUser(String userId) async {
    await _maybeFail();
    unsuspendCalls.add(userId);
    return servedUser;
  }

  @override
  Future<ListingStatus> unpublishListing(
    String listingId,
    String reason,
  ) async {
    await _maybeFail();
    unpublishCalls.add('$listingId:$reason');
    return unpublishStatus;
  }

  @override
  Future<ListingStatus> republishListing(String listingId) async {
    await _maybeFail();
    republishCalls.add(listingId);
    return republishStatus;
  }

  @override
  Future<AdminUser> getUser(String userId) async => servedUser;

  /// Fraud signals are not served by this fake: panel tests override
  /// `fraudSignalsProvider` directly, so an empty set is the honest
  /// "not set up here" answer.
  @override
  Future<ListingFraudSignals> fraudSignals(String listingId) async =>
      ListingFraudSignals(listingId: listingId);
}
