import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Standard legal disclaimer callout regarding Nepal property transactions.
///
/// Required by DATA.md: nBhumi provides digital listing and discovery only.
/// Legal ownership, registry transfer (Rajinama pass), and land taxes are
/// executed exclusively through government Land Revenue Offices (Malpot).
class LegalDisclaimerCard extends StatelessWidget {
  /// Creates the disclaimer card.
  const LegalDisclaimerCard({
    this.compact = false,
    this.showNepali = true,
    super.key,
  });

  /// True for a single-line or condensed card.
  final bool compact;

  /// Whether to include Nepali legal text alongside English.
  final bool showNepali;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.shield_outlined,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Property deed transfers must be executed at government Malpot.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Nepal Property Safety & Malpot Notice',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'nBhumi facilitates marketplace discovery. In accordance with '
              'Nepal Real Estate & Land Acts, official ownership transfer '
              '(Rajinama / Bakaspatra) must be completed in-person at the '
              'competent Government Land Revenue Office (Malpot Karyalaya). '
              'Always inspect original Lalpurja and citizenship credentials.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
            ),
            if (showNepali) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'सरकारी मालपोत कार्यालयबाट मात्र जग्गा/घरको कानुनी हक हस्तान्तरण '
                'हुन्छ। कारोबार गर्नु अघि सक्कल लालपुर्जा र नागरिकता जाँच गर्नुहोस्।',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
