import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
import 'package:models/models.dart';

import '../providers/listing_detail_providers.dart';
import 'listing_detail_body.dart';
import 'listing_verification_slot.dart';

/// Listing detail as an embeddable pane.
///
/// Owns the loading/error/unavailable/data states plus the favorite wiring,
/// so the full detail route and the wide-layout side pane share one
/// implementation instead of drifting apart.
///
/// Pass [leading] to replace the body app bar's automatic back button — the
/// side pane supplies a close button, since popping the tab route would be
/// wrong there.
class ListingDetailPane extends ConsumerWidget {
  /// Creates the detail pane for [listingId].
  const ListingDetailPane({required this.listingId, this.leading, super.key});

  /// The listing to show.
  final String listingId;

  /// App-bar leading widget for the loaded body. Null keeps the automatic
  /// back button used by the full route.
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(listingDetailViewProvider(listingId));

    return switch (detail) {
      // Rule 19: sealed pattern matching on AsyncValue. Bindings are typed
      // explicitly, otherwise the compiler infers dynamic from the hierarchy.
      AsyncLoading() => const _Loading(),
      AsyncError(:final error) => _LoadError(
          listingId: listingId,
          message: AppException.unmapped(error).localizedForContext(context),
        ),
      // A null value is a *successful* load with nothing in it, not a
      // failure. The RPC answers P0002 for missing, unpublished and
      // not-yours alike, so this pane cannot tell those apart and must
      // not pretend to.
      AsyncData(value: null) => const _NotAvailable(),
      AsyncData(:final ListingDetail value) => _FavoriteBody(
            listingId: listingId,
            listing: value,
            leading: leading,
          ),
    };
  }
}

/// Detail body with the favorite state attached.
///
/// Favorite state lives in `favoriteIdsProvider` (HYA-268 C1), not in the
/// `is_favorite` wire field. Guests get no heart: saving needs a session,
/// and a button that only ever errors is worse than none.
class _FavoriteBody extends ConsumerWidget {
  const _FavoriteBody({
    required this.listingId,
    required this.listing,
    this.leading,
  });

  final String listingId;
  final ListingDetail listing;
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = switch (ref.watch(favoriteIdsProvider)) {
      AsyncData(:final value) => value.contains(listingId),
      _ => false,
    };
    final session = ref.watch(sessionProvider);
    final strings = detail_strings.AppLocalizations.of(context);

    return ListingDetailBody(
      listing: listing,
      isFavorite: saved,
      leading: leading,
      verificationSlot: ListingVerificationSlot(listing: listing),
      onFavoriteToggle:
          session == null ? null : () => _toggle(context, ref, strings),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    detail_strings.AppLocalizations strings,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final userId = ref.read(sessionProvider)?.user.id;
    if (userId == null) return;

    try {
      final nowSaved = await ref
          .read(favoritesRepositoryProvider)
          .toggleFavorite(userId: userId, listingId: listingId);
      ref
        ..invalidate(favoriteIdsProvider)
        ..invalidate(savedListingsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            nowSaved ? strings.favoriteSaved : strings.favoriteRemoved,
          ),
        ),
      );
    } on AppException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.localizedForContext(context)),
          action: e.isRetryable
              ? SnackBarAction(
                  label: strings.tryAgain,
                  onPressed: () => _toggle(context, ref, strings),
                )
              : null,
        ),
      );
    }
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingState());
  }
}

class _NotAvailable extends StatelessWidget {
  const _NotAvailable();

  @override
  Widget build(BuildContext context) {
    final strings = detail_strings.AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        title: strings.notAvailableTitle,
        body: strings.notAvailableBody,
        actionLabel: strings.browseOthers,
        onAction: () => context.go('/'),
      ),
    );
  }
}

class _LoadError extends ConsumerWidget {
  const _LoadError({required this.listingId, required this.message});

  final String listingId;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = detail_strings.AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ErrorState(
              message: message,
              retryLabel: strings.tryAgain,
              onRetry: () => ref
                  .read(listingDetailViewProvider(listingId).notifier)
                  .retry(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              strings.loadRetryHint,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
