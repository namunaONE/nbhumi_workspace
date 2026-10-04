import 'package:flutter/material.dart';

/// Bottom sheet for narrowing a browse query by type, purpose, district, price
/// and area.
///
/// Placeholder body. HYA-203 wires it to `ListingFilter`, which is why the
/// filter state lives in a single immutable value rather than in widget state:
/// changing any field must invalidate the feed exactly once.
class FilterSheet extends StatelessWidget {
  /// Creates the filter sheet.
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: Center(child: Text('Filters')),
    );
  }
}
