import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';
import 'package:post_listing/l10n/output/post_localizations.dart'
    as post_strings;

import '../../viewmodels/listing_wizard_state.dart';
import '../../viewmodels/listing_wizard_validation.dart';
import '../../widgets/wizard_fields.dart';

/// Wizard step 2: district, municipality, ward and road access.
///
/// A strict cascade: the municipality list is scoped to the chosen district,
/// and the ward picker is sized from the chosen municipality's `wardCount`.
/// Each level resets the ones below it, so the submitted (district, city, ward)
/// triple can never name a combination the database refuses — the composite
/// city FK and the per-body ward bound hold by construction rather than by
/// validation alone.
///
/// A [ConsumerWidget] rather than a plain widget because the municipality list
/// is fetched per district. Watching the family provider here keeps the screen
/// shell unchanged: it still resolves only `districtsProvider`, and this step
/// owns its own loading and error states inline.
class LocationStep extends ConsumerWidget {
  /// Creates the location step.
  const LocationStep({
    required this.state,
    required this.districts,
    required this.onDistrictChanged,
    required this.onMunicipalityChanged,
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

  /// Called with the chosen municipality.
  final void Function(Municipality municipality) onMunicipalityChanged;

  /// Called with the ward number, or '' when skipped.
  final void Function(String value) onWardChanged;

  /// Called when the road frontage field changes.
  final void Function(String value) onRoadAccessChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = post_strings.AppLocalizations.of(context);
    final errors = state.validate(WizardStep.location, strings);
    final district = state.district;

    // Always watched with a possibly-empty district, which the provider maps
    // to an empty list. No conditional watch, so there is no subscribe-or-miss
    // question when the seller picks their first district.
    final municipalities =
        ref.watch(municipalitiesProvider(district: district?.name ?? ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WizardSection(
          strings.locationTitle,
          subtitle: strings.locationSubtitle,
        ),
        _DistrictDropdown(
          districts: districts,
          selected: district,
          error: errors['district'],
          onChanged: onDistrictChanged,
        ),
        municipalities.when(
          loading: () => _ReferenceLoading(
            label: strings.municipalitiesLoading,
          ),
          error: (error, stackTrace) => _ReferenceError(
            message: strings.municipalitiesError,
            onRetry: () => ref.invalidate(
              municipalitiesProvider(district: district?.name ?? ''),
            ),
          ),
          data: (list) => _MunicipalityDropdown(
            municipalities: list,
            enabled: district != null,
            selected: state.municipality,
            error: errors['municipality'],
            onChanged: onMunicipalityChanged,
          ),
        ),
        _WardPicker(
          municipality: state.municipality,
          ward: state.ward,
          error: errors['ward'],
          onChanged: onWardChanged,
        ),
        WizardField(
          label: strings.fieldRoadAccess,
          hint: strings.fieldOptional,
          suffixText: 'ft',
          value: state.roadAccessFt,
          error: errors['roadAccessFt'],
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
          onChanged: onRoadAccessChanged,
        ),
        WizardNote(
          icon: Icons.map_outlined,
          text: strings.wardHint,
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
    final strings = post_strings.AppLocalizations.of(context);
    final byProvince = <String, List<District>>{};
    for (final district in districts) {
      byProvince
          .putIfAbsent(district.provinceName, () => <District>[])
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
          labelText: strings.fieldDistrict,
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

/// Municipality picker, scoped to the chosen district.
///
/// Disabled until a district is picked: with 753 bodies nationally, an
/// unscoped list is unusable, and a municipality belongs to exactly one
/// district so an unscoped pick could never be valid anyway.
class _MunicipalityDropdown extends StatelessWidget {
  const _MunicipalityDropdown({
    required this.municipalities,
    required this.enabled,
    required this.selected,
    required this.onChanged,
    this.error,
  });

  final List<Municipality> municipalities;
  final bool enabled;
  final Municipality? selected;
  final ValueChanged<Municipality> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final strings = post_strings.AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Municipality>(
        initialValue: selected,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: strings.fieldMunicipality,
          border: const OutlineInputBorder(),
          errorText: error,
        ),
        items: <DropdownMenuItem<Municipality>>[
          for (final municipality in municipalities)
            DropdownMenuItem<Municipality>(
              value: municipality,
              child: Text(
                municipality.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: !enabled
            ? null
            : (municipality) {
                if (municipality != null) onChanged(municipality);
              },
      ),
    );
  }
}

/// Ward picker, sized from the chosen municipality's ward count.
///
/// A dropdown of 1..wardCount rather than a numeric field, so an out-of-range
/// ward cannot be entered in the first place: ward 25 in a 9-ward body is
/// unselectable here, not merely invalid. Optional per Rule 28, so the first
/// entry clears the selection rather than forcing one.
class _WardPicker extends StatelessWidget {
  const _WardPicker({
    required this.municipality,
    required this.ward,
    required this.onChanged,
    this.error,
  });

  final Municipality? municipality;
  final String ward;
  final ValueChanged<String> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final strings = post_strings.AppLocalizations.of(context);
    final body = municipality;
    if (body == null) {
      // No municipality yet means the ward has no bound, so there is nothing
      // honest to offer. The municipality is required to leave the step, which
      // is what unblocks this picker.
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: WizardNote(
          icon: Icons.numbers,
          text: strings.wardNoMunicipality,
        ),
      );
    }

    final selected = int.tryParse(ward);
    final inRange =
        selected != null && selected >= 1 && selected <= body.wardCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int?>(
        initialValue: inRange ? selected : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: strings.fieldWard,
          border: const OutlineInputBorder(),
          errorText: error,
        ),
        items: <DropdownMenuItem<int?>>[
          DropdownMenuItem<int?>(
            child: Text(strings.wardNone),
          ),
          for (var number = 1; number <= body.wardCount; number++)
            DropdownMenuItem<int?>(
              value: number,
              child: Text(strings.wardNumber(number)),
            ),
        ],
        onChanged: (number) => onChanged(number?.toString() ?? ''),
      ),
    );
  }
}

/// Inline loading row for reference data.
class _ReferenceLoading extends StatelessWidget {
  const _ReferenceLoading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final strings = post_strings.AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            strings.loadingSuffix(label),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Inline error row for reference data, with retry.
class _ReferenceError extends StatelessWidget {
  const _ReferenceError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = post_strings.AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(strings.retryAction),
          ),
        ],
      ),
    );
  }
}
