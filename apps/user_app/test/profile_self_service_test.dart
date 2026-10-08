import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/screens/profile_screen.dart';
import 'package:user_app/screens/settings_screen.dart';

const Profile _profile = Profile(
  id: 'buyer-1',
  email: 'buyer@probe.test',
  fullName: 'Sita Kumari',
  phone: '+9779841234567',
);

/// A signed-in session.
///
/// Built by hand because gotrue's `Session` and `User` have several required
/// fields, and Rule 33 forbids letting a test touch the network to obtain one.
Session _session() => Session(
      accessToken: 'token',
      refreshToken: 'refresh',
      tokenType: 'bearer',
      user: const User(
        id: 'buyer-1',
        appMetadata: <String, dynamic>{},
        userMetadata: <String, dynamic>{},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
      ),
    );

/// Repository stub recording calls and returning scripted results.
///
/// `noSuchMethod` covers the other UserRepository members, none of which this
/// screen touches.
class _FakeUserRepository implements UserRepository {
  _FakeUserRepository();

  Profile? profileResult = _profile;
  Map<String, Object?>? exportResult;

  /// Thrown instead of returning. Typed as [AppException] because that is what
  /// the real repository throws after mapping (Rule 38).
  AppException? failure;

  int updateCalls = 0;
  int exportCalls = 0;
  int deleteCalls = 0;
  Profile? lastSaved;

  @override
  Future<Profile?> getUserById(String id) async => profileResult;

  @override
  Future<Profile> updateProfile(Profile profile) async {
    updateCalls++;
    lastSaved = profile;
    final error = failure;
    if (error != null) throw error;
    return profile;
  }

  @override
  Future<Map<String, Object?>> exportMyData({required String userId}) async {
    exportCalls++;
    final error = failure;
    if (error != null) throw error;
    return exportResult ?? <String, Object?>{};
  }

