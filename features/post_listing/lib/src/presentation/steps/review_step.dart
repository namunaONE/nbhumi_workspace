import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:post_listing/l10n/output/post_localizations.dart'
    as post_strings;

import '../../viewmodels/listing_wizard_state.dart';
import '../../viewmodels/listing_wizard_validation.dart';
import '../../widgets/wizard_fields.dart';

/// Wizard step 5: review and submit.
///
/// Shows everything at once, because a seller about to commit to a listing
/// should not have to remember what they typed five screens ago. Each summary
/// row is tappable and jumps back to the step that owns it, which is why this
/// step takes a [onEditStep] rather than only a submit button.
///
/// ### No contact number here, on purpose
///
/// There is deliberately no phone field. \`v1_get_listing_detail\` omits the
/// seller's phone and email, and they are released only through
/// \`v1_contact_seller\`, which requires a signed-in buyer and is capped at ten
/// first-time reveals per rolling 24 hours. A phone number entered on the
/// listing form would be public to every guest immediately, bypassing both the
/// RPC and the cap. The seller's own number lives on their profile.
class ReviewStep extends StatelessWidget {
  /// Creates the review step.
  const ReviewStep({
    required this.state,
    required this.onEditStep,
    required this.onSubmit,
    super.key,
  });

  /// Current wizard state.
  final ListingWizardState state;

  /// Called with the step to jump back to.
  final void Function(WizardStep step) onEditStep;

  /// Called to submit the listing for review.
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = post_strings.AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(strings.reviewTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          strings.reviewSubtitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 16),
        _Row(
          label: strings.reviewType,
          value: _join(
            context,
            state.propertyType?.name,
            state.listingPurpose?.name,
          ),
          onTap: () => onEditStep(WizardStep.type),
        ),
        _Row(
          label: strings.reviewTitleRow,
          value: state.title.isEmpty
              ? strings.reviewNotSet
              : state.title,
          onTap: () => onEditStep(WizardStep.type),
        ),
        _Row(
          label: strings.reviewLocation,
          value: _location(context, state),
          onTap: () => onEditStep(WizardStep.location),
        ),
        _Row(
          label: strings.reviewArea,
          value: _area(context, state),
          onTap: () => onEditStep(WizardStep.specs),
        ),
        _Row(
          label: strings.reviewRooms,
          value: _rooms(context, state),
          onTap: () => onEditStep(WizardStep.specs),
        ),
        _Row(
          label: strings.reviewPrice,
          value: _price(context, state),
          onTap: () => onEditStep(WizardStep.price),
        ),
        _Row(
          label: strings.reviewPhotos,
          value: strings.reviewPhotosAdded(state.uploadedPhotoUrls.length),
          onTap: () => onEditStep(WizardStep.price),
        ),
        if (state.description.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          WizardSection(strings.reviewDescription),
          Text(state.description.trim(), style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        WizardNote(
          icon: Icons.phone_outlined,
          text: strings.reviewContactNote,
        ),
        if (state.submitError case final message?) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        PrimaryCTA(
          // Disabled unless every step passes, not just this one: the
          // seller can reach review by stepping backwards.
          label: strings.reviewSubmit,
          isLoading: state.submitting,
          onPressed: state.canSubmit(strings) && !state.submitting
              ? onSubmit
              : null,
        ),
      ],
    );
  }

  static String _join(BuildContext context, String? a, String? b) {
    final strings = post_strings.AppLocalizations.of(context);
    final parts = <String>[
      if (a != null) _humanise(a),
      if (b != null) _humanise(b),
    ];
    return parts.isEmpty ? strings.reviewNotSet : parts.join(' · ');
  }

  static String _humanise(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  static String _location(BuildContext context, ListingWizardState state) {
    final strings = post_strings.AppLocalizations.of(context);
    final parts = <String>[
      if (state.district != null) state.district!.name,
      if (state.city.trim().isNotEmpty) state.city.trim(),
      if (state.ward.trim().isNotEmpty)
        switch (int.tryParse(state.ward.trim())) {
          final n? => strings.wardNumber(n),
          // Unparseable ward text passes through rather than crashing review:
          // validation flags it on its own step, and review must never throw
          // on a state the seller was allowed to reach.
          _ => state.ward.trim(),
        },
    ];
    return parts.isEmpty ? strings.reviewNotSet : parts.join(', ');
  }

  /// The seller's own units, which is what they entered and what the listing
  /// will display.
  static String _area(BuildContext context, ListingWizardState state) {
    final strings = post_strings.AppLocalizations.of(context);
    final parts = <String>[
      if (state.usesHillUnits) ...<String>[
        if (state.areaRopani.isNotEmpty)
          '${state.areaRopani} ${strings.unitRopani}',
        if (state.areaAana.isNotEmpty)
          '${state.areaAana} ${strings.unitAana}',
        if (state.areaPaisa.isNotEmpty)
          '${state.areaPaisa} ${strings.unitPaisa}',
        if (state.areaDam.isNotEmpty) '${state.areaDam} ${strings.unitDam}',
      ] else ...<String>[
        if (state.areaBigha.isNotEmpty)
          '${state.areaBigha} ${strings.unitBigha}',
        if (state.areaKattha.isNotEmpty)
          '${state.areaKattha} ${strings.unitKattha}',
        if (state.areaDhur.isNotEmpty)
          '${state.areaDhur} ${strings.unitDhur}',
      ],
    ];
    if (parts.isEmpty) return strings.reviewNotSet;
    final sqm = state.areaSqm;
    if (sqm == null) return parts.join(' ');
    return '${parts.join(' ')} (~${sqm.toStringAsFixed(0)} sqm)';
  }

  static String _rooms(BuildContext context, ListingWizardState state) {
    final strings = post_strings.AppLocalizations.of(context);
    final parts = <String>[
      if (state.bedrooms.trim().isNotEmpty)
        '${state.bedrooms.trim()} ${strings.fieldBedrooms}',
      if (state.bathrooms.trim().isNotEmpty)
        '${state.bathrooms.trim()} ${strings.fieldBathrooms}',
    ];
    return parts.isEmpty ? strings.reviewNotApplicable : parts.join(' · ');
  }

  static String _price(BuildContext context, ListingWizardState state) {
    final strings = post_strings.AppLocalizations.of(context);
    final price = int.tryParse(state.priceNpr.trim());
    if (price == null || price <= 0) return strings.reviewNotSet;
    return NepaliCurrency.full(price);
  }
}

/// A tappable label/value row in the review summary.
class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 88,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
            Expanded(
              child: Text(value, style: theme.textTheme.bodyMedium),
            ),
            Icon(
              Icons.edit_outlined,
              size: 16,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
