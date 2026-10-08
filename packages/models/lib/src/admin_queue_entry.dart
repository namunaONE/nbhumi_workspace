import 'package:freezed_annotation/freezed_annotation.dart';

import 'listing.dart';
import 'queue_sla.dart';

part 'admin_queue_entry.freezed.dart';
part 'admin_queue_entry.g.dart';

/// The seller summary embedded in a queue row.
///
/// Narrower than `ListingSeller` and wider in one respect: it carries
/// `agency_reg_no`, which the browse and detail RPCs omit because a public card
/// has no use for it but an admin checking a brokerage needs it. Deliberately
/// still carries no `email` or `phone` — contact details reach a buyer only
/// through the rate-limited `v1_contact_seller`, and widening that boundary for
/// admin convenience would undo HYA-252.
@freezed
sealed class QueueSeller with _$QueueSeller {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory QueueSeller({
    required String id,
    String? fullName,
    String? role,
    @Default(false) bool isVerified,
    @Default('none') String kycTier,
    String? agencyName,
    String? agencyRegNo,
  }) = _QueueSeller;

  factory QueueSeller.fromJson(Map<String, dynamic> json) =>
      _$QueueSellerFromJson(json);
}

/// One row in the admin verification queue.
///
/// Mirrors a single entry of `v1_admin_get_queue`. It is not a
/// [ListingSummary]: the queue is admin-scoped, so it carries
/// [rejectionReason] and [reviewedAt] (a seller may not see why their own
/// listing was rejected while it is still pending, but the reviewer sees the
/// previous verdict on a resubmission), and it omits `is_favorite`
/// and `description`, which are of no use on a row an admin is triaging.
///
/// [submittedAt] is the field this model exists for. See [QueueSla] for why the
/// SLA is computed in Dart rather than returned by the RPC.
@freezed
sealed class AdminQueueEntry with _$AdminQueueEntry {
  // explicitToJson forces the generator to call toJson() on the nested
  // QueueSeller. Same reason as ListingDetail: without it the encoder emits the
  // private implementation object and the round-trip test fails on a cast.
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory AdminQueueEntry({
    required String id,
    required String title,
    required String district,
    required String city,
    required int priceNpr,
    required PropertyType propertyType,
    required ListingPurpose listingPurpose,
    required ListingStatus status,
    required QueueSeller seller,
    String? ward,
    double? areaSqm,
    int? areaRopani,
    int? areaAana,
    int? areaPaisa,
    int? areaDam,
    int? areaBigha,
    int? areaKattha,
    int? areaDhur,

    /// Cover photo for the queue row, joined server-side.
    String? photoUrl,

    /// Total photos attached. Shown as a warning when below the 3 the seller is
    /// asked for in the wizard, so a reviewer sees it without opening the row.
    @Default(0) int photoCount,

    String? rejectionReason,

    /// When the seller submitted this for review. Null for a draft.
    DateTime? submittedAt,

    /// When an admin last acted on it. Null while still pending.
    DateTime? reviewedAt,
    DateTime? createdAt,
  }) = _AdminQueueEntry;

  factory AdminQueueEntry.fromJson(Map<String, dynamic> json) =>
      _$AdminQueueEntryFromJson(json);

  /// How this listing stands against the 48-hour review SLA.
  ///
  /// A convenience over [QueueSla.fromSubmittedAt] so widgets read
  /// `entry.sla` rather than threading a clock through every row. Widgets that
  /// need a stable value across rebuilds should compute it once upstream
  /// and pass it down, since this re-evaluates on every call.
  }

/// The photo floor the post-listing wizard asks sellers for.
///
/// A shared constant rather than a literal at the call site: the wizard
/// (features/post_listing), the review dialog and the queue row all need to
/// agree on the number, and three literals is three chances to disagree.
const int minPhotosPerListing = 3;

/// Derived, non-wire facts about an [AdminQueueEntry].
///
/// An extension rather than getters on the class because Freezed 4 requires
/// those to live on the generated `._` constructor. Keeping them here means the
/// logic is readable in this file and unit-testable, rather than hidden
/// behind a generated one.
extension AdminQueueEntryX on AdminQueueEntry {
  /// How this listing stands against the 48-hour review SLA.
  ///
  /// A convenience over [QueueSla.fromSubmittedAt] so widgets read `entry.sla`
  /// rather than threading a clock through every row. A widget that needs the
  /// value stable across rebuilds should compute it once in the ViewModel and
  /// pass it down, because this re-evaluates on every call.
  QueueSla sla({DateTime? now}) =>
      QueueSla.fromSubmittedAt(submittedAt, now: now);

  /// Whether this listing has fewer photos than the wizard asks for.
  ///
  /// A queued listing below [minPhotosPerListing] is worth a second look,
  /// automatically a rejection — the reviewer decides. This only surfaces the
  /// gap so it is visible without opening the row.
  bool get isUnderPhotoMinimum => photoCount < minPhotosPerListing;
}

