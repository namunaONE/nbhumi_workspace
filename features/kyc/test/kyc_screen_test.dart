import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyc/kyc.dart';
import 'package:models/models.dart';

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
          child: const MaterialApp(home: KycScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('No documents yet'), findsOneWidget);
      expect(find.text('Submit a document'), findsOneWidget);
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
          child: const MaterialApp(home: KycScreen()),
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
          child: const MaterialApp(home: KycScreen()),
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
          child: const MaterialApp(home: KycScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit a document'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pick photo and submit'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sign in before uploading'), findsOneWidget);
    });
  });
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
