import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';

import '../../viewmodels/listing_wizard_state.dart';
import '../../viewmodels/listing_wizard_validation.dart';
import '../../widgets/wizard_fields.dart';

/// Wizard step 2: district, city, ward and road access.
///
/// ### Why city is free text
///
/// The `municipalities` table arrives with HYA-253. Until it exists there is
/// nothing to cascade from, and a hard-coded list of local bodies would go
/// stale and cover only a fraction of the country. Free text with the district
/// as the validated part is the honest interim: the district is what drives
/// Rule 25's unit system, and that part is correct today.
class LocationStep extends StatelessWidget {
  /// Creates the location step.
  const LocationStep({
    required this.state,
    required this.districts,
    required this.onDistrictChanged,
    required this.onCityChanged,
    required this.onWardChanged,
    required this.onRoadAccessChanged,
    super.key,
  });

  /// Current wizard state.
  final ListingWizardState state;

  /// Districts to choose from, guest-readable reference data.
  final List<District> districts;

  /// Called with the chosen district.
  final void Function(District district) onDistrictChanged;

  /// Called when the city field changes.
  final void Function(String value) onCityChanged;

  /// Called when the ward field changes.
  final void Function(String value) onWardChanged;

  /// Called when the road frontage field changes.
  final void Function(String value) onRoadAccessChanged;

  @override
  Widget build(BuildContext context) {
    final errors = state.validate(WizardStep.location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const WizardSection(
          'Where is it?',
          subtitle: 'The district decides whether area is entered in ropani '
              'or in bigha.',
        ),
        _DistrictDropdown(
          districts: districts,
          selected: state.district,
          error: errors['district'],
          onChanged: onDistrictChanged,
        ),
        WizardField(
          label: 'City or municipality',
          value: state.city,
          error: errors['city'],
          onChanged: onCityChanged,
        ),
        WizardField(
          label: 'Ward',
          // Optional per Rule 28, so the hint says so rather than leaving the
          // seller to guess whether it matters.
          hint: 'Optional, 1-${Validators.maxWard}',
          value: state.ward,
          error: errors['ward'],
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
          onChanged: onWardChanged,
        ),
        WizardField(
          label: 'Road access',
          hint: 'Optional',
          suffixText: 'ft',
          value: state.roadAccessFt,
          error: errors['roadAccessFt'],
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
          onChanged: onRoadAccessChanged,
        ),
        const WizardNote(
          icon: Icons.map_outlined,
          text: 'Ward numbers run from 1 to 33. Pokhara Metropolitan City '
              'has the most wards of any local body in Nepal, at 33.',
        ),
      ],
    );
  }
}

/// District picker.
///
/// A dropdown rather than a text field so the seller cannot invent a district
/// name that no browse filter will ever match. Grouped by province because 77
/// flat entries is a long list to scroll on a phone.
class _DistrictDropdown extends StatelessWidget {
  const _DistrictDropdown({
    required this.districts,
    required this.selected,
    required this.onChanged,
    this.error,
  });

  final List<District> districts;
  final District? selected;
  final ValueChanged<District> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final byProvince = <String, List<District>>{};
    for (final district in districts) {
      byProvince
          .putIfAbsent(district.province, () => <District>[])
          .add(district);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<District>(
        // Keyed by district id so switching steps and back does not lose the
        // selection, which a value-only dropdown would.
        initialValue: selected,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'District',
          border: const OutlineInputBorder(),
          errorText: error,
        ),
        items: <DropdownMenuItem<District>>[
          for (final entry in byProvince.entries)
            ...<DropdownMenuItem<District>>[
            DropdownMenuItem<District>(
              enabled: false,
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            for (final district in entry.value)
              DropdownMenuItem<District>(
                value: district,
                child: Text(district.name),
              ),
          ],
        ],
        onChanged: (district) {
          if (district != null) onChanged(district);
        },
      ),
    );
  }
}
