import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Types of notifications.
enum NotificationType {
  /// A listing was approved by an admin.
  @JsonValue('listing_approved')
  listingApproved,

  /// A listing was rejected by an admin.
  @JsonValue('listing_rejected')
  listingRejected,

  /// A KYC document was verified.
  @JsonValue('kyc_verified')
  kycVerified,

  /// A KYC document was rejected.
  @JsonValue('kyc_rejected')
  kycRejected,

  /// A new message was received.
  @JsonValue('new_message')
  newMessage,
}

/// An in-app notification.
@freezed
sealed class AppNotification with _$AppNotification {
  @JsonSerializable(fieldRename: FieldRename.snake)
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
