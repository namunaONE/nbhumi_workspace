import 'package:freezed_annotation/freezed_annotation.dart';

import 'profile.dart';

part 'admin_user.freezed.dart';
part 'admin_user.g.dart';

/// One account as an admin sees it (HYA-262).
///
/// Mirrors `v1_admin_get_user`. It is not a [Profile]: a profile is what a
/// user says about themselves, this is what moderation needs -- suspension
/// state, per-status listing counts, and how many open reports name this
/// seller. Carries `email` and `phone` deliberately: an admin suspending an
/// account must be sure it is the right one, and contact details never reach
/// this model through any buyer-facing path.
///
/// [listings] maps status wire names to counts (`{'live': 3}`), exactly as the
/// RPC's `json_object_agg` builds it. A status with no rows is absent rather
/// than 0, so readers must default -- see [AdminUserX.listingsIn].
@freezed
sealed class AdminUser with _$AdminUser {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AdminUser({
    required String id,
    required String email,
    required String fullName,
    String? phone,
    @Default(UserRole.buyer) UserRole role,
    @Default(false) bool isVerified,
    @Default(KycTier.none) KycTier kycTier,
    DateTime? suspendedAt,
    String? suspendedReason,
    @Default(false) bool suspended,
    DateTime? createdAt,
    @Default(<String, int>{}) Map<String, int> listings,
    @Default(0) int openReportsAgainst,
  }) = _AdminUser;

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);
}

/// Derived, non-wire facts about an [AdminUser].
extension AdminUserX on AdminUser {
  /// How many of this seller's listings sit in [statusWireName].
  ///
  /// 0 for a status with no rows, because the RPC omits empty buckets rather
  /// than sending them as 0 (same shape as `QueueCounts.fromJson`).
  int listingsIn(String statusWireName) => listings[statusWireName] ?? 0;

  /// Total listings across every status.
  int get totalListings => listings.values.fold(0, (a, b) => a + b);
}
