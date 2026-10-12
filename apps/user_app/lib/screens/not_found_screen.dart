import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/l10n/output/app_localizations.dart';

/// Shown for unknown routes (go_router `errorBuilder`).
///
/// Web users reach bad URLs constantly — typos, stale shared links, truncated
/// copies. The framework default is an unbranded error page; this keeps the
/// app chrome and offers the one action that makes sense from anywhere:
/// back to the listings.
class NotFoundScreen extends StatelessWidget {
  /// Creates the unknown-route screen.
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return PageTitle(
      title: strings.notFoundTitle,
      child: Scaffold(
        appBar: AppBar(),
        // Capped at form width — centered error card, never full-screen.
        body: CenteredContent(
          maxWidth: AppContentWidths.form,
          child: EmptyState(
            title: strings.notFoundTitle,
            body: strings.notFoundBody,
            actionLabel: strings.onboardingBrowse,
            onAction: () => context.go('/'),
          ),
        ),
      ),
    );
  }
}
