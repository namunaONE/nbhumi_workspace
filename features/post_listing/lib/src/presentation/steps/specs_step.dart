import 'package:flutter/material.dart';

/// Wizard step 3: area, bedrooms, bathrooms and road access.
///
/// Area is entered in hill or terai units depending on the district's region
/// (Rule 25), with sqm derived server-side. Bedrooms and bathrooms arrive with
/// migration 007 in HYA-251.
class SpecsStep extends StatelessWidget {
  /// Creates the specs step.
  const SpecsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Specs Step'));
  }
}
