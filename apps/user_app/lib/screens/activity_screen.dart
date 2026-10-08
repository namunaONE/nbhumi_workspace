import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:user_app/l10n/output/app_localizations.dart';

import 'activity_rows.dart';

/// The caller's marketplace activity: listings, interest, reveals,
/// verifications and updates in one read-only timeline.
///
/// Lives under `/profile` (not a fifth tab: the shell maps branches to
/// indices positionally, so inserting a tab would silently repoint every
/// saved tab index). Read-only by design — every row links to the screen
/// that owns its action; nothing here mutates.
class ActivityScreen extends ConsumerWidget {
  /// Creates the activity screen.
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final strings = AppLocalizations.of(context);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.activityTitle)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(strings.commonSignIn),
              subtitle: Text(strings.activityGuestPrompt),
              onTap: () => context.push('/login'),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.activityTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: strings.activityRefresh,
            onPressed: () => ref.invalidate(activityPageProvider),
          ),
        ],
      ),
      body: _ActivityBody(userId: session.user.id),
    );
  }
}

/// Signed-in body: role-aware sections over the assembled page.
///
/// Role gating is display-only (sellers see interest, buyers get a Post
/// CTA): authorization stays server-side in RLS and the RPCs.
class _ActivityBody extends ConsumerWidget {
  /// Creates the body.
  const _ActivityBody({required this.userId});

  /// Profile row id (== auth user id).
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(userId: userId));
    final page = ref.watch(activityPageProvider);
    final strings = AppLocalizations.of(context);

    final isSeller = switch (profile) {
      AsyncData(:final value) => value?.role != UserRole.buyer,
      // A profile that will not load must not hide activity: the user who
      // most needs self-service is the one whose data is broken.
      _ => false,
    };

    return switch (page) {
      AsyncLoading() => LoadingState(message: strings.profileLoading),
      AsyncError(:final error) => ErrorState(
          message: error is AppException
              ? error.localizedForContext(context)
              : strings.activityLoadFailed,
          retryLabel: strings.commonRetry,
          onRetry: () => ref.invalidate(activityPageProvider),
        ),
      AsyncData(:final value) => ListView(
          padding:
              const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: <Widget>[
            _Section(
              title: strings.activityListings,
              child: value.listings.isEmpty
                  ? _EmptyRow(
                      text: isSeller
                          ? strings.activityListingsEmpty
                          : strings.activityListingsEmptyBuyer,
                      actionLabel: strings.activityPostCta,
                      onAction: () => context.push('/post'),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (final listing in value.listings)
                          ActivityListingRow(listing: listing),
                      ],
                    ),
            ),
            if (value.revealStats.isNotEmpty)
              _Section(
                title: strings.activityInterest,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final stat in value.revealStats)
                      ActivityStatRow(stat: stat),
                  ],
                ),
              ),
            _Section(
              title: strings.activityReveals,
              child: value.reveals.isEmpty
                  ? _EmptyRow(text: strings.activityRevealsEmpty)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (final reveal in value.reveals)
                          ActivityRevealRow(reveal: reveal),
                      ],
                    ),
            ),
            _Section(
              title: strings.activityDocs,
              child: value.documents.isEmpty
                  ? _EmptyRow(
                      text: strings.activityDocsEmpty,
                      actionLabel: strings.profileKycTitle,
                      onAction: () => context.push('/kyc'),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (final document in value.documents)
                          ActivityDocRow(document: document),
                      ],
                    ),
            ),
            _Section(
              title: strings.activityUpdates,
              child: value.updates.isEmpty
                  ? _EmptyRow(text: strings.activityUpdatesEmpty)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (final update in value.updates.take(5))
                          ActivityUpdateRow(update: update),
                        if (value.updates.length > 5)
                          TextButton(
                            onPressed: () =>
                                context.push('/notifications'),
                            child: Text(strings.activityViewAll),
                          ),
                      ],
                    ),
            ),
          ],
        ),
    };
  }
}

/// Section header plus content.
class _Section extends StatelessWidget {
  /// Creates the section.
  const _Section({required this.title, required this.child});

  /// Section heading.
  final String title;

  /// Section content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

/// One-line empty state with an optional action.
class _EmptyRow extends StatelessWidget {
  /// Creates the row.
  const _EmptyRow({required this.text, this.actionLabel, this.onAction});

  /// Explanatory copy.
  final String text;

  /// Optional CTA label.
  final String? actionLabel;

  /// Called when the CTA is tapped.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(text, style: theme.textTheme.bodySmall),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
