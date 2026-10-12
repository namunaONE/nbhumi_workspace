import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Storage error codes worth branching on.
///
/// Spelled out here rather than imported because the SDK exposes `error` as a
/// bare `String?` with no constants class. Only the two transient codes matter:
/// they are the cases where offering a retry button is honest.
abstract final class StorageErrorCode {
  /// The request failed in a way that may succeed on a second attempt.
  static const String retryable = 'RetryableError';

  /// The request timed out.
  static const String timedOut = 'Timeout';
}

/// Maps Supabase/Postgres failures onto the [AppException] hierarchy (Rule 38).
///
/// Postgres signals through SQLSTATE codes. Mapping them centrally means the
/// wording a user sees is consistent everywhere, and no raw Postgres text can
/// leak through to the UI.
///
/// Note the deliberate name split: core's authentication failure is
/// [AuthFailureException], while `AuthException` in this file always refers to
/// gotrue's own type. The two are unrelated and the names are easy to confuse.
abstract final class PostgrestErrorMapper {
  /// Translates a [PostgrestException] into a safe, bilingual [AppException].
  ///
  /// [action] names the operation being attempted and is attached for logging
  /// (Rule 37). The raw error is kept as [AppException.cause] and never
  /// rendered.
  static AppException map(PostgrestException e, {required String action}) {
    return switch (e.code) {
      // 42501 with the suspension marker: the write RPCs raise
      // 'FORBIDDEN: account suspended' for suspended sellers (HYA-262), and
      // flattening that into the generic permission error below would tell a
      // suspended seller something misleading. Matched on the stable marker
      // the RPCs own -- never rendered -- so no Postgres text leaks (Rule 38).
      // Non-retryable: retrying changes nothing until an admin unsuspends.
      '42501' when _isSuspended(e) => AuthFailureException(
        code: 'auth.accountSuspended',
        messageEn:
            'Your account is suspended. '
            'You cannot post or edit listings right now.',
        messageNe:
            'तपाईंको खाता निलम्बनमा छ। '
            'तपाईं अहिले लिस्टिङ पोस्ट वा सम्पादन गर्न सक्नुहुन्न।',
        context: action,
        cause: e,
      ),

      // 42501 insufficient_privilege - RLS denied, or an admin-only RPC called
      // by a non-admin. Also raised for an anon caller on a revoked function.
      '42501' => AuthFailureException(
        code: 'auth.forbidden',
        messageEn: 'You do not have permission to do that.',
        messageNe: 'तपाईंलाई यो गर्न अनुमति छैन।',
        context: action,
        cause: e,
      ),

      // 22023 invalid_parameter_value - the RPC rejected the input, or the
      // state machine refused the transition.
      '22023' => ValidationException(
        code: 'validation.rejected',
        messageEn: 'That request was not valid. Please check and try again.',
        messageNe: 'यो अनुरोध मान्य छैन। कृपया जाँच गरी पुनः प्रयास गर्नुहोस्।',
        context: action,
        cause: e,
      ),

      // 23505 unique_violation - duplicate key (favourites, saved searches).
      '23505' => ValidationException(
        code: 'validation.duplicate',
        messageEn: 'That already exists.',
        messageNe: 'यो पहिले नै थियो।',
        context: action,
        cause: e,
      ),

      // 23503 foreign_key_violation - e.g. a district absent from the reference
      // table.
      '23503' => ValidationException(
        code: 'validation.badReference',
        messageEn: 'One of the selected values is not available.',
        messageNe: 'छानिएका मध्ये एउटा मान उपलब्ध छैन।',
        context: action,
        cause: e,
      ),

      // 23514 check_violation - the status-transition trigger, the ward 1-33
      // check, or a positive-area constraint.
      '23514' => ValidationException(
        code: 'validation.constraint',
        messageEn: 'That value is not allowed.',
        messageNe: 'यो मान अनुमति छैन।',
        context: action,
        cause: e,
      ),

      // P0002 no_data_found and PGRST116 PostgREST's equivalent.
      // v1_get_listing_detail raises the same code for "missing" and "not
      // visible", so callers must treat both as null rather than revealing that
      // a hidden listing exists.
      'P0002' || 'PGRST116' => ServerException(
        code: 'server.notFound',
        messageEn: 'That listing is no longer available.',
        messageNe: 'यो विज्ञापन अब उपलब्ध छैन।',
        context: action,
        cause: e,
      ),

      // 57014 statement_timeout - usually a runaway filter combination.
      '57014' => ServerException(
        code: 'server.timeout',
        messageEn: 'That took too long. Try narrowing your search.',
        messageNe: 'धेरै समय लाग्यो। खोजी साँघुरो पारिदेशुहोस्।',
        context: action,
        cause: e,
      ),

      // Unrecognised: treat as a server fault rather than leaking the message.
      // `_isConnectivity` reclassifies transport failures as retryable.
      // PN001 - v1_contact_seller's own code, raised once a buyer has used up
      // the ten first-time reveals allowed per rolling 24 hours. Not retryable:
      // waiting is the only remedy, so a retry button would just fail again.
      'PN001' => ValidationException(
        code: 'contact.rateLimited',
        messageEn:
            'You have viewed contact details for 10 properties today. '
            'Please try again tomorrow.',
        messageNe:
            'आज तपाईंले १० घरजग्गाको सम्पर्क विवरण हेरिसक्नुभयो। '
            'कृपया भोलि प्रयास गर्नुहोस्।',
        context: action,
        cause: e,
      ),

      // Unrecognised: treat as a server fault rather than leaking the message.
      // `_isConnectivity` reclassifies transport failures as retryable.
      _ => switch (_isConnectivity(e)) {
        true => NetworkException(
          code: 'network.unreachable',
          messageEn: 'No connection. Check your network and try again.',
          messageNe:
              'इन्टरनेट छैन। आफ्नो नेटवर्क जाँच गरी पुनः प्रयास गर्नुहोस्।',
          context: action,
          cause: e,
        ),
        false => ServerException(
          code: 'server.unexpected',
          messageEn: 'Something went wrong on our side. Please try again.',
          messageNe: 'हाम्रोतर्फ समस्या भयो। कृपया पुनः प्रयास गर्नुहोस्।',
          context: action,
          cause: e,
        ),
      },
    };
  }

