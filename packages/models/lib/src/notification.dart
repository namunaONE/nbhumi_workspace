import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Types of notifications.
///
/// Carries an explicit [wireName]: `listingApproved` is `listing_approved`
/// in the database, and sending `.name` straight to a reader or writer
/// would miss every row. Use [wireName] outbound, [fromWire] inbound —
/// never `.name` for anything crossing the wire.
enum NotificationType {
  /// A listing was approved by an admin.
  @JsonValue('listing_approved')
  listingApproved('listing_approved'),

  /// A listing was rejected by an admin.
  @JsonValue('listing_rejected')
  listingRejected('listing_rejected'),

  /// A KYC document was verified.
  @JsonValue('kyc_verified')
  kycVerified('kyc_verified'),

  /// A KYC document was rejected.
  @JsonValue('kyc_rejected')
  kycRejected('kyc_rejected'),

  /// A new message was received.
  @JsonValue('new_message')
  newMessage('new_message');

  /// Creates a type with its Postgres wire value.
  NotificationType(this.wireName);

  /// The value the `notifications.type` check constraint uses.
  final String wireName;

  /// The type whose [wireName] is [value].
  static NotificationType fromWire(String value) => values.firstWhere(
        (type) => type.wireName == value,
        orElse: () => throw ArgumentError.value(
          value,
          'value',
          'not a notification type value',
        ),
      );
}

/// An in-app notification.
///
/// Content is bilingual by schema ([message] + [messageNe]): Rule 36 covers
/// notifications as much as errors, and a verdict email-equivalent in the
/// wrong language is a support ticket waiting to happen.
@freezed
sealed class AppNotification with _$AppNotification {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AppNotification({
    required String id,
    required String userId,
    required NotificationType type,
    required String message,
    required String messageNe,
    @Default(false) bool isRead,
    DateTime? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
