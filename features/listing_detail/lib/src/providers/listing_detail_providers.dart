import 'package:data/data.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'listing_detail_providers.g.dart';

/// One listing, by id.
///
/// A family rather than a plain provider so the detail page and any future
/// "similar listings" rail can read different ids without one clobbering the
/// other, and so navigating between two listings does not reuse the first
/// response.
///
/// Retry is left at the default here, unlike the browse feed: a detail page is
/// a deliberate, one-shot navigation, and the user is waiting on a single
/// request rather than scrolling a list. A transient blip is worth one silent
/// retry; a hard failure surfaces on the error state.
@riverpod
class ListingDetailView extends _$ListingDetailView {
  @override
  Future<ListingDetail?> build(String listingId) {
    return ref.watch(listingRepositoryProvider).getListingById(listingId);
  }

  /// Refetches the listing.
  void retry() => ref.invalidateSelf();
}
