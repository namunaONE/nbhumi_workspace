import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Repository for listing data.
///
/// Single source of truth for listing operations (Rule 18). Every method maps
/// failures through [PostgrestErrorMapper] and logs them with full context
/// (Rules 37, 38), so no Supabase or Postgres type ever reaches a widget.
class ListingRepository {
  /// Wraps a Supabase client.
  ListingRepository(this._client);

  final SupabaseClient _client;

  /// Browse listings with filters and keyset pagination.
  ///
  /// Uses a cursor rather than a page number: `v1_get_listings` is keyset
  /// paginated, so cost is constant at any depth — which matters because
  /// HYA-203 wants infinite scroll from day one. Pass the previous page's
  /// cursor to advance.
  ///
  /// Throws an [AppException] subclass, never a raw [PostgrestException].
  Future<ListingPage> getListings({
    ListingFilter filter = const ListingFilter(),
    ListingCursor? cursor,
  }) async {
    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_get_listings',
        params: <String, Object?>{
          'p_property_type': filter.propertyType?.name,
          'p_listing_purpose': filter.listingPurpose?.name,
          'p_district': filter.district,
          'p_min_price': filter.minPriceNpr,
          'p_max_price': filter.maxPriceNpr,
          'p_min_area': filter.minAreaSqm,
          'p_max_area': filter.maxAreaSqm,
          'p_sort': filter.sort.wireName,
          'p_cursor': cursor == null
              ? null
              : <String, String>{'k': cursor.k, 'id': cursor.id},
          'p_page_size': filter.pageSize,
        },
      ),
      action: 'getListings',
    );

    final rawListings = response['listings'] as List<dynamic>? ?? const [];
    return ListingPage(
      listings: rawListings
          .map((e) => ListingSummary.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      totalCount: (response['total_count'] as num?)?.toInt() ?? 0,
      pageSize: (response['page_size'] as num?)?.toInt() ?? filter.pageSize,
      hasMore: response['has_more'] as bool? ?? false,
    );
  }

  /// Fetch a single listing with photos and seller card.
  ///
  /// Returns null when the listing does not exist *or* is not visible to the
  /// caller: `v1_get_listing_detail` raises the same `P0002` for both, and that
  /// distinction must not be probeable by a client.
  Future<ListingDetail?> getListingById(String id) async {
    try {
      final response = await _client.rpc<Map<String, dynamic>>(
        'v1_get_listing_detail',
        params: <String, Object?>{'p_listing_id': id},
      );
      return ListingDetail.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'P0002' || e.code == 'PGRST116') {
        // Expected whenever a listing is unpublished, deleted, or belongs to
        // someone else. Not an incident, so deliberately not logged.
        return null;
      }
      final mapped = PostgrestErrorMapper.map(e, action: 'getListingById');
      _logFailure(mapped, action: 'getListingById', cause: e);
      throw mapped;
    }
  }

  /// Create a listing and return its new id.
  ///
  /// [status] must be `draft` or `pending_review`; `v1_create_listing` rejects
  /// anything else with `22023`. Only an admin can make a listing live.
  Future<String> createListing({
    required Listing listing,
    ListingStatus status = ListingStatus.draft,
  }) async {
    final json = listing.toJson();
    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_create_listing',
        params: <String, Object?>{
          'p_property_type': json['property_type'],
          'p_listing_purpose': json['listing_purpose'],
          'p_title': json['title'],
          'p_description': json['description'],
          'p_price_npr': json['price_npr'],
          'p_area_sqm': json['area_sqm'],
          'p_area_ropani': json['area_ropani'],
          'p_area_aana': json['area_aana'],
          'p_area_paisa': json['area_paisa'],
          'p_area_dam': json['area_dam'],
          'p_area_bigha': json['area_bigha'],
          'p_area_kattha': json['area_kattha'],
          'p_area_dhur': json['area_dhur'],
          'p_district': json['district'],
          'p_city': json['city'],
          'p_ward': json['ward'],
          'p_road_access_ft': json['road_access_ft'],
          'p_status': status.name,
        },
      ),
      action: 'createListing',
    );
    return response['id'] as String;
  }

  /// Update an existing listing. Owner-scoped server-side.
  ///
  /// Note the RPC currently does not accept the local area-unit fields, so a
  /// title-only edit preserves them server-side. HYA-251 extends it.
  Future<ListingStatus> updateListing({
    required String listingId,
    Listing? listing,
    ListingStatus? status,
  }) async {
    final json = listing?.toJson();
    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_update_listing',
        params: <String, Object?>{
          'p_listing_id': listingId,
          'p_title': json?['title'],
          'p_description': json?['description'],
          'p_price_npr': json?['price_npr'],
          'p_area_sqm': json?['area_sqm'],
          'p_district': json?['district'],
          'p_city': json?['city'],
          'p_ward': json?['ward'],
          'p_road_access_ft': json?['road_access_ft'],
          'p_status': status?.name,
        },
      ),
      action: 'updateListing',
    );
    return ListingStatus.values.byName(response['status'] as String);
  }

  /// Reveals the seller contact for [listingId].
  ///
  /// The one path by which a seller phone number or email reaches the client.
  /// Server-side this requires a session, a live listing, a buyer who is not
  /// the seller, and is capped at ten first-time reveals per rolling 24 hours;
  /// see migration `20261004070057_add_contact_logs_and_contact_seller.sql`.
  ///
  /// Throws rather than returning a sentinel, because every failure here is
  /// meaningful and differently worded to the user:
  ///
  /// * `AuthFailureException`   - not signed in, or this is your own listing
  /// * `ValidationException`    - `contact.rateLimited`, the daily cap is spent
  /// * `ServerException`        - the listing is no longer available
  /// * `NetworkException`       - transport failure, retryable
  Future<SellerContact> contactSeller(String listingId) async {
    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_contact_seller',
        params: <String, Object?>{'p_listing_id': listingId},
      ),
      action: 'contactSeller',
    );
    return SellerContact.fromJson(response);
  }

  /// Runs [call], converting transport failures into the [AppException]
  /// hierarchy so callers only ever match on types they can render (Rule 38),
  /// and logging the failure with full context (Rule 37).
  ///
  /// User and screen come from `sessionContext`, maintained by the auth layer
  /// and the router. Threading a `screen` argument through every call instead
  /// would put a UI concern into the data layer, and would be wrong anyway: a
  /// ViewModel cannot know which screen is reading it.
  Future<T> _guard<T>(
    Future<T> Function() call, {
    required String action,
  }) async {
    try {
      return await call();
    } on PostgrestException catch (e) {
      final mapped = PostgrestErrorMapper.map(e, action: action);
      _logFailure(mapped, action: action, cause: e);
      throw mapped;
    } on AuthException catch (e) {
      final mapped = AuthExceptionMapper.map(e, action: action);
      _logFailure(mapped, action: action, cause: e);
      throw mapped;
    }
  }

  /// Records a failed call.
  ///
  /// Network failures log at warning, not error: a dead connection on a poor
  /// mobile network is expected rather than an incident, and promoting every
  /// blip to an error would bury the real ones. Everything else is an error.
  void _logFailure(
    AppException mapped, {
    required String action,
    required Object cause,
  }) {
    final context = logContext(
      action: action,
      detail: <String, Object?>{'code': mapped.code},
    );

    if (mapped is NetworkException) {
      AppLogger.warning(
        'Network failure in $action',
        context: context,
        error: cause,
      );
      return;
    }

    AppLogger.error(
      'Failed in $action',
      context: context,
      error: cause,
    );
  }
}
