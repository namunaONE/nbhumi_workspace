import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
import 'package:listing_detail/listing_detail.dart';
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

ListingDetail _listing() => const ListingDetail(
      id: 'listing-1',
      sellerId: 'seller-1',
      title: 'House in KMC',
      priceNpr: 2500000,
      district: 'Kathmandu',
      city: 'KMC',
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
    );

/// Sessions are hand-built: no network for a session (Rule 33).
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

/// Scripted verification answers; everything else falls through.
class _FakeKycRepository implements KycRepository {
  _FakeKycRepository({this.verified = false});

  final bool verified;

  @override
  Future<({bool verified, DateTime? reviewedAt})> listingVerified(
    String listingId,
  ) async =>
      (verified: verified, reviewedAt: null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(
  WidgetTester tester, {
  Session? session,
  bool verified = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      sessionProvider.overrideWithValue(session),
      kycRepositoryProvider.overrideWithValue(
        _FakeKycRepository(verified: verified),
      ),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        // Scaffold: the badge's InkWell needs a Material ancestor.
        builder: (context, state) => Scaffold(
          body: ListingVerificationSlot(
            listing: _listing(),
          ),
        ),
      ),
      GoRoute(
        path: '/kyc',
        builder: (context, state) => Scaffold(
          body: Text('KYC ${state.uri.queryParameters['listingId']}'),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          detail_strings.AppLocalizations.delegate,
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
  group('ListingVerificationSlot', () {
    testWidgets('verified listings show the badge for everyone',
        (tester) async {
      await _pump(tester, verified: true);

      expect(find.text('Verified Listing'), findsOneWidget);
      expect(find.text('Verify this listing'), findsNothing);
    });

    testWidgets('the badge explains the doc-check boundary', (tester) async {
      await _pump(tester, verified: true);

      await tester.tap(find.text('Verified Listing'));
      await tester.pumpAndSettle();

      expect(find.textContaining('document check only'), findsOneWidget);
    });

    testWidgets('owners of unverified listings get the entry', (tester) async {
      await _pump(tester, session: _session('seller-1'));

      expect(find.text('Verify this listing'), findsOneWidget);
      expect(find.text('Verified Listing'), findsNothing);
    });

    testWidgets('the entry opens the tier-3 submit flow', (tester) async {
      await _pump(tester, session: _session('seller-1'));

      await tester.tap(find.text('Verify this listing'));
      await tester.pumpAndSettle();

      expect(find.text('KYC listing-1'), findsOneWidget);
    });

    testWidgets('other buyers see nothing', (tester) async {
      await _pump(tester, session: _session('buyer-9'));

      expect(find.text('Verified Listing'), findsNothing);
      expect(find.text('Verify this listing'), findsNothing);
    });

    testWidgets('guests see nothing on unverified listings', (tester) async {
      await _pump(tester);

      expect(find.text('Verified Listing'), findsNothing);
      expect(find.text('Verify this listing'), findsNothing);
    });
  });
}
