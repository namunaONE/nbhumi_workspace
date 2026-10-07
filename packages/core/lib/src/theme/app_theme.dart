import 'package:core/src/theme/brand_colors.dart';
import 'package:core/src/theme/marketplace_colors.dart';
import 'package:flutter/material.dart';

/// nBhumi theme — Material 3 with seed color #002C6D.
class AppTheme {
  AppTheme._();

  /// Brand seed color — the logo's deep blue. Aliased (not re-declared) so
  /// the seed can never drift from [BrandColors.logoBlue].
  static const Color seedColor = BrandColors.logoBlue;

  /// Light theme.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
        ),
        extensions: const <ThemeExtension<dynamic>>[
          MarketplaceColors.light,
        ],
      );

  /// Dark theme.
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        extensions: const <ThemeExtension<dynamic>>[
          MarketplaceColors.dark,
        ],
      );
}
