import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Repository for the in-app notification inbox (HYA-242 B1).
///
/// Owner-scoped by construction: every read and write goes through RLS
/// policies that admit only the row owner, and rows are written server-side
/// only (verdict RPCs in B2, service_role Edge Functions) — there is no
/// INSERT policy for clients, so nothing here can forge or send.
///
/// Every method maps transport failures onto the [AppException] hierarchy
/// (Rule 38) and logs with full context (Rule 37).
class NotificationRepository {
  /// Wraps a Supabase client.
  NotificationRepository(this._client);

  final SupabaseClient _client;

  /// The caller's notifications, newest first.
  ///
  /// No user filter is sent: RLS already confines the read to the caller's
  /// rows, served by `notifications_user_idx`. [limit] is clamped to 1..100
  /// so a careless caller cannot page the whole inbox in one round trip.
  Future<List<AppNotification>> inbox({int limit = 50}) async {
    var bounded = limit;
    if (bounded < 1) bounded = 1;
    if (bounded > 100) bounded = 100;

    final response = await _guard(
      () => _client
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(bounded),
      action: 'inbox',
    );

    return response.map(AppNotification.fromJson).toList(growable: false);
  }

  /// The number of unread notifications, for the inbox badge.
  ///
  /// Counts ids only (served by `notifications_unread_idx`), capped at 1000:
  /// beyond that the badge reads "999+" and the exact count is trivia. A
  /// seller with a thousand unread verdicts has a different problem than an
  /// exact number.
  Future<int> unreadCount() async {
    final response = await _guard(
      () => _client
          .from('notifications')
          .select('id')
          .eq('is_read', false)
          .limit(1000),
      action: 'unreadCount',
    );
    return response.length;
  }

  /// Marks one notification read and returns the updated row.
  ///
  /// Content cannot be altered through this path even by the owner: the
  /// `enforce_notification_immutable` trigger rejects anything but an
  /// `is_read` flip with 23514. A missing row (another session deleted it,
  /// or the id never belonged to the caller — RLS reports both identically)
  /// is remapped to an honest "gone" rather than the generic not-found.
  Future<AppNotification> markRead(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.notificationIdRequired',
        messageEn: 'That notification could not be found.',
        messageNe: 'यो सूचना फेला परेन।',
      );
    }

    try {
      final row = await _guard(
        () => _client
            .from('notifications')
            .update(<String, Object?>{'is_read': true})
            .eq('id', trimmed)
            .select()
            .single(),
        action: 'markRead',
      );
      return AppNotification.fromJson(row);
    } on ServerException catch (e) {
      if (e.code == 'server.notFound') {
        throw ValidationException(
          code: 'validation.notificationNotFound',
          messageEn: 'That notification is no longer in your inbox.',
          messageNe: 'यो सूचना अब तपाईंको इनबक्समा छैन।',
          context: 'markRead',
          cause: e,
        );
      }
      rethrow;
    }
  }

  /// Marks every unread notification read. Returns how many were marked.
  Future<int> markAllRead() async {
    final response = await _guard(
      () => _client
          .from('notifications')
          .update(<String, Object?>{'is_read': true})
          .eq('is_read', false)
          .select('id'),
      action: 'markAllRead',
    );
    return response.length;
  }

  /// Subscribes to the caller's inbox over Realtime (HYA-242).
  ///
  /// Filter `user_id=eq.<userId>` selects the rows; RLS admits only the
  /// caller's own, so one seller never sees another's events even though the
  /// channel is shared infrastructure. The returned channel belongs to the
  /// caller: pass it to [unsubscribeInbox] when the inbox screen disposes,
  /// otherwise the socket outlives the screen and every navigation stacks
  /// another listener.
  RealtimeChannel subscribeInbox({
    required String userId,
    required void Function() onEvent,
  }) {
    return _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => onEvent(),
        )
        .subscribe();
  }

  /// Releases a channel opened by [subscribeInbox].
  Future<void> unsubscribeInbox(RealtimeChannel channel) =>
      _guard(() => _client.removeChannel(channel), action: 'unsubscribeInbox');

  /// Runs [call], converting transport failures into the [AppException]
  /// hierarchy (Rule 38) and logging with full context (Rule 37).
  Future<T> _guard<T>(
    Future<T> Function() call, {
    required String action,
  }) async {
    try {
      return await call();
    } on PostgrestException catch (e) {
      final mapped = PostgrestErrorMapper.map(e, action: action);
      _logFailure(mapped, action: action, cause: e);
      throw mapped;
    } on AuthException catch (e) {
      final mapped = AuthExceptionMapper.map(e, action: action);
      _logFailure(mapped, action: action, cause: e);
      throw mapped;
    }
  }

  /// Records a failed call.
  void _logFailure(
    AppException mapped, {
    required String action,
    required Object cause,
  }) {
    final context = logContext(
      action: action,
      detail: <String, Object?>{'code': mapped.code},
    );

    if (mapped is NetworkException) {
      AppLogger.warning(
        'Network failure in $action',
        context: context,
        error: cause,
      );
      return;
    }

    AppLogger.error(
      'Failed in $action',
      context: context,
      error: cause,
    );
  }
}
