import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

void main() {
  group('Listing', () {
    test('fromJson creates valid Listing from snake_case DB row', () {
      final json = {
        'id': 'test-id',
        'seller_id': 'seller-id',
        'property_type': 'apartment',
        'listing_purpose': 'sale',
        'title': 'Test Listing',
        'price_npr': 1000000,
        'district': 'Kathmandu',
        'city': 'Lalitpur',
        'status': 'draft',
      };

      final listing = Listing.fromJson(json);

      expect(listing.id, 'test-id');
      expect(listing.title, 'Test Listing');
      expect(listing.priceNpr, 1000000);
      expect(listing.propertyType, PropertyType.apartment);
      expect(listing.listingPurpose, ListingPurpose.sale);
      expect(listing.status, ListingStatus.draft);
    });

    test('status serializes to snake_case DB value', () {
      const listing = Listing(
        id: 'test-id',
        sellerId: 'seller-id',
        propertyType: PropertyType.apartment,
        listingPurpose: ListingPurpose.sale,
        title: 'Test Listing',
        priceNpr: 1000000,
        district: 'Kathmandu',
        city: 'Lalitpur',
        status: ListingStatus.pendingReview,
      );

      final json = listing.toJson();

      expect(json['status'], 'pending_review');
      expect(json['seller_id'], 'seller-id');
      expect(json['price_npr'], 1000000);
      expect(json.containsKey('sellerId'), isFalse);
    });

    test('round-trip preserves all fields', () {
      const listing = Listing(
        id: 'test-id',
        sellerId: 'seller-id',
        propertyType: PropertyType.land,
        listingPurpose: ListingPurpose.lease,
        title: 'Land in Pokhara',
        description: 'Lake side',
        priceNpr: 5000000,
        areaSqm: 508.74,
        areaRopani: 1,
        areaAana: 2,
        areaPaisa: 3,
        areaDam: 1,
        district: 'Kaski',
        city: 'Pokhara',
        ward: '6',
        roadAccessFt: 20,
        status: ListingStatus.live,
      );

      final restored = Listing.fromJson(listing.toJson());

      expect(restored, listing);
    });

    test('copyWith updates fields', () {
      const listing = Listing(
        id: 'test-id',
        sellerId: 'seller-id',
        propertyType: PropertyType.apartment,
        listingPurpose: ListingPurpose.sale,
        title: 'Test Listing',
        priceNpr: 1000000,
        district: 'Kathmandu',
        city: 'Lalitpur',
      );

      final updated = listing.copyWith(title: 'Updated Title');

      expect(updated.title, 'Updated Title');
      expect(updated.id, 'test-id');
    });
  });

  group('Profile', () {
    test('fromJson creates valid Profile from snake_case DB row', () {
      final json = {
        'id': 'user-id',
        'email': 'test@example.com',
        'full_name': 'Test User',
        'role': 'buyer',
        'kyc_tier': 'none',
        'is_verified': false,
      };

      final profile = Profile.fromJson(json);

      expect(profile.id, 'user-id');
      expect(profile.email, 'test@example.com');
      expect(profile.fullName, 'Test User');
      expect(profile.role, UserRole.buyer);
      expect(profile.kycTier, KycTier.none);
    });

    test('round-trip preserves all fields', () {
      const profile = Profile(
        id: 'user-id',
        email: 'agent@example.com',
        fullName: 'Agent User',
        phone: '9841234567',
        role: UserRole.agent,
        isVerified: true,
        kycTier: KycTier.identity,
        agencyName: 'ABC Realty',
        agencyRegNo: 'REG-123',
      );

      final restored = Profile.fromJson(profile.toJson());

      expect(restored, profile);
      expect(profile.toJson()['agency_reg_no'], 'REG-123');
      expect(profile.toJson()['full_name'], 'Agent User');
    });
  });

  group('KycDocument', () {
    test('doc_type serializes to snake_case DB value', () {
      const doc = KycDocument(
        id: 'doc-id',
        profileId: 'user-id',
        docType: KycDocType.agencyReg,
        storagePath: 'kyc/user-id/reg.pdf',
      );

      final json = doc.toJson();

      expect(json['doc_type'], 'agency_reg');
      expect(json['profile_id'], 'user-id');
      expect(json['storage_path'], 'kyc/user-id/reg.pdf');
    });

    test('round-trip preserves all fields', () {
      const doc = KycDocument(
        id: 'doc-id',
        profileId: 'user-id',
        docType: KycDocType.lalpurja,
        storagePath: 'kyc/user-id/lalpurja.pdf',
        status: KycDocStatus.verified,
      );

      expect(KycDocument.fromJson(doc.toJson()), doc);
    });
  });

  group('AppNotification', () {
    test('type serializes to snake_case DB value', () {
      const notification = AppNotification(
        id: 'notif-id',
        userId: 'user-id',
        type: NotificationType.listingApproved,
        message: 'Your listing is live!',
        messageNe: 'तपाईंको विज्ञापन प्रकाशित भयो!',
      );

      final json = notification.toJson();

      expect(json['type'], 'listing_approved');
      expect(json['user_id'], 'user-id');
      expect(json['message_ne'], 'तपाईंको विज्ञापन प्रकाशित भयो!');
      expect(json['is_read'], false);
    });

    test('round-trip preserves all fields', () {
      const notification = AppNotification(
        id: 'notif-id',
        userId: 'user-id',
        type: NotificationType.newMessage,
        message: 'Hello',
        messageNe: 'नमस्ते',
        isRead: true,
      );

      expect(AppNotification.fromJson(notification.toJson()), notification);
    });
  });
}
