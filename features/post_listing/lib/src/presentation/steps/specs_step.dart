import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:models/models.dart';
import 'package:post_listing/l10n/output/post_localizations.dart'
    as post_strings;

import '../../viewmodels/listing_wizard_state.dart';
import '../../viewmodels/listing_wizard_validation.dart';
import '../../widgets/wizard_fields.dart';

/// Wizard step 3: area, rooms, and whatever the property type and purpose
/// actually call for.
///
/// ### Why the area inputs change with the district
///
/// Nepal measures land in two systems that do not mix (Rule 25). Hill
/// districts use ropani-aana-paisa-dam, terai districts use bigha-kattha-dhur,
/// and one bigha is roughly twelve aana. Showing the wrong set does not
/// merely confuse: the values would be stored in the wrong columns and
/// rendered back with the wrong unit, understating or overstating the plot by
/// an order of magnitude.
///
/// The set is therefore driven by `District.region` via
/// [ListingWizardState.usesHillUnits], and the sqm figure shown underneath is
/// derived with [AreaConverter] so the seller can sanity-check the result.
///
/// ### Why the later sections appear and disappear
///
/// A plot of land has no bedrooms, a flat has no frontage, and a lease
/// without a term is not a lease. The sections below are gated on
/// [ListingWizardState.isResidential], [ListingWizardState.hasParking],
/// [ListingWizardState.hasFloors], [ListingWizardState.isBuilt],
/// [ListingWizardState.isLease] and [ListingWizardState.isRent] -- the same
/// predicates the database trigger and the validators read, so the form
/// cannot ask for something the schema will refuse, and cannot hide something
/// it will accept.
class SpecsStep extends StatelessWidget {
  /// Creates the specs step.
  const SpecsStep({
    required this.state,
    required this.onUnitChanged,
    required this.onBedroomsChanged,
    required this.onBathroomsChanged,
    required this.onLeaseTermChanged,
    required this.onLeaseRenewableChanged,
    required this.onDepositChanged,
    required this.onAvailableFromChanged,
    required this.onFurnishingChanged,
    required this.onUtilitiesChanged,
    required this.onPetPolicyChanged,
    required this.onParkingChanged,
    required this.onFloorNumberChanged,
    required this.onTotalFloorsChanged,
    required this.onPropertyAgeChanged,
    required this.onConstructionStatusChanged,
    super.key,
  });

  /// Current wizard state.
  final ListingWizardState state;

  /// Called with a storage field name and its new value for any area unit.
  ///
  /// One callback for all seven units rather than seven setters: the fields
  /// are declared as a list below, and a switch in the notifier is clearer
  /// than seven methods that differ only in a name.
  final void Function(String field, String value) onUnitChanged;

  /// Called when the bedroom count changes.
  final void Function(String value) onBedroomsChanged;

  /// Called when the bathroom count changes.
  final void Function(String value) onBathroomsChanged;

  /// Called when the lease length in months changes.
  final void Function(String value) onLeaseTermChanged;

  /// Called with the renewal answer, or null to withdraw it.
  final void Function({required bool? renewable}) onLeaseRenewableChanged;

  /// Called when the security deposit changes.
  final void Function(String value) onDepositChanged;

  /// Called with the availability date, or null to clear it.
  final void Function({required DateTime? availableFrom})
      onAvailableFromChanged;

  /// Called with the furnishing level, or null to clear it.
  final void Function({required FurnishingStatus? furnishing})
      onFurnishingChanged;

  /// Called when the utilities note changes.
  final void Function(String value) onUtilitiesChanged;

  /// Called with the pet policy, or null to clear it.
  final void Function({required PetPolicy? petPolicy}) onPetPolicyChanged;

  /// Called when the parking space count changes.
  final void Function(String value) onParkingChanged;

  /// Called when the floor number changes.
  final void Function(String value) onFloorNumberChanged;

