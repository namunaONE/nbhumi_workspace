import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search screen.
///
/// Shows search bar, filter chips, and listing results.
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: const Center(
        child: Text('Search listings...'),
      ),
    );
  }
}
