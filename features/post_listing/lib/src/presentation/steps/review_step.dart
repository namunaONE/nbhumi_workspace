import 'package:core/core.dart';
import 'package:flutter/material.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Check your listing', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'It will be reviewed before it appears publicly.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 16),
        _Row(
          label: 'Type',
          value: _join(state.propertyType?.name, state.listingPurpose?.name),
          onTap: () => onEditStep(WizardStep.type),
        ),
        _Row(
          label: 'Title',
          value: state.title.isEmpty ? 'Not set' : state.title,
          onTap: () => onEditStep(WizardStep.type),
        ),
        _Row(
          label: 'Location',
          value: _location(state),
          onTap: () => onEditStep(WizardStep.location),
        ),
        _Row(
          label: 'Area',
          value: _area(state),
          onTap: () => onEditStep(WizardStep.specs),
        ),
        _Row(
          label: 'Rooms',
          value: _rooms(state),
          onTap: () => onEditStep(WizardStep.specs),
        ),
        _Row(
          label: 'Price',
          value: _price(state),
          onTap: () => onEditStep(WizardStep.price),
        ),
        _Row(
          label: 'Photos',
          value: '${state.uploadedPhotoUrls.length} added',
          onTap: () => onEditStep(WizardStep.price),
        ),
        if (state.description.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          const WizardSection('Description'),
          Text(state.description.trim(), style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        const WizardNote(
          icon: Icons.phone_outlined,
          text: 'Buyers see your contact details only after signing in and '
              'requesting them, so your number is never published on the '
              'listing.',
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
        FilledButton(
          // Disabled unless every step passes, not just this one: the
          // seller can reach review by stepping backwards.
          onPressed: state.canSubmit && !state.submitting ? onSubmit : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: state.submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit for review'),
        ),
      ],
    );
  }

  static String _join(String? a, String? b) {
    final parts = <String>[
      if (a != null) _humanise(a),
      if (b != null) _humanise(b),
    ];
    return parts.isEmpty ? 'Not set' : parts.join(' · ');
  }

  static String _humanise(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  static String _location(ListingWizardState state) {
    final parts = <String>[
      if (state.district != null) state.district!.name,
      if (state.city.trim().isNotEmpty) state.city.trim(),
      if (state.ward.trim().isNotEmpty) 'Ward ${state.ward.trim()}',
    ];
    return parts.isEmpty ? 'Not set' : parts.join(', ');
  }

  /// The seller's own units, which is what they entered and what the listing
  /// will display.
  static String _area(ListingWizardState state) {
    final parts = <String>[
      if (state.usesHillUnits) ...<String>[
        if (state.areaRopani.isNotEmpty) '${state.areaRopani} ropani',
        if (state.areaAana.isNotEmpty) '${state.areaAana} aana',
        if (state.areaPaisa.isNotEmpty) '${state.areaPaisa} paisa',
        if (state.areaDam.isNotEmpty) '${state.areaDam} dam',
      ] else ...<String>[
        if (state.areaBigha.isNotEmpty) '${state.areaBigha} bigha',
        if (state.areaKattha.isNotEmpty) '${state.areaKattha} kattha',
        if (state.areaDhur.isNotEmpty) '${state.areaDhur} dhur',
      ],
    ];
    if (parts.isEmpty) return 'Not set';
    final sqm = state.areaSqm;
    if (sqm == null) return parts.join(' ');
    return '${parts.join(' ')} (~${sqm.toStringAsFixed(0)} sqm)';
  }

  static String _rooms(ListingWizardState state) {
    final parts = <String>[
      if (state.bedrooms.trim().isNotEmpty) '${state.bedrooms.trim()} bed',
      if (state.bathrooms.trim().isNotEmpty) '${state.bathrooms.trim()} bath',
    ];
    return parts.isEmpty ? 'Not applicable' : parts.join(' · ');
  }

  static String _price(ListingWizardState state) {
    final price = int.tryParse(state.priceNpr.trim());
    if (price == null || price <= 0) return 'Not set';
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
