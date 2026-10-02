import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:models/models.dart';

/// Repository for listing data.
///
/// Single source of truth for listing operations.
class ListingRepository {
  ListingRepository(this._client);

  final SupabaseClient _client;

  /// Get listings with filters and pagination.
  Future<List<Listing>> getListings({
    PropertyType? propertyType,
    ListingPurpose? listingPurpose,
    String? district,
    int? minPrice,
    int? maxPrice,
    double? minArea,
    double? maxArea,
    String? sort,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.rpc('v1_get_listings', params: {
      'p_property_type': propertyType?.name,
      'p_listing_purpose': listingPurpose?.name,
      'p_district': district,
      'p_min_price': minPrice,
      'p_max_price': maxPrice,
      'p_min_area': minArea,
      'p_max_area': maxArea,
      'p_sort': sort,
      'p_page': page,
      'p_page_size': pageSize,
    });
    return (response['listings'] as List)
        .map((e) => Listing.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a single listing by ID.
  Future<Listing?> getListingById(String id) async {
    final response = await _client.rpc('v1_get_listing_detail', params: {
      'p_listing_id': id,
    });
    if (response == null) return null;
    return Listing.fromJson(response as Map<String, dynamic>);
  }

  /// Create a new listing.
  Future<Listing> createListing(Listing listing) async {
    // Use generated serialization as the single source of truth for
    // snake_case keys and enum JSON values.
    final json = listing.toJson();
    final response = await _client.rpc('v1_create_listing', params: {
      'p_property_type': json['property_type'],
      'p_listing_purpose': json['listing_purpose'],
      'p_title': json['title'],
      'p_description': json['description'],
      'p_price_npr': json['price_npr'],
      'p_area_sqm': json['area_sqm'],
      'p_district': json['district'],
      'p_city': json['city'],
      'p_ward': json['ward'],
      'p_road_access_ft': json['road_access_ft'],
      'p_status': json['status'],
    });
    return listing.copyWith(
      id: response['id'] as String,
      status: Listing.fromJson({'status': response['status'], ...json}).status,
    );
  }

  /// Update an existing listing.
  Future<Listing> updateListing(Listing listing) async {
    final json = listing.toJson();
    final response = await _client.rpc('v1_update_listing', params: {
      'p_listing_id': listing.id,
      'p_title': json['title'],
      'p_description': json['description'],
      'p_price_npr': json['price_npr'],
      'p_district': json['district'],
      'p_city': json['city'],
      'p_ward': json['ward'],
      'p_road_access_ft': json['road_access_ft'],
      'p_status': json['status'],
    });
    return listing.copyWith(
      status: Listing.fromJson({'status': response['status'], ...json}).status,
    );
  }
}
