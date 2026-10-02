import 'package:flutter/material.dart';

/// Custom color tokens for nBhumi marketplace.
@immutable
class MarketplaceColors extends ThemeExtension<MarketplaceColors> {
  const MarketplaceColors({
    required this.verifiedGreen,
    required this.onVerifiedGreen,
    required this.saleOrange,
    required this.rentBlue,
    required this.leaseTeal,
  });

  final Color verifiedGreen;
  final Color onVerifiedGreen;
  final Color saleOrange;
  final Color rentBlue;
  final Color leaseTeal;

  static const MarketplaceColors light = MarketplaceColors(
    verifiedGreen: Color(0xFF2E7D32),
    onVerifiedGreen: Color(0xFFFFFFFF),
    saleOrange: Color(0xFFE65100),
    rentBlue: Color(0xFF1565C0),
    leaseTeal: Color(0xFF00695C),
  );

  static const MarketplaceColors dark = MarketplaceColors(
    verifiedGreen: Color(0xFF66BB6A),
    onVerifiedGreen: Color(0xFF003300),
    saleOrange: Color(0xFFFF8A65),
    rentBlue: Color(0xFF64B5F6),
    leaseTeal: Color(0xFF4DB6AC),
  );

  @override
  MarketplaceColors copyWith({
    Color? verifiedGreen,
    Color? onVerifiedGreen,
    Color? saleOrange,
    Color? rentBlue,
    Color? leaseTeal,
  }) {
    return MarketplaceColors(
      verifiedGreen: verifiedGreen ?? this.verifiedGreen,
      onVerifiedGreen: onVerifiedGreen ?? this.onVerifiedGreen,
      saleOrange: saleOrange ?? this.saleOrange,
      rentBlue: rentBlue ?? this.rentBlue,
      leaseTeal: leaseTeal ?? this.leaseTeal,
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
      rentBlue: Color.lerp(rentBlue, other.rentBlue, t)!,
      leaseTeal: Color.lerp(leaseTeal, other.leaseTeal, t)!,
    );
  }
}
