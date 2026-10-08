import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Repository for the profile Activity page (HYA-297).
///
/// Read-only by construction: every method is an owner-scoped read. Own
/// listings (any status) and own reveals pass RLS directly
/// (`listings_select_public_live` admits the seller;
/// `contact_logs_select_own` admits the buyer). Per-listing interest in the
/// caller's own listings goes through `v1_my_listing_reveals`, because
/// `contact_logs` rows belong to their buyers and RLS admits no seller read.
///
/// Every method maps transport failures onto the [AppException] hierarchy
/// (Rule 38) and logs with full context (Rule 37).
class ActivityRepository {
  /// Wraps a Supabase client.
  ActivityRepository(this._client);

  final SupabaseClient _client;

  /// The caller's own listings, newest first, any status.
  ///
  /// No seller filter nuance: RLS admits `auth.uid() = seller_id` for every
  /// status, so drafts and rejected rows the public feed never shows still
  /// return here. An empty list means no listings yet — a successful answer,
  /// not an error.
  Future<List<ListingSummary>> myListings() {
    return _guard(
      () async {
        final response = await _client
            .from('listings')
            .select(
              'id, seller_id, title, price_npr, district, city, '
              'property_type, listing_purpose, status, created_at, updated_at',
            )
            .order('created_at', ascending: false);
        return response
            .map(ListingSummary.fromJson)
            .toList(growable: false);
      },
      action: 'myListings',
    );
  }

  /// Seller-contact reveals the caller made, newest first.
  ///
  /// Titles come from a left-embedded `listings` read: live listings resolve,
  /// listings unpublished since the reveal arrive with a null title and the
  /// model renders a fallback. Carries no phone or email (see [MyReveal]).
  Future<List<MyReveal>> myReveals() {
    return _guard(
      () async {
        final response = await _client
            .from('contact_logs')
            .select('listing_id, revealed_at, expires_at, listings(title)')
            .order('revealed_at', ascending: false);
        return response.map((row) {
          final embedded = row['listings'];
          return MyReveal(
            listingId: row['listing_id'] as String,
            listingTitle: embedded is Map<String, dynamic>
                ? embedded['title'] as String?
                : null,
            revealedAt: row['revealed_at'] == null
                ? null
                : DateTime.parse(row['revealed_at'] as String),
            expiresAt: row['expires_at'] == null
                ? null
                : DateTime.parse(row['expires_at'] as String),
          );
        }).toList(growable: false);
      },
      action: 'myReveals',
    );
  }

  /// Per-listing reveal interest in the caller's own listings.
  ///
  /// Via `v1_my_listing_reveals`: aggregates (count + latest timestamp)
  /// with no buyer identity, by privacy design. Only listings with at least
  /// one reveal return; an empty list means no interest yet.
  Future<List<ListingRevealStat>> listingRevealStats() {
    return _guard(
      () async {
        final response = await _client.rpc<List<Map<String, dynamic>>>(
          'v1_my_listing_reveals',
        );
        return response
            .map(ListingRevealStat.fromJson)
            .toList(growable: false);
      },
      action: 'listingRevealStats',
    );
  }

  /// Runs [call], converting failures into the [AppException] hierarchy so
  /// callers only ever match on types they can render (Rule 38), and logging
  /// the failure with full context (Rule 37).
  Future<T> _guard<T>(
    Future<T> Function() call, {
    required String action,
  }) async {
    try {
      return await call();
    } on PostgrestException catch (e) {
      final mapped = PostgrestErrorMapper.map(e, action: action);
      AppLogger.error(
        'Activity failure in $action',
        context: logContext(
          action: action,
          detail: <String, Object?>{'code': mapped.code},
        ),
        error: e,
      );
      throw mapped;
    }
  }
}
