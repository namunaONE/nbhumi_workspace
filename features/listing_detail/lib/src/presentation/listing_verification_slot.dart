import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listing_detail/l10n/output/detail_localizations.dart'
    as detail_strings;
import 'package:models/models.dart';

/// Tier-3 verification slot for the detail chips row (HYA-265).
///
/// Three states, all honest about what verification is:
/// * verified listing (any viewer, guests included) — the green badge.
///   Tapping explains the doc-check boundary, never legal/title language.
/// * owning seller on an unverified listing — an outlined entry into the
///   Tier-3 submit flow (`/kyc?listingId=`).
/// * everyone else — nothing. Guests and other buyers hold no documents
///   for this listing, so offering the flow would only ever error.
///
/// Provider reads live here (not in the body) so provider-free body tests
/// keep passing nothing.
class ListingVerificationSlot extends ConsumerWidget {
  /// Creates the slot for [listing].
  const ListingVerificationSlot({required this.listing, super.key});

  /// The listing to verify or badge.
  final ListingDetail listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final verification =
        ref.watch(listingVerificationProvider(listingId: listing.id));

    final verified = switch (verification) {
      AsyncData(:final value) => value.verified,
      _ => false,
    };
    if (verified) return const _VerifiedListingBadge();
    if (session?.user.id == listing.sellerId) {
      final strings = detail_strings.AppLocalizations.of(context);
      return OutlinedButton.icon(
        icon: const Icon(Icons.verified_outlined, size: 18),
        label: Text(strings.verifyThisListing),
        onPressed: () => context.push('/kyc?listingId=${listing.id}'),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Tier-3 "Verified Listing" badge with its honesty dialog.
///
/// The badge means an admin doc-checked the lalpurja / Tiro Rasid bound to
/// this listing — never a legal opinion on ownership or title, and the
/// dialog states that where the badge is used (HYA-265 copy rule). Green
/// comes from the `verifiedGreen` token in both schemes.
class _VerifiedListingBadge extends StatelessWidget {
  /// Creates the badge.
  const _VerifiedListingBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        theme.extension<MarketplaceColors>()?.verifiedGreen ??
            theme.colorScheme.primary;
    final strings = detail_strings.AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.verified, size: 40, color: foreground),
          title: Text(strings.verifiedListing),
          content: Text(strings.verifiedListingBody),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.verifiedListingUnderstood),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: foreground.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.verified, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Text(
              strings.verifiedListing,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
