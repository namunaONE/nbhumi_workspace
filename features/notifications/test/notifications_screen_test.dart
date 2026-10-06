import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:notifications/notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget tests for [NotificationsScreen].
///
/// Rule 33: pump with `ProviderScope` overrides, never real providers. The
/// inbox comes from an overridden `notificationsProvider`, the Realtime
/// subscription is stubbed out, and row actions run against a repository
/// backed by a method-aware HTTP client.
void main() {
  group('NotificationsScreen', () {
    testWidgets('empty inbox explains what lands here', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsProvider().overrideWith(
              (ref) async => const <AppNotification>[],
            ),
            notificationsRealtimeProvider.overrideWith((ref) {}),
          ],
          child: const MaterialApp(home: NotificationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Nothing yet'), findsOneWidget);
      expect(find.text('Mark all read'), findsNothing);
    });

    testWidgets('renders rows with English bodies', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsProvider().overrideWith(
              (ref) async => const <AppNotification>[
                AppNotification(
                  id: 'n1',
                  userId: 'u1',
                  type: NotificationType.listingApproved,
                  message: 'Your listing is live!',
                  messageNe: 'विज्ञापन प्रकाशित भयो!',
                ),
                AppNotification(
                  id: 'n2',
                  userId: 'u1',
                  type: NotificationType.kycRejected,
                  message: 'Rejected.',
                  messageNe: 'अस्वीकृत।',
                  isRead: true,
                ),
              ],
            ),
            notificationsRealtimeProvider.overrideWith((ref) {}),
          ],
          child: const MaterialApp(home: NotificationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your listing is live!'), findsOneWidget);
      expect(find.text('Rejected.'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
    });

    testWidgets('tapping an unread row marks it read', (tester) async {
      // A hand fake, not a repository over a real SupabaseClient: constructing
      // the client starts GoTrue's auto-refresh timer, which outlives the
      // widget tree and fails teardown with a pending timer.
      final repository = _FakeNotificationRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsProvider().overrideWith(
              (ref) async => repository.rows,
            ),
            notificationsRealtimeProvider.overrideWith((ref) {}),
            notificationRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(home: NotificationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Someone viewed.'));
      await tester.pumpAndSettle();

      expect(repository.markReadCalls, hasLength(1));
      expect(repository.markReadCalls.single, 'n1');
    });
  });
}

/// Records row actions without touching the network.
///
/// A repository over a real client (even with an injected `http.Client`)
/// starts GoTrue timers that fail widget-test teardown, so row-action tests
/// fake at the repository seam instead. The HTTP-level mapping is already
/// covered in `notification_repository_test.dart`.
class _FakeNotificationRepository implements NotificationRepository {
  /// Ids passed to [markRead], in order.
  final List<String> markReadCalls = <String>[];

  /// Rows the inbox override serves.
  final List<AppNotification> rows = const <AppNotification>[
    AppNotification(
      id: 'n1',
      userId: 'u1',
      type: NotificationType.newMessage,
      message: 'Someone viewed.',
      messageNe: 'कसैले हेर्नुभयो।',
    ),
  ];

  @override
  Future<List<AppNotification>> inbox({int limit = 50}) async => rows;

  @override
  Future<int> unreadCount() async =>
      rows.where((row) => !row.isRead).length;

  @override
  Future<AppNotification> markRead(String id) async {
    markReadCalls.add(id);
    return rows.firstWhere((row) => row.id == id).copyWith(isRead: true);
  }

  @override
  Future<int> markAllRead() async => 0;

  @override
  RealtimeChannel subscribeInbox({
    required String userId,
    required void Function() onEvent,
  }) =>
      throw UnimplementedError('inbox tests never subscribe');

  @override
  Future<void> unsubscribeInbox(RealtimeChannel channel) async {}
}
