import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search/l10n/output/search_localizations.dart'
    as search_strings;

import '../providers/browse_providers.dart';
import 'listing_grid.dart';

/// Renders the browse feed in every state: loading, error, empty and loaded.
///
/// Home and Search share this so the states cannot drift apart. Everything
/// user-visible about an error lives here, which is what Rule 36 asks for: a
/// bilingual message and, when the failure is retryable, a retry action.
class BrowseFeed extends ConsumerWidget {
  /// Creates a browse feed.
  const BrowseFeed({
    this.onListingTap,
    this.header,
    this.layout = ListingLayout.grid,
    this.emptyTitle = 'No listings found',
    this.emptyBody =
        'Try widening your search or clearing some filters.',
    super.key,
  });

  /// Called with the id of a tapped listing.
  final void Function(String id)? onListingTap;

  /// Pinned above the grid, e.g. the search field on Search.
  final Widget? header;

  /// Grid or list presentation, forwarded to [ListingGrid].
  final ListingLayout layout;

  /// Title for the empty state.
  final String emptyTitle;

  /// Body copy for the empty state.
  final String emptyBody;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browse = ref.watch(browseProvider);

    return switch (browse) {
      // Rule 19: sealed pattern matching, never .when with null checks.
      // The bindings are typed explicitly; without them the compiler infers
      // `dynamic` from the sealed hierarchy and every field access below is
      // unchecked.
      AsyncLoading() => const LoadingState(),
      // Normally unreachable: `Browse` catches every AppException and
      // returns it as state. Reached only when something that is not an
      // AppException escapes the repository, which is worth showing
      // rather than crashing on.
      AsyncError(:final error) => _ErrorState(error: _asAppException(error)),
      AsyncData(:final BrowseState value) => _FeedBody(
          state: value,
          emptyTitle: emptyTitle,
          emptyBody: emptyBody,
          onListingTap: onListingTap,
          header: header,
          layout: layout,
        ),
    };
  }

  /// A provider failure should already be an [AppException]: repositories map
  /// before they throw. Anything else is a programming error escaping that
  /// mapping, and is reported as such rather than mislabelled a server fault.
  static AppException _asAppException(Object error) {
    if (error is AppException) return error;
    return ValidationException(
      code: 'provider.unmappedError',
      messageEn: 'Something went wrong. Please try again.',
      messageNe: 'केही गडबड भयो। कृपया पुनः प्रयास गर्नुहोस्।',
      cause: error,
    );
  }
}

class _FeedBody extends ConsumerWidget {
  const _FeedBody({
    required this.state,
    required this.emptyTitle,
    required this.emptyBody,
    this.onListingTap,
    this.header,
    this.layout = ListingLayout.grid,
  });

  final BrowseState state;
  final void Function(String id)? onListingTap;
  final Widget? header;
  final String emptyTitle;
  final String emptyBody;
  final ListingLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(browseProvider.notifier);

    // Checked before `isEmpty`, and it has to be: `Browse.build` converts a
    // repository failure into state rather than throwing it, so a failed first
    // load arrives here as AsyncData with an error and no rows. Testing
    // `isEmpty` first would fall through to an empty grid and show the user
    // nothing at all.
    if (state.loadError case final error? when state.listings.isEmpty) {
      return _ErrorState(error: error);
    }

    if (state.isEmpty) {
      return EmptyState(title: emptyTitle, body: emptyBody);
    }

    final grid = ListingGrid(
      listings: state.listings,
      hasMore: state.hasMore,
      isLoadingMore: state.isLoadingMore,
      layout: layout,
      onLoadMore: notifier.loadMore,
      onRefresh: notifier.retry,
      onListingTap: onListingTap,
    );

    // A page-three failure must not blank the forty rows already on screen, so
    // the error appears beneath them with a retry rather than replacing them.
    if (state.loadError != null) {
      return Column(
        children: <Widget>[
          Expanded(child: grid),
          _InlineErrorBar(
            error: state.loadError!,
            onRetry: notifier.retry,
          ),
        ],
      );
    }

    if (header == null) return grid;

    return Column(
      children: <Widget>[
        header!,
        Expanded(child: grid),
      ],
    );
  }
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.error});

  final AppException error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = search_strings.AppLocalizations.of(context);
    return EmptyState(
      title: error.localizedForContext(context),
      body: error.isRetryable ? strings.feedRetryHint : strings.feedLaterHint,
      icon: error is AuthFailureException
          ? Icons.lock_outline
          : Icons.error_outline,
      actionLabel: error.isRetryable ? strings.tryAgain : null,
      onAction: error.isRetryable
          ? () => ref.read(browseProvider.notifier).retry()
          : null,
    );
  }
}

/// Error bar shown beneath rows that are already loaded.
class _InlineErrorBar extends StatelessWidget {
  const _InlineErrorBar({required this.error, required this.onRetry});

  final AppException error;
  final FutureOr<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.errorContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  error.localizedForContext(context),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
