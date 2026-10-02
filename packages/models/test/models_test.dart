import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

void main() {
  group('Listing', () {
    test('fromJson creates valid Listing', () {
      final json = {
        'id': 'test-id',
        'sellerId': 'seller-id',
        'propertyType': 'apartment',
        'listingPurpose': 'sale',
        'title': 'Test Listing',
        'priceNpr': 1000000,
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
    test('fromJson creates valid Profile', () {
      final json = {
        'id': 'user-id',
        'email': 'test@example.com',
        'fullName': 'Test User',
        'role': 'buyer',
        'kycTier': 'none',
      };

      final profile = Profile.fromJson(json);

      expect(profile.id, 'user-id');
      expect(profile.email, 'test@example.com');
      expect(profile.fullName, 'Test User');
      expect(profile.role, UserRole.buyer);
      expect(profile.kycTier, KycTier.none);
    });
  });
}
