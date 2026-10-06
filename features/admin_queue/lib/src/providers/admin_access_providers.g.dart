// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_access_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The role of the signed-in user, resolved once per session.
///
/// ### Why `profiles.role` and not a JWT claim
///
/// `profiles.role` is authoritative and server-owned: `profiles_update_own`
/// pins it, so a client cannot self-promote. Reading it through RLS gives the
/// panel the same answer the admin RPCs will give. A role claim inside the JWT
/// would be a cache of a value that can be revoked, and a stale cache here
/// means
/// an admin panel that keeps working after the role is removed — until the
/// first
/// RPC fails.
///
/// ### Why every failure collapses to [AdminAccess.denied]
///
/// A role read can fail for several very different reasons — signed out,
/// network
/// down, `profiles` unreadable — and the panel must not lump "cannot tell" in
/// with "allowed". Failing closed is correct, and the server gate means a false
/// denial costs one sign-in rather than a security hole.
///
/// ### Why retry is disabled
///
/// Ten attempts with backoff would hold the panel in `checking` for roughly
/// forty
/// seconds on a genuinely offline network. Failing to `/forbidden` immediately
/// and letting the admin retry explicitly is faster and honest.

@ProviderFor(adminAccess)
final adminAccessProvider = AdminAccessProvider._();

/// The role of the signed-in user, resolved once per session.
///
/// ### Why `profiles.role` and not a JWT claim
///
/// `profiles.role` is authoritative and server-owned: `profiles_update_own`
/// pins it, so a client cannot self-promote. Reading it through RLS gives the
/// panel the same answer the admin RPCs will give. A role claim inside the JWT
/// would be a cache of a value that can be revoked, and a stale cache here
/// means
/// an admin panel that keeps working after the role is removed — until the
/// first
/// RPC fails.
///
/// ### Why every failure collapses to [AdminAccess.denied]
///
/// A role read can fail for several very different reasons — signed out,
/// network
/// down, `profiles` unreadable — and the panel must not lump "cannot tell" in
/// with "allowed". Failing closed is correct, and the server gate means a false
/// denial costs one sign-in rather than a security hole.
///
/// ### Why retry is disabled
///
/// Ten attempts with backoff would hold the panel in `checking` for roughly
/// forty
/// seconds on a genuinely offline network. Failing to `/forbidden` immediately
/// and letting the admin retry explicitly is faster and honest.

final class AdminAccessProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminAccess>,
          AdminAccess,
          FutureOr<AdminAccess>
        >
    with $FutureModifier<AdminAccess>, $FutureProvider<AdminAccess> {
  /// The role of the signed-in user, resolved once per session.
  ///
  /// ### Why `profiles.role` and not a JWT claim
  ///
  /// `profiles.role` is authoritative and server-owned: `profiles_update_own`
  /// pins it, so a client cannot self-promote. Reading it through RLS gives the
  /// panel the same answer the admin RPCs will give. A role claim inside the JWT
  /// would be a cache of a value that can be revoked, and a stale cache here
  /// means
  /// an admin panel that keeps working after the role is removed — until the
  /// first
  /// RPC fails.
  ///
  /// ### Why every failure collapses to [AdminAccess.denied]
  ///
  /// A role read can fail for several very different reasons — signed out,
  /// network
  /// down, `profiles` unreadable — and the panel must not lump "cannot tell" in
  /// with "allowed". Failing closed is correct, and the server gate means a false
  /// denial costs one sign-in rather than a security hole.
  ///
  /// ### Why retry is disabled
  ///
  /// Ten attempts with backoff would hold the panel in `checking` for roughly
  /// forty
  /// seconds on a genuinely offline network. Failing to `/forbidden` immediately
  /// and letting the admin retry explicitly is faster and honest.
  AdminAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminAccessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminAccessHash();

  @$internal
  @override
  $FutureProviderElement<AdminAccess> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdminAccess> create(Ref ref) {
    return adminAccess(ref);
  }
}

String _$adminAccessHash() => r'78cb05f487816aa48f2f80f15803376644d1318d';

/// Whether the current session is an admin, as a plain bool.
///
/// Convenience for UI that does not care *why* access was refused. Derived from
/// [adminAccessProvider] rather than read separately, so there is one network
/// call and one source of truth.

@ProviderFor(adminIsAuthorized)
final adminIsAuthorizedProvider = AdminIsAuthorizedProvider._();

/// Whether the current session is an admin, as a plain bool.
///
/// Convenience for UI that does not care *why* access was refused. Derived from
/// [adminAccessProvider] rather than read separately, so there is one network
/// call and one source of truth.

final class AdminIsAuthorizedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the current session is an admin, as a plain bool.
  ///
  /// Convenience for UI that does not care *why* access was refused. Derived from
  /// [adminAccessProvider] rather than read separately, so there is one network
  /// call and one source of truth.
  AdminIsAuthorizedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminIsAuthorizedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminIsAuthorizedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return adminIsAuthorized(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$adminIsAuthorizedHash() => r'0141ba282d5e4473ce16facb37b78a165294c27b';

/// The signed-in admin's display name, for the panel's app bar.
///
/// Null until the profile loads, and null for a non-admin. Best-effort: the
/// panel
/// works without it, so a failure here must not gate anything. Kept separate
/// from
/// [adminAccessProvider] so a naming change cannot invalidate the authorization
/// decision and bounce an admin back to the gate.

@ProviderFor(adminDisplayName)
final adminDisplayNameProvider = AdminDisplayNameProvider._();

/// The signed-in admin's display name, for the panel's app bar.
///
/// Null until the profile loads, and null for a non-admin. Best-effort: the
/// panel
/// works without it, so a failure here must not gate anything. Kept separate
/// from
/// [adminAccessProvider] so a naming change cannot invalidate the authorization
/// decision and bounce an admin back to the gate.

final class AdminDisplayNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The signed-in admin's display name, for the panel's app bar.
  ///
  /// Null until the profile loads, and null for a non-admin. Best-effort: the
  /// panel
  /// works without it, so a failure here must not gate anything. Kept separate
  /// from
  /// [adminAccessProvider] so a naming change cannot invalidate the authorization
  /// decision and bounce an admin back to the gate.
  AdminDisplayNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDisplayNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDisplayNameHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return adminDisplayName(ref);
  }
}

String _$adminDisplayNameHash() => r'4d3aa867a4cd43b0e16ee26e4c79266e4793656d';
