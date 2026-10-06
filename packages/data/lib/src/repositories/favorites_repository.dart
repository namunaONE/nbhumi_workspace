import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Columns read for each saved listing, matching [ListingSummary].
///
/// Kept as a named constant rather than inline so the shelf query and its
/// test assert on the same string: a missing key means a card renders blank,
/// and a blank card is invisible in review but obvious to a seller.
const String _savedListingColumns =
    'id,seller_id,title,price_npr,district,city,property_type,'
    'listing_purpose,status,description,area_sqm,area_ropani,area_aana,'
    'area_paisa,area_dam,area_bigha,area_kattha,area_dhur,ward,'
    'road_access_ft,created_at,updated_at,listing_photos(url,sort_order)';

/// Repository for buyer bookmarks (HYA-268 C1).
///
/// Owner-scoped by construction: RLS admits only the row owner, and `user_id`
/// on writes is the session's own id passed explicitly — the server re-checks
/// it (`WITH CHECK user_id = current_uid`), so a spoofed id fails there, not
/// here. Taking it as a parameter rather than reading `auth.currentUser`
/// keeps every path unit-testable without a signed-in client, the same
/// reason `uploadListingPhoto` takes its `userId` as a parameter.
///
/// Favorite state is read from this table, not from the `is_favorite` wire
/// field, which the browse/detail RPCs still hardcode to false. Flipping it
/// server-side means restating both RPC bodies and is C2, verified against a
/// live database; until then the provider set below is the single source of
/// truth and the wire field is ignored.
///
/// Every method maps transport failures onto the [AppException] hierarchy
/// (Rule 38) and logs with full context (Rule 37).
class FavoritesRepository {
  /// Wraps a Supabase client.
  FavoritesRepository(this._client);

  final SupabaseClient _client;

  /// Ids the caller bookmarked.
  Future<Set<String>> favoriteIds() async {
    final response = await _guard(
      () => _client.from('favorites').select('listing_id'),
      action: 'favoriteIds',
    );
    return <String>{
      for (final row in response) row['listing_id'] as String,
    };
  }

  /// Saved listings as cards, newest bookmark first.
  ///
  /// One round trip: favorites joined to their listings with embedded photos,
  /// cover picked by lowest `sort_order` in Dart. Rows whose listing is no
  /// longer visible (unpublished after bookmarking — RLS admits live-or-own)
  /// come back with a null embed and are skipped rather than rendered blank:
  /// a disappearing bookmark needs no error, it needs quiet pruning, and the
  /// next shelf read drops it the same way.
  Future<List<ListingSummary>> savedListings() async {
    final response = await _guard(
      () => _client
          .from('favorites')
          .select('listing_id, listing:listings($_savedListingColumns)')
          .order('created_at', ascending: false),
      action: 'savedListings',
    );

    final saved = <ListingSummary>[];
    for (final row in response) {
      final embedded = row['listing'];
      if (embedded is! Map<String, dynamic>) continue;
      saved.add(ListingSummary.fromJson(_withCover(embedded)));
    }
    return saved;
  }

  /// Bookmarks [listingId] for [userId]. Idempotent from the buyer's view:
  /// bookmarking twice answers "already saved" rather than failing silently
  /// or doubling.
  Future<void> addFavorite({
    required String userId,
    required String listingId,
  }) async {
    final trimmedUser = _requireUser(userId);
    final trimmed = _requireId(listingId);

    try {
      await _guard(
        () => _client.from('favorites').insert(<String, Object?>{
          'user_id': trimmedUser,
          'listing_id': trimmed,
        }),
        action: 'addFavorite',
      );
    } on ValidationException catch (e) {
      // The composite PK fired: this exact bookmark already exists. The
      // generic duplicate wording would read as a form error, so it is
      // reworded here the way deleteMyAccount rewords its not-found.
      if (e.code == 'validation.duplicate') {
        throw ValidationException(
          code: 'validation.alreadySaved',
          messageEn: 'That property is already in your saved list.',
          messageNe: 'यो घरजग्गा पहिले नै तपाईंको सूचीमा छ।',
          context: 'addFavorite',
          cause: e,
        );
      }
      rethrow;
    }
  }

  /// Removes a bookmark. Removing what was never bookmarked succeeds: the
  /// end state (not saved) is what the caller asked for either way.
  Future<void> removeFavorite({
    required String userId,
    required String listingId,
  }) async {
    final trimmedUser = _requireUser(userId);
    final trimmed = _requireId(listingId);

    await _guard(
      () => _client
          .from('favorites')
          .delete()
          .eq('user_id', trimmedUser)
          .eq('listing_id', trimmed),
      action: 'removeFavorite',
    );
  }

  /// Flips the bookmark and returns the new state: true means saved now.
  ///
  /// Read-then-write costs two round trips on a tap-frequency action, which
  /// is acceptable: the alternative (blind insert, delete on 23505) turns a
  /// conflict into control flow and would read as a failure in the logs.
  Future<bool> toggleFavorite({
    required String userId,
    required String listingId,
  }) async {
    final trimmedUser = _requireUser(userId);
    final trimmed = _requireId(listingId);
    final saved = await favoriteIds();
    if (saved.contains(trimmed)) {
      await removeFavorite(userId: trimmedUser, listingId: trimmed);
      return false;
    }
    await addFavorite(userId: trimmedUser, listingId: trimmed);
    return true;
  }

  /// Picks the cover photo out of the embedded `listing_photos`.
  ///
  /// Exposed for tests: cover selection is the one piece of shelf logic that
  /// can silently regress (wrong photo, or none) without any error surfacing.
  @visibleForTesting
  static Map<String, dynamic> withCoverForTest(
    Map<String, dynamic> embedded,
  ) =>
      _withCover(embedded);

  /// Copies [embedded] with `photo_url` set to the lowest `sort_order` photo.
  static Map<String, dynamic> _withCover(Map<String, dynamic> embedded) {
    final photos = embedded['listing_photos'];
    String? cover;
    var bestOrder = 1 << 30;
    if (photos is List) {
      for (final photo in photos) {
        if (photo is Map<String, dynamic>) {
          final order = (photo['sort_order'] as num?)?.toInt() ?? bestOrder;
          if (order < bestOrder) {
            bestOrder = order;
            cover = photo['url'] as String?;
          }
        }
      }
    }
    return <String, dynamic>{...embedded, 'photo_url': cover}
      ..remove('listing_photos');
  }

  /// Rejects blank ids client-side (Rule 6) before any round trip.
  String _requireId(String listingId) {
    final trimmed = listingId.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.favoriteIdRequired',
        messageEn: 'That listing could not be found. Refresh and try again.',
        messageNe: 'यो विज्ञापन फेला परेन। ताजा पारेर पुनः प्रयास गर्नुहोस्।',
      );
    }
    return trimmed;
  }

  /// Rejects blank user ids client-side (Rule 6) before any round trip.
  String _requireUser(String userId) {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.favoriteSignInRequired',
        messageEn: 'Sign in to save properties.',
        messageNe: 'घरजग्गा सेभ गर्न साइन इन गर्नुहोस्।',
      );
    }
    return trimmed;
  }

  /// Runs [call], converting transport failures into the [AppException]
  /// hierarchy (Rule 38) and logging with full context (Rule 37).
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
