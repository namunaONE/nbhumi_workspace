import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Account and seller actions.
///
/// Shows the seller entry point when signed in and a sign-in prompt when not.
/// Deliberately does not offer sign-out yet: that is HYA-202, which owns the
/// magic-link session lifecycle, and a half-wired sign-out would strand users
/// in an inconsistent auth state.
class ProfileScreen extends ConsumerWidget {
  /// Creates the profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(session?.user.email ?? 'Not signed in'),
            subtitle: session == null
                ? const Text('Sign in with a magic link to post a property')
                : const Text('Signed in'),
          ),
          const Divider(),
          if (session != null)
            ListTile(
              leading: const Icon(Icons.add_home_work_outlined),
              title: const Text('Post a property'),
              subtitle: const Text('Create a listing for review'),
              onTap: () => context.push('/post'),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign in'),
              subtitle: const Text('We email you a link, no password needed'),
              onTap: () => context.push('/login'),
            ),
          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('About nBhumi'),
            subtitle: Text(
              'We facilitate listings only. Ownership transfers are '
              'completed at Malpot.',
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'nBhumi collects the minimum information needed to operate a '
              'marketplace, in line with the Privacy Act 2075 (2018).',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
