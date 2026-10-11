// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_wizard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Photo picker for the wizard.
///
/// Overridden in tests with a scripted implementation. The default is real,
/// so a build that forgets to override still works.

@ProviderFor(photoPicker)
final photoPickerProvider = PhotoPickerProvider._();

/// Photo picker for the wizard.
///
/// Overridden in tests with a scripted implementation. The default is real,
/// so a build that forgets to override still works.

final class PhotoPickerProvider
    extends $FunctionalProvider<PhotoPicker, PhotoPicker, PhotoPicker>
    with $Provider<PhotoPicker> {
  /// Photo picker for the wizard.
  ///
  /// Overridden in tests with a scripted implementation. The default is real,
  /// so a build that forgets to override still works.
  PhotoPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoPickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoPickerHash();

  @$internal
  @override
  $ProviderElement<PhotoPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoPicker create(Ref ref) {
    return photoPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoPicker>(value),
    );
  }
}

String _$photoPickerHash() => r'ce0a345b80580cd6727f629b4b9492bfdcc8eb27';

/// The post-listing wizard.
///
/// Owns navigation between steps and the submit call, and nothing else: the
/// steps read the state and call these methods, and validation lives in
/// [ListingWizardValidation] rather than here so it can be tested without a
/// provider.

@ProviderFor(ListingWizard)
final listingWizardProvider = ListingWizardProvider._();

/// The post-listing wizard.
///
/// Owns navigation between steps and the submit call, and nothing else: the
/// steps read the state and call these methods, and validation lives in
/// [ListingWizardValidation] rather than here so it can be tested without a
/// provider.
final class ListingWizardProvider
    extends $NotifierProvider<ListingWizard, ListingWizardState> {
  /// The post-listing wizard.
  ///
  /// Owns navigation between steps and the submit call, and nothing else: the
  /// steps read the state and call these methods, and validation lives in
  /// [ListingWizardValidation] rather than here so it can be tested without a
  /// provider.
  ListingWizardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listingWizardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listingWizardHash();

  @$internal
  @override
  ListingWizard create() => ListingWizard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListingWizardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListingWizardState>(value),
    );
  }
}

String _$listingWizardHash() => r'68f5561fc50797f1f936ec77a5a46448e85cdc8c';

/// The post-listing wizard.
///
/// Owns navigation between steps and the submit call, and nothing else: the
/// steps read the state and call these methods, and validation lives in
/// [ListingWizardValidation] rather than here so it can be tested without a
/// provider.

abstract class _$ListingWizard extends $Notifier<ListingWizardState> {
  ListingWizardState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ListingWizardState, ListingWizardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ListingWizardState, ListingWizardState>,
              ListingWizardState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
