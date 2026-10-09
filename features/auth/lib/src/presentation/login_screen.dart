import 'dart:async';

import 'package:auth/l10n/output/auth_localizations.dart' as auth_strings;
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';

/// What the password form does.
enum _PasswordMode { signIn, signUp, reset }

/// Login screen. Email + password only — no magic links.
///
/// The single form covers sign-in, account creation, and recovery:
///
/// * Sign in / Create account toggle on one form (confirm field included).
///   A successful signup marks the install for post-signup onboarding.
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
    final strings = auth_strings.AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.localizedForContext(context)),
        action: retry == null
            ? null
            : SnackBarAction(label: strings.retry, onPressed: retry),
      ),
    );
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _busy = true);
    try {
      final auth = ref.read(authProvider.notifier);
      switch (_mode) {
        case _PasswordMode.signIn:
          await auth.signInWithPassword(
            email: _email.text,
            password: _password.text,
          );
        case _PasswordMode.signUp:
          await auth.signUpWithPassword(
            email: _email.text,
            password: _password.text,
          );
          if (!mounted) return;
          setState(() {
            _sentTo = _email.text.trim();
          });
        case _PasswordMode.reset:
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

  String? _emailError(String? value) {
    if (Validators.isValidEmail((value ?? '').trim())) return null;
    return auth_strings.AppLocalizations.of(context).emailError;
  }

  String? _passwordError(String? value) {
    if (Validators.isValidPassword(value ?? '')) return null;
    return auth_strings.AppLocalizations.of(context).passwordError(
      Validators.minPasswordLength,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = auth_strings.AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  switch (_mode) {
                    _PasswordMode.signIn => strings.passwordSignInTitle,
                    _PasswordMode.signUp => strings.signUpTitle,
                    _PasswordMode.reset => strings.resetTitle,
                  },
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  switch (_mode) {
                    _PasswordMode.signIn => strings.passwordSignInSubtitle,
                    _PasswordMode.signUp => strings.signUpSubtitle,
                    _PasswordMode.reset => strings.resetSubtitle,
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: strings.emailLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: _emailError,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_mode != _PasswordMode.reset) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      labelText: strings.passwordLabel,
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
                if (_mode == _PasswordMode.signUp) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      labelText: strings.confirmLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == _password.text
                        ? null
                        : strings.mismatchError,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy || _cooldownSeconds > 0 ? null : _submit,
                  child: Text(
                    _busy
                        ? strings.sending
                        : _cooldownSeconds > 0
                            ? strings.resendIn(_cooldownSeconds)
                            : switch (_mode) {
                                _PasswordMode.signIn => strings.signInAction,
                                _PasswordMode.signUp => strings.signUpAction,
                                _PasswordMode.reset => _sentTo == null
                                    ? strings.sendReset
                                    : strings.resendReset,
                              },
                  ),
                ),
                if (_mode != _PasswordMode.reset)
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
                          ? strings.switchToSignUp
                          : strings.switchToSignIn,
                    ),
                  ),
                if (_mode == _PasswordMode.signIn)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _mode = _PasswordMode.reset;
                              _sentTo = null;
                            }),
                    child: Text(strings.forgotPassword),
                  ),
                if (_mode == _PasswordMode.reset)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(
                            () => _mode = _PasswordMode.signIn),
                    child: Text(strings.backToSignIn),
                  ),
                if (_sentTo != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    switch (_mode) {
                      _PasswordMode.signUp => strings.accountCreated(_sentTo!),
                      _ => strings.resetSent(_sentTo!),
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
