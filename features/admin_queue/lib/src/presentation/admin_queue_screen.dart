import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin verification queue screen.
///
/// Master-detail layout: list of pending listings on left, detail on right.
class AdminQueueScreen extends ConsumerWidget {
  const AdminQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Queue'),
      ),
      body: const Center(
        child: Text('Admin queue...'),
      ),
    );
  }
}
