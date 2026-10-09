import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Consistent empty state with icon, title, body, and optional action.
///
/// Replaces ad-hoc empty layouts so every empty screen shares the same calm
/// icon, centred copy, and CTA placement.
class EmptyState extends StatelessWidget {
  /// Creates an empty state.
  const EmptyState({
    required this.title,
    required this.body,
    this.icon = Icons.search_off,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Empty-state title.
  final String title;

  /// Explanatory body copy.
  final String body;

  /// Leading icon.
  final IconData icon;

  /// Optional CTA label.
  final String? actionLabel;

  /// Called when the CTA is tapped.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 48,
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Consistent error state with icon, message, and optional retry.
///
/// Messages must already be user-safe and bilingual by the time they reach
/// here; repositories map before they throw (Rule 38).
class ErrorState extends StatelessWidget {
  /// Creates an error state.
  const ErrorState({
    required this.message,
    this.icon = Icons.error_outline,
    this.retryLabel,
    this.onRetry,
    super.key,
  });

  /// User-safe message to display.
  final String message;

  /// Leading icon.
  final IconData icon;

  /// Optional retry label. When null, no retry button renders.
  final String? retryLabel;

  /// Called when retry is tapped.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 48,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (retryLabel != null && onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Consistent loading state with spinner and optional message.
class LoadingState extends StatelessWidget {
  /// Creates a loading state.
  const LoadingState({this.message, super.key});

  /// Optional message under the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            if (message case final text?) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
