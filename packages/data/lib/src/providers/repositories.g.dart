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

/// Auth service, for the admin panel's password sign-in.
///
/// Takes the [GoTrueClient] rather than the [SupabaseClient] because that is
/// what it wraps, and because `signInWithPassword` has no business reaching for
/// storage or realtime. See `AuthService` for why the user app's magic link and
/// the admin panel's password are deliberately different methods.

@ProviderFor(authService)
final authServiceProvider = AuthServiceProvider._();

/// Auth service, for the admin panel's password sign-in.
///
/// Takes the [GoTrueClient] rather than the [SupabaseClient] because that is
/// what it wraps, and because `signInWithPassword` has no business reaching for
/// storage or realtime. See `AuthService` for why the user app's magic link and
/// the admin panel's password are deliberately different methods.

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  /// Auth service, for the admin panel's password sign-in.
  ///
  /// Takes the [GoTrueClient] rather than the [SupabaseClient] because that is
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

/// Reference data: districts, and later municipalities and wards.

@ProviderFor(referenceRepository)
final referenceRepositoryProvider = ReferenceRepositoryProvider._();

/// Reference data: districts, and later municipalities and wards.

final class ReferenceRepositoryProvider
    extends
        $FunctionalProvider<
          ReferenceRepository,
          ReferenceRepository,
          ReferenceRepository
        >
    with $Provider<ReferenceRepository> {
  /// Reference data: districts, and later municipalities and wards.
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
