import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyc/kyc.dart';
import 'package:kyc/l10n/output/kyc_localizations.dart' as kyc_strings;
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pumps [child] with the delegates the real app supplies in main.dart.
///
/// Defaults to English; pass `ne` to assert the Nepali strings.
Widget _harness(
  Widget child, {
  Locale locale = const Locale('en'),
}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        kyc_strings.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
      home: child,
    );

/// Widget tests for [KycScreen].
///
/// Rule 33: pump with `ProviderScope` overrides, never real providers. The
/// document list comes from an overridden `myKycDocumentsProvider`; the
/// picker is a scripted [DocPicker] so no device dialog ever opens.
void main() {
  group('KycScreen', () {
    testWidgets('empty inbox explains the next step', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myKycDocumentsProvider.overrideWith(
              (ref) async => const <KycDocument>[],
            ),
          ],
          child: _harness(const KycScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('No documents yet'), findsOneWidget);
      expect(find.text('Submit a document'), findsOneWidget);
    });

    testWidgets('Nepali locale renders Nepali strings', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myKycDocumentsProvider.overrideWith(
              (ref) async => const <KycDocument>[],
            ),
          ],
          child: _harness(const KycScreen(), locale: const Locale('ne')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('पहिचान प्रमाणित गर्नुहोस्'), findsOneWidget);
      expect(find.text('कागजात पेस गर्नुहोस्'), findsOneWidget);
    });

    testWidgets('renders each document with its review state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myKycDocumentsProvider.overrideWith(
              (ref) async => <KycDocument>[
                const KycDocument(
                  id: 'doc-1',
                  profileId: 'user-1',
                  docType: KycDocType.citizenship,
                  storagePath: 'user-1/1.jpg',
                ),
                const KycDocument(
                  id: 'doc-2',
                  profileId: 'user-1',
                  docType: KycDocType.lalpurja,
                  storagePath: 'user-1/2.jpg',
                  status: KycDocStatus.verified,
                ),
              ],
            ),
          ],
          child: _harness(const KycScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Citizenship'), findsOneWidget);
      expect(find.text('Lalpurja (land ownership)'), findsOneWidget);
      expect(find.text('Pending review'), findsOneWidget);
      expect(find.textContaining('Verified'), findsOneWidget);
    });

    testWidgets('a cancelled pick leaves no error behind', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myKycDocumentsProvider.overrideWith(
              (ref) async => const <KycDocument>[],
            ),
            docPickerProvider.overrideWithValue(const _CancellingPicker()),
            sessionProvider.overrideWithValue(null),
          ],
          child: _harness(const KycScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit a document'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a document'), findsOneWidget);

      await tester.tap(find.text('Pick photo and submit'));
      await tester.pumpAndSettle();

      // Cancelling is not a failure: the sheet stays open with no error, so
      // the seller can pick a different document type and try again.
      expect(find.text('Choose a document'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
    });

    testWidgets('submitting signed out explains the problem', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myKycDocumentsProvider.overrideWith(
              (ref) async => const <KycDocument>[],
            ),
            docPickerProvider.overrideWithValue(const _PhotoPicker()),
            sessionProvider.overrideWithValue(null),
          ],
          child: _harness(const KycScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit a document'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pick photo and submit'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sign in before uploading'), findsOneWidget);
    });

    testWidgets('tier-3 sheet binds lalpurja to the listing', (tester) async {
      final repository = _FakeKycRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myKycDocumentsProvider.overrideWith(
              (ref) async => const <KycDocument>[],
            ),
            docPickerProvider.overrideWithValue(const _PhotoPicker()),
            sessionProvider.overrideWithValue(_session()),
            kycRepositoryProvider.overrideWithValue(repository),
          ],
          child: _harness(const KycScreen(listingId: 'listing-1')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit a document'));
      await tester.pumpAndSettle();

      // Tier-3 mode: hint shown, lalpurja fixed, citizenship not offered.
      expect(find.textContaining('listing you came from'), findsOneWidget);
      expect(find.text('Lalpurja (land ownership)'), findsOneWidget);
      expect(find.text('Citizenship'), findsNothing);

      await tester.tap(find.text('Pick photo and submit'));
      await tester.pumpAndSettle();

      expect(repository.lastDocType, KycDocType.lalpurja);
      expect(repository.lastListingId, 'listing-1');
      expect(find.textContaining('review within 48 hours'), findsOneWidget);
    });
  });
}

/// Signed-in session, hand-built: no network for a session (Rule 33).
Session _session() => Session(
      accessToken: 'token',
      refreshToken: 'refresh',
      tokenType: 'bearer',
      user: const User(
        id: 'seller-1',
        appMetadata: <String, dynamic>{},
        userMetadata: <String, dynamic>{},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
      ),
    );

/// Records Tier-3 submissions; everything else falls through to noSuchMethod.
class _FakeKycRepository implements KycRepository {
  KycDocType? lastDocType;
  String? lastListingId;

  @override
  Future<String> uploadKycFile({
    required String userId,
    required Uint8List bytes,
    required String filename,
    required KycDocType docType,
  }) async =>
      '$userId/1_${docType.wireName}.jpg';

  @override
  Future<KycDocument> submitKyc({
    required KycDocType docType,
    required String storagePath,
    String? listingId,
  }) async {
    lastDocType = docType;
    lastListingId = listingId;
    return KycDocument(
      id: 'doc-9',
      profileId: 'seller-1',
      docType: docType,
      storagePath: storagePath,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Picker that always cancels, for the cancel-is-not-failure test.
class _CancellingPicker implements DocPicker {
  const _CancellingPicker();

  @override
  Future<PickedDocument?> pickDocument() async => null;
}

/// Picker that returns one tiny photo without touching a plugin.
class _PhotoPicker implements DocPicker {
  const _PhotoPicker();

  @override
  Future<PickedDocument?> pickDocument() async => PickedDocument(
        bytes: Uint8List.fromList(_transparentPng),
        filename: 'citizenship.jpg',
      );
}

/// Minimal PNG bytes shared by tests that need "a photo" with no plugin.
const List<int> _transparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
];
