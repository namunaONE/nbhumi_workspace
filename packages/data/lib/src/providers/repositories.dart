import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show GoTrueClient;

import '../repositories/auth_repository.dart';
import '../repositories/listing_repository.dart';
import '../repositories/reference_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

part 'repositories.g.dart';

/// Listing repository, wired to the app's Supabase client.
///
/// Previously there was no provider for any repository, which broke the
/// `View -> ViewModel -> Repository` chain at its first link (Rule 18): every
/// repository existed but nothing could reach one.
@riverpod
ListingRepository listingRepository(Ref ref) {
  return ListingRepository(ref.watch(supabaseClientProvider));
}

/// Authentication repository.
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
}

/// Auth service, for the admin panel's password sign-in.
///
/// Takes the auth client rather than the whole `SupabaseClient` because that is
/// what it wraps, and because `signInWithPassword` has no business reaching for
/// storage or realtime. See `AuthService` for why the user app's magic link and
/// the admin panel's password are deliberately different methods.
@riverpod
AuthService authService(Ref ref) {
  return AuthService(ref.watch(supabaseAuthProvider));
}

/// User and profile repository.
@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(ref.watch(supabaseClientProvider));
}

/// Reference data: districts, and later municipalities and wards.
@riverpod
ReferenceRepository referenceRepository(Ref ref) {
  return ReferenceRepository(ref.watch(supabaseClientProvider));
}

/// Every district, ordered by name.
///
/// Kept alive for the process because the table is 77 rows of near-immutable
/// reference data (Rule 40: nothing here changes within a session), so
/// refetching per screen would be waste. `keepAlive` is the explicit statement
/// of that intent rather than relying on a listener happening to hold it.
@riverpod
Future<List<District>> districts(Ref ref) {
  return ref.watch(referenceRepositoryProvider).getDistricts();
}
