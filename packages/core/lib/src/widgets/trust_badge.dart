import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/marketplace_colors.dart';

/// KYC document-check badge for verified listings and sellers.
///
/// Deliberately states what the verification is: an admin document check of
/// government identity or land ownership paper (Lalpurja), never legal title
/// warranty (Rule 5 & DATA.md).
class TrustBadge extends StatelessWidget {
  /// Creates a trust badge.
  const TrustBadge({
    this.compact = false,
    this.showInfoOnTap = true,
    super.key,
  });

  /// When true, renders icon only or compact form suitable for small chips.
  final bool compact;

  /// When true, tapping opens a dialog explaining the verification boundary.
  final bool showInfoOnTap;

  void _showInfo(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) {
          final theme = Theme.of(context);
          return AlertDialog(
            icon: Icon(
              Icons.verified,
              size: 40,
              color: theme.extension<MarketplaceColors>()?.verifiedGreen ??
                  theme.colorScheme.primary,
            ),
            title: const Text('Verified by nBhumi'),
            content: const Text(
              'This badge confirms that our admin team has verified the '
              "seller's government ID (Nagarikta/Passport) and listing "
              'documents.\n\n'
              'Notice: nBhumi verifies submitted records. Legal title '
              'transfer and final document execution always take place at '
              'the government Land Revenue Office (Malpot Karyalaya).',
            ),
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Understood'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<MarketplaceColors>();
    final foreground = colors?.verifiedGreen ?? theme.colorScheme.primary;

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 7,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: foreground.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.verified, size: 14, color: foreground),
          if (!compact) ...<Widget>[
            const SizedBox(width: 4),
            Text(
              'Verified',
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );

    if (!showInfoOnTap) return badge;

    return InkWell(
      onTap: () => _showInfo(context),
      borderRadius: BorderRadius.circular(6),
      child: badge,
    );
  }
}
