import 'package:flutter/material.dart';

/// Canonical nBhumi brand palette, sampled from the logo SVG.
///
/// The logo is the single source of truth for brand color. Theme tokens
/// (`MarketplaceColors`) and the app seed color reference these constants
/// rather than repeating hex literals, so the icon and the UI can never
/// drift apart again.
abstract final class BrandColors {
  BrandColors._();

  /// Deep brand blue — logo gradient end, Material seed, pin pupil.
  static const Color logoBlue = Color(0xFF002C6D);

  /// Bright brand blue — logo gradient start (top-left).
  static const Color logoBlueBright = Color(0xFF0B3F94);

  /// Brand green — logo land arc and pin dot. Doubles as the verified-badge
  /// fill; its foreground is always [logoBlue] (≈6.3:1, WCAG AA), mirroring
  /// the logo's own dark pupil on the green dot.
  static const Color logoGreen = Color(0xFF4FD166);

  /// Logo background gradient, top-left to bottom-right.
  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[logoBlueBright, logoBlue],
  );
}
