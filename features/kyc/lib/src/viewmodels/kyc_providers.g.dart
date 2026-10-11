// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Document picker for KYC submissions.
///
/// Overridden in tests with a scripted implementation. The default is real,
/// so a build that forgets to override still works.

@ProviderFor(docPicker)
final docPickerProvider = DocPickerProvider._();

/// Document picker for KYC submissions.
///
/// Overridden in tests with a scripted implementation. The default is real,
/// so a build that forgets to override still works.

final class DocPickerProvider
    extends $FunctionalProvider<DocPicker, DocPicker, DocPicker>
    with $Provider<DocPicker> {
  /// Document picker for KYC submissions.
  ///
  /// Overridden in tests with a scripted implementation. The default is real,
  /// so a build that forgets to override still works.
  DocPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'docPickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$docPickerHash();

  @$internal
  @override
  $ProviderElement<DocPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DocPicker create(Ref ref) {
    return docPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocPicker>(value),
    );
  }
}

String _$docPickerHash() => r'b782cc0698c124bda7cda89442256132f3be038e';

/// Runs one KYC submission: pick, upload, submit, refresh.
///
/// Owns the submit call and nothing else: the document list itself comes from
/// `myKycDocumentsProvider` in the data layer, which this invalidates on
/// success so the new pending row appears without a manual refresh.

@ProviderFor(KycSubmitController)
final kycSubmitControllerProvider = KycSubmitControllerProvider._();

/// Runs one KYC submission: pick, upload, submit, refresh.
///
/// Owns the submit call and nothing else: the document list itself comes from
/// `myKycDocumentsProvider` in the data layer, which this invalidates on
/// success so the new pending row appears without a manual refresh.
final class KycSubmitControllerProvider
    extends $NotifierProvider<KycSubmitController, KycSubmitState> {
  /// Runs one KYC submission: pick, upload, submit, refresh.
  ///
  /// Owns the submit call and nothing else: the document list itself comes from
  /// `myKycDocumentsProvider` in the data layer, which this invalidates on
  /// success so the new pending row appears without a manual refresh.
  KycSubmitControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycSubmitControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycSubmitControllerHash();

  @$internal
  @override
  KycSubmitController create() => KycSubmitController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KycSubmitState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KycSubmitState>(value),
    );
  }
}

String _$kycSubmitControllerHash() =>
    r'6e26c42fa743b61f6e6f4776cf5362ce813b4808';

/// Runs one KYC submission: pick, upload, submit, refresh.
///
/// Owns the submit call and nothing else: the document list itself comes from
/// `myKycDocumentsProvider` in the data layer, which this invalidates on
/// success so the new pending row appears without a manual refresh.

abstract class _$KycSubmitController extends $Notifier<KycSubmitState> {
  KycSubmitState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<KycSubmitState, KycSubmitState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KycSubmitState, KycSubmitState>,
              KycSubmitState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