  /// Called when the total floor count changes.
  final void Function(String value) onTotalFloorsChanged;

  /// Called when the building age changes.
  final void Function(String value) onPropertyAgeChanged;

  /// Called with the construction status, or null to clear it.
  final void Function({required ConstructionStatus? constructionStatus})
      onConstructionStatusChanged;

  @override
  Widget build(BuildContext context) {
    final strings = post_strings.AppLocalizations.of(context);
    final errors = state.validate(WizardStep.specs, strings);

    // No district yet means no unit system, so there is nothing honest to ask
    // for. The location step is the previous one and validation blocks
    // skipping past it.
    if (state.district == null) {
      return WizardNote(
        icon: Icons.place_outlined,
        text: strings.specsNoDistrict,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WizardSection(
          strings.specsAreaTitle,
          subtitle: state.usesHillUnits
              ? strings.specsAreaHill(state.district!.name)
              : strings.specsAreaTerai(state.district!.name),
        ),
        if (state.usesHillUnits) ...<Widget>[
          _unit('areaRopani', strings.unitRopani, state.areaRopani, errors),
          _unit('areaAana', strings.unitAana, state.areaAana, errors),
          _unit('areaPaisa', strings.unitPaisa, state.areaPaisa, errors),
          _unit('areaDam', strings.unitDam, state.areaDam, errors),
        ] else ...<Widget>[
          _unit('areaBigha', strings.unitBigha, state.areaBigha, errors),
          _unit('areaKattha', strings.unitKattha, state.areaKattha, errors),
          _unit('areaDhur', strings.unitDhur, state.areaDhur, errors),
        ],
        if (errors['area'] case final areaError?) ...<Widget>[
          _AreaError(message: areaError),
          const SizedBox(height: 16),
        ],
        // Shown only once something has been entered, so it does not read as
        // a claim about a plot the seller has not described yet.
        if (state.areaSqm case final sqm?) _DerivedArea(sqm: sqm),
        const SizedBox(height: 24),
        // Rooms: house, apartment and villa only. Land, commercial and
        // business have none, and asking a land seller how many bedrooms
        // their plot has is both confusing and a signal we do not want in the
        // data.
        if (state.isResidential) ...<Widget>[
          WizardSection(strings.specsRooms),
          WizardField(
            label: strings.fieldBedrooms,
            hint: strings.fieldOptional,
            value: state.bedrooms,
            error: errors['bedrooms'],
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: onBedroomsChanged,
          ),
          WizardField(
            label: strings.fieldBathrooms,
            hint: strings.fieldOptional,
            value: state.bathrooms,
            error: errors['bathrooms'],
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: onBathroomsChanged,
          ),
        ],
        if (state.hasParking) ...<Widget>[
          WizardSection(strings.sectionBuilding),
          WizardField(
            label: strings.fieldParking,
            hint: strings.fieldOptional,
            value: state.parkingSpaces,
            error: errors['parkingSpaces'],
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: onParkingChanged,
          ),
        ],
        if (state.hasFloors) ...<Widget>[
          WizardField(
            label: strings.fieldFloor,
            hint: strings.fieldFloorHint,
            value: state.floorNumber,
            error: errors['floorNumber'],
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: onFloorNumberChanged,
          ),
          WizardField(
            label: strings.fieldTotalFloors,
            value: state.totalFloors,
            error: errors['totalFloors'],
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: onTotalFloorsChanged,
          ),
        ],
        if (state.isBuilt) ...<Widget>[
          WizardField(
            label: strings.fieldPropertyAge,
            hint: strings.fieldPropertyAgeHint,
            value: state.propertyAgeYears,
            error: errors['propertyAgeYears'],
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: onPropertyAgeChanged,
          ),
          _ConstructionStatusPicker(
            value: state.constructionStatus,
            onChanged: (status) =>
                onConstructionStatusChanged(constructionStatus: status),
          ),
        ],
        // Lease terms: a lease needs one. Anything else would leave the
        // review screen showing "Not set" for the field that defines the
        // arrangement.
        if (state.isLease) ...<Widget>[
          const SizedBox(height: 24),
          WizardSection(
            strings.sectionLeaseTerms,
            subtitle: strings.leaseTermsExplanation,
          ),
          WizardField(
            label: strings.fieldLeaseTerm,
            hint: strings.fieldLeaseTermHint,
            value: state.leaseTermMonths,
            error: errors['leaseTermMonths'],
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: onLeaseTermChanged,
          ),
          _RenewablePicker(
            value: state.leaseRenewable,
            onChanged: onLeaseRenewableChanged,
          ),
        ],
        // Rental terms: what a tenant needs before they enquire.
        if (state.isRent) ...<Widget>[
          const SizedBox(height: 24),
          WizardSection(strings.sectionRentalTerms),
          _AvailabilityPicker(
            value: state.availableFrom,
            error: errors['availableFrom'],
            onChanged: (date) =>
                onAvailableFromChanged(availableFrom: date),
          ),
          WizardField(
            label: strings.fieldDeposit,
            hint: strings.fieldDepositHint,
            value: state.depositAmount,
            error: errors['depositAmount'],
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: onDepositChanged,
          ),
          _FurnishingPicker(
            value: state.furnishingStatus,
            onChanged: (furnishing) =>
                onFurnishingChanged(furnishing: furnishing),
          ),
          WizardField(
            label: strings.fieldUtilities,
            hint: strings.fieldUtilitiesHint,
            value: state.utilitiesIncluded,
            error: errors['utilitiesIncluded'],
            onChanged: onUtilitiesChanged,
          ),
          _PetPolicyPicker(
            value: state.petPolicy,
            onChanged: (petPolicy) => onPetPolicyChanged(petPolicy: petPolicy),
          ),
        ],
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
    final strings = post_strings.AppLocalizations.of(context);
    return WizardNote(
      icon: Icons.square_foot,
      text: strings.derivedArea(sqm.toStringAsFixed(0)),
    );
  }
}

/// Lease renewal: a genuinely three-way answer.
///
/// Yes, No, and "the seller did not say" are different states. A two-way
/// switch would force a seller who has not thought about it into a "No" that
/// then misleads every tenant who filters on renewal, so the unset state is
/// kept and rendered as its own choice.
class _RenewablePicker extends StatelessWidget {
  const _RenewablePicker({required this.value, required this.onChanged});

  final bool? value;
  final void Function({required bool? renewable}) onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = post_strings.AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.fieldLeaseRenewable,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              ChoiceChip(
                label: Text(strings.leaseRenewableYes),
                selected: value == true,
                onSelected: (chosen) =>
                    chosen ? onChanged(renewable: true) : null,
              ),
              ChoiceChip(
                label: Text(strings.leaseRenewableNo),
                selected: value == false,
                onSelected: (chosen) =>
                    chosen ? onChanged(renewable: false) : null,
              ),
              // Tapping the selected chip clears it, which is how a seller
              // withdraws an answer they gave by accident.
              if (value != null)
                ChoiceChip(
                  label: Text(strings.leaseRenewableUnset),
                  selected: false,
                  onSelected: (_) => onChanged(renewable: null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Construction status picker, shared by everything that is built.
class _ConstructionStatusPicker extends StatelessWidget {
  const _ConstructionStatusPicker({
    required this.value,
    required this.onChanged,
  });

  final ConstructionStatus? value;
  final void Function(ConstructionStatus? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = post_strings.AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<ConstructionStatus?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: strings.fieldConstructionStatus,
          border: const OutlineInputBorder(),
        ),
        items: <DropdownMenuItem<ConstructionStatus?>>[
          DropdownMenuItem<ConstructionStatus?>(
            child: Text(strings.fieldOptional),
          ),
          for (final status in ConstructionStatus.values)
            DropdownMenuItem<ConstructionStatus?>(
              value: status,
              child: Text(_label(strings, status)),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  static String _label(
    post_strings.AppLocalizations strings,
    ConstructionStatus status,
  ) =>
      switch (status) {
        ConstructionStatus.newBuild => strings.constructionNew,
        ConstructionStatus.underConstruction =>
          strings.constructionUnderConstruction,
        ConstructionStatus.resale => strings.constructionResale,
      };
}

/// Availability date. A date picker rather than a text field because the
/// value is compared against today, and a free-text date that parses
/// differently on two devices is worse than a picker two taps away.
class _AvailabilityPicker extends StatelessWidget {
  const _AvailabilityPicker({
    required this.value,
    required this.onChanged,
    this.error,
  });

  final DateTime? value;
  final String? error;
  final void Function(DateTime? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = post_strings.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          OutlinedButton.icon(
            icon: const Icon(Icons.event_outlined),
            label: Text(
              value == null
                  ? strings.fieldAvailableFromPick
                  : '${strings.fieldAvailableFrom}: '
                      '${DateFormat.yMMMd(locale).format(value!)}',
            ),
            onPressed: () => _pick(context),
          ),
          if (value != null)
            TextButton(
              onPressed: () => onChanged(null),
              child: Text(strings.fieldAvailableFromClear),
            ),
          if (error case final message?)
            Text(
              message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: now,
      // A year of runway is enough for any handover, and a picker that spans
      // a decade invites a mis-tap on a year.
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (picked != null) onChanged(picked);
  }
}

/// Furnishing level picker. Unset is a legitimate answer: a seller who has
/// not decided what stays should not be forced into "Unfurnished".
class _FurnishingPicker extends StatelessWidget {
  const _FurnishingPicker({required this.value, required this.onChanged});

  final FurnishingStatus? value;
  final void Function(FurnishingStatus? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = post_strings.AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<FurnishingStatus?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: strings.fieldFurnishing,
          border: const OutlineInputBorder(),
        ),
        items: <DropdownMenuItem<FurnishingStatus?>>[
          DropdownMenuItem<FurnishingStatus?>(
            child: Text(strings.fieldOptional),
          ),
          for (final level in FurnishingStatus.values)
            DropdownMenuItem<FurnishingStatus?>(
              value: level,
              child: Text(_label(strings, level)),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  static String _label(
    post_strings.AppLocalizations strings,
    FurnishingStatus level,
  ) =>
      switch (level) {
        FurnishingStatus.unfurnished => strings.furnishingUnfurnished,
        FurnishingStatus.semiFurnished => strings.furnishingSemiFurnished,
        FurnishingStatus.furnished => strings.furnishingFurnished,
      };
}

/// Pet policy picker, with a "negotiable" option distinct from permission.
class _PetPolicyPicker extends StatelessWidget {
  const _PetPolicyPicker({required this.value, required this.onChanged});

  final PetPolicy? value;
  final void Function(PetPolicy? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = post_strings.AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<PetPolicy?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: strings.fieldPetPolicy,
          border: const OutlineInputBorder(),
        ),
        items: <DropdownMenuItem<PetPolicy?>>[
          DropdownMenuItem<PetPolicy?>(
            child: Text(strings.leaseRenewableUnset),
          ),
          for (final policy in PetPolicy.values)
            DropdownMenuItem<PetPolicy?>(
              value: policy,
              child: Text(_label(strings, policy)),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  static String _label(
    post_strings.AppLocalizations strings,
    PetPolicy policy,
  ) =>
      switch (policy) {
        PetPolicy.notAllowed => strings.petNotAllowed,
        PetPolicy.catsOk => strings.petCatsOk,
        PetPolicy.dogsOk => strings.petDogsOk,
        PetPolicy.allPets => strings.petAllPets,
        PetPolicy.negotiable => strings.petNegotiable,
      };
}
