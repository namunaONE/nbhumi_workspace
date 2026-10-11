import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
import 'package:models/models.dart';

import '../providers/listing_detail_providers.dart';
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
    // The tab title follows the loaded listing so shared links name the tab
    // after the property. Same provider the pane watches, so no second
    // fetch. Only the full route does this — the side-pane variant must
    // never retitle the tab it sits in.
    final detail = ref.watch(listingDetailViewProvider(listingId));
    final strings = detail_strings.AppLocalizations.of(context);
    final title = switch (detail) {
      AsyncData(:final ListingDetail? value) =>
        value?.title ?? strings.detailPageTitle,
      _ => strings.detailPageTitle,
    };

    // States and favorite wiring live in the shared pane so the full route
    // and the wide-layout side pane cannot drift apart.
    return PageTitle(
      title: title,
      child: Scaffold(body: ListingDetailPane(listingId: listingId)),
    );
  }
}
