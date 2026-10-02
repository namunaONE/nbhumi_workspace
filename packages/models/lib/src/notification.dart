import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Types of notifications.
enum NotificationType {
  listingApproved,
  listingRejected,
  kycVerified,
  kycRejected,
  newMessage,
}

/// An in-app notification.
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    required NotificationType type,
    required String message,
    @Default(false) bool isRead,
    DateTime? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
