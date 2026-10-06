import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'reports_providers.dart';

part 'reports_controller.g.dart';

/// Resolving a report, as a mutation rather than a read.
///
/// Every design decision here is inherited from
/// `AdminReviewController`, and the reasons transfer unchanged — this file
/// exists to say so rather than to re-explain them:
///
/// * **Plain notifier, not `AsyncNotifier`.** Riverpod retries a provider
///   whose `build` returns a `Future`: ten attempts with backoff, so a
///   resolution that *succeeds* server-side but fails on the response would
///   be retried, and the retry would then fail with `22023: already
///   resolved`. A moderation action would be reported to the admin as a
///   validation error, and an admin reading that would reasonably conclude
///   their click did nothing and click again.
///   One attempt, explicit retry.
/// * **`keepAlive`.** A plain notifier disposes when nothing watches it, which
///   for a button-triggered action is the common case — and the disposal
///   lands *mid-call*, after the repository `await` returns, so the next
///   `ref` throws `UnmountedRefException`. The container outlives every
///   screen, so a resolution started in one tab finishes even if the admin
///   switches tabs.
/// * **In-flight set as an instance field, not provider state.** Putting it in
///   `state` would auto-dispose the controller the moment nothing watched it,
///   silently dropping the double-submit guard.
/// * **The queue is updated from the server's answer.** The row and the badge
///   must move together, and only the response says which tab the report landed
///   in.
@Riverpod(keepAlive: true)
class ReportsController extends _$ReportsController {
  /// Builds nothing.
  ///
  /// Required by the generator, and genuinely nothing to build: this is a
  /// mutation holder, not a source of state anyone reads.
  @override
  void build() {}

  /// Report ids with a resolution in flight.
  ///
  /// Keyed by report rather than a single flag, so resolving one report does
  /// not disable the buttons on another, and so a double submit on the
  /// *same* report is refused while the first is still open.
  final Set<String> _inFlight = <String>{};

  /// Ids with a resolution in flight.
  Set<String> get inFlight => Set<String>.unmodifiable(_inFlight);

  /// Whether [reportId] has a resolution in flight.
  bool isBusy(String reportId) => _inFlight.contains(reportId);

  /// Marks [reportId] as actioned: the report was justified and the listing was
  /// dealt with.
  Future<ReportResolutionOutcome> action(String reportId) =>
      _resolve(reportId, ReportResolution.actioned);

  /// Marks [reportId] as dismissed: the report was unfounded and the listing
  /// stays up.
  Future<ReportResolutionOutcome> dismiss(String reportId) =>
      _resolve(reportId, ReportResolution.dismissed);

  /// Performs one resolution, guarding against a concurrent duplicate.
  ///
  /// Returns the server's answer. Throws the mapped [AppException] on failure
  /// so the caller can show a bilingual message with a retry action (Rule 36)
  /// — never a silent no-op.
  Future<ReportResolutionOutcome> _resolve(
    String reportId,
    ReportResolution resolution,
  ) async {
    // The guard is here rather than in the button's `onPressed`, because the
    // button can be re-enabled by a rebuild while the call is already out.
    // The server would refuse the duplicate with `22023`, but only after a
    // round trip and only with a message that reads like a bug.
    if (_inFlight.contains(reportId)) {
      throw const ValidationException(
        code: 'validation.reportAlreadyInFlight',
        messageEn: 'This report is already being closed.',
        messageNe: 'यो रिपोर्ट बन्द हुँदै छ।',
      );
    }

    _inFlight.add(reportId);
    try {
      final repository = ref.read(adminRepositoryProvider);
      final serverStatus = await repository.resolveReport(reportId, resolution);

      final outcome = ReportResolutionOutcome(
        reportId: reportId,
        // The repository does not return the listing id, so the row's own value
        // is the only source. Read from the queue rather than echoed from the
        // call: an echo would be whatever this client last asked for.
        listingId: _listingIdFor(reportId) ?? '',
        requested: resolution,
        serverStatus: serverStatus,
      );

      // Applied only on success. Rolling the list back after a failure would be
      // noise: the row never left, because nothing was written.
      ref
          .read(adminReportsProvider.notifier)
          .applyResolution(reportId, serverStatus);

      return outcome;
    } finally {
      // In a finally, not after the call: a failure about to propagate must
      // still release the lock, or the buttons stay dead for the session.
      _inFlight.remove(reportId);
    }
  }

  /// The listing a loaded report belongs to.
  ///
  /// Null when the report is not in the loaded queue — it may have been
  /// resolved from another tab, or the list reloaded underneath. The caller
  /// substitutes an empty id rather than throwing: the listing is carried for
  /// convenience so the UI can move on to it, and losing that would not
  /// justify failing a resolution the server already committed.
  String? _listingIdFor(String reportId) {
    final state = ref.read(adminReportsProvider).value;
    if (state == null) return null;

    for (final entry in state.entries) {
      if (entry.id == reportId) return entry.listing.id;
    }
    return null;
  }
}
