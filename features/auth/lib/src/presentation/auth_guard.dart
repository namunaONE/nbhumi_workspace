import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth guard — redirects to login if not authenticated.
class AuthGuard extends ConsumerWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement auth state check
    return child;
  }
}
