import 'package:freezed_annotation/freezed_annotation.dart';

import 'listing.dart';

part 'listing_report.freezed.dart';
part 'listing_report.g.dart';

/// Why a buyer reported a listing.
///
/// Carries an explicit [wireName] for the same reason [ListingStatus] does:
/// `duplicateListing` is `duplicate_listing` in the database. Sending `.name`
/// straight to `v1_report_listing` would be caught by the RPC's own cast and
/// returned as a `22023` — which is why that RPC maps the failure to a readable
/// message rather than letting `22P02` escape — but a client that builds the
/// string itself should never produce the error in the first place.
///
/// Use [wireName] outbound and [fromWire] inbound. Never `.name` or `.byName`
/// for anything crossing the wire.
enum ReportReason {
  /// The same property is listed more than once.
  @JsonValue('duplicate_listing')
  duplicateListing('duplicate_listing'),

  /// Photos do not show the property being sold.
  @JsonValue('photos_misleading')
  photosMisleading('photos_misleading'),

  /// The price looks wrong for the size, location or condition.
  @JsonValue('price_suspicious')
  priceSuspicious('price_suspicious'),

  /// The pin does not match the stated address.
  @JsonValue('wrong_location')
  wrongLocation('wrong_location'),

  /// The seller says it is already sold.
  @JsonValue('already_sold')
  alreadySold('already_sold'),

  /// The seller asked to deal outside the platform.
  ///
  /// The most serious reason here, and the one a seller has the clearest
  /// motive to have reported by the wrong person. It stays a plain report
  /// rather than a direct action: the platform's role is to surface it to a
  /// human, and auto-punishing a seller on one buyer's word would be worse
  /// than the fraud it guards against.
  @JsonValue('seller_asked_offsite')
  sellerAskedOffsite('seller_asked_offsite'),

  /// The listing does not correspond to a real property.
  @JsonValue('fake_listing')
  fakeListing('fake_listing'),

  /// Anything else — requires [ListingReport.details].
  @JsonValue('other')
  other('other');

  /// Creates a reason with its Postgres wire value.
  ReportReason(this.wireName);

  /// The value the `report_reason` enum uses in Postgres.
  final String wireName;

  /// The reason whose [wireName] is [value].
  ///
  /// Throws [ArgumentError] for an unknown value rather than defaulting to
  /// [ReportReason.other]: silently reading an unrecognised reason as "other"
  /// would put a specific complaint in the "needs a description" bucket, and
  /// the CHECK constraint would then reject a report the buyer filed
  /// correctly.
  static ReportReason fromWire(String value) => values.firstWhere(
        (reason) => reason.wireName == value,
        orElse: () => throw ArgumentError.value(
          value,
          'value',
          'not a report_reason value',
        ),
      );
}

/// Where a report stands.
///
/// [ReportResolution] is a separate type rather than a subset of this enum
/// because the two travel in opposite directions: this is what the server
/// reports, that is what a caller asks for. A `ReportResolution` cannot be
/// `open`, so `resolveReport` has no invalid state to reject.
enum ReportStatus {
  /// Filed and not yet looked at.
  open,

  /// An admin acted on it — the listing was removed or corrected.
  actioned,

  /// An admin looked and found nothing wrong.
  dismissed,
}

/// How an admin closed a report.
///
/// Deliberately not a bool. "Actioned" and "dismissed" are different judgements
/// with different consequences for the seller, and a boolean invites reading
/// `true` as "the report was valid" in one place and "the admin did something"
/// in another.
enum ReportResolution {
  /// The report was justified; the listing was actioned.
  actioned,

  /// The report was unfounded; the listing stays up.
  dismissed,
}

/// The listing a report is about, as the admin queue shows it.
///
/// Narrower than `ListingSummary` on purpose: this is a moderation row, and it
/// carries the [status] because an admin triaging reports needs to know whether
/// the listing is still live before deciding — a report against a listing that
/// was already pulled is history rather than work.
@freezed
sealed class ReportedListing with _$ReportedListing {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ReportedListing({
    required String id,
    required String title,
    required int priceNpr,
    required ListingStatus status,
    required String district,
    required String city,
    required String sellerId,
  }) = _ReportedListing;

  factory ReportedListing.fromJson(Map<String, dynamic> json) =>
      _$ReportedListingFromJson(json);
}

