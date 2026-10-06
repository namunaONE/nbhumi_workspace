// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      message: json['message'] as String,
      messageNe: json['message_ne'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'message': instance.message,
      'message_ne': instance.messageNe,
      'is_read': instance.isRead,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.listingApproved: 'listing_approved',
  NotificationType.listingRejected: 'listing_rejected',
  NotificationType.kycVerified: 'kyc_verified',
  NotificationType.kycRejected: 'kyc_rejected',
  NotificationType.newMessage: 'new_message',
};
