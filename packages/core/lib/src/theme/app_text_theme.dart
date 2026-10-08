import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// nBhumi text theme: Plus Jakarta Sans over the M3 baseline.
///
/// Factored out of `AppTheme` (Rule 42) so the theme file stays under the
/// soft cap. Bilingual-safe Latin with system Devanagari fallback; hierarchy
/// rides on weight contrast (semibold titles, regular body) rather than size
/// proliferation.
TextTheme buildAppTextTheme(
  Brightness brightness,
  ColorScheme colorScheme,
) {
  final base = brightness == Brightness.light
      ? Typography.material2021().black
      : Typography.material2021().white;

  return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.8,
      color: colorScheme.onSurface,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.6,
      color: colorScheme.onSurface,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: colorScheme.onSurface,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: colorScheme.onSurface,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
      color: colorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
      color: colorScheme.onSurface,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.45,
      color: colorScheme.onSurface,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: colorScheme.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
  );
}
