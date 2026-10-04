import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:listing_detail/listing_detail.dart';
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

ListingDetail _listing() => const ListingDetail(
      id: 'listing-1',
      sellerId: 'seller-1',
      title: 'Shanti Villa',
      priceNpr: 25000000,
      district: 'Kathmandu',
      city: 'Kathmandu',
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      status: ListingStatus.live,
    );

/// Repository stub returning a scripted result from `contactSeller`.
///
/// `noSuchMethod` covers the other five ListingRepository methods, none of
/// which this widget touches.
class _FakeListingRepository implements ListingRepository {
  _FakeListingRepository({this.result, this.error});

  final SellerContact? result;

  /// Thrown instead of returning [result]. Typed as [AppException] because that
  /// is what the real repository throws after mapping (Rule 38).
  final AppException? error;

  int calls = 0;

  @override
  Future<SellerContact> contactSeller(String listingId) async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return result!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SellerContact _contact() => SellerContact(
      listingId: 'listing-1',
      sellerId: 'seller-1',
      sellerName: 'Ram Bahadur',
      sellerPhone: '+9779841234567',
      sellerEmail: 'seller@probe.test',
      agencyName: 'Himal Realtors',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );

/// Pumps the button with [isSignedIn] and a scripted repository result.
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  bool isSignedIn = true,
  _FakeListingRepository? repository,
  Locale locale = const Locale('en'),
}) async {
  final container = ProviderContainer(
    overrides: [
      listingRepositoryProvider
          .overrideWithValue(repository ?? _FakeListingRepository()),
      sessionProvider.overrideWithValue(isSignedIn ? _session() : null),
    ],
  );
  addTearDown(container.dispose);

  // A real router, not a stub: the guest path pushes /login, and asserting that
  // it actually navigates is the point of the test. A bare MaterialApp would
  // throw "No GoRouter found in context".
  final router = GoRouter(
    initialLocation: '/listing/listing-1',
    routes: [
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) => Scaffold(
          body: ContactSellerButton(listing: _listing()),
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
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
      ),
    ),
  );
  return container;
}

/// A minimal signed-in session.
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

void main() {
  testWidgets('shows no contact details before the button is pressed',
      (tester) async {
    // The core privacy property: nothing on screen reveals a phone number
    // until a reveal has actually succeeded.
    await _pump(tester);

    expect(find.text('+9779841234567'), findsNothing);
    expect(find.text('seller@probe.test'), findsNothing);
    expect(find.textContaining('Himal Realtors'), findsNothing);
  });

  testWidgets('invites a guest to sign in instead of revealing',
      (tester) async {
    final repository = _FakeListingRepository(result: _contact());
    await _pump(tester, isSignedIn: false, repository: repository);

    expect(
      find.widgetWithText(FilledButton, 'Sign in to contact'),
      findsOneWidget,
    );

    // Pressing it must navigate to sign-in and must not spend a reveal.
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('SIGN-IN SCREEN'), findsOneWidget);
    expect(repository.calls, 0);
  });

  testWidgets('reveals the contact when pressed while signed in',
      (tester) async {
    final repository = _FakeListingRepository(result: _contact());
    await _pump(tester, repository: repository);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(repository.calls, 1);
    expect(find.text('+9779841234567'), findsOneWidget);
    expect(find.text('seller@probe.test'), findsOneWidget);
    expect(find.text('Himal Realtors'), findsOneWidget);
  });

  testWidgets('calls the repository exactly once per tap', (tester) async {
    // A reveal is capped at ten per day, so an automatic retry would spend the
    // user's allowance on a single tap.
    final repository = _FakeListingRepository(result: _contact());
    await _pump(tester, repository: repository);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repository.calls, 1);
  });

  testWidgets('shows a mapped error rather than a raw failure',
      (tester) async {
    final repository = _FakeListingRepository(
      error: const ValidationException(
        code: 'contact.rateLimited',
        messageEn: 'You have viewed contact details for 10 properties today.',
        messageNe: 'आज १० देखिसक्नुभयो।',
      ),
    );
    await _pump(tester, repository: repository);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(
      find.text('You have viewed contact details for 10 properties today.'),
      findsOneWidget,
    );
    // No contact data leaked alongside the error.
    expect(find.text('+9779841234567'), findsNothing);
  });

  testWidgets('shows the error in Nepali when the locale is Nepali',
      (tester) async {
    final repository = _FakeListingRepository(
      error: const ValidationException(
        code: 'contact.rateLimited',
        messageEn: 'Ten today.',
        messageNe: 'आज १० देखिसक्नुभयो।',
      ),
    );
    await _pump(
      tester,
      repository: repository,
      locale: const Locale('ne'),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('आज १० देखिसक्नुभयो।'), findsOneWidget);
    expect(find.text('Ten today.'), findsNothing);
  });

  testWidgets('re-enables the button after a failure', (tester) async {
    // Otherwise a single network blip would leave the user stuck.
    final repository = _FakeListingRepository(
      error: const NetworkException(
        code: 'network.offline',
        messageEn: 'No connection',
        messageNe: 'इन्टरनेट छैन',
      ),
    );
    await _pump(tester, repository: repository);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('renders a seller with only a phone number', (tester) async {
    final repository = _FakeListingRepository(
      result: SellerContact(
        listingId: 'listing-1',
        sellerId: 'seller-1',
        sellerPhone: '+9779841234567',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ),
    );
    await _pump(tester, repository: repository);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('+9779841234567'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('survives a seller with no contact details at all',
      (tester) async {
    // The RPC succeeds even when the profile is incomplete, so the client must
    // render an empty card rather than assume a phone exists.
    final repository = _FakeListingRepository(
      result: SellerContact(
        listingId: 'listing-1',
        sellerId: 'seller-1',
        sellerName: 'Ram Bahadur',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ),
    );
    await _pump(tester, repository: repository);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
