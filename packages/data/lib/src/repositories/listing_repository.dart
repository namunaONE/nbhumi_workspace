import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Storage bucket holding listing photos.
///
/// Public, unlike the `kyc-documents` bucket, and deliberately so: guest browse
/// has to render cover photos without a session, and a signed URL per photo per
/// row would mean a round trip the browse RPC cannot make. Photos are marketing
/// material for a public listing; seller contact details are the sensitive
/// thing, and those never appear in this bucket.
const String _photoBucket = 'listing-photos';

/// Content type for uploads.
///
/// Declared explicitly rather than inferred from the key, because the key
/// carries a client-supplied extension and the seller chooses it.
const String _photoContentType = 'image/jpeg';

/// The file extension of [filename], lower-cased and dot-prefixed.
///
/// Defaults to `.jpg` when there is no usable extension, so the object is still
/// served as an image rather than as an opaque download.
String _extensionOf(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot < 0 || dot == filename.length - 1) return '.jpg';
  final extension = filename.substring(dot).toLowerCase();
  return RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(extension) ? extension : '.jpg';
}

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
    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_create_listing',
        params: buildCreateParams(listing, status),
      ),
      action: 'createListing',
    );
    return response['id'] as String;
  }

  /// Update an existing listing. Owner-scoped server-side.
  Future<ListingStatus> updateListing({
    required String listingId,
    Listing? listing,
    ListingStatus? status,
  }) async {
    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_update_listing',
        params: buildUpdateParams(listingId, listing, status),
      ),
      action: 'updateListing',
    );
    return ListingStatus.fromWire(response['status'] as String);
  }

  /// RPC parameters for `v1_create_listing`.
  ///
  /// Extracted so the mapping can be asserted without a Supabase client. G-12
  /// and G-13 both existed because this map silently omitted columns the table
  /// had: nobody could see a missing key, and the RPC had no parameter to
  /// receive it even if they had. A test that enumerates the keys is the only
  /// thing that reliably catches the next omission.
  @visibleForTesting
  static Map<String, Object?> buildCreateParams(
    Listing listing,
    ListingStatus status,
  ) {
    final json = listing.toJson();
    return <String, Object?>{
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
      // HYA-300: parcel number for the duplicate/missing-kitta signals. Null
      // means "not provided" (the wizard sends null for blank); the RPC
      // trims and length-caps server-side.
      'p_kitta_number': json['kitta_number'],
      'p_bedrooms': json['bedrooms'],
      'p_bathrooms': json['bathrooms'],
      'p_status': status.wireName,
    };
  }

  /// RPC parameters for `v1_update_listing`.
  ///
  /// Every parameter other than `p_listing_id` follows the server's
  /// coalesce(p_x, x) convention, so a null means "leave this alone". That is
  /// also why passing the whole [Listing] is safe: fields the caller did not
  /// touch arrive null and are preserved server-side rather than blanked.
  @visibleForTesting
  static Map<String, Object?> buildUpdateParams(
    String listingId,
    Listing? listing,
    ListingStatus? status,
  ) {
    final json = listing?.toJson();
    return <String, Object?>{
      'p_listing_id': listingId,
      'p_title': json?['title'],
      'p_description': json?['description'],
      'p_price_npr': json?['price_npr'],
      'p_area_sqm': json?['area_sqm'],
      // G-13: the seven local area units had no parameters at all, so a seller
      // who entered 5 aana 4 paisa could never change them.
      'p_area_ropani': json?['area_ropani'],
      'p_area_aana': json?['area_aana'],
      'p_area_paisa': json?['area_paisa'],
      'p_area_dam': json?['area_dam'],
      'p_area_bigha': json?['area_bigha'],
      'p_area_kattha': json?['area_kattha'],
      'p_area_dhur': json?['area_dhur'],
      'p_district': json?['district'],
      'p_city': json?['city'],
      'p_ward': json?['ward'],
      'p_road_access_ft': json?['road_access_ft'],
      // HYA-300: see buildCreateParams. Coalesce server-side means null is
      // "leave alone", so a cleared wizard field cannot blank a stored kitta
      // (same limitation as description).
      'p_kitta_number': json?['kitta_number'],
      'p_bedrooms': json?['bedrooms'],
      'p_bathrooms': json?['bathrooms'],
      'p_status': status?.wireName,
    };
  }

  /// RPC parameters for `v1_report_listing`, exposed for tests.
  ///
  /// Takes the already-trimmed details: trimming is the caller's job
  /// ([reportListing]), and asserting here pins the wire contract so the
  /// description a moderator reads never carries stray whitespace.
  ///
  /// `p_reason` uses [ReportReason.wireName] rather than `.name` — the two
  /// differ for every multi-word reason, and the RPC's enum cast is the only
  /// thing that would catch it.
  @visibleForTesting
  static Map<String, Object?> buildReportListingParams({
    required String listingId,
    required ReportReason reason,
    String? details,
  }) =>
      <String, Object?>{
        'p_listing_id': listingId,
        'p_reason': reason.wireName,
        'p_details': details,
      };

  /// Uploads one photo for a listing and returns its public URL and path.
  ///
  /// The Storage path is `<userId>/<random>.<ext>`: the leading folder must be
  /// the seller's own id, because `listing_photos_storage_insert` only permits
  /// writes whose first folder segment equals `auth.uid()`. Uploading before
  /// the listing exists is therefore deliberate: the path needs no listing id,
  /// and a seller who abandons the wizard leaves an orphaned file rather than a
  /// half-created listing.
  ///
  /// Both values travel together because the attach step persists the path
  /// alongside the URL (HYA-300): re-deriving it from the URL later would be
  /// the fragile regex the signals migration deliberately refused to write.
  ///
  /// The extension is taken from [filename] because the bucket serves images by
  /// content type, and a key with no extension is served as octet-stream.
  Future<PhotoAttachment> uploadListingPhoto({
    required String userId,
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final extension = _extensionOf(filename);
      final path = '$userId/${DateTime.now().microsecondsSinceEpoch}$extension';

      await _client.storage.from(_photoBucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: _photoContentType),
          );

      final url = _client.storage.from(_photoBucket).getPublicUrl(path);
      return (url: url, storagePath: path);
    } on StorageException catch (e) {
      final mapped = PostgrestErrorMapper.mapStorage(e, action: 'uploadPhoto');
      _logFailure(mapped, action: 'uploadPhoto', cause: e);
      throw mapped;
    }
  }

  /// Attaches already-uploaded photos to [listingId], in the order given.
  ///
  /// Done after the listing row exists because `listing_photos.listing_id` is a
  /// foreign key. `listing_photos_insert_own` checks that the caller owns the
  /// listing, so a seller cannot attach a photo to somebody else's.
  ///
  /// Inserted one row per call rather than as a batch so a failure part-way
  /// through leaves the earlier photos attached and retryable. Re-reading the
  /// seller's attached URLs before retrying prevents duplicate photo rows on
  /// the same draft (the table has no `(listing_id, url)` unique constraint).
  Future<void> attachListingPhotos(
    String listingId,
    List<PhotoAttachment> photos,
  ) async {
    if (photos.isEmpty) return;

    final rows = await _guard(
      () => _client
          .from('listing_photos')
          .select('url')
          .eq('listing_id', listingId),
      action: 'getAttachedListingPhotos',
    );
    final attached = rows.map((row) => row['url'] as String).toSet();

    for (var i = 0; i < photos.length; i++) {
      if (attached.contains(photos[i].url)) continue;
      await _guard(
        () => _client.from('listing_photos').insert(<String, Object?>{
          'listing_id': listingId,
          'url': photos[i].url,
          'sort_order': i,
          // HYA-300: the duplicate-photo signal groups on this, never on a
          // regexed URL. Null for pre-path rows, which stay URL-matched.
          'storage_path': photos[i].storagePath,
        }),
        action: 'attachListingPhotos',
      );
      attached.add(photos[i].url);
    }
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

  /// Reports a listing to the moderation queue (HYA-263).
  ///
  /// Returns the server's stored report rather than void, so the app can show
  /// the reason that was actually recorded instead of assuming the submission
  /// worked because nothing was thrown.
  ///
  /// Lives here rather than on `AdminRepository` because it is a buyer action
  /// on someone else's listing — the same family as [contactSeller] — and only
  /// the two admin methods are admin-scoped.
  ///
  /// Throws rather than returning a sentinel, because each failure is
  /// meaningfully worded for the buyer:
  ///
  /// * `AuthFailureException`   - not signed in
  /// * `ValidationException`    - already reported this listing, or your own,
  ///                              or `other` with no description
  /// * `NetworkException`       - transport failure, retryable
  Future<ListingReport> reportListing({
    required String listingId,
    required ReportReason reason,
    String? details,
  }) async {
    final trimmedDetails = details?.trim();

    // Checked client-side as well as server-side (Rule 6). The RPC refuses this
    // with 22023, but catching it here means the buyer sees the complaint
    // against the field they typed into rather than as a snackbar after a round
    // trip. `other` with nothing to say is not actionable, so the form should
    // have asked for the description before submitting.
    if (reason.requiresDetails &&
        (trimmedDetails == null || trimmedDetails.isEmpty)) {
      throw const ValidationException(
        code: 'validation.reportDetailsRequired',
        messageEn: 'Please describe the problem so our team can act on it.',
        messageNe: 'कृपया समस्या बयान गर्नुहोस्, हाम्रो टोलीले कारबाही लिन '
            'सक्नेछ।',
      );
    }

    final response = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'v1_report_listing',
        params: buildReportListingParams(
          listingId: listingId,
          reason: reason,
          details: trimmedDetails,
        ),
      ),
      action: 'reportListing',
    );

    return ListingReport.fromJson(response);
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
