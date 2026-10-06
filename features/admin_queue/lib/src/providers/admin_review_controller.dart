import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'admin_queue_providers.dart';

part 'admin_review_controller.g.dart';

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
/// A plain notifier is disposed the moment nothing watches it, and for a
/// button-triggered action that is the common case: nothing holds this provider
/// while the admin reads the listing. The disposal lands *mid-call* — the
/// repository `await` returns, and then `ref.read` on a dead ref throws
/// `UnmountedRefException`. A widget test caught exactly that.
///
/// `keepAlive` ties the controller's lifetime to the container instead,
/// which is the right scope: the container outlives every screen, so a
/// decision started in one pane finishes even if the admin navigates away
/// mid-request.
///
/// ### Why the queue is updated here rather than in the widget
///
/// The row and the tab badge must change together, and the server's answer is
/// what says how. A widget that removed the row on a 200 would have to guess
/// which tab the listing moved to; [ReviewOutcome] carries the status the RPC
/// reported, so the decision is made once, from the authoritative answer.
@Riverpod(keepAlive: true)
class AdminReviewController extends _$AdminReviewController {
  /// Builds nothing.
  ///
  /// Required by the generator, and there is genuinely nothing to build: this
  /// is
  /// a mutation holder, not a source of state anyone reads. The in-flight set
  /// below is a plain instance field rather than this provider's state on
  /// purpose — putting it in `state` would make the controller auto-dispose the
  /// moment nothing watched it, which for a button-triggered action is the
  /// common case, and would silently drop the guard against a double submit.
  @override
  void build() {}

  /// Listing ids with a decision in flight.
  ///
  /// Keyed by listing rather than a single flag, so reviewing one listing does
  /// not disable the buttons on another, and so a double submit on the *same*
  /// listing is refused while the first is still open.
  final Set<String> _inFlight = <String>{};

  /// Ids with a decision in flight.
  Set<String> get inFlight => Set<String>.unmodifiable(_inFlight);

  /// Approves [listingId], publishing it.
  ///
  /// Returns what the server reported. Throws the mapped [AppException] on
  /// failure so the caller can show a bilingual message with a retry action
  /// (Rule 36) — never a silent no-op.
  Future<ReviewOutcome> approve(String listingId) =>
      _decide(listingId, ReviewDecision.approve);

  /// Rejects [listingId] with [reason], returning it to the seller.
  ///
  /// [reason] must be non-blank; the repository refuses it client-side before a
  /// round trip (Rule 6), and the RPC refuses it again server-side.
  Future<ReviewOutcome> reject(String listingId, String reason) =>
      _decide(listingId, ReviewDecision.reject, reason: reason);

  /// Performs one decision, guarding against a concurrent duplicate.
  Future<ReviewOutcome> _decide(
    String listingId,
    ReviewDecision decision, {
    String? reason,
  }) async {
    // The guard is here rather than in the button's `onPressed`, because the
    // button can be re-enabled by a rebuild while the call is already out. The
    // server would refuse the duplicate with 22023, but only after a round trip
    // and only with a message that reads like a bug.
    if (_inFlight.contains(listingId)) {
      throw const ValidationException(
        code: 'validation.reviewAlreadyInFlight',
        messageEn: 'A decision on this listing is already being saved.',
        messageNe: 'यस लिस्टिङमा निर्णय पहिले नै जारी छ।',
      );
    }

    _inFlight.add(listingId);
    try {
      final repository = ref.read(adminRepositoryProvider);

      final serverStatus = switch (decision) {
        ReviewDecision.approve => await repository.approveListing(listingId),
        ReviewDecision.reject =>
          await repository.rejectListing(listingId, reason ?? ''),
      };

      final outcome = ReviewOutcome(
        listingId: listingId,
        decision: decision,
        serverStatus: serverStatus,
      );

      // Applied only on success. Rolling the list back after a failure would be
      // noise: the row never left, because nothing was written.
      ref.read(adminQueueProvider.notifier).applyReviewOutcome(outcome);

      // A reviewed listing is no longer pending, so leaving it open would show
      // a
      // listing the admin can no longer act on. On the live and rejected tabs
      // it
      // stays open, because there it is being read rather than acted on.
      if (ref.read(adminQueueTabProvider) == ListingStatus.pendingReview) {
        ref.read(adminSelectedListingProvider.notifier).clear();
      }

      // The detail pane's copy is now stale — its status and its audit trail
      // both changed. Invalidating rather than leaving it means an admin who
      // reopens the listing sees the verdict and who gave it.
      ref
        ..invalidate(adminListingDetailProvider(listingId))
        ..invalidate(adminAuditTrailProvider(listingId));

      return outcome;
    } finally {
      // In a finally, not after the switch: a failure about to propagate must
      // still release the lock, or the buttons stay dead for the rest of the
      // session.
      _inFlight.remove(listingId);
    }
  }
}
