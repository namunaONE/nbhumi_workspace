import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';

import '../providers/listing_detail_providers.dart';
import 'listing_detail_body.dart';

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
    final detail = ref.watch(listingDetailViewProvider(listingId));

    return Scaffold(
      body: switch (detail) {
        // Rule 19: sealed pattern matching on AsyncValue. Bindings are typed
        // explicitly, otherwise the compiler infers dynamic from the hierarchy.
        AsyncLoading() => const _Loading(),
        AsyncError(:final error) => _LoadError(
            listingId: listingId,
            message: AppException.unmapped(error).localizedForContext(context),
          ),
        // A null value is a *successful* load with nothing in it, not a
        // failure. The RPC answers P0002 for missing, unpublished and
        // not-yours alike, so this screen cannot tell those apart and must
        // not pretend to.
        AsyncData(value: null) => const _NotAvailable(),
        AsyncData(: final ListingDetail value) =>
          ListingDetailBody(listing: value),
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _NotAvailable extends StatelessWidget {
  const _NotAvailable();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.search_off,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'This property is no longer available',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'It may have been sold, withdrawn by the seller, or the link '
                'may be wrong.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Browse other properties'),
              ),
            ],
          ),
        ),
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
    final isNepali = Localizations.maybeLocaleOf(context)?.languageCode != 'en';

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ref
                    .read(listingDetailViewProvider(listingId).notifier)
                    .retry(),
                child: const Text('Try again'),
              ),
              const SizedBox(height: 8),
              Text(
                isNepali
                    ? 'इन्टरनेट जडान जाँच गर्नुहोस्।'
                    : 'Check your connection and try again.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
