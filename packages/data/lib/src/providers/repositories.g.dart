// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Listing repository, wired to the app's Supabase client.
///
/// Previously there was no provider for any repository, which broke the
/// `View -> ViewModel -> Repository` chain at its first link (Rule 18): every
/// repository existed but nothing could reach one.

@ProviderFor(listingRepository)
final listingRepositoryProvider = ListingRepositoryProvider._();

/// Listing repository, wired to the app's Supabase client.
///
/// Previously there was no provider for any repository, which broke the
/// `View -> ViewModel -> Repository` chain at its first link (Rule 18): every
/// repository existed but nothing could reach one.

final class ListingRepositoryProvider
    extends
        $FunctionalProvider<
          ListingRepository,
          ListingRepository,
          ListingRepository
        >
    with $Provider<ListingRepository> {
  /// Listing repository, wired to the app's Supabase client.
  ///
  /// Previously there was no provider for any repository, which broke the
  /// `View -> ViewModel -> Repository` chain at its first link (Rule 18): every
  /// repository existed but nothing could reach one.
  ListingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listingRepositoryHash();

  @$internal
  @override
  $ProviderElement<ListingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListingRepository create(Ref ref) {
    return listingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListingRepository>(value),
    );
  }
}

String _$listingRepositoryHash() => r'0959744daf9a6114a136e717b6f9f29238a6a7b1';

/// Authentication repository.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Authentication repository.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Authentication repository.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'ad0d2dbdcd16330667642d40541f556a89f93328';

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

@ProviderFor(adminRepository)
final adminRepositoryProvider = AdminRepositoryProvider._();

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

final class AdminRepositoryProvider
    extends
        $FunctionalProvider<AdminRepository, AdminRepository, AdminRepository>
    with $Provider<AdminRepository> {
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
  AdminRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdminRepository create(Ref ref) {
    return adminRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRepository>(value),
    );
  }
}

String _$adminRepositoryHash() => r'c9f5225539e3b4de62557a4c70ad98e063e521c5';

/// Auth service, for the admin panel's password sign-in.
///
/// Takes the auth client rather than the whole `SupabaseClient` because that is
/// what it wraps, and because `signInWithPassword` has no business reaching for
/// storage or realtime. See `AuthService` for why the user app's magic link and
/// the admin panel's password are deliberately different methods.

@ProviderFor(authService)
final authServiceProvider = AuthServiceProvider._();

/// Auth service, for the admin panel's password sign-in.
///
/// Takes the auth client rather than the whole `SupabaseClient` because that is
/// what it wraps, and because `signInWithPassword` has no business reaching for
/// storage or realtime. See `AuthService` for why the user app's magic link and
/// the admin panel's password are deliberately different methods.

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  /// Auth service, for the admin panel's password sign-in.
  ///
  /// Takes the auth client rather than the whole `SupabaseClient` because that is
  /// what it wraps, and because `signInWithPassword` has no business reaching for
  /// storage or realtime. See `AuthService` for why the user app's magic link and
  /// the admin panel's password are deliberately different methods.
  AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'2dd24f253cb31c9f5ef50b85fde1e86ff94164b3';

/// User and profile repository.

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

/// User and profile repository.

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  /// User and profile repository.
  UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'a6928f0216eec406ea121d36fba16beec4fc6f57';

/// Seller KYC repository (HYA-264 Tier 2, HYA-265 Tier 3).
///
/// Separate from [userRepository] because KYC is file upload + RPC submit,
/// not profile editing — and separate from [adminRepository] because verdicts
/// are moderation, not seller writes.

@ProviderFor(kycRepository)
final kycRepositoryProvider = KycRepositoryProvider._();

/// Seller KYC repository (HYA-264 Tier 2, HYA-265 Tier 3).
///
/// Separate from [userRepository] because KYC is file upload + RPC submit,
/// not profile editing — and separate from [adminRepository] because verdicts
/// are moderation, not seller writes.

final class KycRepositoryProvider
    extends $FunctionalProvider<KycRepository, KycRepository, KycRepository>
    with $Provider<KycRepository> {
  /// Seller KYC repository (HYA-264 Tier 2, HYA-265 Tier 3).
  ///
  /// Separate from [userRepository] because KYC is file upload + RPC submit,
  /// not profile editing — and separate from [adminRepository] because verdicts
  /// are moderation, not seller writes.
  KycRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycRepositoryHash();

  @$internal
  @override
  $ProviderElement<KycRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KycRepository create(Ref ref) {
    return kycRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KycRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KycRepository>(value),
    );
  }
}

