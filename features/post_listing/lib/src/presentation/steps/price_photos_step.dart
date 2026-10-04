import 'package:flutter/material.dart';

/// Wizard step 4: price and photos.
///
/// Photos upload to the `listing-photos` bucket. At least three are required
/// before a listing can be submitted (DATA.md).
class PricePhotosStep extends StatelessWidget {
  /// Creates the price and photos step.
  const PricePhotosStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Price & Photos Step'));
  }
}
