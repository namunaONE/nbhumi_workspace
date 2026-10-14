import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_kyc_providers.freezed.dart';
part 'admin_kyc_providers.g.dart';

/// KYC document as shown in the admin review queue.
///
/// Mirrors the KYC document row with the SLA fields resolved server-side
/// so the list renders without re-evaluating `DateTime.now()` per row.
@freezed
sealed class AdminKycEntry with _$AdminKycEntry {
  const factory AdminKycEntry({
    required String id,
    required String profileId,
    required String profileName,
    required KycDocType docType,
    required String storagePath,
    required KycDocStatus status,
    required DateTime createdAt,
    required DateTime? reviewedAt,
    required String? reviewedByName,
    required String? listingId,
    required String? listingTitle,
  }) = _AdminKycEntry;

  factory AdminKycEntry.fromJson(Map<String, dynamic> json) =>
      _$AdminKycEntryFromJson(json);
}

/// Counts for the KYC queue tabs.
@freezed
sealed class AdminKycCounts with _$AdminKycCounts {
  const factory AdminKycCounts({
    @Default(0) int pending,
    @Default(0) int verified,
    @Default(0) int rejected,
  }) = _AdminKycCounts;

  factory AdminKycCounts.fromJson(Map<String, dynamic> json) =>
      _$AdminKycCountsFromJson(json);
}

/// View state for the admin KYC queue.
@freezed
sealed class AdminKycQueueState with _$AdminKycQueueState {
  const factory AdminKycQueueState({
    @Default(<AdminKycEntry>[]) List<AdminKycEntry> entries,
    @Default(AdminKycCounts()) AdminKycCounts counts,
    String? cursor,
    @Default(false) bool isLoadingMore,
    AppException? loadError,
  }) = _AdminKycQueueState;
}

extension AdminKycQueueStateX on AdminKycQueueState {
  bool get hasMore => cursor != null;

  bool get isEmpty => loadError == null && entries.isEmpty && cursor == null;

  AdminKycQueueState withClearedError({
    required String? cursor,
    List<AdminKycEntry>? entries,
    AdminKycCounts? counts,
    bool? isLoadingMore,
  }) =>
      AdminKycQueueState(
        entries: entries ?? this.entries,
        counts: counts ?? this.counts,
        cursor: cursor,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

/// Which KYC tab is active.
@riverpod
class AdminKycTab extends _$AdminKycTab {
  @override
  KycDocStatus build() => KycDocStatus.pending;

  KycDocStatus get tab => state;

  set tab(KycDocStatus value) => state = value;

  static const List<KycDocStatus> tabs = <KycDocStatus>[
    KycDocStatus.pending,
    KycDocStatus.verified,
    KycDocStatus.rejected,
  ];
}

/// KYC document currently open in the detail pane.
@riverpod
class AdminSelectedKyc extends _$AdminSelectedKyc {
  @override
  String? build() => null;

  String? get docId => state;

  set docId(String? value) => state = value;

  void clear() => state = null;
}

/// Admin KYC queue — paginated with keyset cursor.
@riverpod
class AdminKycQueue extends _$AdminKycQueue {
  @override
  Future<AdminKycQueueState> build() {
    final tab = ref.watch(adminKycTabProvider);
    return _loadFirstPage(tab);
  }

  Future<AdminKycQueueState> _loadFirstPage(KycDocStatus tab) async {
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .pendingKycDocuments(status: tab);

      return AdminKycQueueState(
        entries: page.entries,
        counts: page.counts,
        cursor: page.nextCursor,
      );
    } on AppException catch (e) {
      return AdminKycQueueState(loadError: e);
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null) return;
    if (!current.hasMore || current.cursor == null) return;
    if (current.isLoadingMore) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true),
    );

