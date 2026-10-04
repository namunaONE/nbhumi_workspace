import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin listing detail: full listing, KYC documents, approve or reject.
///
/// Approve and reject call `v1_admin_approve_listing` and
/// `v1_admin_reject_listing`. Both are SECURITY DEFINER, revoked from `anon`,
/// and gated by `private.is_admin()`, with every action written to `audit_log`
/// (Rule 8). There is deliberately no repository method for them yet; HYA-208
/// adds one.
class AdminListingDetailScreen extends ConsumerWidget {
  /// Creates the admin detail screen.
  const AdminListingDetailScreen({required this.listingId, super.key});

  /// Id of the listing under review, from the route path.
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listing Detail')),
      body: Center(child: Text('Admin listing: $listingId')),
    );
  }
}
