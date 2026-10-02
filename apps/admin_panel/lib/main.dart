import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AdminPanel(),
    ),
  );
}

/// nBhumi Admin Panel — Flutter web for verification/moderation.
class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nBhumi Admin',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const AdminHomeScreen(),
    );
  }
}

/// Admin home screen.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('nBhumi Admin'),
      ),
      body: const Center(
        child: Text('nBhumi Admin Panel'),
      ),
    );
  }
}
