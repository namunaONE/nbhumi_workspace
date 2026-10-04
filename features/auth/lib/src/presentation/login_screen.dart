import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login screen. Magic link only — no OTP and no passwords (DATA.md).
///
/// Placeholder body. HYA-202 replaces it with an email field validated by
/// `Validators.isValidEmail`, a "check your inbox" state, and a resend
/// cooldown.
class LoginScreen extends ConsumerWidget {
  /// Creates the login screen.
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Magic link login...')),
    );
  }
}