String _$kycRepositoryHash() => r'5a9f7a90c80a81be37ba01a502b9e32999aca9ed';

/// The seller's own KYC documents, newest first.
///
/// An empty list is a successful answer (nothing submitted yet), not null:
/// there is no "missing" state here, only "none yet".

@ProviderFor(myKycDocuments)
final myKycDocumentsProvider = MyKycDocumentsProvider._();

/// The seller's own KYC documents, newest first.
///
/// An empty list is a successful answer (nothing submitted yet), not null:
/// there is no "missing" state here, only "none yet".

final class MyKycDocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<KycDocument>>,
          List<KycDocument>,
          FutureOr<List<KycDocument>>
        >
    with
        $FutureModifier<List<KycDocument>>,
        $FutureProvider<List<KycDocument>> {
  /// The seller's own KYC documents, newest first.
  ///
  /// An empty list is a successful answer (nothing submitted yet), not null:
  /// there is no "missing" state here, only "none yet".
  MyKycDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myKycDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myKycDocumentsHash();

  @$internal
  @override
  $FutureProviderElement<List<KycDocument>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<KycDocument>> create(Ref ref) {
    return myKycDocuments(ref);
  }
}

String _$myKycDocumentsHash() => r'48ba6168f28d97979e1d96cbf2db1a1756921d02';

/// Pending KYC documents for the admin review inbox, oldest first.
///
/// Seller-side reads are confined to their own rows by RLS; the inbox is
/// only meaningful with an admin session. [limit] is clamped to 1..100 in
/// the repository, so the default page here is just a hint.

@ProviderFor(pendingKycDocuments)
final pendingKycDocumentsProvider = PendingKycDocumentsFamily._();

/// Pending KYC documents for the admin review inbox, oldest first.
///
/// Seller-side reads are confined to their own rows by RLS; the inbox is
/// only meaningful with an admin session. [limit] is clamped to 1..100 in
/// the repository, so the default page here is just a hint.

