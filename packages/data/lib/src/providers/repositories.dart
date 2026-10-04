import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/auth_repository.dart';
import '../repositories/listing_repository.dart';
import '../repositories/user_repository.dart';
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

/// User and profile repository.
@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(ref.watch(supabaseClientProvider));
}
