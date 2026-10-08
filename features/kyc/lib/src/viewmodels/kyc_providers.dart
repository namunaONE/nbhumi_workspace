import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kyc_providers.g.dart';

/// One document photo chosen by the seller, before it is uploaded.
class PickedDocument {
  /// Creates a picked document.
  const PickedDocument({
    required this.bytes,
    required this.filename,
  });

  /// Raw file contents.
  final Uint8List bytes;

  /// Original file name, used to keep the extension.
  final String filename;
}

/// Supplies the document photo for a KYC submission.
///
/// An interface rather than a direct `image_picker` call for the same two
/// reasons as the listing wizard's `PhotoPicker`: the picker cannot run in a
/// widget test, and keeping it behind a seam means the upload and submit
/// logic is testable without a device or a file dialog.
abstract interface class DocPicker {
  /// Asks the user for one document photo and returns its bytes.
  ///
  /// Returns null when the user cancels.
  Future<PickedDocument?> pickDocument();
}

/// Picks a document photo with the platform photo picker.
///
/// The only implementation that touches a plugin. Everything else works
/// against [DocPicker], so the upload and submit logic are testable without
/// a device.
class DeviceDocPicker implements DocPicker {
  /// Creates a picker.
  const DeviceDocPicker();

  @override
  Future<PickedDocument?> pickDocument() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      // A citizenship scan is read on a phone screen, so anything larger is
      // wasted upload on a mobile connection.
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    if (file == null) return null;
    return PickedDocument(
      bytes: await file.readAsBytes(),
      filename: file.name,
    );
  }
}

/// Document picker for KYC submissions.
///
/// Overridden in tests with a scripted implementation. The default is real,
/// so a build that forgets to override still works.
@riverpod
DocPicker docPicker(Ref ref) => const DeviceDocPicker();

/// State of an in-flight KYC submission.
class KycSubmitState {
  /// Creates a submission state.
  const KycSubmitState({
    this.submitting = false,
    this.errorEn,
    this.errorNe,
  });

  /// Whether an upload + submit round trip is running.
  final bool submitting;

  /// English failure message from the last attempt, if any.
  final String? errorEn;

  /// Nepali failure message from the last attempt, if any.
  final String? errorNe;

  /// Whether the last attempt failed.
  bool get hasError => errorEn != null;

  /// Copies with the given fields replaced.
  KycSubmitState copyWith({
    bool? submitting,
    String? errorEn,
    String? errorNe,
    bool clearError = false,
  }) =>
      KycSubmitState(
        submitting: submitting ?? this.submitting,
        errorEn: clearError ? null : errorEn ?? this.errorEn,
        errorNe: clearError ? null : errorNe ?? this.errorNe,
      );
}

/// Runs one KYC submission: pick, upload, submit, refresh.
///
/// Owns the submit call and nothing else: the document list itself comes from
/// `myKycDocumentsProvider` in the data layer, which this invalidates on
/// success so the new pending row appears without a manual refresh.
@riverpod
class KycSubmitController extends _$KycSubmitController {
  @override
  KycSubmitState build() => const KycSubmitState();

  /// Clears the last failure, used when the sheet reopens.
  void clearError() => state = state.copyWith(clearError: true);

  /// Picks a photo, uploads it and submits it for admin doc-check.
  ///
  /// Returns true on success. Returns false without touching the state when
  /// the user cancels the picker: cancelling is not a failure and must not
  /// leave an error behind. Failures keep both message languages (Rule 36);
  /// the repository has already mapped them, so they render directly.
  ///
  /// Pass [listingId] for Tier-3 per-listing checks (HYA-265: lalpurja /
  /// Tiro Rasid bound to one listing); omit it for Tier-2 identity checks.
  /// Citizenship is identity-only and the repository refuses it with a
  /// listing — the sheet hides that option rather than offering a refusal.
  Future<bool> submit(KycDocType docType, {String? listingId}) async {
    if (state.submitting) return false;
    state = state.copyWith(submitting: true, clearError: true);

    final picked = await ref.read(docPickerProvider).pickDocument();
    if (picked == null) {
      state = state.copyWith(submitting: false);
      return false;
    }

    final userId = ref.read(sessionProvider)?.user.id;
    if (userId == null) {
      state = state.copyWith(
        submitting: false,
        errorEn: 'Sign in before uploading a document.',
        errorNe: 'कागजात अपलोड गर्नुअघि साइन इन गर्नुहोस्।',
      );
      return false;
    }

    final repository = ref.read(kycRepositoryProvider);
    try {
      final path = await repository.uploadKycFile(
        userId: userId,
        bytes: picked.bytes,
        filename: picked.filename,
        docType: docType,
      );
      await repository.submitKyc(
        docType: docType,
        storagePath: path,
        listingId: (listingId ?? '').trim().isEmpty ? null : listingId!.trim(),
      );
    } on AppException catch (e) {
      state = state.copyWith(
        submitting: false,
        errorEn: e.messageEn,
        errorNe: e.messageNe,
      );
      return false;
    }

    state = state.copyWith(submitting: false);
    ref.invalidate(myKycDocumentsProvider);
    return true;
  }
}
