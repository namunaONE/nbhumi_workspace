import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:post_listing/l10n/output/post_localizations_en.dart';
import 'package:post_listing/src/viewmodels/listing_wizard_provider.dart';
import 'package:post_listing/src/viewmodels/listing_wizard_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Records the exact call sequence so the draft → attach → submit ordering
/// is asserted rather than assumed.
class _FakeListingRepository implements ListingRepository {
  _FakeListingRepository();

  final List<String> calls = <String>[];
  final List<String> attachedUrls = <String>[];
  final List<String?> attachedPaths = <String?>[];
  Listing? createdListing;
  String? createdId;
  AppException? createFailure;
  AppException? attachFailure;
  AppException? submitFailure;

  @override
  Future<String> createListing({
    required Listing listing,
    ListingStatus status = ListingStatus.draft,
  }) async {
    calls.add('create:${status.wireName}');
    final error = createFailure;
    if (error != null) throw error;
    createdListing = listing;
    createdId ??= 'draft-1';
    return createdId!;
  }

  @override
  Future<ListingStatus> updateListing({
    required String listingId,
    Listing? listing,
    ListingStatus? status,
  }) async {
    calls.add('update:${status?.wireName ?? 'none'}');
    final error = submitFailure;
    if (error != null) throw error;
    return status ?? ListingStatus.draft;
  }

  @override
  Future<void> attachListingPhotos(
    String listingId,
    List<PhotoAttachment> photos,
  ) async {
    calls.add('attach:${photos.length}');
    final error = attachFailure;
    if (error != null) throw error;
    attachedUrls.addAll(photos.map((photo) => photo.url));
    attachedPaths.addAll(photos.map((photo) => photo.storagePath));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

final _session = Session(
  accessToken: 'token',
  refreshToken: 'refresh',
  tokenType: 'bearer',
  user: const User(
    id: 'seller-1',
    appMetadata: <String, dynamic>{},
    userMetadata: <String, dynamic>{},
    aud: 'authenticated',
    createdAt: '2026-01-01T00:00:00Z',
  ),
);

ListingWizardState _state() => const ListingWizardState(
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      title: 'Test House',
      district: District(
        id: 29,
        name: 'Kathmandu',
        province: 3,
        region: Region.hill,
      ),
      municipality: Municipality(
        id: 'm-ktm',
        slug: 'kathmandu-kathmandu',
        district: 'Kathmandu',
        name: 'Kathmandu',
        type: MunicipalityType.metropolitan,
        wardCount: 32,
      ),
      city: 'Kathmandu',
      areaAana: '5',
      areaPaisa: '4',
      priceNpr: '25000000',
      photos: <WizardPhoto>[
        WizardPhoto(
          url: 'https://example.com/photo.jpg',
          storagePath: 'seller-1/123.jpg',
        ),
      ],
    );

void main() {
  final strings = AppLocalizationsEn();

  ProviderContainer makeContainer(_FakeListingRepository repository) {
    return ProviderContainer(
      overrides: [
        sessionProvider.overrideWithValue(_session),
        listingRepositoryProvider.overrideWithValue(repository),
      ],
    );
  }

  /// Seeds a complete wizard state directly.
  ///
  /// The submit tests own the create/attach/submit ordering; the provider's
  /// own setters are covered elsewhere, so they are bypassed here.
  void seedCompleteState(ListingWizard notifier) {
    notifier.state = _state();
  }

  group('ListingWizard.submit', () {
    test('creates a draft, attaches photos, then submits in order', () async {
      final repository = _FakeListingRepository();
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);

      final ok = await notifier.submit(strings);

      expect(ok, isTrue);
      expect(repository.calls, <String>[
        'create:draft',
        'attach:1',
        'update:pending_review',
      ]);
      expect(
        repository.attachedUrls,
        <String>['https://example.com/photo.jpg'],
      );
      expect(notifier.state.draftListingId, 'draft-1');
      expect(notifier.state.createdListingId, 'draft-1');
      expect(notifier.state.isSubmitted, isTrue);
    });

    test('a failed attach leaves a draft and no pending submission',
        () async {
      final repository = _FakeListingRepository()
        ..attachFailure = const NetworkException(
          code: 'network.offline',
          messageEn: 'No connection',
          messageNe: 'इन्टरनेट छैन',
        );
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);

      final ok = await notifier.submit(strings);

      expect(ok, isFalse);
      expect(repository.calls, <String>['create:draft', 'attach:1']);
      expect(repository.calls, isNot(contains('update:pending_review')));
      expect(notifier.state.draftListingId, 'draft-1');
      expect(notifier.state.createdListingId, isNull);
      expect(notifier.state.submitError, isNotNull);
    });

    test('retry after a failed attach reuses the same draft', () async {
      final repository = _FakeListingRepository()
        ..attachFailure = const NetworkException(
          code: 'network.offline',
          messageEn: 'No connection',
          messageNe: 'इन्टरनेट छैन',
        );
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);

      // First attempt: create + failed attach.
      expect(await notifier.submit(strings), isFalse);
      expect(repository.calls, <String>['create:draft', 'attach:1']);

      // Retry: no new create, form update, attach succeeds, submit succeeds.
      repository.attachFailure = null;
      expect(await notifier.submit(strings), isTrue);
      expect(repository.calls, <String>[
        'create:draft',
        'attach:1',
        'update:none',
        'attach:1',
        'update:pending_review',
      ]);
      // Only one draft was ever created.
      expect(
        repository.calls.where((c) => c == 'create:draft'),
        hasLength(1),
      );
    });

    test('a failed submit keeps the draft for retry', () async {
      final repository = _FakeListingRepository()
        ..submitFailure = const ServerException(
          code: 'server.listingNotReady',
          messageEn: 'Listing is not ready for review.',
          messageNe: 'लिस्टिङ समीक्षाको लागि तयार छैन।',
        );
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);

      final ok = await notifier.submit(strings);

      expect(ok, isFalse);
      expect(repository.calls, <String>[
        'create:draft',
        'attach:1',
        'update:pending_review',
      ]);
      expect(notifier.state.draftListingId, 'draft-1');
      expect(notifier.state.createdListingId, isNull);
    });

