import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Parsing tests for the HYA-262 moderation models.
///
/// Payload shapes are those `v1_admin_get_user` actually returns, captured
/// from the live database after the HYA-262 migrations were applied. A change
/// to the SQL that breaks parsing fails here rather than in the panel.
void main() {
  group('ListingStatus.unpublished', () {
    test('round-trips through the wire name', () {
      expect(ListingStatus.fromWire('unpublished'), ListingStatus.unpublished);
      expect(ListingStatus.unpublished.wireName, 'unpublished');
    });

    test('is distinct from rejected', () {
      // The whole point of the fifth value: reusing `rejected` would tell a
      // seller their live listing failed review.
      expect(ListingStatus.unpublished, isNot(ListingStatus.rejected));
    });
  });

  group('QueueCounts', () {
    test('reads an unpublished count when present', () {
      final counts = QueueCounts.fromJson(<String, dynamic>{
        'pending_review': 2,
        'unpublished': 1,
      });

      expect(counts.unpublished, 1);
      expect(counts.rejected, 0);
    });

    test('defaults unpublished to 0 when absent', () {
      // Responses captured before HYA-262 have no such key.
      final counts = QueueCounts.fromJson(<String, dynamic>{'live': 5});

      expect(counts.unpublished, 0);
    });

    test('forStatus answers 0 for statuses with no tab', () {
      const counts = QueueCounts(pendingReview: 3, unpublished: 2);

      expect(counts.forStatus(ListingStatus.unpublished), 0);
      expect(counts.forStatus(ListingStatus.draft), 0);
      expect(counts.forStatus(ListingStatus.pendingReview), 3);
    });
  });

  group('AdminUser.fromJson', () {
    test('parses the verified wire shape', () {
      final user = AdminUser.fromJson(<String, dynamic>{
        'id': 'u1',
        'email': 'seller@example.com',
        'full_name': 'Ram Seller',
        'phone': '9841111111',
        'role': 'agent',
        'is_verified': false,
        'kyc_tier': 'none',
        'suspended_at': '2026-10-08T04:18:19+00:00',
        'suspended_reason': 'Fake listings',
        'suspended': true,
        'created_at': '2026-10-05T08:11:20+00:00',
        'listings': <String, dynamic>{'live': 2, 'pending_review': 1},
        'open_reports_against': 1,
      });

      expect(user.id, 'u1');
      expect(user.role, UserRole.agent);
      expect(user.suspended, isTrue);
      expect(user.suspendedReason, 'Fake listings');
      expect(user.suspendedAt, DateTime.utc(2026, 10, 8, 4, 18, 19));
      expect(user.listingsIn('live'), 2);
      expect(user.totalListings, 3);
      expect(user.openReportsAgainst, 1);
    });

    test('a missing listings map reads as no listings', () {
      // `json_object_agg` over zero rows yields '{}', but a hand-built or
      // older response may omit the key; either way the admin sees zeroes,
      // not a crash.
      final user = AdminUser.fromJson(<String, dynamic>{
        'id': 'u1',
        'email': 'seller@example.com',
        'full_name': 'Ram Seller',
        'suspended': false,
      });

      expect(user.listingsIn('live'), 0);
      expect(user.totalListings, 0);
      expect(user.openReportsAgainst, 0);
      expect(user.suspendedAt, isNull);
    });

    test('round-trips', () {
      final user = AdminUser.fromJson(<String, dynamic>{
        'id': 'u1',
        'email': 'seller@example.com',
        'full_name': 'Ram Seller',
        'suspended': false,
        'listings': <String, dynamic>{'live': 1},
        'open_reports_against': 0,
      });

      expect(AdminUser.fromJson(user.toJson()), user);
    });
  });
}
