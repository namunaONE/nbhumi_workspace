import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';
import 'package:search/l10n/output/search_localizations.dart'
    as search_strings;

import '../providers/browse_providers.dart';

/// Swipe-through featured row for the newest listings.
///
/// Reads the same shared browse session as the feed below, so no second
/// request fires: the first page's rows are reused as horizontal cards with
/// a peek of the next one. Hidden while the feed is loading, failed, or
/// empty, so surrounding states cannot contradict each other.
///
/// Shown only for the unfiltered browse-all surface (Explore without an
/// active filter): a featured row above narrowed results would push the
/// matches the user asked for down the screen.
class FeaturedCarousel extends ConsumerStatefulWidget {
  /// Creates the featured carousel.
  const FeaturedCarousel({required this.onListingTap, super.key});

  /// Called with the id of a tapped listing.
  final void Function(String id) onListingTap;

  @override
  ConsumerState<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends ConsumerState<FeaturedCarousel> {
  late final PageController _pages = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = search_strings.AppLocalizations.of(context);
    final browse = ref.watch(browseProvider);
    final listings = switch (browse) {
      AsyncData(:final BrowseState value) => value.listings.take(5).toList(),
      _ => const <ListingSummary>[],
    };
    if (listings.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(title: strings.featuredTitle),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          // Page bottom inset removed: the grid below carries its own top
          // padding, so any inset here would double the section gap.
          height: AppSizes.horizontalCardHeight,
          child: PageView.builder(
            controller: _pages,
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              // Wide screens would otherwise stretch a 0.9-viewport page
              // across the whole feed: cap the card and let the next one
              // peek through the remaining space.
              return Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? AppSpacing.lg : 0,
                      right: AppSpacing.sm,
                    ),
                    child: HorizontalListingCard(
                      listing: listing,
                      onTap: () => widget.onListingTap(listing.id),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
