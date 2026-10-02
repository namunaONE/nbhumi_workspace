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
    final response = await _client.rpc('v1_create_listing', params: {
      'p_property_type': listing.propertyType.name,
      'p_listing_purpose': listing.listingPurpose.name,
      'p_title': listing.title,
      'p_description': listing.description,
      'p_price_npr': listing.priceNpr,
      'p_area_sqm': listing.areaSqm,
      'p_district': listing.district,
      'p_city': listing.city,
      'p_ward': listing.ward,
      'p_road_access_ft': listing.roadAccessFt,
      'p_status': listing.status.name,
    });
    return listing.copyWith(
      id: response['id'] as String,
      status: ListingStatus.values.byName(response['status'] as String),
    );
  }

  /// Update an existing listing.
  Future<Listing> updateListing(Listing listing) async {
    final response = await _client.rpc('v1_update_listing', params: {
      'p_listing_id': listing.id,
      'p_title': listing.title,
      'p_description': listing.description,
      'p_price_npr': listing.priceNpr,
      'p_district': listing.district,
      'p_city': listing.city,
      'p_ward': listing.ward,
      'p_road_access_ft': listing.roadAccessFt,
      'p_status': listing.status.name,
    });
    return listing.copyWith(
      status: ListingStatus.values.byName(response['status'] as String),
    );
  }
}
