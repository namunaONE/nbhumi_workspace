import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Boundary tests for the 48h review SLA.
///
/// Rule 32 demands exhaustive testing of converters and their boundaries.
/// The SLA is the one piece of arithmetic in the verification queue, and it
/// decides what an admin looks at first, so the boundaries are pinned here
/// whatever `>=` happens to do.
void main() {
  // A fixed reference point. Every case below is an offset from this, so a test
  // never depends on the wall clock and cannot start failing on a slow Friday.
  final now = DateTime.utc(2026, 10, 5, 12);

  DateTime ago(Duration d) => now.subtract(d);

  group('QueueSlaThresholds', () {
    test('the breach threshold is the 48h SLA from DATA.md', () {
      expect(QueueSlaThresholds.breachAfter, const Duration(hours: 48));
    });

    test('at-risk starts before the breach, not after', () {
      // If atRisk were at or after breachAfter the bucket would be unreachable:
      // anything long enough to be at risk would already read breached.
      expect(
        QueueSlaThresholds.atRiskAfter,
        lessThan(QueueSlaThresholds.breachAfter),
      );
    });

    test('at-risk leaves real runway before the breach', () {
      expect(
        QueueSlaThresholds.breachAfter - QueueSlaThresholds.atRiskAfter,
        const Duration(hours: 12),
      );
    });
  });

  group('QueueSla.fromSubmittedAt', () {
    test('a listing submitted moments ago is fresh', () {
      expect(
        QueueSla.fromSubmittedAt(ago(const Duration(minutes: 5)), now: now),
        QueueSla.fresh,
      );
    });

    test('exactly at the at-risk threshold is at risk, not fresh', () {
      // The boundary belongs to the later bucket: an admin who sees "at risk"
      // has 12 hours of runway, and the flag should appear the moment that
      // runway starts rather than a second later.
      expect(
        QueueSla.fromSubmittedAt(
          ago(QueueSlaThresholds.atRiskAfter),
          now: now,
        ),
        QueueSla.atRisk,
      );
    });

    test('one second inside the at-risk threshold is still fresh', () {
      expect(
        QueueSla.fromSubmittedAt(
          ago(QueueSlaThresholds.atRiskAfter - const Duration(seconds: 1)),
          now: now,
        ),
        QueueSla.fresh,
      );
    });

    test('one second past the at-risk threshold is at risk', () {
      expect(
        QueueSla.fromSubmittedAt(
          ago(QueueSlaThresholds.atRiskAfter + const Duration(seconds: 1)),
          now: now,
        ),
        QueueSla.atRisk,
      );
    });

    test('exactly at the breach threshold is breached', () {
      expect(
        QueueSla.fromSubmittedAt(
          ago(QueueSlaThresholds.breachAfter),
          now: now,
        ),
        QueueSla.breached,
      );
    });

    test('one second inside the breach threshold is still at risk', () {
      expect(
        QueueSla.fromSubmittedAt(
          ago(QueueSlaThresholds.breachAfter - const Duration(seconds: 1)),
          now: now,
        ),
        QueueSla.atRisk,
      );
    });

    test('well past the breach threshold is still breached', () {
      expect(
        QueueSla.fromSubmittedAt(ago(const Duration(days: 30)), now: now),
        QueueSla.breached,
      );
    });

    test('a null submission time is fresh, not breached', () {
      // A draft has no clock running. Reading "unknown" as "overdue" would flag
      // rows that were never late, and would train an admin to ignore the flag.
      expect(QueueSla.fromSubmittedAt(null, now: now), QueueSla.fresh);
    });

    test('a future submission time is fresh, not breached', () {
      // A database clock ahead of the device, or a fixture. Neither is an SLA
      // breach and neither should be reported as one.
      expect(
        QueueSla.fromSubmittedAt(now.add(const Duration(hours: 5)), now: now),
        QueueSla.fresh,
      );
    });

    test('a wildly future submission time is fresh', () {
      expect(
        QueueSla.fromSubmittedAt(now.add(const Duration(days: 365)), now: now),
        QueueSla.fresh,
      );
    });

    test('comparison is in UTC regardless of the input offset', () {
      // Rule 29: store UTC, display local. A device in NPT hands back a local
      // DateTime, and a naive difference() against a UTC now() is wrong by
      // 5h45m, enough to move a listing across a bucket boundary.
      final localNow = DateTime.utc(2026, 10, 5, 12).toLocal();
      final localSubmitted = DateTime.utc(2026, 10, 3, 12).toLocal();

      expect(
        QueueSla.fromSubmittedAt(localSubmitted, now: localNow),
        QueueSla.breached,
      );
      expect(
        QueueSla.fromSubmittedAt(localSubmitted, now: localNow),
        QueueSla.fromSubmittedAt(
          DateTime.utc(2026, 10, 3, 12),
          now: DateTime.utc(2026, 10, 5, 12),
        ),
      );
    });

    test('defaults to the current time when no reference is supplied', () {
      final justNow = DateTime.now().toUtc().subtract(const Duration(hours: 2));

      expect(QueueSla.fromSubmittedAt(justNow), QueueSla.fresh);
    });
  });
}
