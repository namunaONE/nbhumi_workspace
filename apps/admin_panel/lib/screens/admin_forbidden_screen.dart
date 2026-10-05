import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shown to a signed-in visitor whose account is not an admin.
///
/// ### Why this screen exists at all
///
/// Supabase signup is enabled on the hosted project, so anyone can create an
/// account with a magic link and then navigate to the panel's URL. They will
/// hold a valid session and `profiles.role = 'buyer'`.
///
/// The obvious alternative, bouncing non-admins straight to `/login`, traps
/// them in a loop: `/login` redirects to `/queue` for anyone signed in, `/queue`
/// bounces them back. A dead end that looks like a bug is worse than an
/// explanation, so the router sends them here instead.
///
/// This is presentation only. Nothing is protected by it: every admin read is
/// gated by RLS and every admin write by a `SECURITY DEFINER` RPC that raises
/// `42501` for non-admins, so bypassing this screen reveals an empty queue and
/// failing RPCs rather than any data.
class AdminForbiddenScreen extends ConsumerWidget {
  /// Creates the forbidden screen.
  const AdminForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Access denied')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'This account is not an administrator',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in with an admin account to review listings.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    // Sign out rather than push: the router redirects any
                    // signed-in visitor away from /login, so a plain
                    // context.go('/login') would be undone immediately.
                    await ref.read(authServiceProvider).signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
