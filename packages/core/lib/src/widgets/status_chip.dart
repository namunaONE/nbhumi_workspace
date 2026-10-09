import 'package:flutter/material.dart';
import 'package:models/models.dart';

import '../theme/app_tokens.dart';
import '../theme/marketplace_colors.dart';

/// Semantic status chip for listing purpose and verification state.
///
/// Centralises the sale/rent/lease colours from [MarketplaceColors] so cards,
/// detail headers, and filter selections cannot drift. Falls back to the
/// primary container pair when the extension is absent, so widget tests
/// without a full theme still render.
class StatusChip extends StatelessWidget {
  /// Creates a status chip.
  const StatusChip({
    required this.label,
    this.background,
    this.foreground,
    this.icon,
    this.dense = false,
    super.key,
  });

  /// Creates a purpose chip (Sale/Rent/Lease) from theme tokens.
  factory StatusChip.purpose(
    ListingPurpose purpose, {
    MarketplaceColors? colors,
    bool dense = false,
  }) {
    const fallback = (
      background: Color(0xFFE8ECF3),
      foreground: Color(0xFF002C6D),
    );
    final resolved = colors == null
        ? fallback
        : switch (purpose) {
            ListingPurpose.sale => (
                background: colors.saleOrange,
                foreground: colors.onSaleOrange,
              ),
            ListingPurpose.rent => (
                background: colors.rentBlue,
                foreground: colors.onRentBlue,
              ),
            ListingPurpose.lease => (
                background: colors.leaseTeal,
                foreground: colors.onLeaseTeal,
              ),
          };
    final label =
        '${purpose.name[0].toUpperCase()}${purpose.name.substring(1)}';
    return StatusChip(
      label: label,
      background: resolved.background,
      foreground: resolved.foreground,
      dense: dense,
    );
  }

  /// Creates a KYC-verified chip.
  factory StatusChip.verified({
    MarketplaceColors? colors,
    Color? fallbackForeground,
    bool dense = false,
  }) {
    final foreground =
        colors?.verifiedGreen ?? fallbackForeground ?? const Color(0xFF1B6B2E);
    return StatusChip(
      label: 'Verified',
      background: foreground.withValues(alpha: 0.12),
      foreground: foreground,
      icon: Icons.verified,
      dense: dense,
    );
  }

  /// Chip label text.
  final String label;

  /// Background fill. Defaults to surface container when null.
  final Color? background;

  /// Text and icon colour. Defaults to on-surface-variant when null.
  final Color? foreground;

  /// Optional leading icon.
  final IconData? icon;

  /// Compact padding and type for dense layouts such as photo overlays.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        this.background ?? theme.colorScheme.surfaceContainerHighest;
    final foreground =
        this.foreground ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 10,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: dense ? 12 : 14, color: foreground),
            SizedBox(width: dense ? 3 : 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: dense ? 10 : 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
