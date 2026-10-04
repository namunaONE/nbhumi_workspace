import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Post listing wizard screen.
///
/// Multi-step form: type -> location -> specs -> price/photos -> review.
///
/// Note the documentation describes five steps but only four step widgets
/// exist. The missing one is "type + purpose", which HYA-205 adds.
class PostListingScreen extends ConsumerWidget {
  /// Creates the wizard shell.
  const PostListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Property')),
      body: const Center(child: Text('Post listing wizard...')),
    );
  }
}
