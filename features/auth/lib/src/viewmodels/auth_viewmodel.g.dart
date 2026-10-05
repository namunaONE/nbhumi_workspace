// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Session state for the magic-link flow.
///
/// Mirrors `isSignedInProvider` rather than owning its own session copy so the
/// router's [AuthRefreshNotifier], the profile screen and this notifier can
/// never disagree. The notifier's real job is the side-effects (send link,
/// sign out) plus the validation gate (Rule 6) that belongs above the service.

@ProviderFor(Auth)
final authProvider = AuthProvider._();

/// Session state for the magic-link flow.
///
/// Mirrors `isSignedInProvider` rather than owning its own session copy so the
/// router's [AuthRefreshNotifier], the profile screen and this notifier can
/// never disagree. The notifier's real job is the side-effects (send link,
/// sign out) plus the validation gate (Rule 6) that belongs above the service.
final class AuthProvider extends $NotifierProvider<Auth, bool> {
  /// Session state for the magic-link flow.
  ///
  /// Mirrors `isSignedInProvider` rather than owning its own session copy so the
  /// router's [AuthRefreshNotifier], the profile screen and this notifier can
  /// never disagree. The notifier's real job is the side-effects (send link,
  /// sign out) plus the validation gate (Rule 6) that belongs above the service.
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

String _$authHash() => r'ca1c892f6c1258d6f94a48cff3ca39869b096f6a';

/// Session state for the magic-link flow.
///
/// Mirrors `isSignedInProvider` rather than owning its own session copy so the
/// router's [AuthRefreshNotifier], the profile screen and this notifier can
/// never disagree. The notifier's real job is the side-effects (send link,
/// sign out) plus the validation gate (Rule 6) that belongs above the service.

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
