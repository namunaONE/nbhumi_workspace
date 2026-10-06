import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Bilingual content and wire names added in HYA-242 B1.
void main() {
  group('NotificationType.wireName', () {
    test('Dart names arrive as snake_case wire values', () {
      expect(NotificationType.listingApproved.wireName, 'listing_approved');
      expect(NotificationType.kycVerified.wireName, 'kyc_verified');
      expect(NotificationType.newMessage.wireName, 'new_message');
    });

    test('fromWire round-trips every value', () {
      for (final type in NotificationType.values) {
        expect(NotificationType.fromWire(type.wireName), type);
      }
    });

    test('fromWire throws on unknown values instead of defaulting', () {
      expect(() => NotificationType.fromWire('push'), throwsArgumentError);
    });
  });

  group('AppNotification bilingual content', () {
    test('messageNe serializes alongside message', () {
      const notification = AppNotification(
        id: 'notif-id',
        userId: 'user-id',
        type: NotificationType.kycRejected,
        message: 'Citizenship photo was unreadable.',
        messageNe: 'नागरिकताको फोटो पढ्न सकिएन।',
      );

      final json = notification.toJson();

      expect(json['message'], 'Citizenship photo was unreadable.');
      expect(json['message_ne'], 'नागरिकताको फोटो पढ्न सकिएन।');
      expect(
        AppNotification.fromJson(notification.toJson()),
        notification,
      );
    });
  });
}
