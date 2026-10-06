import 'dart:async';

import 'package:data/data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_providers.g.dart';

/// Keeps the inbox live over Realtime.
///
/// Subscribes with the caller's `user_id=eq.<uid>` filter when a session
/// exists and does nothing signed out: a guest has no inbox, so there is
/// nothing to keep live. Every event invalidates the inbox page and the
/// badge count; watching this provider is what keeps the subscription (and
/// therefore the freshness) alive, so screens that render inbox data watch
/// it alongside the data providers.
///
/// The channel is released on dispose: without that every navigation to the
/// inbox would stack another socket listener.
@riverpod
void notificationsRealtime(Ref ref) {
  final userId = ref.watch(sessionProvider)?.user.id;
  if (userId == null) return;

  final repository = ref.watch(notificationRepositoryProvider);
  final channel = repository.subscribeInbox(
    userId: userId,
    onEvent: () => ref
      ..invalidate(notificationsProvider())
      ..invalidate(unreadNotificationCountProvider),
  );

  ref.onDispose(() {
    unawaited(repository.unsubscribeInbox(channel));
  });
}
