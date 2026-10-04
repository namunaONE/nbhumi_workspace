import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Landing screen.
///
/// HYA-203 replaces the placeholder body with the paginated browse feed. The
/// chrome built here — the search entry point and the seller action — is final
/// for M1, so those should not need revisiting.
class HomeScreen extends StatelessWidget {
  /// Creates the landing screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('nBhumi'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search listings',
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Post a property',
            onPressed: () => context.push('/post'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.home_work_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'nBhumi',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Nepal Property Marketplace',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Property listings across Nepal appear here.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
