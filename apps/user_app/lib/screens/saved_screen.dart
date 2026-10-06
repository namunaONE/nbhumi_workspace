import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:search/search.dart' show browseFilterProvider;
import 'package:user_app/l10n/output/app_localizations.dart';

/// Saved listings.
///
/// The buyer's bookmarks (HYA-268 C1), newest first. Guests see a sign-in
/// prompt rather than an empty shelf: an empty list would read as "you saved
/// nothing" to someone who was never given the chance to save.
class SavedScreen extends ConsumerWidget {
  /// Creates the saved listings screen.
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final strings = AppLocalizations.of(context);
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.savedTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.favorite_outline, size: 48),
                const SizedBox(height: 16),
                Text(strings.savedGuestPrompt),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.push('/login'),
                  child: Text(strings.commonSignIn),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.savedTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(savedListingsProvider)
            ..invalidate(savedSearchesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: const <Widget>[
            _ShelfSection(),
            SizedBox(height: 8),
            _SearchesSection(),
          ],
        ),
      ),
    );
  }
}

/// Bookmarked listings, newest first.
class _ShelfSection extends ConsumerWidget {
  const _ShelfSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedListingsProvider);

    return switch (saved) {
      AsyncLoading() => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      AsyncError(:final error) => _SavedError(
          error: error,
          onRetry: () => ref.invalidate(savedListingsProvider),
        ),
      AsyncData(:final value) when value.isEmpty => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.favorite_outline, size: 40),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).savedEmptyTitle,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).savedEmptyBody,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      AsyncData(:final value) => Column(
          children: <Widget>[
            for (final listing in value) _SavedCard(listing: listing),
          ],
        ),
    };
  }
}

/// Stored searches with one-tap re-run and delete.
///
/// Tapping a row installs its filter into the browse state and jumps to the
/// Search tab, so the buyer sees today's matches, not the day's they saved.
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(AppLocalizations.of(context).savedSearchesTitle),
              ),
              for (final search in value)
                ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: Text(search.name),
                  onTap: () {
                    ref.read(browseFilterProvider.notifier).filter =
                        search.toFilter();
                    context.go('/search');
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
class _SavedCard extends ConsumerWidget {
  const _SavedCard({required this.listing});

  final ListingSummary listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ListingCard(
          listing: listing,
          onTap: () => context.push('/listing/${listing.id}'),
        ),
      );
}

/// Failure loading the shelf, with a retry for recoverable errors.
class _SavedError extends StatelessWidget {
  const _SavedError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = error is AppException ? error as AppException : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              failure?.localizedForContext(context) ??
                  'Could not load your saved list.',
            ),
            const SizedBox(height: 8),
            if (failure == null || failure.isRetryable)
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).commonRetry),
                onPressed: onRetry,
              ),
          ],
        ),
      ),
    );
  }
}
