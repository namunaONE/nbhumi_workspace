import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Listing detail screen.
///
/// Shows photo gallery, specs, description, location, and contact seller.
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Detail'),
      ),
      body: Center(
        child: Text('Listing: $listingId'),
      ),
    );
  }
}
