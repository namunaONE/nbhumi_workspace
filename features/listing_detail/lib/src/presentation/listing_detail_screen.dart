import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full listing view: photo gallery, specs, description, map, contact CTA.
///
/// Routed as `/listing/:id`, so the id arrives through the path rather than as a
/// constructor argument. HYA-204 replaces the placeholder body with the real
/// gallery and the auth-gated Contact Seller button.
class ListingDetailScreen extends ConsumerWidget {
  /// Creates the detail screen.
  const ListingDetailScreen({required this.listingId, super.key});

  /// Id of the listing to display, from the route path.
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listing Detail')),
      body: Center(child: Text('Listing: $listingId')),
    );
  }
}
