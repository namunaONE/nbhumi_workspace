import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:models/models.dart';
import 'package:post_listing/l10n/output/post_localizations.dart'
    as post_strings;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'listing_wizard_state.dart';
import 'listing_wizard_validation.dart';

part 'listing_wizard_provider.g.dart';

/// Supplies image bytes for the wizard.
///
/// An interface rather than a direct `image_picker` call for two reasons: the
/// picker cannot run in a widget test, and keeping it behind a seam means the
/// upload and validation logic is testable without a device or a file dialog.
abstract interface class PhotoPicker {
  /// Asks the user for images and returns their bytes.
  ///
  /// Returns an empty list when the user cancels.
  Future<List<PickedPhoto>> pickImages();
}

/// One image chosen by the seller, before it is uploaded.
class PickedPhoto {
  /// Creates a picked photo.
  const PickedPhoto({
    required this.bytes,
    required this.filename,
  });

  /// Raw file contents.
  final Uint8List bytes;

  /// Original file name, used to keep the extension.
  final String filename;
}

/// Picks images with the platform photo picker.
///
/// The only implementation that touches a plugin. Everything else in the wizard
/// works against [PhotoPicker], so the upload, validation and submit logic are
/// all testable without a device or a file dialog.
class DevicePhotoPicker implements PhotoPicker {
  /// Creates a picker.
  const DevicePhotoPicker();

  @override
  Future<List<PickedPhoto>> pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(
      // Sellers photograph on phones, so anything larger is wasted upload on a
      // mobile connection. The card and hero both decode well below this.
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );

    final picked = <PickedPhoto>[];
    for (final file in files) {
      picked.add(
        PickedPhoto(
          bytes: await file.readAsBytes(),
          filename: file.name,
        ),
      );
    }
    return picked;
  }
}

/// Photo picker for the wizard.
///
/// Overridden in tests with a scripted implementation. The default is real,
/// so a build that forgets to override still works.
@riverpod
PhotoPicker photoPicker(Ref ref) => const DevicePhotoPicker();

/// The post-listing wizard.
///
/// Owns navigation between steps and the submit call, and nothing else: the
/// steps read the state and call these methods, and validation lives in
/// [ListingWizardValidation] rather than here so it can be tested without a
/// provider.
@riverpod
class ListingWizard extends _$ListingWizard {
  @override
  ListingWizardState build() => const ListingWizardState();

  /// Moves to the next step if the current one passes validation.
  ///
  /// Returns false and changes nothing when it does not, so the caller can show
  /// the inline messages rather than silently refusing to advance.
  bool next(post_strings.AppLocalizations strings) {
    final current = state.step;
    final nextStep = current.next;
    if (nextStep == null) return false;
    if (!state.canLeave(current, strings)) return false;
    state = state.copyWith(step: nextStep);
    return true;
  }

  /// Moves back a step. Always allowed: a seller must be able to reconsider.
  bool back() {
    final previous = state.step.previous;
    if (previous == null) return false;
    state = state.copyWith(step: previous);
    return true;
  }

  /// Jumps to [step], used by the review screen to send the seller back to a
  /// specific problem.
  void goTo(WizardStep step) => state = state.copyWith(step: step);

  /// Records the chosen property type.
  void setPropertyType(PropertyType type) =>
      state = state.copyWith(propertyType: type);

  /// Records the chosen purpose.
  void setPurpose(ListingPurpose purpose) =>
      state = state.copyWith(listingPurpose: purpose);

  /// Records the title.
  void setTitle(String value) => state = state.copyWith(title: value);

  /// Records the description.
  void setDescription(String value) =>
      state = state.copyWith(description: value);

  /// Records the district, and clears everything below it.
  ///
  /// Clearing matters twice over. A municipality belongs to exactly one
  /// district, so keeping Kathmandu's selection after switching to Lalitpur
  /// would submit a (district, city) pair the composite city FK refuses. And a
  /// seller who typed 2 bigha, then changed district to one that uses hill
  /// units, would otherwise have both sets stored and an `area_display`
  /// computed from the wrong one.
  void setDistrict(District district) {
    if (district == state.district) return;
    final changedRegion = state.district != null &&
        state.district!.region != district.region;
    state = state.copyWith(
      district: district,
      clearMunicipality: true,
      city: '',
      ward: '',
      areaRopani: changedRegion ? '' : null,
      areaAana: changedRegion ? '' : null,
      areaPaisa: changedRegion ? '' : null,
      areaDam: changedRegion ? '' : null,
      areaBigha: changedRegion ? '' : null,
      areaKattha: changedRegion ? '' : null,
      areaDhur: changedRegion ? '' : null,
    );
  }

