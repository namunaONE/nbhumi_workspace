import 'package:core/src/theme/marketplace_colors.dart';
import 'package:flutter/material.dart';

/// nBhumi theme — Material 3 with seed color #002C6D.
class AppTheme {
  AppTheme._();

  /// Brand seed color — Intense Cobalt Blue (Fidelity).
  static const Color seedColor = Color(0xFF002C6D);

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