final class PendingKycDocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<KycDocument>>,
          List<KycDocument>,
          FutureOr<List<KycDocument>>
        >
    with
        $FutureModifier<List<KycDocument>>,
        $FutureProvider<List<KycDocument>> {
  /// Pending KYC documents for the admin review inbox, oldest first.
  ///
  /// Seller-side reads are confined to their own rows by RLS; the inbox is
  /// only meaningful with an admin session. [limit] is clamped to 1..100 in
  /// the repository, so the default page here is just a hint.
  PendingKycDocumentsProvider._({
    required PendingKycDocumentsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pendingKycDocumentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pendingKycDocumentsHash();

  @override
  String toString() {
    return r'pendingKycDocumentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<KycDocument>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<KycDocument>> create(Ref ref) {
    final argument = this.argument as int;
    return pendingKycDocuments(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PendingKycDocumentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pendingKycDocumentsHash() =>
    r'8ce0ddbaba92c8e636123e35f39da140f371918b';

/// Pending KYC documents for the admin review inbox, oldest first.
///
/// Seller-side reads are confined to their own rows by RLS; the inbox is
/// only meaningful with an admin session. [limit] is clamped to 1..100 in
/// the repository, so the default page here is just a hint.

final class PendingKycDocumentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<KycDocument>>, int> {
  PendingKycDocumentsFamily._()
    : super(
        retry: null,
        name: r'pendingKycDocumentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Pending KYC documents for the admin review inbox, oldest first.
  ///
  /// Seller-side reads are confined to their own rows by RLS; the inbox is
  /// only meaningful with an admin session. [limit] is clamped to 1..100 in
  /// the repository, so the default page here is just a hint.

  PendingKycDocumentsProvider call({int limit = 50}) =>
      PendingKycDocumentsProvider._(argument: limit, from: this);

  @override
  String toString() => r'pendingKycDocumentsProvider';
}

/// Notification inbox repository (HYA-242).
///
/// Owner-scoped: reads and `is_read` flips on the caller's own rows. Rows
/// are written server-side only, so this provider can never send.

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

/// Notification inbox repository (HYA-242).
///
/// Owner-scoped: reads and `is_read` flips on the caller's own rows. Rows
/// are written server-side only, so this provider can never send.

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepository,
          NotificationRepository,
          NotificationRepository
        >
    with $Provider<NotificationRepository> {
  /// Notification inbox repository (HYA-242).
  ///
  /// Owner-scoped: reads and `is_read` flips on the caller's own rows. Rows
  /// are written server-side only, so this provider can never send.
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'3346e51a12e64025965c56e88b289b28118d9887';

/// The caller's notifications, newest first.
///
/// An empty list means no events yet — a successful answer, not an error.

@ProviderFor(notifications)
final notificationsProvider = NotificationsFamily._();

/// The caller's notifications, newest first.
///
/// An empty list means no events yet — a successful answer, not an error.

final class NotificationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppNotification>>,
          List<AppNotification>,
          FutureOr<List<AppNotification>>
        >
    with
        $FutureModifier<List<AppNotification>>,
        $FutureProvider<List<AppNotification>> {
  /// The caller's notifications, newest first.
  ///
  /// An empty list means no events yet — a successful answer, not an error.
  NotificationsProvider._({
    required NotificationsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'notificationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @override
  String toString() {
    return r'notificationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AppNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AppNotification>> create(Ref ref) {
    final argument = this.argument as int;
    return notifications(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationsHash() => r'7a3b2694d5a7bb77f32ea398c3dbb47453fafd4d';

/// The caller's notifications, newest first.
///
/// An empty list means no events yet — a successful answer, not an error.

final class NotificationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AppNotification>>, int> {
  NotificationsFamily._()
    : super(
        retry: null,
        name: r'notificationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The caller's notifications, newest first.
  ///
  /// An empty list means no events yet — a successful answer, not an error.

  NotificationsProvider call({int limit = 50}) =>
      NotificationsProvider._(argument: limit, from: this);

  @override
  String toString() => r'notificationsProvider';
}

/// Unread count for the inbox badge.
///
/// Kept separate from [notifications] so the shell badge does not refetch
/// the whole page when all it needs is a number.

@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// Unread count for the inbox badge.
///
/// Kept separate from [notifications] so the shell badge does not refetch
/// the whole page when all it needs is a number.

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Unread count for the inbox badge.
  ///
  /// Kept separate from [notifications] so the shell badge does not refetch
  /// the whole page when all it needs is a number.
  UnreadNotificationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadNotificationCount(ref);
  }
}

String _$unreadNotificationCountHash() =>
    r'9329041df3e373fa603d295aadf0fb2b98d6ece7';

/// One user's profile, by id.
///
/// A family so the profile screen and any future seller preview read different
/// users without one clobbering the other. Null when no profile row exists
/// yet, which is a real state for a fresh magic-link session whose trigger has
/// not run.

@ProviderFor(userProfile)
final userProfileProvider = UserProfileFamily._();

/// One user's profile, by id.
///
/// A family so the profile screen and any future seller preview read different
/// users without one clobbering the other. Null when no profile row exists
/// yet, which is a real state for a fresh magic-link session whose trigger has
/// not run.

final class UserProfileProvider
    extends
        $FunctionalProvider<AsyncValue<Profile?>, Profile?, FutureOr<Profile?>>
    with $FutureModifier<Profile?>, $FutureProvider<Profile?> {
  /// One user's profile, by id.
  ///
  /// A family so the profile screen and any future seller preview read different
  /// users without one clobbering the other. Null when no profile row exists
  /// yet, which is a real state for a fresh magic-link session whose trigger has
  /// not run.
  UserProfileProvider._({
    required UserProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @override
  String toString() {
    return r'userProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile?> create(Ref ref) {
    final argument = this.argument as String;
    return userProfile(ref, userId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileHash() => r'2943899f5f80e54d3302f680220d69c632631708';

/// One user's profile, by id.
///
/// A family so the profile screen and any future seller preview read different
/// users without one clobbering the other. Null when no profile row exists
/// yet, which is a real state for a fresh magic-link session whose trigger has
/// not run.

final class UserProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Profile?>, String> {
  UserProfileFamily._()
    : super(
        retry: null,
        name: r'userProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One user's profile, by id.
  ///
  /// A family so the profile screen and any future seller preview read different
  /// users without one clobbering the other. Null when no profile row exists
  /// yet, which is a real state for a fresh magic-link session whose trigger has
  /// not run.

  UserProfileProvider call({required String userId}) =>
      UserProfileProvider._(argument: userId, from: this);

  @override
  String toString() => r'userProfileProvider';
}

/// Reference data: districts, municipalities and wards.

@ProviderFor(referenceRepository)
final referenceRepositoryProvider = ReferenceRepositoryProvider._();

/// Reference data: districts, municipalities and wards.

final class ReferenceRepositoryProvider
    extends
        $FunctionalProvider<
          ReferenceRepository,
          ReferenceRepository,
          ReferenceRepository
        >
    with $Provider<ReferenceRepository> {
  /// Reference data: districts, municipalities and wards.
  ReferenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referenceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReferenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReferenceRepository create(Ref ref) {
    return referenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReferenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReferenceRepository>(value),
    );
  }
}

String _$referenceRepositoryHash() =>
    r'f03cdc700d529adbeed98180ef7f33ad281d5cf4';

/// Municipalities in one district, ordered by name.
///
/// A family keyed on the district name so each district's list is cached
/// separately and switching districts does not refetch the previous one. An
/// empty district returns an empty list rather than all 753 rows, so the
/// wizard cannot accidentally render the whole country before a district is
/// picked.

@ProviderFor(municipalities)
final municipalitiesProvider = MunicipalitiesFamily._();

/// Municipalities in one district, ordered by name.
///
/// A family keyed on the district name so each district's list is cached
/// separately and switching districts does not refetch the previous one. An
/// empty district returns an empty list rather than all 753 rows, so the
/// wizard cannot accidentally render the whole country before a district is
/// picked.

final class MunicipalitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Municipality>>,
          List<Municipality>,
          FutureOr<List<Municipality>>
        >
    with
        $FutureModifier<List<Municipality>>,
        $FutureProvider<List<Municipality>> {
  /// Municipalities in one district, ordered by name.
  ///
  /// A family keyed on the district name so each district's list is cached
  /// separately and switching districts does not refetch the previous one. An
  /// empty district returns an empty list rather than all 753 rows, so the
  /// wizard cannot accidentally render the whole country before a district is
  /// picked.
  MunicipalitiesProvider._({
    required MunicipalitiesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'municipalitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$municipalitiesHash();

  @override
  String toString() {
    return r'municipalitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Municipality>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Municipality>> create(Ref ref) {
    final argument = this.argument as String;
    return municipalities(ref, district: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MunicipalitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$municipalitiesHash() => r'b1fa717a17618b090139bae7fb412216277c38dd';

/// Municipalities in one district, ordered by name.
///
/// A family keyed on the district name so each district's list is cached
/// separately and switching districts does not refetch the previous one. An
/// empty district returns an empty list rather than all 753 rows, so the
/// wizard cannot accidentally render the whole country before a district is
/// picked.

final class MunicipalitiesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Municipality>>, String> {
  MunicipalitiesFamily._()
    : super(
        retry: null,
        name: r'municipalitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Municipalities in one district, ordered by name.
  ///
  /// A family keyed on the district name so each district's list is cached
  /// separately and switching districts does not refetch the previous one. An
  /// empty district returns an empty list rather than all 753 rows, so the
  /// wizard cannot accidentally render the whole country before a district is
  /// picked.

  MunicipalitiesProvider call({String district = ''}) =>
      MunicipalitiesProvider._(argument: district, from: this);

  @override
  String toString() => r'municipalitiesProvider';
}

/// Every district, ordered by name.
///
/// Kept alive for the process because the table is 77 rows of near-immutable
/// reference data (Rule 40: nothing here changes within a session), so
/// refetching per screen would be waste. `keepAlive` is the explicit statement
/// of that intent rather than relying on a listener happening to hold it.

@ProviderFor(districts)
final districtsProvider = DistrictsProvider._();

/// Every district, ordered by name.
///
/// Kept alive for the process because the table is 77 rows of near-immutable
/// reference data (Rule 40: nothing here changes within a session), so
/// refetching per screen would be waste. `keepAlive` is the explicit statement
/// of that intent rather than relying on a listener happening to hold it.

final class DistrictsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<District>>,
          List<District>,
          FutureOr<List<District>>
        >
    with $FutureModifier<List<District>>, $FutureProvider<List<District>> {
  /// Every district, ordered by name.
  ///
  /// Kept alive for the process because the table is 77 rows of near-immutable
  /// reference data (Rule 40: nothing here changes within a session), so
  /// refetching per screen would be waste. `keepAlive` is the explicit statement
  /// of that intent rather than relying on a listener happening to hold it.
  DistrictsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'districtsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$districtsHash();

  @$internal
  @override
  $FutureProviderElement<List<District>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<District>> create(Ref ref) {
    return districts(ref);
  }
}

String _$districtsHash() => r'ea9689546116aba01e38c95a5ec429f7a1c3595d';
