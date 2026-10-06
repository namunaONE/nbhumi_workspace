// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolving a report, as a mutation rather than a read.
///
/// Every design decision here is inherited from [AdminReviewController], and the
/// reasons transfer unchanged — this file exists to say so rather than to
/// re-explain them:
///
/// * **Plain notifier, not `AsyncNotifier`.** Riverpod retries a provider whose
///   `build` returns a `Future`: ten attempts with backoff, so a resolution that
///   *succeeds* server-side but fails on the response would be retried, and the
///   retry would then fail with `22023: already resolved`. A moderation action
///   would be reported to the admin as a validation error, and an admin reading
///   that would reasonably conclude their click did nothing and click again.
///   One attempt, explicit retry.
/// * **`keepAlive`.** A plain notifier disposes when nothing watches it, which
///   for a button-triggered action is the common case — and the disposal lands
///   *mid-call*, after the repository `await` returns, so the next `ref` throws
///   `UnmountedRefException`. The container outlives every screen, so a
///   resolution started in one tab finishes even if the admin switches tabs.
/// * **In-flight set as an instance field, not provider state.** Putting it in
///   `state` would auto-dispose the controller the moment nothing watched it,
///   silently dropping the double-submit guard.
/// * **The queue is updated from the server's answer.** The row and the badge
///   must move together, and only the response says which tab the report landed
///   in.

@ProviderFor(ReportsController)
final reportsControllerProvider = ReportsControllerProvider._();

/// Resolving a report, as a mutation rather than a read.
///
/// Every design decision here is inherited from [AdminReviewController], and the
/// reasons transfer unchanged — this file exists to say so rather than to
/// re-explain them:
///
/// * **Plain notifier, not `AsyncNotifier`.** Riverpod retries a provider whose
///   `build` returns a `Future`: ten attempts with backoff, so a resolution that
///   *succeeds* server-side but fails on the response would be retried, and the
///   retry would then fail with `22023: already resolved`. A moderation action
///   would be reported to the admin as a validation error, and an admin reading
///   that would reasonably conclude their click did nothing and click again.
///   One attempt, explicit retry.
/// * **`keepAlive`.** A plain notifier disposes when nothing watches it, which
///   for a button-triggered action is the common case — and the disposal lands
///   *mid-call*, after the repository `await` returns, so the next `ref` throws
///   `UnmountedRefException`. The container outlives every screen, so a
///   resolution started in one tab finishes even if the admin switches tabs.
/// * **In-flight set as an instance field, not provider state.** Putting it in
///   `state` would auto-dispose the controller the moment nothing watched it,
///   silently dropping the double-submit guard.
/// * **The queue is updated from the server's answer.** The row and the badge
///   must move together, and only the response says which tab the report landed
///   in.
final class ReportsControllerProvider
    extends $NotifierProvider<ReportsController, void> {
  /// Resolving a report, as a mutation rather than a read.
  ///
  /// Every design decision here is inherited from [AdminReviewController], and the
  /// reasons transfer unchanged — this file exists to say so rather than to
  /// re-explain them:
  ///
  /// * **Plain notifier, not `AsyncNotifier`.** Riverpod retries a provider whose
  ///   `build` returns a `Future`: ten attempts with backoff, so a resolution that
  ///   *succeeds* server-side but fails on the response would be retried, and the
  ///   retry would then fail with `22023: already resolved`. A moderation action
  ///   would be reported to the admin as a validation error, and an admin reading
  ///   that would reasonably conclude their click did nothing and click again.
  ///   One attempt, explicit retry.
  /// * **`keepAlive`.** A plain notifier disposes when nothing watches it, which
  ///   for a button-triggered action is the common case — and the disposal lands
  ///   *mid-call*, after the repository `await` returns, so the next `ref` throws
  ///   `UnmountedRefException`. The container outlives every screen, so a
  ///   resolution started in one tab finishes even if the admin switches tabs.
  /// * **In-flight set as an instance field, not provider state.** Putting it in
  ///   `state` would auto-dispose the controller the moment nothing watched it,
  ///   silently dropping the double-submit guard.
  /// * **The queue is updated from the server's answer.** The row and the badge
  ///   must move together, and only the response says which tab the report landed
  ///   in.
  ReportsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsControllerHash();

  @$internal
  @override
  ReportsController create() => ReportsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$reportsControllerHash() => r'58777da40b52cb66b3dc2962e43d067b4a879eb2';

/// Resolving a report, as a mutation rather than a read.
///
/// Every design decision here is inherited from [AdminReviewController], and the
/// reasons transfer unchanged — this file exists to say so rather than to
/// re-explain them:
///
/// * **Plain notifier, not `AsyncNotifier`.** Riverpod retries a provider whose
///   `build` returns a `Future`: ten attempts with backoff, so a resolution that
///   *succeeds* server-side but fails on the response would be retried, and the
///   retry would then fail with `22023: already resolved`. A moderation action
///   would be reported to the admin as a validation error, and an admin reading
///   that would reasonably conclude their click did nothing and click again.
///   One attempt, explicit retry.
/// * **`keepAlive`.** A plain notifier disposes when nothing watches it, which
///   for a button-triggered action is the common case — and the disposal lands
///   *mid-call*, after the repository `await` returns, so the next `ref` throws
///   `UnmountedRefException`. The container outlives every screen, so a
///   resolution started in one tab finishes even if the admin switches tabs.
/// * **In-flight set as an instance field, not provider state.** Putting it in
///   `state` would auto-dispose the controller the moment nothing watched it,
///   silently dropping the double-submit guard.
/// * **The queue is updated from the server's answer.** The row and the badge
///   must move together, and only the response says which tab the report landed
///   in.

abstract class _$ReportsController extends $Notifier<void> {
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
