import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin verification queue screen.
///
/// Master-detail layout: pending listings on the left, detail on the right,
/// with a 48h SLA indicator per row (HYA-208, M2).
class AdminQueueScreen extends ConsumerWidget {
  /// Creates the queue screen.
  const AdminQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Queue')),
      body: const Center(child: Text('Admin queue...')),
    );
  }
}
