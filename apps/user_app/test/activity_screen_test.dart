import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kyc/l10n/output/kyc_localizations.dart' as kyc_strings;
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/screens/activity_screen.dart';

const _buyer = Profile(
  id: 'buyer-1',
  email: 'buyer@probe.test',
  fullName: 'Sita Kumari',
);

const _agent = Profile(
  id: 'agent-1',
  email: 'agent@probe.test',
  fullName: 'Ram Thapa',
  role: UserRole.agent,
);

ListingSummary _listing(String id, ListingStatus status) => ListingSummary(
      id: id,
      sellerId: 'agent-1',
      title: 'House in $id',
      priceNpr: 2500000,
      district: 'Kathmandu',
      city: 'KMC',
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      status: status,
    );

/// Sessions are hand-built: Rule 33 forbids touching the network for one.
Session _session(String userId) => Session(
      accessToken: 'token',
      refreshToken: 'refresh',
      tokenType: 'bearer',
      user: User(
        id: userId,
        appMetadata: const <String, dynamic>{},
        userMetadata: const <String, dynamic>{},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
      ),
    );

/// Scripted activity seam: one override covers listings, reveals and stats.
class _FakeActivityRepository implements ActivityRepository {
  _FakeActivityRepository();

  List<ListingSummary> listings = const [];
  List<MyReveal> reveals = const [];
  List<ListingRevealStat> stats = const [];

  @override
  Future<List<ListingSummary>> myListings() async => listings;

  @override
  Future<List<MyReveal>> myReveals() async => reveals;

  @override
  Future<List<ListingRevealStat>> listingRevealStats() async => stats;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository(this.profile);

  final Profile? profile;

  @override
  Future<Profile?> getUserById(String id) async => profile;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeKycRepository implements KycRepository {
  _FakeKycRepository({this.documents = const []});

  final List<KycDocument> documents;

  @override
  Future<List<KycDocument>> myDocuments() async => documents;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotificationRepository implements NotificationRepository {
  _FakeNotificationRepository({this.updates = const []});

  final List<AppNotification> updates;

  @override
  Future<List<AppNotification>> inbox({int limit = 50}) async => updates;

  @override
  Future<int> unreadCount() async => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(
  WidgetTester tester, {
  Session? session,
  Profile? profile,
  _FakeActivityRepository? activity,
  List<KycDocument> documents = const [],
  List<AppNotification> updates = const [],
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(400, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      sessionProvider.overrideWithValue(session),
      userRepositoryProvider.overrideWithValue(
        _FakeUserRepository(profile),
      ),
      activityRepositoryProvider.overrideWithValue(
        activity ?? _FakeActivityRepository(),
      ),
      kycRepositoryProvider.overrideWithValue(
        _FakeKycRepository(documents: documents),
      ),
      notificationRepositoryProvider.overrideWithValue(
        _FakeNotificationRepository(updates: updates),
      ),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: '/profile/activity',
    routes: [
      GoRoute(
        path: '/profile/activity',
        builder: (context, state) => const ActivityScreen(),
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) => Scaffold(
          body: Text('DETAIL ${state.pathParameters['id']}'),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const Scaffold(body: Text('SIGN-IN SCREEN')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          kyc_strings.AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('guest activity', () {
    testWidgets('shows a sign-in prompt and no sections', (tester) async {
      await _pump(tester);

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('My listings'), findsNothing);
    });
  });

  group('empty activity', () {
    testWidgets('buyer sees buyer copy plus a post CTA', (tester) async {
      await _pump(tester, session: _session('buyer-1'), profile: _buyer);

      expect(find.text('My listings'), findsOneWidget);
      expect(find.text('Nothing posted yet.'), findsOneWidget);
      expect(find.text('Post a property'), findsOneWidget);
      // Interest renders only with data: nothing to be curious about yet.
      expect(find.text('Interest in my listings'), findsNothing);
      expect(find.text('No contacts viewed yet.'), findsOneWidget);
    });

    testWidgets('Nepali locale renders Nepali sections', (tester) async {
      await _pump(
        tester,
        session: _session('buyer-1'),
        profile: _buyer,
        locale: const Locale('ne'),
      );

      expect(find.text('मेरा विज्ञापनहरू'), findsOneWidget);
      expect(find.text('मेरा सोधपुछहरू'), findsOneWidget);
    });
  });

  group('populated activity', () {
    testWidgets('renders every section from the assembled page',
        (tester) async {
      final activity = _FakeActivityRepository()
        ..listings = [_listing('l-1', ListingStatus.live)]
        ..reveals = [
          const MyReveal(listingId: 'l-9', listingTitle: 'Flat in KMC'),
        ]
        ..stats = [
          ListingRevealStat(
            listingId: 'l-1',
            title: 'House in l-1',
            revealCount: 3,
            lastRevealedAt: DateTime.utc(2026, 10, 2),
          ),
        ];
      const doc = KycDocument(
        id: 'd-1',
        profileId: 'agent-1',
        docType: KycDocType.citizenship,
        storagePath: 'agent-1/1_citizenship.jpg',
      );
      const update = AppNotification(
        id: 'n-1',
        userId: 'agent-1',
        type: NotificationType.listingApproved,
        message: 'Your listing is live.',
        messageNe: 'तपाईंको विज्ञापन प्रकाशित भयो।',
      );
      await _pump(
        tester,
        session: _session('agent-1'),
        profile: _agent,
        activity: activity,
        documents: const [doc],
        updates: const [update],
      );

      expect(find.text('House in l-1'), findsWidgets);
      expect(find.text('Live'), findsOneWidget);
      expect(find.textContaining('3 views'), findsOneWidget);
      expect(find.text('Flat in KMC'), findsOneWidget);
      expect(find.text('Citizenship'), findsOneWidget);
      expect(find.text('Your listing is live.'), findsOneWidget);
    });

    testWidgets('a listing row opens its detail', (tester) async {
      final activity = _FakeActivityRepository()
        ..listings = [_listing('l-1', ListingStatus.live)];
      await _pump(
        tester,
        session: _session('agent-1'),
        profile: _agent,
        activity: activity,
      );

      await tester.tap(find.text('House in l-1'));
      await tester.pumpAndSettle();

      expect(find.text('DETAIL l-1'), findsOneWidget);
    });
  });
}
