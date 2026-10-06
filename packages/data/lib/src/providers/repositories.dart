import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/kyc_repository.dart';
import '../repositories/listing_repository.dart';
import '../repositories/notification_repository.dart';
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

/// Admin repository, for the verification queue.
///
/// Separate from [listingRepository] because moderation actions are not edits
/// to a listing the caller owns. Keeping them apart means the seller write path
/// cannot grow an admin capability by accident.
///
/// Re-added with the repository file in the same change. A previous commit
/// removed this provider on the grounds that `admin_repository.dart` had never
/// been committed, which left `packages/data` unbuildable on a clean checkout.
/// The two belong together: neither file alone is useful, and the missing half
/// is exactly what made the pair look broken.
@riverpod
AdminRepository adminRepository(Ref ref) {
  return SupabaseAdminRepository(ref.watch(supabaseClientProvider));
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

/// Seller KYC repository (HYA-264 Tier 2, HYA-265 Tier 3).
///
/// Separate from [userRepository] because KYC is file upload + RPC submit,
/// not profile editing — and separate from [adminRepository] because verdicts
/// are moderation, not seller writes.
@riverpod
KycRepository kycRepository(Ref ref) {
  return KycRepository(ref.watch(supabaseClientProvider));
}

/// The seller's own KYC documents, newest first.
///
/// An empty list is a successful answer (nothing submitted yet), not null:
/// there is no "missing" state here, only "none yet".
@riverpod
Future<List<KycDocument>> myKycDocuments(Ref ref) {
  return ref.watch(kycRepositoryProvider).myDocuments();
}

/// Pending KYC documents for the admin review inbox, oldest first.
///
/// Seller-side reads are confined to their own rows by RLS; the inbox is
/// only meaningful with an admin session. [limit] is clamped to 1..100 in
/// the repository, so the default page here is just a hint.
@riverpod
Future<List<KycDocument>> pendingKycDocuments(
  Ref ref, {
  int limit = 50,
}) {
  return ref.watch(adminRepositoryProvider).pendingKycDocuments(limit: limit);
}

/// Notification inbox repository (HYA-242).
///
/// Owner-scoped: reads and `is_read` flips on the caller's own rows. Rows
/// are written server-side only, so this provider can never send.
@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepository(ref.watch(supabaseClientProvider));
}

/// The caller's notifications, newest first.
///
/// An empty list means no events yet — a successful answer, not an error.
@riverpod
Future<List<AppNotification>> notifications(
  Ref ref, {
  int limit = 50,
}) {
  return ref.watch(notificationRepositoryProvider).inbox(limit: limit);
}

/// Unread count for the inbox badge.
///
/// Kept separate from [notifications] so the shell badge does not refetch
/// the whole page when all it needs is a number.
@riverpod
Future<int> unreadNotificationCount(Ref ref) {
  return ref.watch(notificationRepositoryProvider).unreadCount();
}

/// One user's profile, by id.
///
/// A family so the profile screen and any future seller preview read different
/// users without one clobbering the other. Null when no profile row exists
/// yet, which is a real state for a fresh magic-link session whose trigger has
/// not run.
@riverpod
Future<Profile?> userProfile(Ref ref, {required String userId}) {
  return ref.watch(userRepositoryProvider).getUserById(userId);
}

/// Reference data: districts, municipalities and wards.
@riverpod
ReferenceRepository referenceRepository(Ref ref) {
  return ReferenceRepository(ref.watch(supabaseClientProvider));
}

/// Municipalities in one district, ordered by name.
///
/// A family keyed on the district name so each district's list is cached
/// separately and switching districts does not refetch the previous one. An
/// empty district returns an empty list rather than all 753 rows, so the
/// wizard cannot accidentally render the whole country before a district is
/// picked.
@riverpod
Future<List<Municipality>> municipalities(
  Ref ref, {
  String district = '',
}) {
  if (district.isEmpty) return Future.value(const <Municipality>[]);
  return ref.watch(referenceRepositoryProvider).getMunicipalities(
        district: district,
      );
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
