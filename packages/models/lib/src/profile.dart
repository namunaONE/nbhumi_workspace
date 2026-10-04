import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// User roles in nBhumi.
///
/// Enforced server-side by `private.is_admin()`; the client only reads it to
/// decide which navigation to show, never to authorise anything.
enum UserRole {
  /// Default role. Can browse, save and reveal seller contact.
  buyer,

  /// Can post listings. Also requires KYC identity verification (M3).
  agent,

  /// Can approve, reject, suspend and verify. Assigned out of band.
  admin,
}

/// KYC verification tiers (DATA.md).
///
/// Doc-check only — nBhumi never claims legal verification of a document.
enum KycTier {
  /// Nothing verified beyond the magic link.
  none,

  /// Email confirmed via magic link. Every account reaches this.
  account,

  /// Citizenship document checked by an admin. Grants the verified badge.
  identity,

  /// Lalpurja and/or Tiro Rasid checked per listing.
  property,
}

/// A user profile linked to Supabase Auth.
@freezed
sealed class Profile with _$Profile {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Profile({
    required String id,
    required String email,
    required String fullName,
    String? phone,
    @Default(UserRole.buyer) UserRole role,
    @Default(false) bool isVerified,
    @Default(KycTier.none) KycTier kycTier,
    String? agencyName,
    String? agencyRegNo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
