import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';
import 'package:notifications/l10n/output/notifications_localizations.dart'
    as notif_strings;

import '../viewmodels/notifications_providers.dart';

/// In-app notification inbox.
///
/// Verdict rows fanned out by the B2 migration (listing approved/rejected,
/// KYC verified/rejected, contact reveals) arrive here over Realtime while
/// this screen is watched. Tapping a row marks it read. Reached from the
/// profile screen; gated behind a session by the router, like `/kyc`.
class NotificationsScreen extends ConsumerWidget {
  /// Creates the inbox screen.
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched for its subscription side effect: while this screen is alive
    // the inbox stays live. The returned void carries no data.
    ref.watch(notificationsRealtimeProvider);
    final inbox = ref.watch(notificationsProvider());
    final strings = notif_strings.AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.title),
        actions: <Widget>[
          _MarkAllReadAction(hasUnread: switch (inbox) {
            AsyncData(:final value) => value.any((n) => !n.isRead),
            _ => false,
          }),
        ],
      ),
      // Capped at reading width (DESIGN.md §4.4b). Centers the inbox.
      body: CenteredContent(
        child: switch (inbox) {
          AsyncLoading() => const LoadingState(),
          AsyncError(:final error) => Builder(
              builder: (context) {
                // Retry only surfaces for recoverable failures, matching the
                // previous inline error: a dead-end error shows the message
                // with no action that could never succeed.
                final failure = error is AppException ? error : null;
                final retryable = failure == null || failure.isRetryable;
                return ErrorState(
                  message: failure?.localizedForContext(context) ??
                      strings.loadFailed,
                  retryLabel: retryable ? strings.retry : null,
                  onRetry: retryable
                      ? () => ref.invalidate(notificationsProvider())
                      : null,
                );
              },
            ),
          AsyncData(:final value) when value.isEmpty => EmptyState(
              title: strings.emptyTitle,
              body: strings.emptyBody,
              icon: Icons.notifications_off_outlined,
            ),
          AsyncData(:final value) => ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index) =>
                  _NotificationTile(notification: value[index]),
            ),
        },
      ),
    );
  }
}

/// Marks every unread notification read.
class _MarkAllReadAction extends ConsumerWidget {
  const _MarkAllReadAction({required this.hasUnread});

  /// Whether any row is unread. The action hides when there is nothing to do.
  final bool hasUnread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!hasUnread) return const SizedBox.shrink();
    final strings = notif_strings.AppLocalizations.of(context);
    return TextButton(
      onPressed: () => _markAllRead(context, ref),
      child: Text(strings.markAllRead),
    );
  }

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = notif_strings.AppLocalizations.of(context);
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      ref
        ..invalidate(notificationsProvider())
        ..invalidate(unreadNotificationCountProvider);
    } on AppException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.localizedForContext(context)),
          action: e.isRetryable
              ? SnackBarAction(
                  label: strings.retry,
                  onPressed: () => _markAllRead(context, ref),
                )
              : null,
        ),
      );
    }
  }
}

/// One inbox row: icon by type, bilingual body, unread marker.
class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final (icon, color) = switch (notification.type) {
      NotificationType.listingApproved ||
      NotificationType.kycVerified =>
        (Icons.check_circle_outline, theme.colorScheme.primary),
      NotificationType.listingRejected ||
      NotificationType.kycRejected =>
        (Icons.cancel_outlined, theme.colorScheme.error),
      NotificationType.newMessage =>
        (Icons.message_outlined, theme.colorScheme.secondary),
    };

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        _bodyFor(context, notification),
        style: notification.isRead
            ? null
            : theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
      ),
      trailing: notification.isRead
          ? null
          : Icon(
              Icons.fiber_manual_record,
              size: 10,
              color: theme.colorScheme.primary,
            ),
      onTap: () => _markRead(context, ref),
    );
  }

  Future<void> _markRead(BuildContext context, WidgetRef ref) async {
    if (notification.isRead) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(notificationRepositoryProvider).markRead(
            notification.id,
          );
      ref
        ..invalidate(notificationsProvider())
        ..invalidate(unreadNotificationCountProvider);
    } on AppException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.localizedForContext(context))),
      );
    }
  }
}

/// Picks the locale's message from the stored pair (Rule 36).
String _bodyFor(BuildContext context, AppNotification notification) {
  final locale = Localizations.maybeLocaleOf(context);
  final preferNepali = (locale?.languageCode ?? 'ne') != 'en';
  return preferNepali ? notification.messageNe : notification.message;
}
