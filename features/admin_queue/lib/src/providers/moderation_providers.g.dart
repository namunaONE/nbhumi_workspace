// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One account for moderation, keyed by user id.
///
/// A family rather than a field on the listing detail: the detail RPC's seller
/// card deliberately carries no suspension state (it is the same shape the
/// buyer-facing app reads), so the admin panel reads it separately. Retry is
/// disabled for the same reason as the detail pane: ten attempts with backoff
/// would hold a suspension decision for roughly forty seconds.

@ProviderFor(adminUser)
final adminUserProvider = AdminUserFamily._();

/// One account for moderation, keyed by user id.
///
/// A family rather than a field on the listing detail: the detail RPC's seller
/// card deliberately carries no suspension state (it is the same shape the
/// buyer-facing app reads), so the admin panel reads it separately. Retry is
/// disabled for the same reason as the detail pane: ten attempts with backoff
/// would hold a suspension decision for roughly forty seconds.

final class AdminUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminUser>,
          AdminUser,
          FutureOr<AdminUser>
        >
    with $FutureModifier<AdminUser>, $FutureProvider<AdminUser> {
  /// One account for moderation, keyed by user id.
  ///
  /// A family rather than a field on the listing detail: the detail RPC's seller
  /// card deliberately carries no suspension state (it is the same shape the
  /// buyer-facing app reads), so the admin panel reads it separately. Retry is
  /// disabled for the same reason as the detail pane: ten attempts with backoff
  /// would hold a suspension decision for roughly forty seconds.
  AdminUserProvider._({
    required AdminUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminUserHash();

  @override
  String toString() {
    return r'adminUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AdminUser> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AdminUser> create(Ref ref) {
    final argument = this.argument as String;
    return adminUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminUserHash() => r'cebaf3adcae9c09df36e7974b607efe3304937bf';

/// One account for moderation, keyed by user id.
///
/// A family rather than a field on the listing detail: the detail RPC's seller
/// card deliberately carries no suspension state (it is the same shape the
/// buyer-facing app reads), so the admin panel reads it separately. Retry is
/// disabled for the same reason as the detail pane: ten attempts with backoff
/// would hold a suspension decision for roughly forty seconds.

final class AdminUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AdminUser>, String> {
  AdminUserFamily._()
    : super(
        retry: null,
        name: r'adminUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One account for moderation, keyed by user id.
  ///
  /// A family rather than a field on the listing detail: the detail RPC's seller
  /// card deliberately carries no suspension state (it is the same shape the
  /// buyer-facing app reads), so the admin panel reads it separately. Retry is
  /// disabled for the same reason as the detail pane: ten attempts with backoff
  /// would hold a suspension decision for roughly forty seconds.

  AdminUserProvider call(String userId) =>
      AdminUserProvider._(argument: userId, from: this);

  @override
  String toString() => r'adminUserProvider';
}

/// Duplicate/fraud signals on one listing, keyed by listing id (HYA-261).
///
/// A family like [adminUser]: the detail screen reads signals for exactly the
/// listing open. Retry is disabled for the same reason as the detail pane --
/// ten attempts with backoff would hold the flags for roughly forty seconds
/// while the admin waits to decide. The panel offers its own explicit retry.

@ProviderFor(fraudSignals)
final fraudSignalsProvider = FraudSignalsFamily._();

/// Duplicate/fraud signals on one listing, keyed by listing id (HYA-261).
///
/// A family like [adminUser]: the detail screen reads signals for exactly the
/// listing open. Retry is disabled for the same reason as the detail pane --
/// ten attempts with backoff would hold the flags for roughly forty seconds
/// while the admin waits to decide. The panel offers its own explicit retry.

final class FraudSignalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ListingFraudSignals>,
          ListingFraudSignals,
          FutureOr<ListingFraudSignals>
        >
    with
        $FutureModifier<ListingFraudSignals>,
        $FutureProvider<ListingFraudSignals> {
  /// Duplicate/fraud signals on one listing, keyed by listing id (HYA-261).
  ///
  /// A family like [adminUser]: the detail screen reads signals for exactly the
  /// listing open. Retry is disabled for the same reason as the detail pane --
  /// ten attempts with backoff would hold the flags for roughly forty seconds
  /// while the admin waits to decide. The panel offers its own explicit retry.
  FraudSignalsProvider._({
    required FraudSignalsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fraudSignalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fraudSignalsHash();

  @override
  String toString() {
    return r'fraudSignalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ListingFraudSignals> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ListingFraudSignals> create(Ref ref) {
    final argument = this.argument as String;
    return fraudSignals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FraudSignalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fraudSignalsHash() => r'6ed2f38ef9c56e1b7bdf8259635a6f558be64d42';

/// Duplicate/fraud signals on one listing, keyed by listing id (HYA-261).
///
/// A family like [adminUser]: the detail screen reads signals for exactly the
/// listing open. Retry is disabled for the same reason as the detail pane --
/// ten attempts with backoff would hold the flags for roughly forty seconds
/// while the admin waits to decide. The panel offers its own explicit retry.

final class FraudSignalsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ListingFraudSignals>, String> {
  FraudSignalsFamily._()
    : super(
        retry: null,
        name: r'fraudSignalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Duplicate/fraud signals on one listing, keyed by listing id (HYA-261).
  ///
  /// A family like [adminUser]: the detail screen reads signals for exactly the
  /// listing open. Retry is disabled for the same reason as the detail pane --
  /// ten attempts with backoff would hold the flags for roughly forty seconds
  /// while the admin waits to decide. The panel offers its own explicit retry.

  FraudSignalsProvider call(String listingId) =>
      FraudSignalsProvider._(argument: listingId, from: this);

  @override
  String toString() => r'fraudSignalsProvider';
}

/// Suspend, unsuspend, unpublish and republish, as mutations rather than reads.
///
/// Same shape and same reasons as [AdminReviewController], which this mirrors
/// deliberately rather than extending: review decisions move a listing through
/// the verification worklist (and update its counts), while these actions
/// operate outside it. Merging them would put unpublished rows and suspended
/// users through `applyReviewOutcome`, which only knows approve/reject.
///
/// * Plain notifier, not `AsyncNotifier`: a resolution that succeeds
///   server-side but fails on the response must not be retried — the retry
///   would fail with `already suspended` / `not live`, reporting a success as
///   a validation error.
/// * `keepAlive`: a button-triggered action is usually unwatched mid-call.
/// * In-flight set as an instance field, keyed by id.
/// * Providers are invalidated from the server's answer, never optimistically.

@ProviderFor(AdminModerationController)
final adminModerationControllerProvider = AdminModerationControllerProvider._();

/// Suspend, unsuspend, unpublish and republish, as mutations rather than reads.
///
/// Same shape and same reasons as [AdminReviewController], which this mirrors
/// deliberately rather than extending: review decisions move a listing through
/// the verification worklist (and update its counts), while these actions
/// operate outside it. Merging them would put unpublished rows and suspended
/// users through `applyReviewOutcome`, which only knows approve/reject.
///
/// * Plain notifier, not `AsyncNotifier`: a resolution that succeeds
///   server-side but fails on the response must not be retried — the retry
///   would fail with `already suspended` / `not live`, reporting a success as
///   a validation error.
/// * `keepAlive`: a button-triggered action is usually unwatched mid-call.
/// * In-flight set as an instance field, keyed by id.
/// * Providers are invalidated from the server's answer, never optimistically.
final class AdminModerationControllerProvider
    extends $NotifierProvider<AdminModerationController, void> {
  /// Suspend, unsuspend, unpublish and republish, as mutations rather than reads.
  ///
  /// Same shape and same reasons as [AdminReviewController], which this mirrors
  /// deliberately rather than extending: review decisions move a listing through
  /// the verification worklist (and update its counts), while these actions
  /// operate outside it. Merging them would put unpublished rows and suspended
  /// users through `applyReviewOutcome`, which only knows approve/reject.
  ///
  /// * Plain notifier, not `AsyncNotifier`: a resolution that succeeds
  ///   server-side but fails on the response must not be retried — the retry
  ///   would fail with `already suspended` / `not live`, reporting a success as
  ///   a validation error.
  /// * `keepAlive`: a button-triggered action is usually unwatched mid-call.
  /// * In-flight set as an instance field, keyed by id.
  /// * Providers are invalidated from the server's answer, never optimistically.
  AdminModerationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminModerationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminModerationControllerHash();

  @$internal
  @override
  AdminModerationController create() => AdminModerationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$adminModerationControllerHash() =>
    r'58b6ab22bb6d65163ea399a0767697b87d2647b1';

/// Suspend, unsuspend, unpublish and republish, as mutations rather than reads.
///
/// Same shape and same reasons as [AdminReviewController], which this mirrors
/// deliberately rather than extending: review decisions move a listing through
/// the verification worklist (and update its counts), while these actions
/// operate outside it. Merging them would put unpublished rows and suspended
/// users through `applyReviewOutcome`, which only knows approve/reject.
///
/// * Plain notifier, not `AsyncNotifier`: a resolution that succeeds
///   server-side but fails on the response must not be retried — the retry
///   would fail with `already suspended` / `not live`, reporting a success as
///   a validation error.
/// * `keepAlive`: a button-triggered action is usually unwatched mid-call.
/// * In-flight set as an instance field, keyed by id.
/// * Providers are invalidated from the server's answer, never optimistically.

abstract class _$AdminModerationController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
