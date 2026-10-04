import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_contact.freezed.dart';
part 'seller_contact.g.dart';

/// A seller's contact details, released by `v1_contact_seller`.
///
/// ### Why this is a separate model
///
/// This is the *only* type in the app carrying a seller's phone number or
/// email. Keeping it distinct from `ListingDetail` makes the exposure
/// auditable: grep for `SellerContact` and there is exactly one place contact
/// data enters the client, which is the `contactSeller` repository call, and
/// one place it is rendered.
///
/// Listing detail deliberately carries no contact fields, and
/// `v1_get_listing_detail` deliberately omits them from its response. A guest
/// browsing the platform must not be able to enumerate seller contacts, which
/// is what `v1_contact_seller` and its daily cap exist to prevent.
@freezed
sealed class SellerContact with _$SellerContact {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SellerContact({
    required String listingId,
    required String sellerId,
    String? sellerName,
    String? sellerPhone,
    String? sellerEmail,
    String? agencyName,
    @Default(false) bool isVerified,
    DateTime? revealedAt,
    DateTime? expiresAt,
  }) = _SellerContact;

  factory SellerContact.fromJson(Map<String, dynamic> json) =>
      _$SellerContactFromJson(json);

  // Private constructor hook so the generated mixin can implement isValidAt
  // below. Without it build_runner emits a class that fails to satisfy the
  // sealed interface.
  const SellerContact._();

  /// Whether the reveal is still valid.
  ///
  /// The server sets a 24 hour expiry to match its rate-limit window. The
  /// client checks it before re-displaying a cached value, so a phone number
  /// is not shown indefinitely from local storage.
  ///
  /// A null [expiresAt] counts as valid: it only arises from a payload that
  /// predates the expiry field, and treating that as expired would hide a
  /// contact the server just handed over.
  bool isValidAt(DateTime now) {
    // Copied to a local so it can be null-checked and then used; a getter on
    // `this` is not promotable in Dart.
    final expiry = expiresAt;
    return expiry == null || expiry.isAfter(now);
  }
}