  /// Records the municipality, syncs the submitted city name, and clears the
  /// ward.
  ///
  /// The ward is cleared because its bound just changed: ward 25 is valid in
  /// Kathmandu Metropolitan City and out of range in a 9-ward body, so a stale
  /// ward would fail validation with no visible cause. `city` is assigned
  /// rather than typed anywhere because the composite city FK only accepts a
  /// municipality name within the chosen district.
  void setMunicipality(Municipality municipality) {
    if (municipality == state.municipality) return;
    state = state.copyWith(
      municipality: municipality,
      city: municipality.name,
      ward: '',
    );
  }

  /// Records the ward. Optional, so blank is a legitimate value.
  void setWard(String value) => state = state.copyWith(ward: value);

  /// Records road frontage in feet.
  void setRoadAccessFt(String value) =>
      state = state.copyWith(roadAccessFt: value);

  /// Records a hill or terai area unit by field name.
  ///
  /// One method rather than seven, because the steps pass a field name from a
  /// declarative list and a switch reads better than seven near-identical
  void setAreaUnit(String field, String value) => state = switch (field) {
        'areaRopani' => state.copyWith(areaRopani: value),
        'areaAana' => state.copyWith(areaAana: value),
        'areaPaisa' => state.copyWith(areaPaisa: value),
        'areaDam' => state.copyWith(areaDam: value),
        'areaBigha' => state.copyWith(areaBigha: value),
        'areaKattha' => state.copyWith(areaKattha: value),
        'areaDhur' => state.copyWith(areaDhur: value),
        _ => state,
      };

  /// Records the bedroom count.
  void setBedrooms(String value) => state = state.copyWith(bedrooms: value);

  /// Records the bathroom count.
  void setBathrooms(String value) => state = state.copyWith(bathrooms: value);

  /// Records the asking price.
  void setPrice(String value) => state = state.copyWith(priceNpr: value);

  /// Replaces the in-flight entries with their settled results.
  ///
  /// Takes the settled entries directly rather than a parallel list of errors,
  /// so the two cannot fall out of step.
  void _replacePending(int firstPending, List<WizardPhoto> settled) {
    state = state.copyWith(
      photos: <WizardPhoto>[...state.photos.take(firstPending), ...settled],
    );
  }

  /// Asks the picker for images and uploads them.
  ///
  /// Each upload is added to the state at once as an in-flight entry, so
  /// seller sees the photo appear rather than the button spinning with no
  /// feedback. A failed upload stays in the list with its error rather than
  /// vanishing, because a silently dropped photo is worse than a visible
  /// failure the seller can retry.
  Future<void> addPhotos() async {
    final picked = await ref.read(photoPickerProvider).pickImages();
    if (picked.isEmpty) return;

    // Index of the first pending entry, so the tail can be replaced wholesale
    // once every upload settles instead of patching entries by index.
    final firstPending = state.photos.length;
    state = state.copyWith(
      photos: <WizardPhoto>[
        ...state.photos,
        ...picked.map((_) => const WizardPhoto(url: '', isUploading: true)),
      ],
    );

    final userId = ref.read(sessionProvider)?.user.id;
    if (userId == null) {
      const failure = AuthFailureException(
        code: 'auth.required',
        messageEn: 'Sign in to add photos.',
        messageNe: 'तस्बिर थप्न साइन इन गर्नुहोस्।',
      );
      _replacePending(
        firstPending,
        List<WizardPhoto>.filled(
          picked.length,
          const WizardPhoto(url: '', error: failure),
        ),
      );
      return;
    }

    final repository = ref.read(listingRepositoryProvider);
    final settled = <WizardPhoto>[];

    for (final photo in picked) {
      try {
        final url = await repository.uploadListingPhoto(
          userId: userId,
          bytes: photo.bytes,
          filename: photo.filename,
        );
        settled.add(WizardPhoto(url: url));
      } on AppException catch (e) {
        settled.add(WizardPhoto(url: '', error: e));
      }
    }

    _replacePending(firstPending, settled);
  }

