// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_queue_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The queue, paginated with a keyset cursor.
///
/// Retry is disabled for the same reason as the browse feed: Riverpod 3.0
/// up to ten times with exponential backoff, so a failure would take roughly 40
/// seconds to surface. An admin staring at a spinner cannot act on that,
/// queue is the screen where waiting is most expensive.

@ProviderFor(AdminQueue)
final adminQueueProvider = AdminQueueProvider._();

/// The queue, paginated with a keyset cursor.
///
/// Retry is disabled for the same reason as the browse feed: Riverpod 3.0
/// up to ten times with exponential backoff, so a failure would take roughly 40
/// seconds to surface. An admin staring at a spinner cannot act on that,
/// queue is the screen where waiting is most expensive.
final class AdminQueueProvider
    extends $AsyncNotifierProvider<AdminQueue, QueueViewState> {
  /// The queue, paginated with a keyset cursor.
  ///
  /// Retry is disabled for the same reason as the browse feed: Riverpod 3.0
  /// up to ten times with exponential backoff, so a failure would take roughly 40
  /// seconds to surface. An admin staring at a spinner cannot act on that,
  /// queue is the screen where waiting is most expensive.
  AdminQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminQueueHash();

  @$internal
  @override
  AdminQueue create() => AdminQueue();
}

String _$adminQueueHash() => r'8adf0d624d750c26a3e663422366870998f14989';

/// The queue, paginated with a keyset cursor.
///
/// Retry is disabled for the same reason as the browse feed: Riverpod 3.0
/// up to ten times with exponential backoff, so a failure would take roughly 40
/// seconds to surface. An admin staring at a spinner cannot act on that,
/// queue is the screen where waiting is most expensive.

abstract class _$AdminQueue extends $AsyncNotifier<QueueViewState> {
  FutureOr<QueueViewState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<QueueViewState>, QueueViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QueueViewState>, QueueViewState>,
              AsyncValue<QueueViewState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Which tab of the queue is showing.
///
/// Separate from [AdminQueue] so a tab switch does not rebuild the provider
/// that owns the rows, and so reloading the rows does not reset the tab.

@ProviderFor(AdminQueueTab)
final adminQueueTabProvider = AdminQueueTabProvider._();

/// Which tab of the queue is showing.
///
/// Separate from [AdminQueue] so a tab switch does not rebuild the provider
/// that owns the rows, and so reloading the rows does not reset the tab.
final class AdminQueueTabProvider
    extends $NotifierProvider<AdminQueueTab, ListingStatus> {
  /// Which tab of the queue is showing.
  ///
  /// Separate from [AdminQueue] so a tab switch does not rebuild the provider
  /// that owns the rows, and so reloading the rows does not reset the tab.
  AdminQueueTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminQueueTabProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminQueueTabHash();

  @$internal
  @override
  AdminQueueTab create() => AdminQueueTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListingStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListingStatus>(value),
    );
  }
}

String _$adminQueueTabHash() => r'e6fc433ea670b3de57523c64bfe4f8925aad4e3b';

/// Which tab of the queue is showing.
///
/// Separate from [AdminQueue] so a tab switch does not rebuild the provider
/// that owns the rows, and so reloading the rows does not reset the tab.

