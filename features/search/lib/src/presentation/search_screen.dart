import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Browse and filter listings.
///
/// Placeholder body. HYA-203 replaces it with the paginated feed, the filter
/// sheet and the responsive grid, driven by a `SearchViewModel` built on
/// `ListingRepository.getListings`.
class SearchScreen extends ConsumerWidget {
  /// Creates the search screen.
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(child: Text('Search listings...')),
    );
  }
}
