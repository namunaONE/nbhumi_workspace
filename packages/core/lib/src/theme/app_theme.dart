import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_text_theme.dart';
import 'app_tokens.dart';
import 'brand_colors.dart';
import 'marketplace_colors.dart';

/// nBhumi theme — Material 3 with a calm, premium visual system.
///
/// Neutral warm surfaces in light mode and deep charcoal surfaces in dark
/// mode, with the brand blue reserved for CTAs, active states, links, and
/// focus rings. Both brightnesses share one component-theme builder
/// ([_buildTheme]); only the scheme, sheet surface, hairline alphas, and
/// tokens differ.
abstract final class AppTheme {
  AppTheme._();

  /// Brand seed color — the logo's deep blue. Aliased (not re-declared) so
  /// the seed can never drift from [BrandColors.logoBlue].
  static const Color seedColor = BrandColors.logoBlue;

  /// Donor schemes for the logo-keyed families (HYA-295).
  ///
  /// Logo-keying works at the *family* level: `fromSeed`'s `secondary:` /
  /// `tertiary:` parameters only replace one role while the `on*`/container
  /// mates stay seed-derived, which breaks pairs (white on raw logo green
  /// is 2:1). Each family is transplanted whole from a scheme seeded with
  /// the logo key instead.
  static ({ColorScheme secondary, ColorScheme tertiary}) _donorFamilies(
    Brightness brightness,
  ) =>
      (
        secondary: ColorScheme.fromSeed(
          seedColor: BrandColors.logoBlueBright,
          brightness: brightness,
        ),
        tertiary: ColorScheme.fromSeed(
          seedColor: BrandColors.logoGreen,
          brightness: brightness,
        ),
      );

  /// Transplants the logo-keyed families onto [base].
  ///
  /// The one hand-set pair is `tertiary`/`onTertiary`: raw logo green under
  /// logo blue (≈6.8:1), mirroring the logo's own pupil-on-dot and the
  /// verified badge pair — one brand mark, one contrast pair, no
  /// per-scheme drift.
  static ColorScheme _withLogoFamilies(
    ColorScheme base, {
    required ColorScheme secondaryDonor,
    required ColorScheme tertiaryDonor,
  }) =>
      base.copyWith(
        secondary: secondaryDonor.primary,
        onSecondary: secondaryDonor.onPrimary,
        secondaryContainer: secondaryDonor.primaryContainer,
        onSecondaryContainer: secondaryDonor.onPrimaryContainer,
        tertiary: BrandColors.logoGreen,
        onTertiary: BrandColors.logoBlue,
        tertiaryContainer: tertiaryDonor.primaryContainer,
        onTertiaryContainer: tertiaryDonor.onPrimaryContainer,
      );

  /// Light color scheme, factored out of [light] so tests can assert
  /// contrast on the generated roles without building the GoogleFonts text
  /// theme (font bytes never load under `flutter test`).
  ///
  /// Light `primary` is pinned to the brand blue rather than generated. The
  /// seed never survives tonalSpot — primary comes out #475D92, a desaturated
  /// pastel, and the brand blue appears nowhere. Fidelity was measured and
  /// rejected: it pushes light primary to near-black #001843 and light
  /// tertiary to a dark brown #370D00. Pinning just this pair is the minimal
  /// brand-exact change: white on logoBlue is 13.28:1, and the generated
  /// primaryContainer (#D9E2FF) stays as the selection-pill surface.
  ///
  /// Dark is deliberately NOT pinned: logoBlue cannot serve as an accent on
  /// dark surfaces, and the generated #B0C6FF already carries the brand hue
  /// at 7.77:1. Asymmetry here is correctness, not drift.
  static ColorScheme get lightScheme {
    final donors = _donorFamilies(Brightness.light);
    return _withLogoFamilies(
      ColorScheme.fromSeed(
        seedColor: seedColor,
        surface: const Color(0xFFFAFAF8),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFF5F5F2),
        surfaceContainer: const Color(0xFFEDEDEA),
        surfaceContainerHigh: const Color(0xFFE4E4E0),
        surfaceContainerHighest: const Color(0xFFDCDCD7),
      ),
      secondaryDonor: donors.secondary,
      tertiaryDonor: donors.tertiary,
    ).copyWith(
      primary: BrandColors.logoBlue,
      onPrimary: Colors.white,
    );
  }

  /// Dark color scheme — same factoring rationale as [lightScheme].
  static ColorScheme get darkScheme {
    final donors = _donorFamilies(Brightness.dark);
    return _withLogoFamilies(
      ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        surface: const Color(0xFF121417),
        surfaceContainerLowest: const Color(0xFF0C0E10),
        surfaceContainerLow: const Color(0xFF1A1D21),
        surfaceContainer: const Color(0xFF22262B),
        surfaceContainerHigh: const Color(0xFF2A2F35),
        surfaceContainerHighest: const Color(0xFF33383F),
      ),
      secondaryDonor: donors.secondary,
      tertiaryDonor: donors.tertiary,
    );
  }

  /// Light theme — warm neutral surfaces with restrained blue accents.
  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        colorScheme: lightScheme,
        tokens: MarketplaceColors.light,
      );

  /// Dark theme — deep charcoal surfaces with soft white text.
  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        colorScheme: darkScheme,
        tokens: MarketplaceColors.dark,
      );

  /// Shared component-theme builder behind [light] and [dark].
  ///
  /// Only four things vary by brightness: the sheet-level surface (cards,
  /// inputs, nav, sheets, dialogs all sit one step higher in dark mode so
  /// they lift off the background), the hairline alphas, the text theme,
  /// and the marketplace tokens. Everything else is identical by design —
  /// restrained components, brand carried by color.
  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required MarketplaceColors tokens,
  }) {
    final light = brightness == Brightness.light;
    final sheet = light
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainerLow;
    final cardLine = light ? 0.4 : 0.3;
    final fieldLine = light ? 0.7 : 0.5;
    final dividerLine = light ? 0.35 : 0.3;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: buildAppTextTheme(brightness, colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: sheet,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: cardLine),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sheet,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: fieldLine),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: fieldLine),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: sheet,
        elevation: 1,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: sheet,
        indicatorColor: colorScheme.primaryContainer,
        selectedLabelTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
        unselectedLabelTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: sheet,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: sheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: dividerLine),
        space: 1,
        thickness: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: sheet,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        tokens,
      ],
    );
  }
}
