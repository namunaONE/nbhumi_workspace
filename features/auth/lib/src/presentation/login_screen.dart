import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';

/// Login screen. Magic link only — no OTP and no passwords (DATA.md).
///
/// Flow: email → sign-in link sent → "check your inbox" with a 30-second
/// resend cooldown. Errors surface bilingually; retry is offered only for
/// retryable failures (Rule 36), because asking a user whose email is
/// malformed to tap retry is noise, not help.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates the login screen.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const Duration _cooldown = Duration(seconds: 30);

  bool _sending = false;
  String? _sentTo;
  int _cooldownSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _email.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownSeconds = _cooldown.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) t.cancel();
      });
    });
  }

  Future<void> _send() async {
    if (_sending) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _sending = true);
    try {
      await ref.read(authProvider.notifier).sendMagicLink(_email.text);
      if (!mounted) return;
      setState(() {
        _sentTo = _email.text.trim();
        _startCooldown();
      });
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.localizedForContext(context)),
          action: e.isRetryable
              ? SnackBarAction(label: 'Retry', onPressed: _send)
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sign in with a magic link',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We email you a sign-in link. No password to remember.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.send,
                  enabled: !_sending,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => Validators.isValidEmail(value ?? '')
                      ? null
                      : 'Enter a valid email address.',
                  onFieldSubmitted: (_) => _send(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _sending || _cooldownSeconds > 0 ? null : _send,
                  child: Text(
                    _sending
                        ? 'Sending…'
                        : _cooldownSeconds > 0
                            ? 'Resend in ${_cooldownSeconds}s'
                            : _sentTo == null
                                ? 'Send sign-in link'
                                : 'Resend link',
                  ),
                ),
                if (_sentTo != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Check your inbox — we sent a sign-in link to $_sentTo.',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
