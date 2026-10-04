// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Session state for the magic-link flow.
///
/// Every method is a stub. HYA-202 fills them in once the deep-link plumbing
/// exists, because sending a magic link before the app can receive the
/// redirect would leave users stranded on a "check your inbox" screen with no
/// way back in.

@ProviderFor(Auth)
final authProvider = AuthProvider._();

/// Session state for the magic-link flow.
///
/// Every method is a stub. HYA-202 fills them in once the deep-link plumbing
/// exists, because sending a magic link before the app can receive the
/// redirect would leave users stranded on a "check your inbox" screen with no
/// way back in.
final class AuthProvider extends $NotifierProvider<Auth, bool> {
  /// Session state for the magic-link flow.
  ///
  /// Every method is a stub. HYA-202 fills them in once the deep-link plumbing
  /// exists, because sending a magic link before the app can receive the
  /// redirect would leave users stranded on a "check your inbox" screen with no
  /// way back in.
  AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authHash() => r'919b44a6bce59437c185db46f15b00b47b9dd81d';

/// Session state for the magic-link flow.
///
/// Every method is a stub. HYA-202 fills them in once the deep-link plumbing
/// exists, because sending a magic link before the app can receive the
/// redirect would leave users stranded on a "check your inbox" screen with no
/// way back in.

abstract class _$Auth extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
