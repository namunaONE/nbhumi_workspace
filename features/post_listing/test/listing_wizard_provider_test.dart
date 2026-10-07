import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:post_listing/l10n/output/post_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:post_listing/l10n/output/post_localizations_en.dart';
import 'package:post_listing/src/viewmodels/listing_wizard_provider.dart';
import 'package:post_listing/src/viewmodels/listing_wizard_state.dart';

/// Records the exact call sequence so the draft â†’ attach â†’ submit ordering
/// is asserted rather than assumed.
class _FakeListingRepository implements ListingRepository {
  _FakeListingRepository();

  final List<String> calls = <String>[];
  final List<String> attachedUrls = <String>[];
  String? createdId;
  ListingStatus? submittedStatus;
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
    submittedStatus = status ?? ListingStatus.draft;
    return submittedStatus!;
  }

  @override
  Future<void> attachListingPhotos(
    String listingId,
    List<String> urls,
  ) async {
    calls.add('attach:${urls.length}');
    final error = attachFailure;
    if (error != null) throw error;
    attachedUrls.addAll(urls);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

final _session = Session(
  accessToken: 'token',
  refreshToken: 'refresh',
  tokenType: 'bearer',
  user: User(
    id: 'seller-1',
    appMetadata: <String, dynamic>{},
    userMetadata: <String, dynamic>{},
    aud: 'authenticated',
    createdAt: '2026-01-01T00:00:00Z',
  ),
);

ListingWizardState _state() => ListingWizardState(
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      title: 'Test House',
      district: const District(
        id: 29,
        name: 'Kathmandu',
        province: 3,
        region: Region.hill,
      ),
      municipality: const Municipality(
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
      photos: const <WizardPhoto>[
        WizardPhoto(url: 'https://example.com/photo.jpg'),
      ],
    );

void main() {
  final strings = AppLocalizationsEn();

  ProviderContainer _container(_FakeListingRepository repository) {
    return ProviderContainer(
      overrides: [
        sessionProvider.overrideWithValue(_session),
        listingRepositoryProvider.overrideWithValue(repository),
      ],
    );
  }

  group('ListingWizard.submit', () {
    test('creates a draft, attaches photos, then submits in order', () async {
      final repository = _FakeListingRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      // Seed the complete state directly; the provider's setters are tested
      // elsewhere and this test owns the submit ordering.
      // ignore: invalid_use_of_protected_member
      notifier.state = _state();

      final ok = await notifier.submit(strings);

      expect(ok, isTrue);
      expect(repository.calls, <String>[
        'create:draft',
        'attach:1',
        'update:pending_review',
      ]);
      expect(repository.attachedUrls, <String>['https://example.com/photo.jpg']);
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
          messageNe: 'à¤‡à¤¨à¥à¤Ÿà¤°à¤¨à¥‡à¤Ÿ à¤›à¥ˆà¤¨',
        );
      final container = _container(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = _state();

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
          messageNe: 'à¤‡à¤¨à¥à¤Ÿà¤°à¤¨à¥‡à¤Ÿ à¤›à¥ˆà¤¨',
        );
      final container = _container(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = _state();

      // First attempt: create + failed attach.
      expect(await notifier.submit(strings), isFalse);
      expect(repository.calls, <String>['create:draft', 'attach:1']);

      // Retry: no new create, attach succeeds, submit succeeds.
      repository.attachFailure = null;
      expect(await notifier.submit(strings), isTrue);
      expect(repository.calls, <String>[
        'create:draft',
        'attach:1',
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
          messageNe: 'à¤²à¤¿à¤¸à¥à¤Ÿà¤¿à¤™ à¤¸à¤®à¥€à¤•à¥à¤·à¤¾à¤•à¥‹ à¤²à¤¾à¤—à¤¿ à¤¤à¤¯à¤¾à¤° à¤›à¥ˆà¤¨à¥¤',
        );
      final container = _container(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = _state();

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
      final container = _container(repository);
      addTearDown(container.dispose);

      final notifier = container.read(listingWizardProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = _state();

      expect(await notifier.submit(strings), isTrue);
      final callsAfterFirst = List<String>.from(repository.calls);

      expect(await notifier.submit(strings), isTrue);
      expect(repository.calls, callsAfterFirst);
    });
  });
}
