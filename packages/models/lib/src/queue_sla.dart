/// How a queued listing stands against the 48-hour review SLA.
///
/// DATA.md sets the SLA; HYA-260 requires the queue to show "queue age shown vs
/// 48h SLA". The thresholds live here rather than in SQL, and that placement is
/// the whole point of this type:
///
/// * **One definition.** A threshold written in both Postgres and Dart drifts,
///   and the admin ends up seeing a different number from the one the tests
///   asserts.
/// * **Testable without a database.** Rule 31 forbids a live Supabase in the
///   unit test loop, so a bucket boundary could not be tested if it were
///   computed server-side. Rule 32 demands exhaustive testing of converters,
///   the same standard applies to time arithmetic.
/// * **Honest about clocks.** The submission time comes from the database clock
///   and the comparison is against the caller's. Returning a precomputed
///   from SQL would hide any disagreement between the two; comparing here makes
///   a skew visible instead of papering over it.
///
/// The boundaries are deliberately unequal. A listing at 40 hours is still
/// inside the SLA but is close enough that an admin working through a queue
/// should see it before it becomes a breach, so [atRisk] starts well before
/// 48h. A single threshold would have to be either too late to be useful or too
/// eager to be calm.
enum QueueSla {
  /// Comfortably inside the SLA.
  fresh,

  /// Past [QueueSlaThresholds.atRiskAfter] but inside
  /// [QueueSlaThresholds.breachAfter].
  atRisk,

  /// Past [QueueSlaThresholds.breachAfter]. The SLA is missed.
  breached;

  /// This bucket, given how long ago [submittedAt] was relative to [now].
  ///
  /// A null [submittedAt] is [fresh] rather than a breach. It means the listing
  /// has no submission clock running, which is the correct state for a draft,
  /// and treating "unknown" as "overdue" would flag rows that were never
  /// actually late.
  ///
  /// A [submittedAt] in the future — a database clock ahead of the device, or a
  /// fixture — also reads [fresh], for the same reason.
  static QueueSla fromSubmittedAt(
    DateTime? submittedAt, {
    DateTime? now,
  }) {
    if (submittedAt == null) return QueueSla.fresh;

    final reference = (now ?? DateTime.now()).toUtc();
    final waited = reference.difference(submittedAt.toUtc());

    // Not an explicit isNegative check: a future timestamp yields a negative
    // duration, which is shorter than every threshold and so lands on fresh on
    // its own. Stated rather than coded because the reason is not obvious.
    if (waited >= QueueSlaThresholds.breachAfter) return QueueSla.breached;
    if (waited >= QueueSlaThresholds.atRiskAfter) return QueueSla.atRisk;
    return QueueSla.fresh;
  }
}

/// The durations [QueueSla] measures against.
///
/// Named rather than inlined so a test, a designer and this file cannot clash
/// about where the line sits, and so changing the policy is a one-line edit in
/// one place.
abstract final class QueueSlaThresholds {
  /// How long a listing may sit in the queue before it counts as breached.
  ///
  /// 48 hours, from DATA.md's review SLA.
  static const Duration breachAfter = Duration(hours: 48);

  /// How long before [breachAfter] a listing is flagged as at risk.
  ///
  /// 12 hours of runway. Long enough to be actionable for a solo admin working
  /// through the queue over a couple of days, short enough that the flag is
  /// still news rather than noise. Deliberately not half the SLA: at 24 hours a
  /// listing would be flagged the moment a weekend started.
  static const Duration atRiskAfter = Duration(hours: 36);
}