/// The tabs across the top of the queue, with their counts.
///
/// WIREFRAMES.md Screen 4 shows a count on each tab ("Pending (12)"). The RPC
/// returns counts for every status it lists regardless of which tab is active,
/// so this is one round trip rather than one per tab.
///
/// Drafts are absent by design: a draft is private work in progress,
/// and an admin queue full of half-written listings would be noise. The RPC
/// deliberately excludes it from both the counts and the pages.
@freezed
sealed class QueueCounts with _$QueueCounts {
  const factory QueueCounts({
    @Default(0) int pendingReview,
    @Default(0) int live,
    @Default(0) int rejected,
    // No unpublished tab exists: the queue is a verification worklist and an
    // unpublished listing awaits nothing. The count is tracked (the RPC sends
    // it) so a future tab can reuse it, but nothing reads it today.
    @Default(0) int unpublished,
  }) = _QueueCounts;

  factory QueueCounts.fromJson(Map<String, dynamic> json) {
    // The RPC builds this with json_object_agg keyed by the *enum label*, so a
    // status with no rows is absent from the object rather than present as 0.
    // Defaulting each field to 0 is therefore load-bearing, not cosmetic: an
    // admin with an empty rejected tab should read 0, not null.
    int read(String key) => (json[key] as num?)?.toInt() ?? 0;
    return QueueCounts(
      pendingReview: read('pending_review'),
      live: read('live'),
      rejected: read('rejected'),
      unpublished: read('unpublished'),
    );
  }

  }

/// The keyset cursor for `v1_admin_get_queue`.
///
/// Opaque, and deliberately a distinct type from `ListingCursor`: the two
/// cursors order by different keys, and passing one where the other is expected
/// would silently restart pagination from the top rather than fail loudly.
///
/// [submittedAt] is not unique — same-transaction submissions share a timestamp
/// — so [id] is part of the cursor, not decoration. That is why the SQL builds
/// it from an ordered array rather than from independent `max()` calls; see the
/// note in `20261005035118_admin_verification_queue_part2_functions.sql`.
///
/// Hand-written rather than Freezed. It is not a wire model on its own: it
/// arrives nested inside `QueuePage`'s `next_cursor` and that nesting is parsed
/// by [QueuePage.fromJson], so json_serializable never needs to generate a
/// `fromJson` for this type. Two generated classes for two fields would buy
/// nothing, and the strict parsing below is clearer written out.
@immutable
class QueueCursor {
  /// Creates a cursor pointing at the last row of a page.
  const QueueCursor({required this.submittedAt, required this.id});

  /// Parses the RPC's `next_cursor` object.
  ///
  /// Returns null when [json] is null, which is how the server says "that was
  /// the last page". A malformed non-null cursor throws rather than returning
  /// null: treating a corrupt cursor as end-of-list would leave the admin
  /// believing the queue is empty when it is not.
  static QueueCursor? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final submittedAt = json['submitted_at'];
    final id = json['id'];
    if (submittedAt is! String || id is! String) {
      throw FormatException(
        'QueueCursor expected submitted_at and id strings, got '
        '${submittedAt.runtimeType} and ${id.runtimeType}',
        json.toString(),
      );
    }
    return QueueCursor(
      submittedAt: DateTime.parse(submittedAt),
      id: id,
    );
  }

  /// Submission time of the last row on the page just read.
  final DateTime submittedAt;

  /// Id of that row, which breaks ties when several share a [submittedAt].
  final String id;

  /// RPC parameters for the page that follows this cursor.
  ///
  /// `p_cursor` is sent as an ISO-8601 string in UTC rather than as a
  /// [DateTime], matching how the rest of the repository sends timestamps to
  /// PostgREST.
  Map<String, Object?> toRpcParams() => <String, Object?>{
        'p_cursor': submittedAt.toUtc().toIso8601String(),
        'p_cursor_id': id,
      };

  @override
  bool operator ==(Object other) =>
      other is QueueCursor &&
      other.submittedAt == submittedAt &&
      other.id == id;

  @override
  int get hashCode => Object.hash(submittedAt, id);

  @override
  String toString() => 'QueueCursor($submittedAt, $id)';
}

/// One page of the verification queue.
///
/// Hand-written for the same reason as [QueueCursor]: `next_cursor` is a nested
/// object rather than a flat field, and [QueuePage.fromJson] composes it by
/// hand. Generating a class here would mean the codegen would need a converter
/// for a type whose parsing rule is the interesting part.
@immutable
class QueuePage {
  /// Creates a page of queue results.
  const QueuePage({
    this.entries = const <AdminQueueEntry>[],
    this.counts = const QueueCounts(),
    this.nextCursor,
  });

