import 'package:flutter/material.dart';

/// Wizard step 5: review and submit.
///
/// Submission moves a listing from `draft` to `pending_review` via
/// `v1_create_listing` / `v1_update_listing`. It does not become public until an
/// admin approves it (HYA-208).
class ReviewStep extends StatelessWidget {
  /// Creates the review step.
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Review Step'));
  }
}
