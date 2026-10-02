import 'package:flutter/material.dart';

/// Filter bottom sheet.
///
/// Allows users to filter by property type, purpose, district, price, area.
class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: Center(
        child: Text('Filters'),
      ),
    );
  }
}