  /// Parses the RPC's top-level response object.
  factory QueuePage.fromJson(Map<String, dynamic> json) => QueuePage(
        entries: (json['entries'] as List<dynamic>? ?? <dynamic>[])
            .map((e) => AdminQueueEntry.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        counts: QueueCounts.fromJson(
          json['counts'] as Map<String, dynamic>? ?? <String, dynamic>{},
        ),
        nextCursor: QueueCursor.fromJson(
          json['next_cursor'] as Map<String, dynamic>?,
        ),
      );

  /// One page of the verification queue.
  final List<AdminQueueEntry> entries;

  /// Tab counts, for every status the queue shows.
  final QueueCounts counts;

  /// Null when this was the final page.
  final QueueCursor? nextCursor;

  /// Whether another page follows.
  bool get hasMore => nextCursor != null;

  /// Whether this page returned no rows.
  bool get isEmpty => entries.isEmpty;

  /// An empty page, for a status with nothing in it.
  ///
  /// Distinct from "no page loaded yet": an empty page is a successful answer
  /// and should render as "nothing to review", not as a spinner.
  static const QueuePage empty = QueuePage();

  @override
  bool operator ==(Object other) =>
      other is QueuePage &&
      other.hasMore == hasMore &&
      other.counts == counts &&
      _sameEntries(other.entries, entries);

  /// Element-wise list comparison.
  ///
  /// Written out rather than imported: `listEquals` lives in Flutter's
  /// `foundation`, and models has no Flutter dependency on purpose. Dart's
  /// `package:collection` has no equivalent either. A private helper keeps the
  /// package dependency-free and the intent obvious.
  static bool _sameEntries(List<AdminQueueEntry> a, List<AdminQueueEntry> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(entries),
        counts,
        nextCursor,
      );

  @override
  String toString() =>
      'QueuePage(${entries.length} entries, hasMore: $hasMore)';
}

/// Derived, non-wire facts about [QueueCounts].
extension QueueCountsX on QueueCounts {
  /// The count for [status], or 0 for a status the queue does not show.
  ///
  /// Exhaustive over [ListingStatus] on purpose: adding a status to the enum
  /// should be a compile error here rather than a silently missing tab count.
  int forStatus(ListingStatus status) => switch (status) {
        ListingStatus.pendingReview => pendingReview,
        ListingStatus.live => live,
        ListingStatus.rejected => rejected,
        // A draft is never in the queue, so it has no tab.
        ListingStatus.draft => 0,
        // Unpublished has no tab either (see the field comment): 0 here means
        // "not tracked by the tab bar", and unpublished listings are reached
        // through user lookup and direct links instead.
        ListingStatus.unpublished => 0,
      };
}

/// What an admin decided about a listing.
///
/// Deliberately a two-value enum rather than a boolean `approved`. A boolean
/// invites a `true` meaning "approve" in one place and "reviewed" elsewhere,
/// and the rejection path carries a reason the approval path does not.
enum ReviewDecision {
  /// Publish the listing.
  approve,

  /// Return the listing to the seller with a reason.
  reject,
}

/// An action taken by an admin, from `audit_log`.
///
/// Every approve and reject writes one of these (Rule 8). Read via RLS, which
/// admits admins only — see `audit_log_select_admin`.
///
/// [details] is deliberately left as a raw map. Its shape is per-action, and
/// typing every future action's payload into this model would make adding an
/// admin action a breaking change to a shared package. The accessors on
/// [AuditLogEntryX] cover the two shapes that exist today.
@freezed
sealed class AuditLogEntry with _$AuditLogEntry {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AuditLogEntry({
    required String id,
    required String actorId,
    required String action,
    required String entityType,
    required String entityId,
    DateTime? createdAt,

    /// Action-specific payload: `{"to": "live"}` for an approve,
    /// `{"to": "rejected", "reason": "..."}` for a reject.
    Map<String, dynamic>? details,
  }) = _AuditLogEntry;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) =>
      _$AuditLogEntryFromJson(json);
}

/// Derived, non-wire facts about an [AuditLogEntry].
extension AuditLogEntryX on AuditLogEntry {
  /// The rejection reason, when this entry records one.
  String? get reason {
    final value = details?['reason'];
    return value is String ? value : null;
  }

  /// The status the entity moved to, when this entry records one.
  ///
  /// Null rather than a throw when `to` holds something unrecognised: an audit
  /// row written by a future version of the app should still render in the
  /// trail, just without a decoded status. Losing the whole row over an unknown
  /// enum value would be worse than showing it plainly.
  ListingStatus? get toStatus {
    final value = details?['to'];
    if (value is! String) return null;
    for (final status in ListingStatus.values) {
      if (status.wireName == value) return status;
    }
    return null;
  }

  /// Whether this entry concerns a listing, rather than a user or KYC document.
  bool get isListing => entityType == 'listing';
}