    test('a second submit after success is a no-op', () async {
      final repository = _FakeListingRepository();
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);

      expect(await notifier.submit(strings), isTrue);
      final callsAfterFirst = List<String>.from(repository.calls);

      // A second submit is a no-op: returns false, makes no new calls.
      expect(await notifier.submit(strings), isFalse);
      expect(repository.calls, callsAfterFirst);
    });

    test('attach carries the storage paths for the signals', () async {
      final repository = _FakeListingRepository();
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);

      expect(await notifier.submit(strings), isTrue);
      expect(
        repository.attachedPaths,
        <String?>['seller-1/123.jpg'],
      );
    });

    test('a kitta number flows into the created draft', () async {
      final repository = _FakeListingRepository();
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);
      notifier.setKittaNumber('  12-A  ');

      expect(await notifier.submit(strings), isTrue);
      // Trimmed on the wire path via _toListing's _nullIfBlank; the RPC
      // trims again server-side (Rule 6). Blank would arrive as null.
      expect(repository.createdListing?.kittaNumber, '12-A');
    });

    test('a blank kitta number arrives as null, not empty', () async {
      final repository = _FakeListingRepository();
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);
      notifier.setKittaNumber('   ');

      expect(await notifier.submit(strings), isTrue);
      expect(repository.createdListing?.kittaNumber, isNull);
    });

    test('facing and amenities flow into the created draft', () async {
      final repository = _FakeListingRepository();
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);
      notifier
        ..setFacingDirection(facing: FacingDirection.east)
        ..addAmenity('  Drinking water  ')
        ..addAmenity('Balcony');

      expect(await notifier.submit(strings), isTrue);
      expect(
        repository.createdListing?.facingDirection,
        FacingDirection.east,
      );
      expect(
        repository.createdListing?.amenities,
        <String>['Drinking water', 'Balcony'],
      );
    });

    test('amenity add drops blanks, duplicates and over-long tags', () async {
      final repository = _FakeListingRepository();
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);
      notifier
        ..addAmenity('   ')
        ..addAmenity('Water')
        ..addAmenity('water')
        ..addAmenity('x' * 41);

      expect(
        container.read(listingWizardProvider).amenities,
        <String>['Water'],
      );
    });

    test('amenity remove drops the chip at its index', () async {
      final repository = _FakeListingRepository();
      final container = makeContainer(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      seedCompleteState(notifier);
      notifier
        ..addAmenity('Water')
        ..addAmenity('Balcony')
        ..removeAmenity(0);

      expect(
        container.read(listingWizardProvider).amenities,
        <String>['Balcony'],
      );
    });
  });
}