  @override
  Future<Map<String, Object?>> deleteMyAccount() async {
    deleteCalls++;
    final error = failure;
    if (error != null) throw error;
    return <String, Object?>{'deleted_user_id': 'buyer-1'};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthService implements AuthService {
  int signOutCalls = 0;

  /// Thrown instead of signing out.
  AppException? failure;

  @override
  Future<void> signOut() async {
    final error = failure;
    if (error != null) throw error;
    signOutCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pumps the profile screen with a session and scripted repositories.
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Session? session,
  _FakeUserRepository? repository,
  _FakeAuthService? authService,
  Locale locale = const Locale('en'),
}) async {
  // Tall portrait surface: the profile now stacks the identity header,
  // agency card and settings entry above the self-service tiles, so the
  // default 800x600 surface (and the previous 1000px height) leaves delete
  // below the fold. Same precedent as widget_test's pumpApp, which sets its
  // size explicitly for the same reason.
  tester.view.physicalSize = const Size(400, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      sessionProvider.overrideWithValue(session),
      userRepositoryProvider.overrideWithValue(
        repository ?? _FakeUserRepository(),
      ),
      authServiceProvider.overrideWithValue(authService ?? _FakeAuthService()),
    ],
  );
  addTearDown(container.dispose);

  // A real router, not a stub: delete-account success navigates to /login,
  // and asserting that it actually navigates is the point of the test.
  final router = GoRouter(
    initialLocation: '/profile',
    routes: [
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
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
        // Required, or localizedForContext falls back to Nepali and every
        // English assertion below fails. main.dart supplies these too.
        locale: locale,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  group('signed-out profile', () {
    testWidgets('shows a sign-in prompt and no self-service tiles',
        (tester) async {
      // No session argument: the default is signed out.
      await _pump(tester);

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Edit profile'), findsNothing);
      expect(find.text('Download my data'), findsNothing);
      expect(find.text('Delete my account'), findsNothing);
    });
  });

  group('signed-in profile', () {
    testWidgets('shows the four self-service tiles', (tester) async {
      await _pump(tester, session: _session());

      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Download my data'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Delete my account'), findsOneWidget);
    });

    testWidgets('Nepali locale renders Nepali tiles', (tester) async {
      await _pump(
        tester,
        session: _session(),
        locale: const Locale('ne'),
      );

      expect(find.text('प्रोफाइल सम्पादन गर्नुहोस्'), findsOneWidget);
      expect(find.text('मेरो डाटा डाउनलोड गर्नुहोस्'), findsOneWidget);
      expect(find.text('साइन आउट'), findsOneWidget);
      expect(find.text('मेरो खाता मेट्नुहोस्'), findsOneWidget);
    });

    testWidgets('shows the profile name in the header', (tester) async {
      await _pump(tester, session: _session());

      expect(find.text('Sita Kumari'), findsOneWidget);
    });

    testWidgets('header shows email, phone, role and KYC chips',
        (tester) async {
      await _pump(tester, session: _session());

      // Email is auth-owned and read-only; the fixture profile mirrors it.
      expect(find.text('buyer@probe.test'), findsOneWidget);
      expect(find.text('+9779841234567'), findsWidgets);
      expect(find.text('Buyer'), findsOneWidget);
      expect(find.text('Unverified'), findsOneWidget);
      expect(
        find.text('Managed by sign-in · cannot be changed here'),
        findsOneWidget,
      );
    });

    testWidgets('agency card explains verification and links to KYC',
        (tester) async {
      await _pump(tester, session: _session());

      expect(find.text('Agency'), findsOneWidget);
      expect(
        find.text('Optional · shown on your listings'),
        findsOneWidget,
      );
      expect(find.text('Verify agency documents'), findsOneWidget);
    });

    testWidgets('settings entry navigates to the settings screen',
        (tester) async {
      await _pump(tester, session: _session());

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });
  });

  group('edit profile', () {
    testWidgets('rejects a non-Nepali phone inline', (tester) async {
      final repository = _FakeUserRepository();
      await _pump(tester, session: _session(), repository: repository);

      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Phone (optional)'),
        '12345',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Inline hint, not a server round trip — and no save attempted.
      expect(find.textContaining('97 or 98'), findsOneWidget);
      expect(repository.updateCalls, 0);
    });

    testWidgets('saves trimmed values and refreshes', (tester) async {
      final repository = _FakeUserRepository();
      await _pump(tester, session: _session(), repository: repository);

      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Full name'),
        '  Sita Updated  ',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repository.updateCalls, 1);
      expect(repository.lastSaved?.fullName, 'Sita Updated');
      expect(find.text('Saved — Sita Updated'), findsOneWidget);
    });

    testWidgets('shows a mapped failure instead of raw text', (tester) async {
      final repository = _FakeUserRepository()
        ..failure = const NetworkException(
          code: 'network.offline',
          messageEn: 'No connection',
          messageNe: 'इन्टरनेट छैन',
        );
      await _pump(tester, session: _session(), repository: repository);

      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('No connection'), findsOneWidget);
    });
  });

  group('export my data', () {
    testWidgets('shows the export as JSON with a working copy button',
        (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      final repository = _FakeUserRepository()
        ..exportResult = <String, Object?>{
          'exported_at': '2026-10-05T00:00:00Z',
          'profile': <String, Object?>{'email': 'buyer@probe.test'},
          'listings': [],
          'contact_reveals': [],
        };
      await _pump(tester, session: _session(), repository: repository);

      await tester.tap(find.text('Download my data'));
      await tester.pumpAndSettle();

      expect(find.text('Your data'), findsOneWidget);
      // The header also renders the profile email, so assert on JSON-only
      // content rather than the address.
      expect(find.textContaining('contact_reveals'), findsOneWidget);

      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(copied, hasLength(1));
      expect(copied.single, contains('contact_reveals'));
      expect(find.text('Copied to clipboard'), findsOneWidget);
    });

    testWidgets('shows a mapped failure', (tester) async {
      final repository = _FakeUserRepository()
        ..failure = const NetworkException(
          code: 'network.offline',
          messageEn: 'No connection',
          messageNe: 'इन्टरनेट छैन',
        );
      await _pump(tester, session: _session(), repository: repository);

      await tester.tap(find.text('Download my data'));
      await tester.pumpAndSettle();

      expect(find.text('No connection'), findsOneWidget);
    });
  });

  group('sign out', () {
    testWidgets('signs out and shows the sign-in prompt', (tester) async {
      final repository = _FakeUserRepository();
      final authService = _FakeAuthService();
      final container = await _pump(
        tester,
        session: _session(),
        repository: repository,
        authService: authService,
      );

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(authService.signOutCalls, 1);

      // The fake cannot emit onAuthStateChange, so flip the session the way a
      // real sign-out would and confirm the screen follows it. All overrides
      // must be restated: updateOverrides replaces the whole set, not one.
      container.updateOverrides([
        sessionProvider.overrideWithValue(null),
        userRepositoryProvider.overrideWithValue(repository),
        authServiceProvider.overrideWithValue(authService),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Sign out'), findsNothing);
    });

    testWidgets('a failed sign-out reports the reason', (tester) async {
      final authService = _FakeAuthService()
        ..failure = const NetworkException(
          code: 'network.offline',
          messageEn: 'No connection',
          messageNe: 'इन्टरनेट छैन',
        );
      await _pump(
        tester,
        session: _session(),
        authService: authService,
      );

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('No connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });
  });

  group('delete account', () {
    testWidgets('states the consequences before anything happens',
        (tester) async {
      await _pump(tester, session: _session());

      await tester.tap(find.text('Delete my account'));
      await tester.pumpAndSettle();

      expect(find.text('Delete your account?'), findsOneWidget);
      // The tile behind the dialog carries similar copy, so match the
      // dialog's fuller sentence rather than the shared fragment.
      expect(
        find.textContaining('without your name on them'),
        findsOneWidget,
      );
      expect(find.text('This cannot be undone.'), findsOneWidget);
    });

    testWidgets('needs the word DELETE typed, not just two taps',
        (tester) async {
      final repository = _FakeUserRepository();
      await _pump(tester, session: _session(), repository: repository);

      await tester.tap(find.text('Delete my account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Type DELETE to confirm'), findsOneWidget);

      // A near-miss must not enable the button.
      await tester.enterText(find.byType(TextField), 'delete');
      await tester.pump();
      var button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete my account'),
      );
      expect(button.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete my account'),
      );
      expect(button.onPressed, isNotNull);
      expect(repository.deleteCalls, 0);
    });

    testWidgets('deletes, signs out locally and lands on sign-in',
        (tester) async {
      final repository = _FakeUserRepository();
      final authService = _FakeAuthService();
      await _pump(
        tester,
        session: _session(),
        repository: repository,
        authService: authService,
      );

      await tester.tap(find.text('Delete my account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete my account'));
      await tester.pumpAndSettle();

      expect(repository.deleteCalls, 1);
      expect(authService.signOutCalls, 1);
      expect(find.text('SIGN-IN SCREEN'), findsOneWidget);
    });

    testWidgets('a failed delete stays put and reports the reason',
        (tester) async {
      final repository = _FakeUserRepository()
        ..failure = const ValidationException(
          code: 'account.alreadyDeleted',
          messageEn: 'Your account is already deleted.',
          messageNe: 'सकियो।',
        );
      final authService = _FakeAuthService();
      await _pump(
        tester,
        session: _session(),
        repository: repository,
        authService: authService,
      );

      await tester.tap(find.text('Delete my account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete my account'));
      await tester.pumpAndSettle();

      // No navigation, no sign-out: the session is still alive because the
      // account is not actually gone.
      expect(find.text('Your account is already deleted.'), findsOneWidget);
      expect(find.text('SIGN-IN SCREEN'), findsNothing);
      expect(authService.signOutCalls, 0);
    });

    testWidgets('delete stays reachable when the profile will not load',
        (tester) async {
      // The user who most needs self-service is the one whose data is broken:
      // a profile failure must not hide the delete action.
      final repository = _FakeUserRepository()..profileResult = null;
      await _pump(tester, session: _session(), repository: repository);

      expect(find.text('Delete my account'), findsOneWidget);
      expect(find.text('Download my data'), findsOneWidget);
    });
  });

  group('suspended account (HYA-301)', () {
    testWidgets('a suspended seller is told so on their profile', (
      tester,
    ) async {
      final repository = _FakeUserRepository()
        ..profileResult = const Profile(
          id: 'buyer-1',
          email: 'buyer@probe.test',
          fullName: 'Sita Kumari',
          suspended: true,
          suspendedReason: 'Fake listings',
        );
      await _pump(tester, session: _session(), repository: repository);

      expect(find.text('Account suspended'), findsOneWidget);
      // The admin's internal reason is not shown: the notice is about the
      // state, not the case file.
      expect(find.text('Fake listings'), findsNothing);
    });

    testWidgets('a clear account sees no suspension notice', (tester) async {
      final repository = _FakeUserRepository();
      await _pump(tester, session: _session(), repository: repository);

      expect(find.text('Account suspended'), findsNothing);
    });
  });
}