  /// Removes the photo at [index].
  void removePhoto(int index) {
    if (index < 0 || index >= state.photos.length) return;
    final next = <WizardPhoto>[...state.photos]..removeAt(index);
    state = state.copyWith(photos: next);
  }

  /// Creates a draft, attaches photos, then submits it for review via RPC.
  ///
  /// A failed attachment must never strand a `pending_review` listing with
  /// no photo. Once the draft exists its id is retained across retries within
  /// this wizard, so attachment or submission failures do not duplicate it.
  /// The server independently refuses a status transition without a photo.
  Future<bool> submit(post_strings.AppLocalizations strings) async {
    if (state.submitting || state.isSubmitted) return false;
    if (!state.canSubmit(strings)) return false;

    state = state.copyWith(submitting: true, clearSubmitError: true);
    final repository = ref.read(listingRepositoryProvider);

    try {
      var draftId = state.draftListingId;
      if (draftId == null) {
        draftId = await repository.createListing(listing: _toListing());
        // Store the id *before* attaching. Even a partial photo failure must
        // leave the same draft available for a retry, not create a new one.
        state = state.copyWith(draftListingId: draftId);
      } else {
        // The seller may have edited the form after a failed attempt. Apply
        // those changes to the existing draft before retrying submission.
        await repository.updateListing(
          listingId: draftId,
          listing: _toListing(),
        );
      }

      await repository.attachListingPhotos(draftId, state.uploadedPhotoUrls);
      await repository.updateListing(
        listingId: draftId,
        status: ListingStatus.pendingReview,
      );

      state = state.copyWith(
        submitting: false,
        createdListingId: draftId,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        submitting: false,
        submitError: e.message(preferNepali: strings.localeName != 'en'),
      );
      return false;
    }
  }

  /// Builds the [Listing] the repository will send.
  ///
  /// Only the fields relevant to the chosen property type are populated, so a
  /// house listing does not carry stray bigha values. The server ignores
  /// nulls, so this is about not sending misleading data rather than about
  /// correctness of the insert.
  Listing _toListing() {
    final sqm = state.areaSqm;
    return Listing(
      id: '',
      sellerId: ref.read(sessionProvider)?.user.id ?? '',
      propertyType: state.propertyType!,
      listingPurpose: state.listingPurpose!,
      title: state.title.trim(),
      description: _nullIfBlank(state.description),
      priceNpr: int.parse(state.priceNpr.trim()),
      district: state.district!.name,
      city: state.city.trim(),
      ward: state.ward.trim().isEmpty ? null : state.ward.trim(),
      roadAccessFt: int.tryParse(state.roadAccessFt.trim()),
      areaSqm: sqm,
      areaRopani: state.usesHillUnits ? _intOrNull(state.areaRopani) : null,
      areaAana: state.usesHillUnits ? _intOrNull(state.areaAana) : null,
      areaPaisa: state.usesHillUnits ? _intOrNull(state.areaPaisa) : null,
      areaDam: state.usesHillUnits ? _intOrNull(state.areaDam) : null,
      areaBigha: state.usesHillUnits ? null : _intOrNull(state.areaBigha),
      areaKattha: state.usesHillUnits ? null : _intOrNull(state.areaKattha),
      areaDhur: state.usesHillUnits ? null : _intOrNull(state.areaDhur),
      bedrooms: _intOrNull(state.bedrooms),
      bathrooms: _intOrNull(state.bathrooms),
    );
  }

  static int? _intOrNull(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  /// [value] trimmed, or null when it holds nothing but whitespace.
  ///
  /// An empty description is stored as SQL NULL rather than '', so a
  /// listing row does not carry a blank string that reads as "the seller
  /// wrote nothing" in the admin review screen, indistinguishable from
  /// missing.
  static String? _nullIfBlank(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