/// Who filed a report.
///
/// Named deliberately, and this is the one place a buyer's identity reaches an
/// admin by way of a moderation queue. The reason it is defensible: the admin
/// needs to see that one account filed four reports this week, which is the
/// abuse the `unique (listing_id, reporter_id)` index limits but does not
/// prevent. Carries no `email` or `phone` — contact details reach a buyer only
/// through the rate-limited `v1_contact_seller`, and widening that boundary for
/// moderation convenience would undo HYA-252.
@freezed
sealed class ReportAuthor with _$ReportAuthor {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ReportAuthor({
    required String id,
    String? fullName,
    String? role,
    @Default(false) bool isVerified,
  }) = _ReportAuthor;

  factory ReportAuthor.fromJson(Map<String, dynamic> json) =>
      _$ReportAuthorFromJson(json);
}

/// One row in the admin reports queue.
///
/// Mirrors a single entry of `v1_admin_get_reports`. It is not a
/// [ListingReport]: that model is what a *buyer* gets back after filing, and it
/// deliberately carries neither [listing] nor [reporter], because the response
/// to "I reported this" has no business echoing back who else looked at it.
///
/// The nesting matters to the client for a practical reason: an admin
/// triaging a queue should not need a second round trip per row to see the
/// title and price of what is being reported.
@freezed
sealed class AdminReportEntry with _$AdminReportEntry {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory AdminReportEntry({
    required String id,
    required String listingId,
    required ReportReason reason,
    required ReportStatus status,
    required ReportedListing listing,
    required ReportAuthor reporter,
    String? details,
    DateTime? resolvedAt,
    DateTime? createdAt,
  }) = _AdminReportEntry;

  factory AdminReportEntry.fromJson(Map<String, dynamic> json) =>
      _$AdminReportEntryFromJson(json);
}

/// The confirmation a buyer receives after filing a report.
///
/// Returned by `v1_report_listing` rather than void so the app can show the
/// report id and the reason the server actually stored, instead of assuming the
/// submission worked because no exception was thrown.
///
/// Deliberately carries no `listing` or `reporter` object. Echoing the reporter
/// back would tell the buyer nothing they did not supply; echoing the listing
/// would make this a second, differently-shaped listing detail response.
@freezed
sealed class ListingReport with _$ListingReport {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ListingReport({
    required String reportId,
    required String listingId,
    required ReportReason reason,
    String? details,
    DateTime? createdAt,
  }) = _ListingReport;

  factory ListingReport.fromJson(Map<String, dynamic> json) =>
      _$ListingReportFromJson(json);
}

/// The keyset cursor for `v1_admin_get_reports`.
///
/// Opaque, and deliberately a distinct type from `QueueCursor`: the two
/// cursors order by different keys, and passing one where the other is expected
/// would silently restart pagination from the top rather than fail loudly.
///
/// [createdAt] is not unique — reports filed in one transaction share a
/// timestamp — so [id] is part of the cursor. That is why the SQL builds it
/// from an ordered array rather than from independent `max()` calls.
///
/// Hand-written for the same reason as `QueueCursor`: it arrives nested inside
/// `ReportPage`'s `next_cursor` and is parsed by [ReportPage.fromJson], so
/// json_serializable never needs to generate a `fromJson` for it.
@immutable
class ReportCursor {
  /// Creates a cursor pointing at the last row of a page.
  const ReportCursor({required this.createdAt, required this.id});

  /// Parses the RPC's `next_cursor` object.
  ///
  /// Returns null when [json] is null, which is how the server says "that was
  /// the last page". A malformed non-null cursor throws rather than returning
  /// null: treating a corrupt cursor as end-of-list would leave the admin
  /// believing the queue is empty when it is not.
  static ReportCursor? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final createdAt = json['created_at'];
    final id = json['id'];
    if (createdAt is! String || id is! String) {
      throw FormatException(
        'ReportCursor expected created_at and id strings, got '
        '${createdAt.runtimeType} and ${id.runtimeType}',
        json.toString(),
      );
    }
    return ReportCursor(
      createdAt: DateTime.parse(createdAt),
      id: id,
    );
  }

  /// Filing time of the last row on the page just read.
  final DateTime createdAt;

  /// Id of that row, which breaks ties when several share a [createdAt].
  final String id;

  /// RPC parameters for the page that follows this cursor.
  ///
  /// `p_cursor` is sent as an ISO-8601 string in UTC rather than as a
  /// [DateTime], matching how the rest of the repository sends timestamps to
  /// PostgREST.
  Map<String, Object?> toRpcParams() => <String, Object?>{
        'p_cursor': createdAt.toUtc().toIso8601String(),
        'p_cursor_id': id,
      };

  @override
  bool operator ==(Object other) =>
      other is ReportCursor &&
      other.createdAt == createdAt &&
      other.id == id;

  @override
  int get hashCode => Object.hash(createdAt, id);

  @override
  String toString() => 'ReportCursor($createdAt, $id)';
}

