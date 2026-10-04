// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browse_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Browse feed, paginated with a keyset cursor.
///
/// ### Why the cursor, not a page number
///
/// `v1_get_listings` is keyset paginated, so cost is constant at any depth.
/// OFFSET scans every skipped row, which is fine at 20 per page and painful at
/// page 100. HYA-203 wants infinite scroll from day one.
///
/// ### Why retry is disabled
///
/// Riverpod 3.0 retries a failing provider up to 10 times with exponential
/// backoff (200ms to 6.4s), so `provider.future` takes roughly 40 seconds to
/// reject. A user on a bad mobile network would watch a spinner for the best
/// part of a minute instead of seeing an error with a retry button (Rule 36).
/// Riverpod's docs note the same risk; the fix is `retry: (count, error) => null`.

@ProviderFor(Browse)
final browseProvider = BrowseProvider._();

/// Browse feed, paginated with a keyset cursor.
///
/// ### Why the cursor, not a page number
///
/// `v1_get_listings` is keyset paginated, so cost is constant at any depth.
/// OFFSET scans every skipped row, which is fine at 20 per page and painful at
/// page 100. HYA-203 wants infinite scroll from day one.
///
/// ### Why retry is disabled
///
/// Riverpod 3.0 retries a failing provider up to 10 times with exponential
/// backoff (200ms to 6.4s), so `provider.future` takes roughly 40 seconds to
/// reject. A user on a bad mobile network would watch a spinner for the best
/// part of a minute instead of seeing an error with a retry button (Rule 36).
/// Riverpod's docs note the same risk; the fix is `retry: (count, error) => null`.
final class BrowseProvider extends $AsyncNotifierProvider<Browse, BrowseState> {
  /// Browse feed, paginated with a keyset cursor.
  ///
  /// ### Why the cursor, not a page number
  ///
  /// `v1_get_listings` is keyset paginated, so cost is constant at any depth.
  /// OFFSET scans every skipped row, which is fine at 20 per page and painful at
  /// page 100. HYA-203 wants infinite scroll from day one.
  ///
  /// ### Why retry is disabled
  ///
  /// Riverpod 3.0 retries a failing provider up to 10 times with exponential
  /// backoff (200ms to 6.4s), so `provider.future` takes roughly 40 seconds to
  /// reject. A user on a bad mobile network would watch a spinner for the best
  /// part of a minute instead of seeing an error with a retry button (Rule 36).
  /// Riverpod's docs note the same risk; the fix is `retry: (count, error) => null`.
  BrowseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browseHash();

  @$internal
  @override
  Browse create() => Browse();
}

String _$browseHash() => r'6a258da92892bd37c03adb3b1e3f179388279825';

/// Browse feed, paginated with a keyset cursor.
///
/// ### Why the cursor, not a page number
///
/// `v1_get_listings` is keyset paginated, so cost is constant at any depth.
/// OFFSET scans every skipped row, which is fine at 20 per page and painful at
/// page 100. HYA-203 wants infinite scroll from day one.
///
/// ### Why retry is disabled
///
/// Riverpod 3.0 retries a failing provider up to 10 times with exponential
/// backoff (200ms to 6.4s), so `provider.future` takes roughly 40 seconds to
/// reject. A user on a bad mobile network would watch a spinner for the best
/// part of a minute instead of seeing an error with a retry button (Rule 36).
/// Riverpod's docs note the same risk; the fix is `retry: (count, error) => null`.

abstract class _$Browse extends $AsyncNotifier<BrowseState> {
  FutureOr<BrowseState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BrowseState>, BrowseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BrowseState>, BrowseState>,
              AsyncValue<BrowseState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The filters currently applied to the feed.
///
/// Separate from [Browse] so a widget can watch and edit the filters without
/// also rebuilding on every page load.

@ProviderFor(BrowseFilter)
final browseFilterProvider = BrowseFilterProvider._();

/// The filters currently applied to the feed.
///
/// Separate from [Browse] so a widget can watch and edit the filters without
/// also rebuilding on every page load.
final class BrowseFilterProvider
    extends $NotifierProvider<BrowseFilter, ListingFilter> {
  /// The filters currently applied to the feed.
  ///
  /// Separate from [Browse] so a widget can watch and edit the filters without
  /// also rebuilding on every page load.
  BrowseFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browseFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browseFilterHash();

  @$internal
  @override
  BrowseFilter create() => BrowseFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListingFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListingFilter>(value),
    );
  }
}

String _$browseFilterHash() => r'a603bb1123e4a8b24ebbca274557fac4819bb6b2';

/// The filters currently applied to the feed.
///
/// Separate from [Browse] so a widget can watch and edit the filters without
/// also rebuilding on every page load.

abstract class _$BrowseFilter extends $Notifier<ListingFilter> {
  ListingFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ListingFilter, ListingFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ListingFilter, ListingFilter>,
              ListingFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
