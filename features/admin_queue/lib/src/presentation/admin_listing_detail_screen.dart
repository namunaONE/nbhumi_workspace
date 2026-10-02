import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin listing detail screen.
///
/// Shows listing details, KYC documents, approve/reject actions.
class AdminListingDetailScreen extends ConsumerWidget {
  const AdminListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Detail'),
      ),
      body: Center(
        child: Text('Admin listing: $listingId'),
      ),
    );
  }
}
