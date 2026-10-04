import 'package:flutter/material.dart';

/// Saved listings.
///
/// Favourites are M3 (HYA-212) and there is no `favorites` table yet, so the
/// tab exists but says so plainly rather than showing an empty list that looks
/// like a bug. The decision to ship the tab now was made so the shell matches
/// WIREFRAMES.md and so the navigation index stays stable once HYA-212 lands.
class SavedScreen extends StatelessWidget {
  /// Creates the saved listings screen.
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.favorite_outline,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Saved listings are not available yet',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You will be able to bookmark properties and get alerted when '
                'a new listing matches your search.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
