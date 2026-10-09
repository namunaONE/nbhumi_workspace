import 'dart:async';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listing_detail/listing_detail.dart';
import 'package:models/models.dart';
import 'package:search/search.dart' show browseFilterProvider;
import 'package:user_app/l10n/output/app_localizations.dart';
import 'package:user_app/shell/app_shell.dart';

/// Saved listings.
///
/// The buyer's bookmarks (HYA-268 C1), newest first. Guests see a sign-in
/// prompt rather than an empty shelf: an empty list would read as "you saved
/// nothing" to someone who was never given the chance to save.
class SavedScreen extends ConsumerStatefulWidget {
  /// Creates the saved listings screen.
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  /// Listing shown in the side pane on wide windows. Null keeps the
  /// single-pane shelf; the pane's close button clears it.
  String? _selectedId;

  /// Opens a listing in place on wide windows, or pushes the route.
  void _openListing(String id) {
    if (MediaQuery.sizeOf(context).width >= AppBreakpoints.twoPane) {
      setState(() => _selectedId = id);
    } else {
      unawaited(context.push('/listing/$id'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final strings = AppLocalizations.of(context);
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.savedTitle)),
        body: EmptyState(
          title: strings.savedGuestPrompt,
          body: strings.savedEmptyBody,
          icon: Icons.favorite_outline,
          actionLabel: strings.commonSignIn,
          onAction: () => context.push('/login'),
        ),
      );
    }

    final selectedId = _selectedId;
    final shelf = RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(savedListingsProvider)
          ..invalidate(savedSearchesProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          _ShelfSection(onListingTap: _openListing),
          const SizedBox(height: AppSpacing.sm),
          const _SearchesSection(),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(strings.savedTitle)),
      body: selectedId != null &&
              MediaQuery.sizeOf(context).width >= AppBreakpoints.twoPane
          ? Row(
              children: <Widget>[
                Expanded(child: shelf),
                const VerticalDivider(width: 1),
                Expanded(
                  child: ListingDetailPane(
                    listingId: selectedId,
                    leading: CloseButton(
                      onPressed: () => setState(() => _selectedId = null),
                    ),
                  ),
                ),
              ],
            )
          : shelf,
    );
  }
}

/// Bookmarked listings, newest first.
class _ShelfSection extends ConsumerWidget {
  /// Creates the shelf section.
  const _ShelfSection({required this.onListingTap});

  /// Called with the id of a tapped listing.
  final void Function(String id) onListingTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedListingsProvider);

    return switch (saved) {
      AsyncLoading() => const LoadingState(),
      AsyncError(:final error) => ErrorState(
          message: error is AppException
              ? error.localizedForContext(context)
              : 'Could not load your saved list.',
          retryLabel: AppLocalizations.of(context).commonRetry,
          onRetry: () => ref.invalidate(savedListingsProvider),
        ),
      AsyncData(:final value) when value.isEmpty => EmptyState(
          title: AppLocalizations.of(context).savedEmptyTitle,
          body: AppLocalizations.of(context).savedEmptyBody,
          icon: Icons.favorite_outline,
          actionLabel: AppLocalizations.of(context).onboardingBrowse,
          onAction: () => context.go('/'),
        ),
      AsyncData(:final value) => Column(
          children: <Widget>[
            for (final listing in value)
              _SavedCard(listing: listing, onListingTap: onListingTap),
          ],
        ),
    };
  }
}

/// Stored searches with one-tap re-run and delete.
///
/// Tapping a row installs its filter into the browse state and jumps to
/// Explore, so the buyer sees today's matches, not the day's they saved.
class _SearchesSection extends ConsumerWidget {
  const _SearchesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searches = ref.watch(savedSearchesProvider);

    return switch (searches) {
      AsyncLoading() => const SizedBox.shrink(),
      // A failed searches read must not take down the shelf above it: the
      // two sections fail independently, and the shelf is the primary one.
      AsyncError() => const SizedBox.shrink(),
      AsyncData(:final value) when value.isEmpty => const SizedBox.shrink(),
      AsyncData(:final value) => Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Text(
                  AppLocalizations.of(context).savedSearchesTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              for (final search in value)
                ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: Text(search.name),
                  onTap: () {
                    ref.read(browseFilterProvider.notifier).filter =
                        search.toFilter();
                    context.go('/');
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: AppLocalizations.of(context).savedSearchDelete,
                    onPressed: () => _delete(context, ref, search.id),
                  ),
                ),
            ],
          ),
        ),
    };
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    String searchId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(savedSearchRepositoryProvider).deleteSearch(searchId);
      ref.invalidate(savedSearchesProvider);
    } on AppException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.localizedForContext(context))),
      );
    }
  }
}

/// One saved listing. Tapping opens the detail page.
///
/// Horizontal rows: the shelf is a single-column list, so dense rows scan
/// faster than full grid cards stacked end to end.
class _SavedCard extends ConsumerWidget {
  /// Creates a saved row.
  const _SavedCard({required this.listing, required this.onListingTap});

  /// The listing to render.
  final ListingSummary listing;

  /// Called with the tapped listing id.
  final void Function(String id) onListingTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: HorizontalListingCard(
          listing: listing,
          onTap: () => onListingTap(listing.id),
        ),
      );
}