/// The tabs across the top of the reports queue, with their counts.
///
/// Same one-round-trip design as `QueueCounts`: the RPC counts every status
/// regardless of which tab is active.
@freezed
sealed class ReportCounts with _$ReportCounts {
  const factory ReportCounts({
    @Default(0) int open,
    @Default(0) int actioned,
    @Default(0) int dismissed,
  }) = _ReportCounts;

  /// Parses the RPC's `counts` object.
  ///
  /// The RPC builds this with `json_object_agg` keyed by the enum label, so a
  /// status with no rows is absent from the object rather than present as 0.
  /// Defaulting each field to 0 is load-bearing, not cosmetic: an admin with no
  /// dismissed reports should read 0, not null.
  factory ReportCounts.fromJson(Map<String, dynamic> json) {
    int read(String key) => (json[key] as num?)?.toInt() ?? 0;
    return ReportCounts(
      open: read('open'),
      actioned: read('actioned'),
      dismissed: read('dismissed'),
    );
  }
}

/// One page of the reports queue.
///
/// Hand-written for the same reason as `QueueCursor`: `next_cursor` is a nested
/// object rather than a flat field, and [ReportPage.fromJson] composes it by
/// hand.
@immutable
class ReportPage {
  /// Creates a page of report results.
  const ReportPage({
    this.entries = const <AdminReportEntry>[],
    this.counts = const ReportCounts(),
    this.nextCursor,
  });

  /// Parses the RPC's top-level response object.
  factory ReportPage.fromJson(Map<String, dynamic> json) => ReportPage(
        entries: (json['entries'] as List<dynamic>? ?? <dynamic>[])
            .map((e) => AdminReportEntry.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        counts: ReportCounts.fromJson(
          json['counts'] as Map<String, dynamic>? ?? <String, dynamic>{},
        ),
        nextCursor: ReportCursor.fromJson(
          json['next_cursor'] as Map<String, dynamic>?,
        ),
      );

  /// One page of the reports queue.
  final List<AdminReportEntry> entries;

  /// Tab counts, for every status the queue shows.
  final ReportCounts counts;

  /// Null when this was the final page.
  final ReportCursor? nextCursor;

  /// Whether another page follows.
  bool get hasMore => nextCursor != null;

  /// Whether this page returned no rows.
  bool get isEmpty => entries.isEmpty;

  /// An empty page, for a status with nothing in it.
  ///
  /// Distinct from "no page loaded yet": an empty page is a successful answer
  /// and should render as "nothing to review", not as a spinner.
  static const ReportPage empty = ReportPage();

  @override
  bool operator ==(Object other) =>
      other is ReportPage &&
      other.hasMore == hasMore &&
      other.counts == counts &&
      _sameEntries(other.entries, entries);

  /// Element-wise list comparison.
  ///
  /// Written out rather than imported: `listEquals` lives in Flutter's
  /// `foundation`, and models has no Flutter dependency on purpose.
  static bool _sameEntries(
    List<AdminReportEntry> a,
    List<AdminReportEntry> b,
  ) {
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
      'ReportPage(${entries.length} entries, hasMore: $hasMore)';
}

/// Derived, non-wire facts about [ReportCounts].
extension ReportCountsX on ReportCounts {
  /// The count for [status].
  int forStatus(ReportStatus status) => switch (status) {
        ReportStatus.open => open,
        ReportStatus.actioned => actioned,
        ReportStatus.dismissed => dismissed,
      };
}

/// Derived, non-wire facts about a report row.
extension ReportReasonX on ReportReason {
  /// Whether this reason is only meaningful alongside a description.
  ///
  /// The database enforces the same rule (`reason = 'other'` requires
  /// non-blank `details`) and `v1_report_listing` returns a readable `22023`
  /// for it. This is for the form: the details field can be required up front
  /// rather than after a round trip, which is the same client-then-server
  /// ordering Rule 6 asks for.
  bool get requiresDetails => this == ReportReason.other;
}
