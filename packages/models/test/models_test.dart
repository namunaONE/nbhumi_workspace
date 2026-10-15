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

    test('conditioned enums use wire names, never Dart names', () {
      // The bug class this guards: `.name` sent straight to the RPC sends
      // `semiFurnished`, which the CHECK rejects. `pendingReview` broke the
      // same way once, hence ListingStatus.fromWire.
      expect(FurnishingStatus.semiFurnished.wireName, 'semi_furnished');
      expect(PetPolicy.catsOk.wireName, 'cats_ok');
      expect(PetPolicy.notAllowed.wireName, 'not_allowed');
      expect(ConstructionStatus.newBuild.wireName, 'new');
      expect(
        ConstructionStatus.underConstruction.wireName,
        'under_construction',
      );

      expect(
        FurnishingStatus.fromWire('semi_furnished'),
        FurnishingStatus.semiFurnished,
      );
      expect(PetPolicy.fromWire('cats_ok'), PetPolicy.catsOk);
      expect(
        ConstructionStatus.fromWire('under_construction'),
        ConstructionStatus.underConstruction,
      );
      expect(FacingDirection.east.wireName, 'east');
      expect(FacingDirection.northWest.wireName, 'north_west');
      expect(
        FacingDirection.fromWire('south_east'),
        FacingDirection.southEast,
      );
    });

    test('conditioned enums refuse unknown values rather than defaulting',
        () {
      expect(() => FurnishingStatus.fromWire('luxury'), throwsArgumentError);
      expect(() => PetPolicy.fromWire('hamsters_ok'), throwsArgumentError);
      expect(
        () => ConstructionStatus.fromWire('palace'),
        throwsArgumentError,
      );
      expect(
        () => FacingDirection.fromWire('up'),
        throwsArgumentError,
      );
    });

    test('round-trip preserves the conditioned fields', () {
      final listing = Listing(
        id: 'test-id',
        sellerId: 'seller-id',
        propertyType: PropertyType.apartment,
        listingPurpose: ListingPurpose.rent,
        title: 'Flat in Jawalakhel',
        priceNpr: 25000,
        district: 'Lalitpur',
        city: 'Lalitpur',
        depositAmount: 50000,
        availableFrom: DateTime.utc(2026, 12),
        furnishingStatus: FurnishingStatus.semiFurnished,
        utilitiesIncluded: 'Water',
        petPolicy: PetPolicy.catsOk,
        parkingSpaces: 1,
        floorNumber: 3,
        totalFloors: 7,
        propertyAgeYears: 10,
        constructionStatus: ConstructionStatus.resale,
        facingDirection: FacingDirection.southWest,
        amenities: const <String>['Drinking water', 'Balcony'],
      );

      final restored = Listing.fromJson(listing.toJson());

      expect(restored, listing);
      expect(restored.toJson()['furnishing_status'], 'semi_furnished');
      expect(restored.toJson()['pet_policy'], 'cats_ok');
      expect(restored.toJson()['construction_status'], 'resale');
      expect(restored.toJson()['facing_direction'], 'south_west');
      expect(
        restored.toJson()['amenities'],
        <String>['Drinking water', 'Balcony'],
      );
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

    test('parses suspension state from the own-row read', () {
      final profile = Profile.fromJson({
        'id': 'user-id',
        'email': 'test@example.com',
        'full_name': 'Test User',
        'suspended': true,
        'suspended_reason': 'Fake listings',
      });

      expect(profile.suspended, isTrue);
      expect(profile.suspendedReason, 'Fake listings');
    });

    test('toJson omits suspension so edits can never write it', () {
      // HYA-301 seatbelt: updateProfile sends toJson straight to PostgREST,
      // and the RLS pin is the backstop. If these keys ever appear here, a
      // suspended seller could clear their own suspension via edit-profile.
      const profile = Profile(
        id: 'user-id',
        email: 'test@example.com',
        fullName: 'Test User',
        suspended: true,
        suspendedReason: 'Fake listings',
      );

      final json = profile.toJson();

      expect(json.containsKey('suspended'), isFalse);
      expect(json.containsKey('suspended_reason'), isFalse);
      // ... while the read path still parses them (see above).
      expect(Profile.fromJson(json).suspended, isFalse);
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
