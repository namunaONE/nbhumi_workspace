// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One listing, by id.
///
/// A family rather than a plain provider so the detail page and any future
/// "similar listings" rail can read different ids without one clobbering the
/// other, and so navigating between two listings does not reuse the first
/// response.
///
/// Retry is left at the default here, unlike the browse feed: a detail page is a
/// deliberate, one-shot navigation, and the user is waiting on a single request
/// rather than scrolling through a list. A transient blip is worth one silent
/// retry; a hard failure surfaces on the error state below.

@ProviderFor(ListingDetailView)
final listingDetailViewProvider = ListingDetailViewFamily._();

/// One listing, by id.
///
/// A family rather than a plain provider so the detail page and any future
/// "similar listings" rail can read different ids without one clobbering the
/// other, and so navigating between two listings does not reuse the first
/// response.
///
/// Retry is left at the default here, unlike the browse feed: a detail page is a
/// deliberate, one-shot navigation, and the user is waiting on a single request
/// rather than scrolling through a list. A transient blip is worth one silent
/// retry; a hard failure surfaces on the error state below.
final class ListingDetailViewProvider
    extends $AsyncNotifierProvider<ListingDetailView, ListingDetail?> {
  /// One listing, by id.
  ///
  /// A family rather than a plain provider so the detail page and any future
  /// "similar listings" rail can read different ids without one clobbering the
  /// other, and so navigating between two listings does not reuse the first
  /// response.
  ///
  /// Retry is left at the default here, unlike the browse feed: a detail page is a
  /// deliberate, one-shot navigation, and the user is waiting on a single request
  /// rather than scrolling through a list. A transient blip is worth one silent
  /// retry; a hard failure surfaces on the error state below.
  ListingDetailViewProvider._({
    required ListingDetailViewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listingDetailViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingDetailViewHash();

  @override
  String toString() {
    return r'listingDetailViewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ListingDetailView create() => ListingDetailView();

  @override
  bool operator ==(Object other) {
    return other is ListingDetailViewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingDetailViewHash() => r'1ba6dbae16c6e85e7d355bd57d861f9c848adf13';

/// One listing, by id.
///
/// A family rather than a plain provider so the detail page and any future
/// "similar listings" rail can read different ids without one clobbering the
/// other, and so navigating between two listings does not reuse the first
/// response.
///
/// Retry is left at the default here, unlike the browse feed: a detail page is a
/// deliberate, one-shot navigation, and the user is waiting on a single request
/// rather than scrolling through a list. A transient blip is worth one silent
/// retry; a hard failure surfaces on the error state below.

final class ListingDetailViewFamily extends $Family
    with
        $ClassFamilyOverride<
          ListingDetailView,
          AsyncValue<ListingDetail?>,
          ListingDetail?,
          FutureOr<ListingDetail?>,
          String
        > {
  ListingDetailViewFamily._()
    : super(
        retry: null,
        name: r'listingDetailViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One listing, by id.
  ///
  /// A family rather than a plain provider so the detail page and any future
  /// "similar listings" rail can read different ids without one clobbering the
  /// other, and so navigating between two listings does not reuse the first
  /// response.
  ///
  /// Retry is left at the default here, unlike the browse feed: a detail page is a
  /// deliberate, one-shot navigation, and the user is waiting on a single request
  /// rather than scrolling through a list. A transient blip is worth one silent
  /// retry; a hard failure surfaces on the error state below.

  ListingDetailViewProvider call(String listingId) =>
      ListingDetailViewProvider._(argument: listingId, from: this);

  @override
  String toString() => r'listingDetailViewProvider';
}

/// One listing, by id.
///
/// A family rather than a plain provider so the detail page and any future
/// "similar listings" rail can read different ids without one clobbering the
/// other, and so navigating between two listings does not reuse the first
/// response.
///
/// Retry is left at the default here, unlike the browse feed: a detail page is a
/// deliberate, one-shot navigation, and the user is waiting on a single request
/// rather than scrolling through a list. A transient blip is worth one silent
/// retry; a hard failure surfaces on the error state below.

abstract class _$ListingDetailView extends $AsyncNotifier<ListingDetail?> {
  late final _$args = ref.$arg as String;
  String get listingId => _$args;

  FutureOr<ListingDetail?> build(String listingId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ListingDetail?>, ListingDetail?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ListingDetail?>, ListingDetail?>,
              AsyncValue<ListingDetail?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