  /// Whether the failure is a suspension refusal rather than a denial.
  ///
  /// The seller write RPCs raise 'FORBIDDEN: account suspended' with 42501
  /// for suspended callers. Message text is the only signal (same reasoning
  /// as [_isConnectivity]): the SQLSTATE is shared with every other
  /// permission failure.
  static bool _isSuspended(PostgrestException e) {
    return e.message.toLowerCase().contains('account suspended');
  }

  /// Whether the failure looks like transport rather than a server problem.
  ///
  /// PostgREST surfaces connectivity failures as a generic error with no
  /// SQLSTATE, so message text is the only available signal.
  static bool _isConnectivity(PostgrestException e) {
    final message = e.message.toLowerCase();
    return message.contains('failed to fetch') ||
        message.contains('connection') ||
        message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('network');
  }

  /// Translates a Supabase Storage failure.
  ///
  /// Separate from [map] because Storage raises [StorageException] rather than
  /// [PostgrestException] and carries no SQLSTATE, so there is nothing to
  /// switch on. The error code is still worth reading: Storage tells transient
  /// failures apart from permanent ones, and that is the difference between
  /// offering a retry button and not.
  static AppException mapStorage(StorageException e, {required String action}) {
    final retryable =
        e.error == StorageErrorCode.retryable ||
        e.error == StorageErrorCode.timedOut;

    return retryable
        ? NetworkException(
            code: 'network.storageUnreachable',
            messageEn: 'Photo upload failed. Check your connection and retry.',
            messageNe:
                'तस्बिर अपलोड भयो। इन्टरनेट जाँच गरी पुनः प्रयास गर्नुहोस्।',
            context: action,
            cause: e,
          )
        : ServerException(
            code: 'server.storage',
            messageEn: 'That photo could not be uploaded.',
            messageNe: 'त्यो तस्बिर अपलोड गर्न सकिएन।',
            context: action,
            cause: e,
          );
  }
}

