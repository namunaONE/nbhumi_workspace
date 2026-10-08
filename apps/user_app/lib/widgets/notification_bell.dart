import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/l10n/output/app_localizations.dart';

/// Bell opening the notification inbox, with the unread badge.
///
/// Lives in the Explore app bar (HYA-299): the badge moved off the profile
/// tab, since a bell in an app bar needs no per-screen repetition while a
/// fifth tab would repoint every saved tab index. Guests read zero rows
/// under RLS, so no session check is needed — zero renders a bare icon.
class NotificationBell extends ConsumerWidget {
  /// Creates the inbox bell.
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = switch (ref.watch(unreadNotificationCountProvider)) {
      AsyncData(:final value) => value,
      _ => 0,
    };
    final icon = IconButton(
      icon: const Icon(Icons.notifications_outlined),
      tooltip: AppLocalizations.of(context).profileNotifTitle,
      onPressed: () => context.push('/notifications'),
    );
    if (unread <= 0) return icon;
    return Badge(
      label: Text(unread > 99 ? '99+' : '$unread'),
      child: icon,
    );
  }
}
