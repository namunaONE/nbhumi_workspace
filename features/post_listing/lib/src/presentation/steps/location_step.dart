import 'package:flutter/material.dart';

/// Wizard step 2: district, municipality, ward and road access.
///
/// Cascading dropdowns are backed by the `municipalities` table that HYA-253
/// creates. Until then this renders a label only.
class LocationStep extends StatelessWidget {
  /// Creates the location step.
  const LocationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Location Step'));
  }
}
