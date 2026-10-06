import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Repository for buyer-stored browse filters (HYA-268 C2b).
///
/// Owner-scoped by construction: RLS admits only the row owner, and `user_id`
/// on writes is the session's own id passed explicitly — the server re-checks
/// it, so a spoofed id fails there. Explicit rather than `auth.currentUser`
/// for the same testability reason the favorites repository takes its user
/// id as a parameter.
///
/// Matching new listings against these rows (alerts) is C3 with a scheduler;
/// this repository stores, lists and deletes. Every method maps transport
/// failures onto the [AppException] hierarchy (Rule 38) and logs with full
/// context (Rule 37).
class SavedSearchRepository {
  /// Wraps a Supabase client.
  SavedSearchRepository(this._client);

  final SupabaseClient _client;

  /// The caller's saved searches, newest first.
  Future<List<SavedSearch>> savedSearches() async {
    final response = await _guard(
      () => _client
          .from('saved_searches')
          .select()
          .order('created_at', ascending: false),
      action: 'savedSearches',
    );

    return response.map(SavedSearch.fromJson).toList(growable: false);
  }

  /// Stores the current browse filter under [name] and returns the row.
  ///
  /// [filter] must not be empty: saving an unfiltered "everything" search
  /// would alert on every listing in the country. [name] must be non-blank;
  /// the UI generates one from the filter ("Houses in Kathmandu") so the
  /// seller rarely types.
  Future<SavedSearch> saveSearch({
    required String userId,
    required String name,
    required ListingFilter filter,
  }) async {
    final trimmedUser = _requireUser(userId);
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException(
        code: 'validation.savedSearchNameRequired',
        messageEn: 'Give this search a name first.',
        messageNe: 'पहिले यो खोजीलाई नाम दिनुहोस्।',
      );
    }
    if (filter.isEmpty) {
      throw const ValidationException(
        code: 'validation.savedSearchEmptyFilter',
        messageEn:
            'Add at least one filter — an unfiltered search would alert on '
            'every listing.',
        messageNe:
            'कम्तीमा एउटा फिल्टर थप्नुहोस् — फिल्टरबिनाको खोजीले हरेक '
            'विज्ञापनमा सूचना दिन्छ।',
      );
    }
    if (filter.minPriceNpr != null &&
        filter.maxPriceNpr != null &&
        filter.minPriceNpr! > filter.maxPriceNpr!) {
      throw const ValidationException(
        code: 'validation.savedSearchPriceRange',
        messageEn: 'The minimum price cannot be above the maximum.',
        messageNe: 'न्यूनतम मूल्य अधिकतमभन्दा बढी हुन सक्दैन।',
      );
    }
    if (filter.minAreaSqm != null &&
        filter.maxAreaSqm != null &&
        filter.minAreaSqm! > filter.maxAreaSqm!) {
      throw const ValidationException(
        code: 'validation.savedSearchAreaRange',
        messageEn: 'The minimum area cannot be above the maximum.',
        messageNe: 'न्यूनतम क्षेत्रफल अधिकतमभन्दा बढी हुन सक्दैन।',
      );
    }

    final row = await _guard(
      () => _client
          .from('saved_searches')
          .insert(<String, Object?>{
            'user_id': trimmedUser,
            'name': trimmedName,
            'district': filter.district,
            'property_type': filter.propertyType?.name,
            'listing_purpose': filter.listingPurpose?.name,
            'min_price_npr': filter.minPriceNpr,
            'max_price_npr': filter.maxPriceNpr,
            'min_area_sqm': filter.minAreaSqm,
            'max_area_sqm': filter.maxAreaSqm,
          })
          .select()
          .single(),
      action: 'saveSearch',
    );
    return SavedSearch.fromJson(row);
  }

  /// Deletes a saved search. Deleting what is already gone succeeds.
  Future<void> deleteSearch(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.savedSearchIdRequired',
        messageEn: 'That saved search could not be found.',
        messageNe: 'यो सेभ गरिएको खोजी फेला परेन।',
      );
    }

    await _guard(
      () => _client.from('saved_searches').delete().eq('id', trimmed),
      action: 'deleteSearch',
    );
  }

  /// Rejects blank user ids client-side (Rule 6) before any round trip.
  String _requireUser(String userId) {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        code: 'validation.savedSearchSignInRequired',
        messageEn: 'Sign in to save searches.',
        messageNe: 'खोजी सेभ गर्न साइन इन गर्नुहोस्।',
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
