import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          messageNe:
              'यो अनुरोध मान्य छैन। कृपया जाँच गरी पुनः प्रयास गर्नुहोस्।',
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

      // 23514 check_violation - the status-transition trigger, the ward 1-32
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
          messageNe:
              'धेरै समय लाग्यो। खोजी साँघुरो पारिदेशुहोस्।',
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
}

/// Maps gotrue authentication failures onto the [AppException] hierarchy.
abstract final class AuthExceptionMapper {
  /// Translates a gotrue [AuthException] into a safe bilingual [AppException].
  static AppException map(AuthException e, {required String action}) {
    return switch (e.message.toLowerCase()) {
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
          messageNe:
              'धेरै प्रयास भयो। कृपया केही समय पर्खनुहोस्।',
        ),
      _ => const AuthFailureException(
          code: 'auth.failed',
          messageEn: 'We could not sign you in. Please try again.',
          messageNe:
              'हामीले तपाईंलाई साइन इन गराउन सकेनौं। '
              'कृपया पुनः प्रयास गर्नुहोस्।',
        ),
    };
  }
}