    try {
      final page = await ref.read(adminRepositoryProvider).pendingKycDocuments(
            status: ref.read(adminKycTabProvider),
            cursor: current.cursor,
          );

      state = AsyncData(
        current.withClearedError(
          entries: <AdminKycEntry>[...current.entries, ...page.entries],
          counts: page.counts,
          cursor: page.nextCursor,
          isLoadingMore: false,
        ),
      );
    } on AppException catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false, loadError: e));
    }
  }

  void retry() => ref.invalidateSelf();

  void removeRow(String docId) {
    final current = state.value;
    if (current == null) return;

    final remaining =
        current.entries.where((e) => e.id != docId).toList(growable: false);
    if (remaining.length == current.entries.length) return;

    state = AsyncData(
      current.copyWith(entries: remaining),
    );
  }

  void applyReviewOutcome(AdminKycReviewOutcome outcome) {
    removeRow(outcome.docId);

    switch (outcome.decision) {
      case AdminKycDecision.verify:
        _shiftCounts(pendingDelta: -1, verifiedDelta: 1);
      case AdminKycDecision.reject:
        _shiftCounts(pendingDelta: -1, rejectedDelta: 1);
    }
  }

  void _shiftCounts({
    int pendingDelta = 0,
    int verifiedDelta = 0,
    int rejectedDelta = 0,
  }) {
    final current = state.value;
    if (current == null) return;

    const floor = 0;
    final counts = current.counts;
    state = AsyncData(
      current.copyWith(
        counts: AdminKycCounts(
          pending: (counts.pending + pendingDelta).clamp(floor, 1 << 31),
          verified: (counts.verified + verifiedDelta).clamp(floor, 1 << 31),
          rejected: (counts.rejected + rejectedDelta).clamp(floor, 1 << 31),
        ),
      ),
    );
  }
}

/// KYC queue page returned by the repository.
@freezed
sealed class AdminKycPage with _$AdminKycPage {
  const factory AdminKycPage({
    required List<AdminKycEntry> entries,
    required AdminKycCounts counts,
    String? nextCursor,
  }) = _AdminKycPage;
}

/// KYC review decision.
enum AdminKycDecision {
  verify,
  reject,
}

/// Outcome of an admin KYC review.
@immutable
class AdminKycReviewOutcome {
  const AdminKycReviewOutcome({
    required this.docId,
    required this.decision,
    required this.serverStatus,
  });

  final String docId;
  final AdminKycDecision decision;
  final KycDocStatus serverStatus;
}

/// Mutation controller for admin KYC verify/reject.
@Riverpod(keepAlive: true)
class AdminKycReviewController extends _$AdminKycReviewController {
  @override
  void build() {}

  final Set<String> _inFlight = <String>{};

  Set<String> get inFlight => Set<String>.unmodifiable(_inFlight);

  Future<AdminKycReviewOutcome> verify(String docId) =>
      _decide(docId, AdminKycDecision.verify);

  Future<AdminKycReviewOutcome> reject(String docId, String reason) =>
      _decide(docId, AdminKycDecision.reject, reason: reason);

  Future<AdminKycReviewOutcome> _decide(
    String docId,
    AdminKycDecision decision, {
    String? reason,
  }) async {
    if (_inFlight.contains(docId)) {
      throw const ValidationException(
        code: 'validation.kycReviewAlreadyInFlight',
        messageEn: 'A decision on this document is already being saved.',
        messageNe: 'यस कागजातमा निर्णय पहिले नै जारी छ।',
      );
    }

    _inFlight.add(docId);
    try {
      final repository = ref.read(adminRepositoryProvider);

      final serverStatus = switch (decision) {
        AdminKycDecision.verify => await repository.verifyKyc(docId),
        AdminKycDecision.reject =>
          await repository.rejectKyc(docId, reason ?? ''),
      };

      final outcome = AdminKycReviewOutcome(
        docId: docId,
        decision: decision,
        serverStatus: serverStatus.status,
      );

      ref.read(adminKycQueueProvider.notifier).applyReviewOutcome(outcome);

      // Close detail pane if on pending tab
      if (ref.read(adminKycTabProvider) == KycDocStatus.pending) {
        ref.read(adminSelectedKycProvider.notifier).clear();
      }

      // Invalidate detail
      ref.invalidate(adminKycDocumentDetailProvider(docId));

      return outcome;
    } finally {
      _inFlight.remove(docId);
    }
  }
}

/// Detail view of one KYC document for admin review.
@riverpod
Future<AdminKycEntry?> adminKycDocumentDetail(
  Ref ref,
  String docId,
) async {
  try {
    return await ref
        .read(adminRepositoryProvider)
        .getKycDocument(docId);
  } on AppException {
    return null;
  }
}