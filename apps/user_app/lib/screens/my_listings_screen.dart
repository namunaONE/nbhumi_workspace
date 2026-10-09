import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/l10n/output/app_localizations.dart';

/// The seller's own listings, newest first.
///
/// Mirrors SavedScreen's guest contract: a signed-out visitor sees a
/// sign-in prompt rather than an empty shelf, since an empty list would read
/// as "you posted nothing" to someone never given the chance. The `/post`
/// route enforces the auth gate; this screen only surfaces the entry points.
class MyListingsScreen extends ConsumerWidget {
  /// Creates the my-listings screen.
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final strings = AppLocalizations.of(context);
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.mineTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.home_work_outlined, size: 48),
                const SizedBox(height: 16),
                Text(strings.mineGuestPrompt),
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
      appBar: AppBar(title: Text(strings.mineTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myListingsProvider);
        },
        child: const _MineList(),
      ),
    );
  }
}

/// Signed-in seller shelf driven by [myListingsProvider].
class _MineList extends ConsumerWidget {
  const _MineList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myListingsProvider);

    return switch (mine) {
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      AsyncError(:final error) => _MineError(
          error: error,
          onRetry: () => ref.invalidate(myListingsProvider),
        ),
      AsyncData(:final value) when value.isEmpty => ListView(
          padding: const EdgeInsets.all(32),
          children: <Widget>[
            const Icon(Icons.home_work_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).mineEmptyTitle,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).mineEmptyBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.push('/post'),
              child:
                  Text(AppLocalizations.of(context).profilePostTitle),
            ),
          ],
        ),
      AsyncData(:final value) => ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: value.length,
          itemBuilder: (context, index) {
            final listing = value[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: HorizontalListingCard(
                listing: listing,
                onTap: () => context.push('/listing/${listing.id}'),
              ),
            );
          },
        ),
    };
  }
}

/// Failure loading the shelf, with a retry for recoverable errors.
class _MineError extends StatelessWidget {
  const _MineError({required this.error, required this.onRetry});

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
                  'Could not load your listings.',
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
