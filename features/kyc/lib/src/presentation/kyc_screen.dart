import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyc/l10n/output/kyc_localizations.dart' as kyc_strings;
import 'package:models/models.dart';

import '../viewmodels/kyc_providers.dart';

/// Seller identity verification.
///
/// Lists the seller's KYC submissions with their review state and offers a
/// submit sheet. Reached from the profile screen; gated behind a session by
/// the router, like `/post`.
class KycScreen extends ConsumerWidget {
  /// Creates the verification screen.
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(myKycDocumentsProvider);
    final strings = kyc_strings.AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const _DisclaimerCard(),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(strings.submitDocument),
            onPressed: () => _SubmitSheet.show(context),
          ),
          const SizedBox(height: 16),
          switch (documents) {
            AsyncLoading() => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            AsyncError(:final error) => _DocumentsError(
                error: error,
                onRetry: () => ref.invalidate(myKycDocumentsProvider),
              ),
            AsyncData(:final value) when value.isEmpty => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(strings.emptyBody),
                ),
              ),
            AsyncData(:final value) => Column(
                children: <Widget>[
                  for (final doc in value) _DocumentTile(document: doc),
                ],
              ),
          },
        ],
      ),
    );
  }
}

/// What verification is and is not (HYA-265 copy rule).
///
/// Doc-check only: an admin confirms the photo is readable and matches the
/// account. It is never a legal opinion on ownership or title, and the copy
/// must say so — a badge that reads as a title guarantee would mislead both
/// sides of the transaction.
class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = kyc_strings.AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.verified_user_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.howItWorks,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(strings.howItWorksBody),
          ],
        ),
      ),
    );
  }
}

/// One submitted document with its review state.
class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document});

  final KycDocument document;

  @override
  Widget build(BuildContext context) {
    final strings = kyc_strings.AppLocalizations.of(context);
    final (icon, label) = switch (document.status) {
      KycDocStatus.pending => (
          Icons.hourglass_top_outlined,
          strings.statusPending,
        ),
      KycDocStatus.verified => (
          Icons.verified_outlined,
          strings.statusVerified,
        ),
      KycDocStatus.rejected => (
          Icons.gpp_bad_outlined,
          strings.statusRejected,
        ),
    };
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(_docTypeLabel(context, document.docType)),
        subtitle: Text(label),
      ),
    );
  }
}

/// Failure loading the document list, with a retry for recoverable errors.
class _DocumentsError extends StatelessWidget {
  const _DocumentsError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure =
        error is AppException ? error as AppException : null;
    final strings = kyc_strings.AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              failure?.localizedForContext(context) ?? strings.loadFailed,
            ),
            const SizedBox(height: 8),
            if (failure == null || failure.isRetryable)
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(strings.retry),
                onPressed: onRetry,
              ),
          ],
        ),
      ),
    );
  }
}

/// Human-readable document type names.
String _docTypeLabel(BuildContext context, KycDocType type) {
  final strings = kyc_strings.AppLocalizations.of(context);
  return switch (type) {
    KycDocType.citizenship => strings.docCitizenship,
    KycDocType.lalpurja => strings.docLalpurja,
    KycDocType.agencyReg => strings.docAgencyReg,
  };
}

/// Bottom sheet that picks a document type and submits one photo.
class _SubmitSheet extends ConsumerStatefulWidget {
  const _SubmitSheet();

  /// Opens the sheet.
  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const _SubmitSheet(),
      );

  @override
  ConsumerState<_SubmitSheet> createState() => _SubmitSheetState();
}

class _SubmitSheetState extends ConsumerState<_SubmitSheet> {
  KycDocType _type = KycDocType.citizenship;

  @override
  Widget build(BuildContext context) {
    final submit = ref.watch(kycSubmitControllerProvider);
    final strings = kyc_strings.AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            strings.chooseDocument,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SegmentedButton<KycDocType>(
            segments: <ButtonSegment<KycDocType>>[
              for (final type in KycDocType.values)
                ButtonSegment<KycDocType>(
                  value: type,
                  label: Text(_docTypeLabel(context, type)),
                ),
            ],
            selected: <KycDocType>{_type},
            onSelectionChanged: submit.submitting
                ? null
                : (selection) => setState(() => _type = selection.first),
            showSelectedIcon: false,
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
          if (submit.hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _errorFor(context, submit),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          FilledButton.icon(
            icon: submit.submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.photo_library_outlined),
            label: Text(
              submit.submitting ? strings.uploading : strings.pickAndSubmit,
            ),
            onPressed: submit.submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  /// Picks the locale's message from the stored pair (Rule 36).
  String _errorFor(BuildContext context, KycSubmitState submit) {
    final locale = Localizations.maybeLocaleOf(context);
    final preferNepali = (locale?.languageCode ?? 'ne') != 'en';
    return preferNepali
        ? (submit.errorNe ?? submit.errorEn ?? '')
        : (submit.errorEn ?? submit.errorNe ?? '');
  }

  Future<void> _submit() async {
    final done = await ref
        .read(kycSubmitControllerProvider.notifier)
        .submit(_type);
    if (!mounted) return;
    if (done) {
      Navigator.of(context).pop();
      final strings = kyc_strings.AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.submitted),
        ),
      );
    }
  }
}
