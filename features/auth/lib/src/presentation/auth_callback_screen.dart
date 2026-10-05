import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../deep_links/auth_link_handler.dart';

/// Landing route for magic-link taps (`/auth/callback`, HYA-257).
///
/// The link itself is consumed by [AuthLinkHandler] before this screen
/// appears; this screen only narrates the outcome, because the exchange is
/// asynchronous and a blank route would read as a broken app:
///
/// * Session present → signed in, bounce home. The router's `redirect`
///   handles every other signed-in case; this explicit hop covers the moment
///   the session arrives while this route is already on screen.
/// * No session yet → "Signing you in…" with a way back to login for an
///   expired or already-used link.
class AuthCallbackScreen extends ConsumerWidget {
  /// Creates the callback screen.
  const AuthCallbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(isSignedInProvider);

    if (signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const Scaffold(
        body: SafeArea(
          child: Center(child: Text('Signed in. Taking you home…')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Signing in')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LinearProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Signing you in…',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'If this takes more than a few seconds, the link may have '
                'expired or been used already. Request a fresh one from the '
                'login screen.',
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Back to login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
