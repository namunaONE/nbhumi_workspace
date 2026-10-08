import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';

import '../../providers/moderation_providers.dart';

/// Duplicate/fraud signals on the listing under review (HYA-261).
///
/// Read-only context for the decision, not a decision itself: a warning says
/// "look closer", never "reject". Placed high on the detail screen so the
/// admin sees it before scrolling through photos, but visually quieter than
/// the action bar -- signals inform, buttons decide.
///
/// An empty set renders as "no signals" rather than nothing: a missing panel
/// would read as "not checked", and an admin must be able to tell the two
/// apart. A load failure renders inline with a retry and never blocks the
/// approve/reject bar below (same reasoning as the audit trail panel).
class FraudSignalsPanel extends ConsumerWidget {
  /// Creates the signals panel for [listingId].
  const FraudSignalsPanel({required this.listingId, super.key});

  /// The listing under review.
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signals = ref.watch(fraudSignalsProvider(listingId));

    return switch (signals) {
      AsyncLoading() => const SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      AsyncError(:final error) => _SignalsLoadError(
          error: AppException.unmapped(error),
          onRetry: () => ref.invalidate(fraudSignalsProvider(listingId)),
        ),
      AsyncData(:final ListingFraudSignals value) =>
        value.signals.isEmpty ? const _NoSignals() : _SignalList(set: value),
    };
  }
}

/// One row per signal, warnings first.
///
/// The RPC already orders warnings before info, so this renders in wire
/// order rather than re-sorting: a client-side sort could disagree with the
/// server about what "most urgent" means. Evidence ids in `detail` are not
/// rendered -- they exist for a future deep-link to the other listing, and
/// raw uuids on screen would be noise until that link exists.
class _SignalList extends StatelessWidget {
  const _SignalList({required this.set});

  final ListingFraudSignals set;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warnings = set.warnings.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  warnings > 0
                      ? Icons.flag_outlined
                      : Icons.info_outline,
                  size: 18,
                  color: warnings > 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  warnings > 0
                      ? 'Fraud signals ($warnings)'
                      : 'Fraud signals',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final signal in set.signals)
              _SignalRow(signal: signal),
          ],
        ),
      ),
    );
  }
}

/// One signal: severity icon plus the bilingual message.
class _SignalRow extends StatelessWidget {
  const _SignalRow({required this.signal});

  final FraudSignal signal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warning = signal.severity == FraudSeverity.warning;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            warning ? Icons.warning_amber_outlined : Icons.info_outline,
            size: 16,
            color: warning
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            // Nepali-first (Rule 36): the target market reads Devanagari,
            // English only when the device locale asks for it.
            child: Text(
              Localizations.localeOf(context).languageCode == 'en'
                  ? signal.messageEn
                  : signal.messageNe,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// The checked-and-clear state: distinct from "not loaded".
class _NoSignals extends StatelessWidget {
  const _NoSignals();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Icon(
          Icons.check_circle_outline,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          'No fraud signals.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Shown when the signals read itself fails.
class _SignalsLoadError extends StatelessWidget {
  const _SignalsLoadError({required this.error, required this.onRetry});

  final AppException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            error.localizedForContext(context),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
