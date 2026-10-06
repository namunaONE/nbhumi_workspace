// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The reports queue, paginated with a keyset cursor.
///
/// Retry is disabled for the same reason as the listing queue: Riverpod retries
/// a provider whose `build` returns a Future, so a failure would take roughly
/// forty seconds to surface. Moderation is where waiting costs most.

@ProviderFor(AdminReports)
final adminReportsProvider = AdminReportsProvider._();

/// The reports queue, paginated with a keyset cursor.
///
/// Retry is disabled for the same reason as the listing queue: Riverpod retries
/// a provider whose `build` returns a Future, so a failure would take roughly
/// forty seconds to surface. Moderation is where waiting costs most.
final class AdminReportsProvider
    extends $AsyncNotifierProvider<AdminReports, ReportsViewState> {
  /// The reports queue, paginated with a keyset cursor.
  ///
  /// Retry is disabled for the same reason as the listing queue: Riverpod retries
  /// a provider whose `build` returns a Future, so a failure would take roughly
  /// forty seconds to surface. Moderation is where waiting costs most.
  AdminReportsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminReportsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminReportsHash();

  @$internal
  @override
  AdminReports create() => AdminReports();
}

String _$adminReportsHash() => r'6e872a7a9be121c46515eef7760233d49010b2a5';

/// The reports queue, paginated with a keyset cursor.
///
/// Retry is disabled for the same reason as the listing queue: Riverpod retries
/// a provider whose `build` returns a Future, so a failure would take roughly
/// forty seconds to surface. Moderation is where waiting costs most.

abstract class _$AdminReports extends $AsyncNotifier<ReportsViewState> {
  FutureOr<ReportsViewState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ReportsViewState>, ReportsViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReportsViewState>, ReportsViewState>,
              AsyncValue<ReportsViewState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Which tab of the reports queue is showing.
///
/// Separate from [AdminReports] so a tab switch does not rebuild the provider
/// that owns the rows, and so reloading the rows does not reset the tab.

@ProviderFor(ReportsTab)
final reportsTabProvider = ReportsTabProvider._();

/// Which tab of the reports queue is showing.
///
/// Separate from [AdminReports] so a tab switch does not rebuild the provider
/// that owns the rows, and so reloading the rows does not reset the tab.
final class ReportsTabProvider
    extends $NotifierProvider<ReportsTab, ReportStatus> {
  /// Which tab of the reports queue is showing.
  ///
  /// Separate from [AdminReports] so a tab switch does not rebuild the provider
  /// that owns the rows, and so reloading the rows does not reset the tab.
  ReportsTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsTabProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsTabHash();

  @$internal
  @override
  ReportsTab create() => ReportsTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportStatus>(value),
    );
  }
}

String _$reportsTabHash() => r'c6c70dbbc57ba890dda07d7eb22d19bf6734ff82';

/// Which tab of the reports queue is showing.
///
/// Separate from [AdminReports] so a tab switch does not rebuild the provider
/// that owns the rows, and so reloading the rows does not reset the tab.

abstract class _$ReportsTab extends $Notifier<ReportStatus> {
  ReportStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReportStatus, ReportStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReportStatus, ReportStatus>,
              ReportStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