/// Maps gotrue authentication failures onto the [AppException] hierarchy.
abstract final class AuthExceptionMapper {
  /// Translates a gotrue [AuthException] into a safe bilingual [AppException].
  static AppException map(AuthException e, {required String action}) {
    return switch (e.message.toLowerCase()) {
      // Admin panel (HYA-259). Its own branch because a bad-credentials
      // rejection is the most likely thing an admin will see, and the
      // generic message below reads as "the server is broken" rather
      // than "check your password".
      final m when m.contains('invalid login credentials') =>
        const AuthFailureException(
          code: 'auth.invalidCredentials',
          messageEn: 'Incorrect email or password.',
          messageNe: 'इमेल वा पासवर्ड मिलेन।',
        ),
      final m when m.contains('email not confirmed') =>
        const AuthFailureException(
          code: 'auth.emailNotConfirmed',
          messageEn: 'This account has not been confirmed yet.',
          messageNe: 'यो खाता अझै पुष्टि गरिएको छैन।',
        ),
      // Transport first: a message about the channel says nothing about the
      // credentials, and without this branch a dead connection during signup
      // reads as "we could not sign you in" with no retry button.
      final m when _isConnectivityMessage(m) => NetworkException(
        code: 'network.unreachable',
        messageEn: 'No connection. Check your network and try again.',
        messageNe:
            'इन्टरनेट छैन। आफ्नो नेटवर्क जाँच गरी पुनः प्रयास गर्नुहोस्।',
        context: action,
        cause: e,
      ),
      final m when m.contains('expired') => const AuthFailureException(
        code: 'auth.linkExpired',
        messageEn: 'That sign-in link has expired. Request a new one.',
        messageNe: 'साइन-इन लिङ्कको म्याद सकिएको छ। नयाँ लिङ्क माग्नुहोस्।',
      ),
      final m when m.contains('jwt') || m.contains('token') =>
        const AuthFailureException(
          code: 'auth.sessionExpired',
          messageEn: 'Your session has expired. Please sign in again.',
          messageNe: 'तपाईंको सेसन सकिएको छ। कृपया फेरि साइन इन गर्नुहोस्।',
        ),
      final m when m.contains('rate') || m.contains('too many') =>
        const ServerException(
          code: 'server.rateLimited',
          messageEn: 'Too many attempts. Please wait a moment and try again.',
          messageNe: 'धेरै प्रयास भयो। कृपया केही समय पर्खनुहोस्।',
        ),
      // Sign-up with an existing address. Naming the fix ("sign in instead")
      // confirms the address is registered — accepted here because the
      // sign-up form cannot work without it, and the marketplace threat model
      // does not include targeted account enumeration.
      final m
          when m.contains('already registered') ||
              m.contains('already exists') ||
              m.contains('already been registered') =>
        const AuthFailureException(
          code: 'auth.accountExists',
          messageEn:
              'An account with this email already exists. Sign in instead.',
          messageNe: 'यो इमेलबाट खाता पहिले नै बनेको छ। साइन इन गर्नुहोस्।',
        ),
      // Sign-ups switched off on the project. Non-retryable: retrying changes
      // nothing until the operator re-enables registration.
      final m
          when m.contains('signups not allowed') ||
              (m.contains('signup') && m.contains('disabled')) =>
        const AuthFailureException(
          code: 'auth.signupsDisabled',
          messageEn:
              "New accounts can't be created right now. "
              'Please try again later.',
          messageNe:
              'अहिले नयाँ खाता बनाउन सकिँदैन। कृपया पछि प्रयास गर्नुहोस्।',
        ),
      // The `on_auth_user_created` trigger failed server-side (e.g. the
      // profiles insert violated a constraint). A server fault, not a user
      // error — and never the raw Postgres text (Rule 38).
      final m when m.contains('database error') => ServerException(
        code: 'server.signupFailed',
        messageEn:
            'Something went wrong creating your account. Please try again.',
        messageNe:
            'तपाईंको खाता बनाउँदा समस्या भयो। कृपया पुनः प्रयास गर्नुहोस्।',
        context: action,
        cause: e,
      ),
      // Server-side password rules beyond the app's length check (leaked or
      // too-common passwords, "different from the old one"). Names the fix
      // rather than bouncing the user back to the form with no hint.
      final m
          when m.contains('password') &&
              (m.contains('should') ||
                  m.contains('characters') ||
                  m.contains('weak') ||
                  m.contains('length') ||
                  m.contains('common') ||
                  m.contains('breach') ||
                  m.contains('compromised') ||
                  m.contains('different')) =>
        const ValidationException(
          code: 'validation.passwordPolicy',
          messageEn:
              "That password doesn't meet the requirements. "
              'Try a longer, less common one.',
          messageNe:
              'यो पासवर्डले मापदण्ड पूरा गर्दैन। '
              'लामो र असामान्य पासवर्ड प्रयास गर्नुहोस्।',
        ),
      // Confirmation or recovery email could not be sent (SMTP unconfigured
      // or rate-limited). Narrow on purpose: a bare mention of "smtp" or
      // "email" is not enough — see the generic-branch test below.
      final m
          when m.contains('error sending') || m.contains('failed to send') =>
        const ServerException(
          code: 'server.emailSendFailed',
          messageEn:
              'We could not send the confirmation email. Please try again.',
          messageNe:
              'पुष्टिकरण इमेल पठाउन सकिएन। '
              'कृपया पुनः प्रयास गर्नुहोस्।',
        ),
      // Action-aware fallback: a signup failure that matches nothing above
      // must not be worded as a sign-in failure.
      _ =>
        _signupAction(action)
            ? const AuthFailureException(
                code: 'auth.signupFailed',
                messageEn:
                    'We could not create your account. Please try again.',
                messageNe:
                    'हामीले तपाईंको खाता बनाउन सकेनौं। '
                    'कृपया पुनः प्रयास गर्नुहोस्।',
              )
            : const AuthFailureException(
                code: 'auth.failed',
                messageEn: 'We could not sign you in. Please try again.',
                messageNe:
                    'हामीले तपाईंलाई साइन इन गराउन सकेनौं। '
                    'कृपया पुनः प्रयास गर्नुहोस्।',
              ),
    };
  }

