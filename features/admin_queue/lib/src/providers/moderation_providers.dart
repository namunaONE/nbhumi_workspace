import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'admin_queue_providers.dart';
import 'admin_review_controller.dart';

part 'moderation_providers.g.dart';

/// One account for moderation, keyed by user id.
///
/// A family rather than a field on the listing detail: the detail RPC's seller
/// card deliberately carries no suspension state (it is the same shape the
/// buyer-facing app reads), so the admin panel reads it separately. Retry is
/// disabled for the same reason as the detail pane: ten attempts with backoff
/// would hold a suspension decision for roughly forty seconds.
@riverpod
Future<AdminUser> adminUser(Ref ref, String userId) {
  return ref.watch(adminRepositoryProvider).getUser(userId);
}

/// Duplicate/fraud signals on one listing, keyed by listing id (HYA-261).
///
/// A family like [adminUser]: the detail screen reads signals for exactly the
/// listing open. Retry is disabled for the same reason as the detail pane --
/// ten attempts with backoff would hold the flags for roughly forty seconds
/// while the admin waits to decide. The panel offers its own explicit retry.
@riverpod
Future<ListingFraudSignals> fraudSignals(Ref ref, String listingId) {
  return ref.watch(adminRepositoryProvider).fraudSignals(listingId);
}

/// What an unpublish or republish did.
@immutable
class ListingModerationOutcome {
  /// Creates the outcome of one listing moderation action.
  const ListingModerationOutcome({
    required this.listingId,
    required this.action,
    required this.serverStatus,
  });

  /// The listing acted on.
  final String listingId;

  /// Which button was pressed. Kept alongside [serverStatus] so the UI can
  /// tell "did what was asked" from "somebody else got there first".
  final ModerationAction action;

  /// The status the server reported afterwards.
  final ListingStatus serverStatus;

  @override
  bool operator ==(Object other) =>
      other is ListingModerationOutcome &&
      other.listingId == listingId &&
      other.action == action &&
      other.serverStatus == serverStatus;

  @override
  int get hashCode => Object.hash(listingId, action, serverStatus);
}

/// The two listing-level moderation actions (HYA-262).
enum ModerationAction {
  /// Pull a live listing. Does not touch the seller's other listings.
  unpublish,

  /// Return an unpublished listing to live.
  republish,
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
@Riverpod(keepAlive: true)
class AdminModerationController extends _$AdminModerationController {
  /// Builds nothing: a mutation holder, not a source of state anyone reads.
  @override
  void build() {}

  /// Ids with a moderation action in flight (listing and user ids share the
  /// set: a UUID cannot be both, so one set guards both without collision).
  final Set<String> _inFlight = <String>{};

  /// Ids with a moderation action in flight.
  Set<String> get inFlight => Set<String>.unmodifiable(_inFlight);

  /// Pulls a live listing with [reason].
  Future<ListingModerationOutcome> unpublish(
    String listingId,
    String reason,
  ) =>
      _moderateListing(listingId, ModerationAction.unpublish, reason: reason);

  /// Returns an unpublished listing to live.
  Future<ListingModerationOutcome> republish(String listingId) =>
      _moderateListing(listingId, ModerationAction.republish);

  /// Suspends [userId] with [reason], cutting off listing writes.
  ///
  /// Returns the re-read user, so the caller renders what the database
  /// stored rather than assuming the suspension landed.
  Future<AdminUser> suspendUser(String userId, String reason) =>
      _moderateUser(userId, suspend: true, reason: reason);

  /// Lifts [userId]'s suspension, restoring listing writes.
  Future<AdminUser> unsuspendUser(String userId) =>
      _moderateUser(userId, suspend: false);

  Future<ListingModerationOutcome> _moderateListing(
    String listingId,
    ModerationAction action, {
    String? reason,
  }) async {
    _guard(listingId, 'moderation action');

    _inFlight.add(listingId);
    try {
      final repository = ref.read(adminRepositoryProvider);

      final serverStatus = switch (action) {
        ModerationAction.unpublish =>
          await repository.unpublishListing(listingId, reason ?? ''),
        ModerationAction.republish =>
          await repository.republishListing(listingId),
      };

      final outcome = ListingModerationOutcome(
        listingId: listingId,
        action: action,
        serverStatus: serverStatus,
      );

      // The detail pane's copy is stale (status and audit trail both moved).
      // The queue is refetched rather than surgically updated: unpublished has
      // no tab and no count field, so there is nothing correct to shift — and
      // a refetch is the only update that cannot drift from the server.
      ref
        ..invalidate(adminListingDetailProvider(listingId))
        ..invalidate(adminAuditTrailProvider(listingId))
        ..invalidate(adminQueueProvider);

      return outcome;
    } finally {
      _inFlight.remove(listingId);
    }
  }

  Future<AdminUser> _moderateUser(
    String userId,
    {required bool suspend, String? reason}) async {
    _guard(userId, 'moderation action');

    _inFlight.add(userId);
    try {
      final repository = ref.read(adminRepositoryProvider);

      final user = suspend
          ? await repository.suspendUser(userId, reason ?? '')
          : await repository.unsuspendUser(userId);

      ref.invalidate(adminUserProvider(userId));

      return user;
    } finally {
      _inFlight.remove(userId);
    }
  }

  /// Refuses a concurrent duplicate on [id].
  ///
  /// Lives here rather than in the button because a rebuild can re-enable the
  /// button while the call is already out. The server would refuse with 22023
  /// after a round trip, with a message that reads like a bug.
  void _guard(String id, String what) {
    if (_inFlight.contains(id)) {
      throw const ValidationException(
        code: 'validation.moderationAlreadyInFlight',
        messageEn: 'A moderation action on this item is already being saved.',
        messageNe: 'यसमा नियमन कार्य पहिले नै जारी छ।',
      );
    }
  }
}
