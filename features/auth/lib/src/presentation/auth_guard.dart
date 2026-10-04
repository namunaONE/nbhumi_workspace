import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gate that redirects to the login route when no session exists.
///
/// Both routers compute redirects inside `redirect`, so this widget is not yet
/// referenced. HYA-202 either adopts it or deletes it — leaving dead code
/// behind a plausible name is worse than removing it.
class AuthGuard extends ConsumerWidget {
  /// Wraps [child], showing it only for a signed-in user.
  const AuthGuard({required this.child, super.key});

  /// The protected subtree.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}
