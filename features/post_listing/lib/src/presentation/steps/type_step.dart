import 'package:flutter/material.dart';
import 'package:models/models.dart';

import '../../viewmodels/listing_wizard_state.dart';

/// Wizard step 1: property type and purpose.
///
/// Purpose sits on the same step as type rather than on its own because the two
/// are almost always chosen together, and a five-step wizard where one step
/// asks a single question feels like a maze.
class TypeStep extends StatelessWidget {
  /// Creates the type step.
  const TypeStep({
    required this.state,
    required this.onTypeSelected,
    required this.onPurposeSelected,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('What are you listing?', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final type in PropertyType.values)
              ChoiceChip(
                label: Text(_humanise(type.name)),
                selected: state.propertyType == type,
                onSelected: (selected) {
                  if (selected) onTypeSelected(type);
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('How do you want to sell it?', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final purpose in ListingPurpose.values)
              ChoiceChip(
                label: Text(_purposeLabel(purpose)),
                selected: state.listingPurpose == purpose,
                onSelected: (selected) {
                  if (selected) onPurposeSelected(purpose);
                },
              ),
          ],
        ),
      ],
    );
  }

  static String _humanise(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  /// Enum names do not read as English labels.
  static String _purposeLabel(ListingPurpose purpose) => switch (purpose) {
        ListingPurpose.sale => 'Sell',
        ListingPurpose.rent => 'Rent out',
        ListingPurpose.lease => 'Lease',
      };
}
