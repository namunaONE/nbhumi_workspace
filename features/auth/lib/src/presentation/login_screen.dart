import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';

/// Which credential the screen asks for.
enum _Pane { link, password }

/// What the password pane does.
enum _PasswordMode { signIn, signUp, reset }

/// Login screen. Magic link or email + password — the user's choice.
///
/// Magic link stays the default: no password to forget, nothing to stuff.
/// The password pane covers sign-in, account creation, and recovery:
///
/// * Sign in / Create account toggle on one form (confirm field included).
/// * "Forgot password?" switches to reset mode: one email field, one button,
///   and the recovery link lands on `/auth/callback?type=recovery`, where
///   the callback screen shows the set-new-password form.
///
/// Errors surface bilingually; retry is offered only for retryable failures
/// (Rule 36).
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates the login screen.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const Duration _cooldown = Duration(seconds: 30);

  _Pane _pane = _Pane.link;
  _PasswordMode _mode = _PasswordMode.signIn;
  bool _busy = false;
  bool _obscure = true;
  String? _sentTo;
  int _cooldownSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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

  void _fail(AppException e) {
    if (!mounted) return;
    final retry = e.isRetryable ? _submit : null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.localizedForContext(context)),
        action: retry == null
            ? null
            : SnackBarAction(label: 'Retry', onPressed: retry),
      ),
    );
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _busy = true);
    try {
      final auth = ref.read(authProvider.notifier);
      switch ((_pane, _mode)) {
        case (_Pane.link, _):
          await auth.sendMagicLink(_email.text);
          if (!mounted) return;
          setState(() {
            _sentTo = _email.text.trim();
            _startCooldown();
          });
        case (_Pane.password, _PasswordMode.signIn):
          await auth.signInWithPassword(
            email: _email.text,
            password: _password.text,
          );
        case (_Pane.password, _PasswordMode.signUp):
          await auth.signUpWithPassword(
            email: _email.text,
            password: _password.text,
          );
          if (!mounted) return;
          setState(() {
            _sentTo = _email.text.trim();
          });
        case (_Pane.password, _PasswordMode.reset):
          await auth.resetPassword(_email.text);
          if (!mounted) return;
          setState(() {
            _sentTo = _email.text.trim();
            _startCooldown();
          });
      }
    } on AppException catch (e) {
      _fail(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _emailError(String? value) =>
      Validators.isValidEmail((value ?? '').trim())
          ? null
          : 'Enter a valid email address.';

  String? _passwordError(String? value) =>
      Validators.isValidPassword(value ?? '')
          ? null
          : 'At least ${Validators.minPasswordLength} characters.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<_Pane>(
                  segments: const [
                    ButtonSegment(
                      value: _Pane.link,
                      label: Text('Magic link'),
                      icon: Icon(Icons.mail_outline),
                    ),
                    ButtonSegment(
                      value: _Pane.password,
                      label: Text('Password'),
                      icon: Icon(Icons.lock_outline),
                    ),
                  ],
                  selected: {_pane},
                  onSelectionChanged: (selected) => setState(() {
                    _pane = selected.single;
                    _sentTo = null;
                  }),
                ),
                const SizedBox(height: 24),
                if (_pane == _Pane.link) ...[
                  Text(
                    'Sign in with a magic link',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We email you a sign-in link. No password to remember.',
                  ),
                ] else ...[
                  Text(
                    switch (_mode) {
                      _PasswordMode.signIn => 'Sign in with your password',
                      _PasswordMode.signUp => 'Create your account',
                      _PasswordMode.reset => 'Reset your password',
                    },
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    switch (_mode) {
                      _PasswordMode.signIn =>
                        'Prefer no password? The link tab needs only email.',
                      _PasswordMode.signUp =>
                        'One account for posting and contacting sellers.',
                      _PasswordMode.reset =>
                        'We email you a link to choose a new password.',
                    },
                  ),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_busy,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: _emailError,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_pane == _Pane.password &&
                    _mode != _PasswordMode.reset) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: _passwordError,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
                if (_pane == _Pane.password &&
                    _mode == _PasswordMode.signUp) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    enabled: !_busy,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == _password.text
                        ? null
                        : 'Passwords do not match.',
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy || _cooldownSeconds > 0 ? null : _submit,
                  child: Text(
                    _busy
                        ? 'Sending…'
                        : _cooldownSeconds > 0
                            ? 'Resend in ${_cooldownSeconds}s'
                            : switch ((_pane, _mode)) {
                                (_Pane.link, _) => _sentTo == null
                                    ? 'Send sign-in link'
                                    : 'Resend link',
                                (_Pane.password, _PasswordMode.signIn) =>
                                  'Sign in',
                                (_Pane.password, _PasswordMode.signUp) =>
                                  'Create account',
                                (_Pane.password, _PasswordMode.reset) =>
                                  _sentTo == null
                                      ? 'Send reset link'
                                      : 'Resend reset link',
                              },
                  ),
                ),
                if (_pane == _Pane.password &&
                    _mode != _PasswordMode.reset)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _mode = _mode == _PasswordMode.signIn
                                  ? _PasswordMode.signUp
                                  : _PasswordMode.signIn;
                              _sentTo = null;
                            }),
                    child: Text(
                      _mode == _PasswordMode.signIn
                          ? 'New here? Create an account'
                          : 'Have an account? Sign in',
                    ),
                  ),
                if (_pane == _Pane.password &&
                    _mode == _PasswordMode.signIn)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _mode = _PasswordMode.reset;
                              _sentTo = null;
                            }),
                    child: const Text('Forgot your password?'),
                  ),
                if (_pane == _Pane.password &&
                    _mode == _PasswordMode.reset)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(
                            () => _mode = _PasswordMode.signIn),
                    child: const Text('Back to sign in'),
                  ),
                if (_sentTo != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    switch ((_pane, _mode)) {
                      (_Pane.link, _) =>
                        'Check your inbox — a sign-in link '
                        'is on its way to $_sentTo.',
                      (_Pane.password, _PasswordMode.signUp) =>
                        'Account created for $_sentTo. If confirmation '
                        'is on, tap the emailed link to finish signing in.',
                      (_, _) =>
                        'Check your inbox — we sent a reset link to $_sentTo.',
                    },
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
