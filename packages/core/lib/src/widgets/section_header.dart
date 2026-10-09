import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Section header with title, optional subtitle, and optional action.
///
/// Used for home sections, detail sections, profile groups, and wizard
/// blocks so hierarchy and spacing stay uniform.
class SectionHeader extends StatelessWidget {
  /// Creates a section header.
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    super.key,
  });

  /// Section title.
  final String title;

  /// Optional explanatory line under the title.
  final String? subtitle;

  /// Optional trailing action label, e.g. "See all" or "Edit".
  final String? actionLabel;

  /// Called when the trailing action is tapped.
  final VoidCallback? onAction;

  /// Outer padding. Defaults to screen horizontal margin.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle case final text?) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
