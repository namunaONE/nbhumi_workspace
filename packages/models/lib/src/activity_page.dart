import 'package:freezed_annotation/freezed_annotation.dart';

import 'kyc_document.dart';
import 'listing_reveal_stat.dart';
import 'listing_summary.dart';
import 'my_reveal.dart';
import 'notification.dart';

part 'activity_page.freezed.dart';
part 'activity_page.g.dart';

/// Everything the Activity page renders, assembled server-side by row
/// ownership and client-side into one object.
///
/// Read-only by construction: every list comes from an owner-scoped read
/// (own listings, own reveals, own KYC docs, own inbox) or the aggregate
/// `v1_my_listing_reveals` RPC. Actions live in the screens each row links
/// to — this model carries no affordance to mutate anything.
///
/// An empty list in any slot is a successful answer (nothing there yet), not
/// an error: new accounts legitimately have no listings, reveals or docs.
@freezed
sealed class ActivityPage with _$ActivityPage {
  const factory ActivityPage({
    @Default(<ListingSummary>[]) List<ListingSummary> listings,
    @Default(<MyReveal>[]) List<MyReveal> reveals,
    @Default(<ListingRevealStat>[]) List<ListingRevealStat> revealStats,
    @Default(<KycDocument>[]) List<KycDocument> documents,
    @Default(<AppNotification>[]) List<AppNotification> updates,
  }) = _ActivityPage;

  factory ActivityPage.fromJson(Map<String, dynamic> json) =>
      _$ActivityPageFromJson(json);
}
