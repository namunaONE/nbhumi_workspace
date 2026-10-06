// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Approve and reject, as a mutation rather than a read.
///
/// ### Why this is a plain notifier, not an `AsyncNotifier`
///
/// Riverpod retries a provider whose `build` returns a `Future`: ten attempts
/// with exponential backoff, so a genuine failure surfaces roughly forty
/// seconds
/// later. That is the right default for loading a feed and badly wrong here.
///
/// An approve that *succeeds* server-side but fails on the response would be
/// retried. The retry would then hit
/// `VALIDATION_ERROR: listing is not in pending_review`, because the first
/// attempt already moved the listing. A successful moderation action would be
/// reported to the admin as a validation failure — and an admin reading that
/// would reasonably conclude their click did nothing and click again. One
/// attempt, explicit retry.
///
/// ### Why this provider is `keepAlive`
///
/// A plain [Notifier] is disposed the moment nothing watches it, and for a
/// button-triggered action that is the common case: nothing holds this provider
/// while the admin reads the listing. The disposal lands *mid-call* — the
/// repository `await` returns, and then `ref.read` on a dead [Ref] throws
/// `UnmountedRefException`. A widget test caught exactly that.
///
/// `keepAlive` ties the controller's lifetime to the container instead, which is
/// the right scope: the container outlives every screen, so a decision started
/// in one pane finishes even if the admin navigates away mid-request.
///
/// ### Why the queue is updated here rather than in the widget
///
/// The row and the tab badge must change together, and the server's answer is
/// what says how. A widget that removed the row on a 200 would have to guess
/// which tab the listing moved to; [ReviewOutcome] carries the status the RPC
/// reported, so the decision is made once, from the authoritative answer.

@ProviderFor(AdminReviewController)
final adminReviewControllerProvider = AdminReviewControllerProvider._();

/// Approve and reject, as a mutation rather than a read.
///
/// ### Why this is a plain notifier, not an `AsyncNotifier`
///
/// Riverpod retries a provider whose `build` returns a `Future`: ten attempts
/// with exponential backoff, so a genuine failure surfaces roughly forty
/// seconds
/// later. That is the right default for loading a feed and badly wrong here.
///
/// An approve that *succeeds* server-side but fails on the response would be
/// retried. The retry would then hit
/// `VALIDATION_ERROR: listing is not in pending_review`, because the first
/// attempt already moved the listing. A successful moderation action would be
/// reported to the admin as a validation failure — and an admin reading that
/// would reasonably conclude their click did nothing and click again. One
/// attempt, explicit retry.
///
/// ### Why this provider is `keepAlive`
///
/// A plain [Notifier] is disposed the moment nothing watches it, and for a
/// button-triggered action that is the common case: nothing holds this provider
/// while the admin reads the listing. The disposal lands *mid-call* — the
/// repository `await` returns, and then `ref.read` on a dead [Ref] throws
/// `UnmountedRefException`. A widget test caught exactly that.
///
/// `keepAlive` ties the controller's lifetime to the container instead, which is
/// the right scope: the container outlives every screen, so a decision started
/// in one pane finishes even if the admin navigates away mid-request.
///
/// ### Why the queue is updated here rather than in the widget
///
/// The row and the tab badge must change together, and the server's answer is
/// what says how. A widget that removed the row on a 200 would have to guess
/// which tab the listing moved to; [ReviewOutcome] carries the status the RPC
/// reported, so the decision is made once, from the authoritative answer.
final class AdminReviewControllerProvider
    extends $NotifierProvider<AdminReviewController, void> {
  /// Approve and reject, as a mutation rather than a read.
  ///
  /// ### Why this is a plain notifier, not an `AsyncNotifier`
  ///
  /// Riverpod retries a provider whose `build` returns a `Future`: ten attempts
  /// with exponential backoff, so a genuine failure surfaces roughly forty
  /// seconds
  /// later. That is the right default for loading a feed and badly wrong here.
  ///
  /// An approve that *succeeds* server-side but fails on the response would be
  /// retried. The retry would then hit
  /// `VALIDATION_ERROR: listing is not in pending_review`, because the first
  /// attempt already moved the listing. A successful moderation action would be
  /// reported to the admin as a validation failure — and an admin reading that
  /// would reasonably conclude their click did nothing and click again. One
  /// attempt, explicit retry.
  ///
  /// ### Why this provider is `keepAlive`
  ///
  /// A plain [Notifier] is disposed the moment nothing watches it, and for a
  /// button-triggered action that is the common case: nothing holds this provider
  /// while the admin reads the listing. The disposal lands *mid-call* — the
  /// repository `await` returns, and then `ref.read` on a dead [Ref] throws
  /// `UnmountedRefException`. A widget test caught exactly that.
  ///
  /// `keepAlive` ties the controller's lifetime to the container instead, which is
  /// the right scope: the container outlives every screen, so a decision started
  /// in one pane finishes even if the admin navigates away mid-request.
  ///
  /// ### Why the queue is updated here rather than in the widget
  ///
  /// The row and the tab badge must change together, and the server's answer is
  /// what says how. A widget that removed the row on a 200 would have to guess
  /// which tab the listing moved to; [ReviewOutcome] carries the status the RPC
  /// reported, so the decision is made once, from the authoritative answer.
  AdminReviewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminReviewControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminReviewControllerHash();

  @$internal
  @override
  AdminReviewController create() => AdminReviewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$adminReviewControllerHash() =>
    r'4d1f254f67caede82d94d56ee94c7fce4e9de085';

/// Approve and reject, as a mutation rather than a read.
///
/// ### Why this is a plain notifier, not an `AsyncNotifier`
///
/// Riverpod retries a provider whose `build` returns a `Future`: ten attempts
/// with exponential backoff, so a genuine failure surfaces roughly forty
/// seconds
/// later. That is the right default for loading a feed and badly wrong here.
///
/// An approve that *succeeds* server-side but fails on the response would be
/// retried. The retry would then hit
/// `VALIDATION_ERROR: listing is not in pending_review`, because the first
/// attempt already moved the listing. A successful moderation action would be
/// reported to the admin as a validation failure — and an admin reading that
/// would reasonably conclude their click did nothing and click again. One
/// attempt, explicit retry.
///
/// ### Why this provider is `keepAlive`
///
/// A plain [Notifier] is disposed the moment nothing watches it, and for a
/// button-triggered action that is the common case: nothing holds this provider
/// while the admin reads the listing. The disposal lands *mid-call* — the
/// repository `await` returns, and then `ref.read` on a dead [Ref] throws
/// `UnmountedRefException`. A widget test caught exactly that.
///
/// `keepAlive` ties the controller's lifetime to the container instead, which is
/// the right scope: the container outlives every screen, so a decision started
/// in one pane finishes even if the admin navigates away mid-request.
///
/// ### Why the queue is updated here rather than in the widget
///
/// The row and the tab badge must change together, and the server's answer is
/// what says how. A widget that removed the row on a 200 would have to guess
/// which tab the listing moved to; [ReviewOutcome] carries the status the RPC
/// reported, so the decision is made once, from the authoritative answer.

abstract class _$AdminReviewController extends $Notifier<void> {
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
