import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../viewmodels/listing_wizard_state.dart';
import '../../viewmodels/listing_wizard_validation.dart';
import '../../widgets/wizard_fields.dart';

/// Wizard step 3: area, bedrooms, bathrooms and road access.
///
/// ### Why the area inputs change with the district
///
/// Nepal measures land in two systems that do not mix (Rule 25). Hill districts
/// use ropani-aana-paisa-dam, terai districts use bigha-kattha-dhur, and one
/// bigha is roughly twelve aana. Showing the wrong set does not merely confuse:
/// the values would be stored in the wrong columns and rendered back with the
/// wrong unit, understating or overstating the plot by an order of magnitude.
///
/// The set is therefore driven by `District.region` via
/// [ListingWizardState.usesHillUnits], and the sqm figure shown underneath is
/// derived with [AreaConverter] so the seller can sanity-check the result.
class SpecsStep extends StatelessWidget {
  /// Creates the specs step.
  const SpecsStep({
    required this.state,
    required this.onUnitChanged,
    required this.onBedroomsChanged,
    required this.onBathroomsChanged,
    super.key,
  });

  /// Current wizard state.
  final ListingWizardState state;

  /// Called with a storage field name and its new value for any area unit.
  ///
  /// One callback for all seven units rather than seven setters: the fields are
  /// declared as a list below, and a switch in the notifier is clearer than
  /// seven methods that differ only in a name.
  final void Function(String field, String value) onUnitChanged;

  /// Called when the bedroom count changes.
  final void Function(String value) onBedroomsChanged;

  /// Called when the bathroom count changes.
  final void Function(String value) onBathroomsChanged;

  @override
  Widget build(BuildContext context) {
    final errors = state.validate(WizardStep.specs);

    // No district yet means no unit system, so there is nothing honest to ask
    // for. The location step is the previous one and validation blocks skipping
    // past it.
    if (state.district == null) {
      return const WizardNote(
        icon: Icons.place_outlined,
        text: 'Choose a district first. Area is entered in ropani for hill '
            'districts and in bigha for terai districts.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WizardSection(
          'Area',
          subtitle: state.usesHillUnits
              ? '${state.district!.name} is a hill district. Enter ropani, '
                  'aana, paisa or dam.'
              : '${state.district!.name} is a terai district. Enter bigha, '
                  'kattha or dhur.',
        ),
        if (state.usesHillUnits) ...<Widget>[
          _unit('areaRopani', 'Ropani', state.areaRopani, errors),
          _unit('areaAana', 'Aana', state.areaAana, errors),
          _unit('areaPaisa', 'Paisa', state.areaPaisa, errors),
          _unit('areaDam', 'Dam', state.areaDam, errors),
        ] else ...<Widget>[
          _unit('areaBigha', 'Bigha', state.areaBigha, errors),
          _unit('areaKattha', 'Kattha', state.areaKattha, errors),
          _unit('areaDhur', 'Dhur', state.areaDhur, errors),
        ],
        if (errors['area'] case final areaError?) ...<Widget>[
          _AreaError(message: areaError),
          const SizedBox(height: 16),
        ],
        // Shown only once something has been entered, so it does not read as a
        // claim about a plot the seller has not described yet.
        if (state.areaSqm case final sqm?) _DerivedArea(sqm: sqm),
        const SizedBox(height: 24),
        const WizardSection('Rooms'),
        WizardField(
          label: 'Bedrooms',
          // Land and commercial premises have none, so this is optional and
          // blank is a legitimate value.
          hint: 'Optional',
          value: state.bedrooms,
          error: errors['bedrooms'],
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
          onChanged: onBedroomsChanged,
        ),
        WizardField(
          label: 'Bathrooms',
          hint: 'Optional',
          value: state.bathrooms,
          error: errors['bathrooms'],
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
          onChanged: onBathroomsChanged,
        ),
      ],
    );
  }

  Widget _unit(
    String field,
    String label,
    String value,
    StepValidation errors,
  ) =>
      WizardField(
        label: label,
        value: value,
        error: errors[field],
        keyboardType: TextInputType.number,
        inputFormatters: digitsOnly,
        onChanged: (next) => onUnitChanged(field, next),
      );
}

/// Inline area error, styled as a hint rather than a field error because it
/// concerns the group of fields rather than one of them.
class _AreaError extends StatelessWidget {
  const _AreaError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      message,
      style: theme.textTheme.bodySmall
          ?.copyWith(color: theme.colorScheme.error),
    );
  }
}

/// The derived square-metre figure.
class _DerivedArea extends StatelessWidget {
  const _DerivedArea({required this.sqm});

  final double sqm;

  @override
  Widget build(BuildContext context) {
    return WizardNote(
      icon: Icons.square_foot,
      text: 'About ${sqm.toStringAsFixed(0)} sqm in total. Listings are stored '
          'in sqm and shown to buyers in the units you entered.',
    );
  }
}
