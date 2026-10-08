import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_reveal.freezed.dart';
part 'my_reveal.g.dart';

/// One seller contact the caller revealed, for the Activity page.
///
/// Unlike the contact-release model this carries no phone or email: the row
/// answers "which listing did I view, and is my access still valid" without
/// re-exposing contact data from local state. The phone itself is shown only
/// from a fresh `v1_contact_seller` call while `isValidAt` holds.
@freezed
sealed class MyReveal with _$MyReveal {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MyReveal({
    required String listingId,

    /// Listing title at read time. Null when the listing is no longer
    /// visible to the caller (unpublished since the reveal); the row still
    /// renders with a fallback title.
    String? listingTitle,
    DateTime? revealedAt,
    DateTime? expiresAt,
  }) = _MyReveal;

  factory MyReveal.fromJson(Map<String, dynamic> json) =>
      _$MyRevealFromJson(json);

  // Private constructor hook so the generated mixin can implement isValidAt
  // below. Without it build_runner emits a class that fails to satisfy the
  // sealed interface (same pattern as SellerContact).
  const MyReveal._();

  /// Whether the reveal is still valid.
  ///
  /// Same 24-hour server window as `v1_contact_seller`: a null [expiresAt]
  /// counts as valid (payload predates the field), otherwise the instant
  /// must lie in the future.
  bool isValidAt(DateTime now) {
    final expiry = expiresAt;
    return expiry == null || expiry.isAfter(now);
  }
}
