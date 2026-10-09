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
        body: EmptyState(
          title: strings.mineGuestPrompt,
          body: strings.mineEmptyBody,
          icon: Icons.home_work_outlined,
          actionLabel: strings.commonSignIn,
          onAction: () => context.push('/login'),
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
      AsyncLoading() => const LoadingState(),
      AsyncError(:final error) => ErrorState(
          message: error is AppException
              ? error.localizedForContext(context)
              : 'Could not load your listings.',
          retryLabel: AppLocalizations.of(context).commonRetry,
          onRetry: () => ref.invalidate(myListingsProvider),
        ),
      AsyncData(:final value) when value.isEmpty => EmptyState(
          title: AppLocalizations.of(context).mineEmptyTitle,
          body: AppLocalizations.of(context).mineEmptyBody,
          icon: Icons.home_work_outlined,
          actionLabel: AppLocalizations.of(context).profilePostTitle,
          onAction: () => context.push('/post'),
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
