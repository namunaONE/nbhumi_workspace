import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'listing_detail_pane.dart';

/// A single property, with photos, specifications and the seller card.
///
/// ### Public
///
/// Reachable without a session: guest browsing is the product's primary use
/// case and the RPC allows it for any `live` listing. The seller card
/// deliberately carries no phone or email — contact details are released only
/// through `v1_contact_seller`, which needs an authenticated buyer and is
/// rate-limited (HYA-252).
class ListingDetailScreen extends ConsumerWidget {
  /// Creates the detail screen for [listingId].
  const ListingDetailScreen({required this.listingId, super.key});

  /// The listing to show.
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // States and favorite wiring live in the shared pane so the full route
    // and the wide-layout side pane cannot drift apart.
    return Scaffold(body: ListingDetailPane(listingId: listingId));
  }
}
