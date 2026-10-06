import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// `savedSearchFromFilter` mapping added in HYA-268 C2b.
void main() {
  group('savedSearchFromFilter', () {
    test('carries filter fields, drops presentation fields', () {
      const filter = ListingFilter(
        district: 'Kathmandu',
        propertyType: PropertyType.house,
        listingPurpose: ListingPurpose.sale,
        maxPriceNpr: 5000000,
        query: 'lake view',
        sort: ListingSort.priceAsc,
      );

      final saved = savedSearchFromFilter(
        id: 's1',
        userId: 'u1',
        name: 'Houses in Kathmandu',
        filter: filter,
      );

      expect(saved.district, 'Kathmandu');
      expect(saved.propertyType, PropertyType.house);
      expect(saved.listingPurpose, ListingPurpose.sale);
      expect(saved.maxPriceNpr, 5000000);
      expect(saved.minPriceNpr, isNull);
    });

    test('round-trips through JSON', () {
      const saved = SavedSearch(
        id: 's1',
        userId: 'u1',
        name: 'N',
        district: 'Kaski',
        propertyType: PropertyType.land,
        minAreaSqm: 100,
      );

      expect(SavedSearch.fromJson(saved.toJson()), saved);
      expect(saved.toJson()['property_type'], 'land');
    });
  });
}