abstract class _$AdminQueueTab extends $Notifier<ListingStatus> {
  ListingStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ListingStatus, ListingStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ListingStatus, ListingStatus>,
              ListingStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The listing currently open in the detail pane.
///
/// Null means the list is full width, which is what the compact layout shows.

@ProviderFor(AdminSelectedListing)
final adminSelectedListingProvider = AdminSelectedListingProvider._();

/// The listing currently open in the detail pane.
///
/// Null means the list is full width, which is what the compact layout shows.
final class AdminSelectedListingProvider
    extends $NotifierProvider<AdminSelectedListing, String?> {
  /// The listing currently open in the detail pane.
  ///
  /// Null means the list is full width, which is what the compact layout shows.
  AdminSelectedListingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminSelectedListingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminSelectedListingHash();

  @$internal
  @override
  AdminSelectedListing create() => AdminSelectedListing();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$adminSelectedListingHash() =>
    r'af0fc9e4147b816732438cdfe134245919c789d4';

/// The listing currently open in the detail pane.
///
/// Null means the list is full width, which is what the compact layout shows.

abstract class _$AdminSelectedListing extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One listing as the admin's detail pane sees it.
///
/// A family keyed on listing id, resolved through the existing detail RPC,
/// than a queue-specific read. That RPC already admits admins to non-live
/// listings and returns everything the pane needs: photos, specs, a seller card
/// with role and KYC tier, and `submitted_at` for the SLA.
///
/// Retry is disabled. The default ten retries with backoff would hold the pane
/// loading for roughly forty seconds, and an admin who just clicked
/// the queue needs either a listing or an explanation.

@ProviderFor(adminListingDetail)
final adminListingDetailProvider = AdminListingDetailFamily._();

/// One listing as the admin's detail pane sees it.
///
/// A family keyed on listing id, resolved through the existing detail RPC,
/// than a queue-specific read. That RPC already admits admins to non-live
/// listings and returns everything the pane needs: photos, specs, a seller card
/// with role and KYC tier, and `submitted_at` for the SLA.
///
/// Retry is disabled. The default ten retries with backoff would hold the pane
/// loading for roughly forty seconds, and an admin who just clicked
/// the queue needs either a listing or an explanation.

final class AdminListingDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ListingDetail?>,
          ListingDetail?,
          FutureOr<ListingDetail?>
        >
    with $FutureModifier<ListingDetail?>, $FutureProvider<ListingDetail?> {
  /// One listing as the admin's detail pane sees it.
  ///
  /// A family keyed on listing id, resolved through the existing detail RPC,
  /// than a queue-specific read. That RPC already admits admins to non-live
  /// listings and returns everything the pane needs: photos, specs, a seller card
  /// with role and KYC tier, and `submitted_at` for the SLA.
  ///
  /// Retry is disabled. The default ten retries with backoff would hold the pane
  /// loading for roughly forty seconds, and an admin who just clicked
  /// the queue needs either a listing or an explanation.
  AdminListingDetailProvider._({
    required AdminListingDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminListingDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminListingDetailHash();

  @override
  String toString() {
    return r'adminListingDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ListingDetail?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ListingDetail?> create(Ref ref) {
    final argument = this.argument as String;
    return adminListingDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminListingDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminListingDetailHash() =>
    r'ae25d7c75158f07537e9be41759c47b75af8df6c';

/// One listing as the admin's detail pane sees it.
///
/// A family keyed on listing id, resolved through the existing detail RPC,
/// than a queue-specific read. That RPC already admits admins to non-live
/// listings and returns everything the pane needs: photos, specs, a seller card
/// with role and KYC tier, and `submitted_at` for the SLA.
///
/// Retry is disabled. The default ten retries with backoff would hold the pane
/// loading for roughly forty seconds, and an admin who just clicked
/// the queue needs either a listing or an explanation.

final class AdminListingDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ListingDetail?>, String> {
  AdminListingDetailFamily._()
    : super(
        retry: null,
        name: r'adminListingDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One listing as the admin's detail pane sees it.
  ///
  /// A family keyed on listing id, resolved through the existing detail RPC,
  /// than a queue-specific read. That RPC already admits admins to non-live
  /// listings and returns everything the pane needs: photos, specs, a seller card
  /// with role and KYC tier, and `submitted_at` for the SLA.
  ///
  /// Retry is disabled. The default ten retries with backoff would hold the pane
  /// loading for roughly forty seconds, and an admin who just clicked
  /// the queue needs either a listing or an explanation.

  AdminListingDetailProvider call(String listingId) =>
      AdminListingDetailProvider._(argument: listingId, from: this);

  @override
  String toString() => r'adminListingDetailProvider';
}

/// Admin actions on one listing, newest first.
///
/// Returns an empty list rather than throwing when the trail cannot be read. A
/// missing audit history must not block a reviewer from approving or rejecting:
/// the decision matters more than its annotation, and Rule 8's guarantee is
/// server-side regardless of whether this panel can display it.

@ProviderFor(adminAuditTrail)
final adminAuditTrailProvider = AdminAuditTrailFamily._();

/// Admin actions on one listing, newest first.
///
/// Returns an empty list rather than throwing when the trail cannot be read. A
/// missing audit history must not block a reviewer from approving or rejecting:
/// the decision matters more than its annotation, and Rule 8's guarantee is
/// server-side regardless of whether this panel can display it.

final class AdminAuditTrailProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuditLogEntry>>,
          List<AuditLogEntry>,
          FutureOr<List<AuditLogEntry>>
        >
    with
        $FutureModifier<List<AuditLogEntry>>,
        $FutureProvider<List<AuditLogEntry>> {
  /// Admin actions on one listing, newest first.
  ///
  /// Returns an empty list rather than throwing when the trail cannot be read. A
  /// missing audit history must not block a reviewer from approving or rejecting:
  /// the decision matters more than its annotation, and Rule 8's guarantee is
  /// server-side regardless of whether this panel can display it.
  AdminAuditTrailProvider._({
    required AdminAuditTrailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminAuditTrailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminAuditTrailHash();

  @override
  String toString() {
    return r'adminAuditTrailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AuditLogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AuditLogEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return adminAuditTrail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminAuditTrailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminAuditTrailHash() => r'436e357adf9fbc7c4ae32c861d26c7f04a9589e1';

/// Admin actions on one listing, newest first.
///
/// Returns an empty list rather than throwing when the trail cannot be read. A
/// missing audit history must not block a reviewer from approving or rejecting:
/// the decision matters more than its annotation, and Rule 8's guarantee is
/// server-side regardless of whether this panel can display it.

final class AdminAuditTrailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AuditLogEntry>>, String> {
  AdminAuditTrailFamily._()
    : super(
        retry: null,
        name: r'adminAuditTrailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Admin actions on one listing, newest first.
  ///
  /// Returns an empty list rather than throwing when the trail cannot be read. A
  /// missing audit history must not block a reviewer from approving or rejecting:
  /// the decision matters more than its annotation, and Rule 8's guarantee is
  /// server-side regardless of whether this panel can display it.

  AdminAuditTrailProvider call(String listingId) =>
      AdminAuditTrailProvider._(argument: listingId, from: this);

  @override
  String toString() => r'adminAuditTrailProvider';
}
