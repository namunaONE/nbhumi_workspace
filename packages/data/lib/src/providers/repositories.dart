import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/activity_repository.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/favorites_repository.dart';
import '../repositories/kyc_repository.dart';
import '../repositories/listing_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/reference_repository.dart';
import '../repositories/saved_search_repository.dart';
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

/// Activity repository (HYA-297): read-only assembly for the profile
/// Activity page — own listings, own reveals, per-listing reveal stats.
///
/// Separate from [listingRepository] (browse + seller writes) and from
/// [userRepository] (profile + Privacy Act) because activity is reads across
/// several tables with no writes at all.
@riverpod
ActivityRepository activityRepository(Ref ref) {
  return ActivityRepository(ref.watch(supabaseClientProvider));
}

/// The caller's own listings, newest first, any status.
///
/// Drafts and rejected rows the public feed never shows still return here:
/// RLS admits the seller on every status.
@riverpod
Future<List<ListingSummary>> myListings(Ref ref) {
  return ref.watch(activityRepositoryProvider).myListings();
}

/// Seller-contact reveals the caller made, newest first.
///
/// Carries listing ids, titles and validity windows — no phone or email
/// (see [MyReveal]).
@riverpod
Future<List<MyReveal>> myReveals(Ref ref) {
  return ref.watch(activityRepositoryProvider).myReveals();
}

/// Per-listing reveal interest in the caller's own listings.
///
/// Aggregates only (count + latest timestamp, no buyer identity) via
/// `v1_my_listing_reveals`. Empty when nothing has been viewed yet.
@riverpod
Future<List<ListingRevealStat>> listingRevealStats(Ref ref) {
  return ref.watch(activityRepositoryProvider).listingRevealStats();
}

/// Everything the Activity page renders, assembled from owner-scoped reads.
///
/// Sources fail independently: each fallback records its [AppException]
/// and answers an empty list, so a KYC outage never blanks the seller's
/// listings. Only when *every* source fails does the provider rethrow the
/// first error, and the screen answers with a retryable error state
/// (Rule 36). An empty list from a healthy source means nothing there yet
/// — a successful answer, not an error — so no nulls flow into the screen.
@riverpod
Future<ActivityPage> activityPage(Ref ref) async {
  final errors = <AppException>[];
  final (listings, reveals, stats, documents, updates) = await (
    _quiet(ref.watch(myListingsProvider.future), <ListingSummary>[], errors),
    _quiet(ref.watch(myRevealsProvider.future), <MyReveal>[], errors),
    _quiet(
      ref.watch(listingRevealStatsProvider.future),
      <ListingRevealStat>[],
      errors,
    ),
    _quiet(ref.watch(myKycDocumentsProvider.future), <KycDocument>[], errors),
    _quiet(
      ref.watch(notificationsProvider().future),
      <AppNotification>[],
      errors,
    ),
  ).wait;
  if (errors.length == 5) throw errors.first;
  return ActivityPage(
    listings: listings,
    reveals: reveals,
    revealStats: stats,
    documents: documents,
    updates: updates,
  );
}

/// Awaits [source], recording its [AppException] and answering [fallback].
///
/// Non-application errors propagate: the screen renders its generic failure
/// copy for those rather than this function inventing a message.
Future<T> _quiet<T>(
  Future<T> source,
  T fallback,
  List<AppException> errors,
) async {
  try {
    return await source;
  } on AppException catch (e) {
    errors.add(e);
    return fallback;
  }
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

/// Per-listing Tier-3 verification for the detail badge (HYA-265).
///
/// A family so each detail screen caches its own answer. False (with no
/// date) covers missing, hidden and never-verified alike: the RPC answers
/// identically for all three, so the client cannot oracle hidden state.
@riverpod
Future<({bool verified, DateTime? reviewedAt})> listingVerification(
  Ref ref, {
  required String listingId,
}) {
  return ref.watch(kycRepositoryProvider).listingVerified(listingId);
}

/// Buyer bookmarks repository (HYA-268).
///
/// State lives in the `favorites` table, never in the `is_favorite` wire
/// field the browse/detail RPCs still hardcode to false (flipping that is
/// C2, verified against a live database).
@riverpod
FavoritesRepository favoritesRepository(Ref ref) {
  return FavoritesRepository(ref.watch(supabaseClientProvider));
}

/// Ids the caller bookmarked.
///
/// Cards and the detail heart read favorite state from this set. An empty
/// set is a successful answer (nothing saved yet), not an error.
@riverpod
Future<Set<String>> favoriteIds(Ref ref) {
  return ref.watch(favoritesRepositoryProvider).favoriteIds();
}

/// Saved listings as cards, newest bookmark first.
@riverpod
Future<List<ListingSummary>> savedListings(Ref ref) {
  return ref.watch(favoritesRepositoryProvider).savedListings();
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

/// Saved-search repository (HYA-268 C2b).
///
/// Owner-scoped like favorites: rows are ordinary user documents the matcher
/// (C3) will read server-side.
@riverpod
SavedSearchRepository savedSearchRepository(Ref ref) {
  return SavedSearchRepository(ref.watch(supabaseClientProvider));
}

/// The caller's saved searches, newest first.
@riverpod
Future<List<SavedSearch>> savedSearches(Ref ref) {
  return ref.watch(savedSearchRepositoryProvider).savedSearches();
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
