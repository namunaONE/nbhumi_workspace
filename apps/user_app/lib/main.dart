import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

void main() {
  runApp(
    const ProviderScope(
      child: UserApp(),
    ),
  );
}

/// nBhumi User App — Flutter mobile for buyers & sellers.
class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nBhumi',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}

/// Home screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('nBhumi'),
      ),
      body: const Center(
        child: Text('nBhumi — Nepal Property Marketplace'),
      ),
    );
  }
}
