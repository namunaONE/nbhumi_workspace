// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'auth_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Sign in';

  @override
  String get paneLink => 'Magic link';

  @override
  String get panePassword => 'Password';

  @override
  String get linkTitle => 'Sign in with a magic link';

  @override
  String get linkSubtitle => 'We email you a sign-in link. No password to remember.';

  @override
  String get passwordSignInTitle => 'Sign in with your password';

  @override
  String get passwordSignInSubtitle => 'Prefer no password? The link tab needs only email.';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get signUpSubtitle => 'One account for posting and contacting sellers.';

  @override
  String get resetTitle => 'Reset your password';

  @override
  String get resetSubtitle => 'We email you a link to choose a new password.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmLabel => 'Confirm password';

  @override
  String get emailError => 'Enter a valid email address.';

  @override
  String passwordError(int min) {
    return 'At least $min characters.';
  }

  @override
  String get mismatchError => 'Passwords do not match.';

  @override
  String get sending => 'Sending…';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get sendLink => 'Send sign-in link';

  @override
  String get resendLink => 'Resend link';

  @override
  String get signInAction => 'Sign in';

  @override
  String get signUpAction => 'Create account';

  @override
  String get sendReset => 'Send reset link';

  @override
  String get resendReset => 'Resend reset link';

  @override
  String get switchToSignUp => 'New here? Create an account';

  @override
  String get switchToSignIn => 'Have an account? Sign in';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String sentLink(String email) {
    return 'Check your inbox — a sign-in link is on its way to $email.';
  }

  @override
  String accountCreated(String email) {
    return 'Account created for $email. If confirmation is on, tap the emailed link to finish signing in.';
  }

  @override
  String resetSent(String email) {
    return 'Check your inbox — we sent a reset link to $email.';
  }

  @override
  String get retry => 'Retry';

  @override
  String get callbackSignedIn => 'Signed in. Taking you home…';

  @override
  String get callbackSigningIn => 'Signing in';

  @override
  String get callbackWorking => 'Signing you in…';

  @override
  String get callbackSlowHint => 'If this takes more than a few seconds, the link may have expired or been used already. Request a fresh one from the login screen.';

  @override
  String get callbackBackToLogin => 'Back to login';

  @override
  String get callbackFailedTitle => 'Sign-in link failed';

  @override
  String get callbackRequestNew => 'Request a new link';

  @override
  String get newPasswordTitle => 'Choose a new password';

  @override
  String newPasswordIntro(int min) {
    return 'Enter a new password for your account. At least $min characters.';
  }

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmNewLabel => 'Confirm new password';

  @override
  String get saving => 'Saving…';

  @override
  String get savePassword => 'Save new password';
}
