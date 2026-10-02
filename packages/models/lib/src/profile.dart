import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// User roles in nBhumi.
enum UserRole {
  buyer,
  agent,
  admin,
}

/// KYC verification tiers.
enum KycTier {
  none,
  account,
  identity,
  property,
}

/// A user profile linked to Supabase Auth.
@freezed
class Profile with _$Profile {
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
