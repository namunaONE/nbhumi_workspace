import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kyc/l10n/output/kyc_localizations.dart' as kyc_strings;
import 'package:models/models.dart';
import 'package:user_app/l10n/output/app_localizations.dart';

/// Short local date for activity rows: `12 Oct 2026`.
///
/// UTC from the server, rendered in device-local time (Rule 29). No
/// relative-time helper: one more shared formatter is exactly the sideways
/// abstraction Rule 47 forbids until a third use appears.
String activityDate(BuildContext context, DateTime? instant) {
  if (instant == null) return '';
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(locale).format(instant.toLocal());
}

/// Localized listing-status label for the Activity page.
///
/// Statuses have no shared label source (search/post ARBs carry none), so
/// the five live here beside their only use.
String activityStatusLabel(AppLocalizations strings, ListingStatus status) =>
    switch (status) {
      ListingStatus.draft => strings.activityStatusDraft,
      ListingStatus.pendingReview => strings.activityStatusPending,
      ListingStatus.live => strings.activityStatusLive,
      ListingStatus.rejected => strings.activityStatusRejected,
      ListingStatus.unpublished => strings.activityStatusUnpublished,
    };

/// One of the caller's own listings: status chip, title, price and location.
///
/// Taps into `/listing/:id`. Drafts and rejected rows render the same tile
/// the public feed never shows them in — that is the point of this list.
class ActivityListingRow extends StatelessWidget {
  /// Creates the row.
  const ActivityListingRow({required this.listing, super.key});

  /// The listing to render.
  final ListingSummary listing;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListTile(
      leading: Icon(
        listing.status == ListingStatus.live
            ? Icons.home_work_outlined
            : Icons.edit_note_outlined,
      ),
      title: Text(listing.title),
      subtitle: Text(
        '${NepaliCurrency.compact(listing.priceNpr)} · '
        '${listing.district}, ${listing.city}',
      ),
      trailing: Chip(
        label: Text(activityStatusLabel(strings, listing.status)),
        visualDensity: VisualDensity.compact,
      ),
      onTap: () => context.push('/listing/${listing.id}'),
    );
  }
}

/// Interest in one own listing: view count and latest view.
///
/// Aggregates only — no buyer identity, by migration design. Taps into the
/// listing itself; there is no per-viewer drill-down to link to.
class ActivityStatRow extends StatelessWidget {
  /// Creates the row.
  const ActivityStatRow({required this.stat, super.key});

  /// The stat to render.
  final ListingRevealStat stat;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListTile(
      leading: const Icon(Icons.visibility_outlined),
      title: Text(stat.title),
      subtitle: Text(
        '${strings.activityViews(stat.revealCount)} · '
        '${strings.activityLastViewed(
          activityDate(context, stat.lastRevealedAt),
        )}',
        style: theme.textTheme.bodySmall,
      ),
      onTap: () => context.push('/listing/${stat.listingId}'),
    );
  }
}

/// One contact the caller revealed: listing, date and validity.
///
/// Carries no phone or email: the row proves access history, and a fresh
/// `v1_contact_seller` call re-releases the number while valid.
class ActivityRevealRow extends StatelessWidget {
  /// Creates the row.
  const ActivityRevealRow({required this.reveal, super.key});

  /// The reveal to render.
  final MyReveal reveal;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final valid = reveal.isValidAt(DateTime.now());
    return ListTile(
      leading: const Icon(Icons.phone_outlined),
      title: Text(
        (reveal.listingTitle ?? '').trim().isEmpty
            ? strings.activityUnknownListing
            : reveal.listingTitle!,
      ),
      subtitle: Text(
        valid
            ? strings.activityValidUntil(
                activityDate(context, reveal.expiresAt),
              )
            : strings.activityExpired,
      ),
      trailing: Icon(
        valid ? Icons.check_circle_outline : Icons.history_outlined,
        color: valid ? null : Theme.of(context).colorScheme.outline,
      ),
      onTap: () => context.push('/listing/${reveal.listingId}'),
    );
  }
}

/// One KYC document: type label plus review status.
///
/// Labels come from the KYC feature's own localizations (apps may import
/// features, Rule 10 direction) so two sources can never disagree on what
/// a `citizenship` row is called.
class ActivityDocRow extends StatelessWidget {
  /// Creates the row.
  const ActivityDocRow({required this.document, super.key});

  /// The document to render.
  final KycDocument document;

  @override
  Widget build(BuildContext context) {
    final kyc = kyc_strings.AppLocalizations.of(context);
    final label = switch (document.docType) {
      KycDocType.citizenship => kyc.docCitizenship,
      // Tiro Rasid folded into lalpurja; the enum member is gone, so the
      // arm goes with it (ports the sibling fold fix to unbreak the build).
      KycDocType.lalpurja => kyc.docLalpurja,
      KycDocType.agencyReg => kyc.docAgencyReg,
    };
    final status = switch (document.status) {
      KycDocStatus.pending => kyc.statusPending,
      KycDocStatus.verified => kyc.statusVerified,
      KycDocStatus.rejected => kyc.statusRejected,
    };
    return ListTile(
      leading: const Icon(Icons.verified_user_outlined),
      title: Text(label),
      subtitle: Text(status),
      trailing: document.status == KycDocStatus.verified
          ? const TrustBadge(compact: true, showInfoOnTap: false)
          : null,
      onTap: () => context.push('/kyc'),
    );
  }
}

/// One inbox update: localized message, date and unread marker.
///
/// Message picking mirrors the notifications screen (`messageNe` unless the
/// locale is English): second occurrence, so still inline per Rule 47.
/// Read-only here: marking read lives in the notifications screen, which
/// this row links to.
class ActivityUpdateRow extends StatelessWidget {
  /// Creates the row.
  const ActivityUpdateRow({required this.update, super.key});

  /// The notification to render.
  final AppNotification update;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.maybeLocaleOf(context);
    final message = (locale?.languageCode ?? 'ne') != 'en'
        ? update.messageNe
        : update.message;
    return ListTile(
      leading: Icon(
        Icons.circle,
        size: AppSpacing.sm,
        color: update.isRead
            ? Colors.transparent
            : theme.colorScheme.primary,
      ),
      title: Text(message),
      subtitle: Text(
        activityDate(context, update.createdAt),
        style: theme.textTheme.bodySmall,
      ),
      onTap: () => context.push('/notifications'),
    );
  }
}
