import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Sign-in screen for the admin panel.
///
/// ### Why this is not the shared user-app `LoginScreen`
///
/// The user app signs in with email and password through a buyer-oriented
/// screen (sign-in / sign-up / recovery modes); this panel signs in with a
/// password on a dedicated screen. Two different flows, two different
/// screens, and keeping them apart is the point: if the panel reused the
/// buyer screen then a future edit to the buyer sign-in would silently change
/// how the platform's most powerful account authenticates.
///
/// ### Sign-up is deliberately absent
///
/// There is no way to create an account from here. Admin accounts are
/// provisioned out of band by `supabase/admin_bootstrap.example.sql`, so a
/// compromised or curious visitor cannot grant themselves a role even if they
/// reach this screen.
class AdminSignInScreen extends ConsumerStatefulWidget {
  /// Creates the admin sign-in screen.
  const AdminSignInScreen({super.key});

  @override
  ConsumerState<AdminSignInScreen> createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends ConsumerState<AdminSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // No navigation here on purpose: the router's `redirect` sees the new
      // session through `refreshListenable` and moves to /queue by itself.
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        // Rule 36: prefer Nepali for non-en locales, fall back to English.
        _errorMessage = e.localizedForContext(context);
        _submitting = false;
      });
      return;
    } on AuthException {
      // Belt and braces: `AuthService` maps gotrue failures to `AppException`,
      // so reaching here means a shape we did not anticipate. Say nothing
      // specific rather than leaking the raw message (Rule 38).
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Sign-in failed. Please try again.';
        _submitting = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          // Admin panels are used on a laptop at a desk and occasionally on a
          // tablet, so cap the width rather than letting the form stretch.
          // Capped at form width so the sheet centers on wide windows
          // instead of stretching edge to edge (DESIGN.md §4.4b).
          // Phones pass through untouched (narrower than the cap).
          constraints: const BoxConstraints(maxWidth: AppContentWidths.form),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'nBhumi Admin',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verification and moderation',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_submitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const <String>[AutofillHints.username],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: (value) => Validators.isValidEmail(
                      value?.trim() ?? '',
                    )
                        ? null
                        : 'Enter a valid email address',
                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    enabled: !_submitting,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const <String>[AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) => (value ?? '').isEmpty
                        ? 'Enter your password'
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_errorMessage != null) ...<Widget>[
                    const SizedBox(height: 16),
                    _ErrorBanner(message: _errorMessage!),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline error surface for a failed sign-in.
///
/// Rendered in the form rather than as a snackbar because a snackbar is easy to
/// miss and this is the only feedback the admin gets before trying again.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 20,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