  /// Translates a failure from the email-link callback exchange.
  ///
  /// A callback exchange redeems a one-time link; there is no session yet
  /// that could have expired, so every token-shaped failure means the link
  /// itself is dead. [map] would report those as `auth.sessionExpired`
  /// ("your session has expired"), which tells a user who never had a session
  /// something confusing. Here they become `auth.linkInvalid` instead, whose
  /// action ("request a new link") is the actual fix.
  static AppException mapCallbackExchange(
    AuthException e, {
    required String action,
  }) {
    final mapped = map(e, action: action);
    if (mapped.code == 'auth.sessionExpired' || _isLinkExchangeFailure(e)) {
      return AuthFailureException(
        code: 'auth.linkInvalid',
        messageEn:
            "That sign-in link didn't work. Request a new one and try again.",
        messageNe:
            'यो साइन-इन लिङ्कले काम गरेन। '
            'नयाँ लिङ्क मागेर पुनः प्रयास गर्नुहोस्।',
        context: action,
        cause: e,
      );
    }
    return mapped;
  }

  /// Whether the failure means the link cannot be redeemed on this device.
  ///
  /// PKCE verifiers live with the requesting install: a link opened on another
  /// device, or after the app was reinstalled, has no verifier to complete
  /// the exchange with.
  static bool _isLinkExchangeFailure(AuthException e) {
    final message = e.message.toLowerCase();
    return message.contains('pkce') || message.contains('verifier');
  }

  /// Whether the failure looks like transport rather than a server answer.
  ///
  /// gotrue surfaces connectivity failures as plain messages with no status
  /// code, so message text is the only available signal (same reasoning as
  /// [PostgrestErrorMapper._isConnectivity]).
  static bool _isConnectivityMessage(String message) {
    return message.contains('failed to fetch') ||
        message.contains('network request failed') ||
        message.contains('connection') ||
        message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('network');
  }

  /// Whether [action] is a sign-up call, for the fallback wording.
  static bool _signupAction(String action) =>
      action.toLowerCase().contains('signup');
}
