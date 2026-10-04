import 'package:flutter/material.dart';

/// Custom color tokens for the nBhumi marketplace.
///
/// Reached via `Theme.of(context).extension<MarketplaceColors>()`. Widgets must
/// never hard-code these hex values (project rule: semantic roles only).
///
/// Every accent has a matching `on*` foreground. Material 3 asks for on-colour
/// pairs, and a chip filled with `saleOrange` using default black text fails
/// contrast on the light scheme — hence the pairs rather than a single value.
@immutable
class MarketplaceColors extends ThemeExtension<MarketplaceColors> {
  /// Creates a token set. Prefer [light] or [dark] over calling this directly.
  const MarketplaceColors({
    required this.verifiedGreen,
    required this.onVerifiedGreen,
    required this.saleOrange,
    required this.onSaleOrange,
    required this.rentBlue,
    required this.onRentBlue,
    required this.leaseTeal,
    required this.onLeaseTeal,
  });

  /// KYC-verified badge fill. Green reads as "checked" without needing an icon.
  final Color verifiedGreen;

  /// Foreground that meets contrast on [verifiedGreen].
  final Color onVerifiedGreen;

  /// Accent for `ListingPurpose.sale` chips.
  final Color saleOrange;

  /// Foreground for text on [saleOrange].
  final Color onSaleOrange;

  /// Accent for `ListingPurpose.rent` chips.
  final Color rentBlue;

  /// Foreground for text on [rentBlue].
  final Color onRentBlue;

  /// Accent for `ListingPurpose.lease` chips.
  final Color leaseTeal;

  /// Foreground for text on [leaseTeal].
  final Color onLeaseTeal;

  /// Light-mode tokens. Accents are dark enough to take white text.
  static const MarketplaceColors light = MarketplaceColors(
    verifiedGreen: Color(0xFF2E7D32),
    onVerifiedGreen: Color(0xFFFFFFFF),
    saleOrange: Color(0xFFE65100),
    onSaleOrange: Color(0xFFFFFFFF),
    rentBlue: Color(0xFF1565C0),
    onRentBlue: Color(0xFFFFFFFF),
    leaseTeal: Color(0xFF00695C),
    onLeaseTeal: Color(0xFFFFFFFF),
  );

  /// Dark-mode tokens. Purpose accents are lightened so they stay legible
  /// against a dark surface, so their foregrounds flip to dark.
  static const MarketplaceColors dark = MarketplaceColors(
    verifiedGreen: Color(0xFF66BB6A),
    onVerifiedGreen: Color(0xFF003300),
    saleOrange: Color(0xFFFF8A65),
    onSaleOrange: Color(0xFF3E1500),
    rentBlue: Color(0xFF64B5F6),
    onRentBlue: Color(0xFF00293F),
    leaseTeal: Color(0xFF4DB6AC),
    onLeaseTeal: Color(0xFF00322D),
  );

  @override
  MarketplaceColors copyWith({
    Color? verifiedGreen,
    Color? onVerifiedGreen,
    Color? saleOrange,
    Color? onSaleOrange,
    Color? rentBlue,
    Color? onRentBlue,
    Color? leaseTeal,
    Color? onLeaseTeal,
  }) {
    return MarketplaceColors(
      verifiedGreen: verifiedGreen ?? this.verifiedGreen,
      onVerifiedGreen: onVerifiedGreen ?? this.onVerifiedGreen,
      saleOrange: saleOrange ?? this.saleOrange,
      onSaleOrange: onSaleOrange ?? this.onSaleOrange,
      rentBlue: rentBlue ?? this.rentBlue,
      onRentBlue: onRentBlue ?? this.onRentBlue,
      leaseTeal: leaseTeal ?? this.leaseTeal,
      onLeaseTeal: onLeaseTeal ?? this.onLeaseTeal,
    );
  }

  @override
  MarketplaceColors lerp(ThemeExtension<MarketplaceColors>? other, double t) {
    if (other is! MarketplaceColors) return this;
    return MarketplaceColors(
      verifiedGreen: Color.lerp(verifiedGreen, other.verifiedGreen, t)!,
      onVerifiedGreen:
          Color.lerp(onVerifiedGreen, other.onVerifiedGreen, t)!,
      saleOrange: Color.lerp(saleOrange, other.saleOrange, t)!,
      onSaleOrange: Color.lerp(onSaleOrange, other.onSaleOrange, t)!,
      rentBlue: Color.lerp(rentBlue, other.rentBlue, t)!,
      onRentBlue: Color.lerp(onRentBlue, other.onRentBlue, t)!,
      leaseTeal: Color.lerp(leaseTeal, other.leaseTeal, t)!,
      onLeaseTeal: Color.lerp(onLeaseTeal, other.onLeaseTeal, t)!,
    );
  }
}
