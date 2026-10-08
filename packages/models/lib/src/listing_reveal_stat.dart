import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_reveal_stat.freezed.dart';
part 'listing_reveal_stat.g.dart';

/// Contact-reveal interest for one of the caller's own listings.
///
/// Returned by `v1_my_listing_reveals` (see migration
/// `20261008130000_activity_my_listing_reveals.sql`). Aggregates only:
/// reveal count plus the latest reveal timestamp. Carries no buyer identity
/// by design — the seller learns interest exists, not who viewed (Privacy Act
/// 2075 purpose limitation; buyer identities are a separate review).
@freezed
sealed class ListingRevealStat with _$ListingRevealStat {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ListingRevealStat({
    required String listingId,
    required String title,
    @Default(0) int revealCount,
    DateTime? lastRevealedAt,
  }) = _ListingRevealStat;

  factory ListingRevealStat.fromJson(Map<String, dynamic> json) =>
      _$ListingRevealStatFromJson(json);
}
