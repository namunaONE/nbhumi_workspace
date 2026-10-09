import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:post_listing/l10n/output/post_localizations.dart'
    as post_strings;

import '../../viewmodels/listing_wizard_state.dart';
import '../../viewmodels/listing_wizard_validation.dart';
import '../../widgets/wizard_fields.dart';

/// Wizard step 1: property type and purpose.
///
/// Purpose sits on the same step as type rather than on its own because the two
/// are almost always chosen together, and a five-step wizard where one step
/// asks a single question feels like a maze.
///
/// Title and description live here too: they describe the property as a whole
/// rather than any one step, and step 1 is the only place every seller passes
/// through with full attention.
class TypeStep extends StatelessWidget {
  /// Creates the type step.
  const TypeStep({
    required this.state,
    required this.onTypeSelected,
    required this.onPurposeSelected,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    super.key,
  });

  /// Current wizard state.
  final ListingWizardState state;

  /// Called with the chosen type.
  ///
  /// Required rather than optional: a nullable callback that quietly does
  /// nothing when omitted produces a chip that looks tappable and is not.
  final void Function(PropertyType type) onTypeSelected;

  /// Called with the chosen purpose.
  final void Function(ListingPurpose purpose) onPurposeSelected;

  /// Called on every title keystroke.
  final ValueChanged<String> onTitleChanged;

  /// Called on every description keystroke.
  final ValueChanged<String> onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = post_strings.AppLocalizations.of(context);
    final errors = state.validate(
      WizardStep.type,
      strings,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(strings.typeQuestion, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final type in PropertyType.values)
              ChoiceChip(
                label: Text(_typeLabel(strings, type)),
                selected: state.propertyType == type,
                onSelected: (selected) {
                  if (selected) onTypeSelected(type);
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(strings.purposeQuestion, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final purpose in ListingPurpose.values)
              ChoiceChip(
                label: Text(_purposeLabel(strings, purpose)),
                selected: state.listingPurpose == purpose,
                onSelected: (selected) {
                  if (selected) onPurposeSelected(purpose);
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        WizardField(
          label: strings.fieldTitle,
          hint: strings.fieldTitleHint,
          value: state.title,
          error: errors['title'],
          onChanged: onTitleChanged,
        ),
        WizardField(
          label: strings.fieldDescription,
          hint: strings.fieldDescriptionHint,
          value: state.description,
          maxLines: 4,
          onChanged: onDescriptionChanged,
        ),
      ],
    );
  }

  static String _typeLabel(
    post_strings.AppLocalizations strings,
    PropertyType type,
  ) =>
      switch (type) {
        PropertyType.land => strings.chipLand,
        PropertyType.house => strings.chipHouse,
        PropertyType.apartment => strings.chipApartment,
        PropertyType.villa => strings.chipVilla,
        PropertyType.commercial => strings.chipCommercial,
        PropertyType.business => strings.chipBusiness,
      };

  /// Enum names do not read as labels in either language.
  static String _purposeLabel(
    post_strings.AppLocalizations strings,
    ListingPurpose purpose,
  ) =>
      switch (purpose) {
        ListingPurpose.sale => strings.purposeSell,
        ListingPurpose.rent => strings.purposeRentOut,
        ListingPurpose.lease => strings.purposeLeaseTx,
      };
}
