import 'package:auth/l10n/output/auth_localizations.dart' as auth_strings;
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/auth_viewmodel.dart';

/// Landing route for magic-link (and recovery-link) taps.
///
/// The link itself is consumed by the deep-link handler before this screen
/// appears; this screen only narrates the outcome, because the exchange is
/// asynchronous and a blank route would read as a broken app:
///
/// * Recovery link (`?type=recovery`) + session → the set-new-password form.
///   The exchange already established a recovery session; saving a new
///   password completes it and the router takes the user home.
/// * Session present → signed in, bounce home.
/// * No session yet → "Signing you in…" with a way back to login for an
///   expired or already-used link.
class AuthCallbackScreen extends ConsumerWidget {
  /// Creates the callback screen.
  ///
  /// [isRecovery] is set only after GoTrue identifies a recovery exchange.
  /// [error] is a safe local flag, never a raw callback URL or server message.
  const AuthCallbackScreen({
    this.isRecovery = false,
    this.error,
    super.key,
  });

  /// Whether this callback carries a password-recovery session.
  final bool isRecovery;

  /// `expired` or `failed` after a callback exchange could not complete.
  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (error != null) return _CallbackError(expired: error == 'expired');

    final signedIn = ref.watch(isSignedInProvider);

    if (signedIn && isRecovery) return const _SetPasswordForm();

    if (signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      final strings = auth_strings.AppLocalizations.of(context);
      return Scaffold(
        body: SafeArea(
          child: Center(child: Text(strings.callbackSignedIn)),
        ),
      );
    }

    final strings = auth_strings.AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.callbackSigningIn)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LinearProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                strings.callbackWorking,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(strings.callbackSlowHint),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go('/login'),
                child: Text(strings.callbackBackToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A safe recovery path for an expired or malformed callback.
class _CallbackError extends StatelessWidget {
  const _CallbackError({required this.expired});

  final bool expired;

  @override
  Widget build(BuildContext context) {
    final failure = expired
        ? const AuthFailureException(
            code: 'auth.linkExpired',
            messageEn: 'That sign-in link has expired. Request a new one.',
            messageNe: 'साइन-इन लिङ्कको म्याद सकिएको छ। नयाँ लिङ्क माग्नुहोस्।',
          )
        : const AuthFailureException(
            code: 'auth.failed',
            messageEn: 'We could not sign you in. Request a new link.',
            messageNe: 'साइन इन हुन सकेन। कृपया नयाँ लिङ्क माग्नुहोस्।',
          );
    final strings = auth_strings.AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.callbackFailedTitle)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(failure.localizedForContext(context)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/login'),
                  child: Text(strings.callbackRequestNew),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sets the new password after a recovery exchange.
class _SetPasswordForm extends ConsumerStatefulWidget {
  const _SetPasswordForm();

  @override
  ConsumerState<_SetPasswordForm> createState() => _SetPasswordFormState();
}

class _SetPasswordFormState extends ConsumerState<_SetPasswordForm> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).updatePassword(_password.text);
      if (!mounted) return;
      context.go('/');
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.localizedForContext(context))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = auth_strings.AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.newPasswordTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.newPasswordIntro(Validators.minPasswordLength),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: strings.newPasswordLabel,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (value) =>
                      Validators.isValidPassword(value ?? '')
                          ? null
                          : strings.passwordError(
                              Validators.minPasswordLength,
                            ),
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirm,
                  obscureText: _obscure,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: strings.confirmNewLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == _password.text
                      ? null
                      : strings.mismatchError,
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: Text(
                    _busy ? strings.saving : strings.savePassword,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
