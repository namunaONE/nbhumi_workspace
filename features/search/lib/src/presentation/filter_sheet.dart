import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';

import '../providers/browse_providers.dart';

/// Bottom sheet for narrowing a browse query by type, purpose, district, price
/// and area.
///
/// Edits a local draft and only commits on "Apply". Committing every keystroke
/// would fire a request per digit typed into a price field, which on a mobile
/// connection is both slow and expensive.
class FilterSheet extends ConsumerStatefulWidget {
  /// Creates the filter sheet.
  const FilterSheet({this.districts = const <String>[], super.key});

  /// District names to offer.
  ///
  /// Passed in rather than fetched here: HYA-253 creates the reference tables
  /// and this sheet should not have to know where they come from.
  final List<String> districts;

  /// Opens the sheet and commits the result if the user applies it.
  ///
  /// Returns the applied filter, or null if dismissed.
  static Future<ListingFilter?> show(
    BuildContext context, {
    List<String> districts = const <String>[],
  }) =>
      showModalBottomSheet<ListingFilter>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => FilterSheet(districts: districts),
      );

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late ListingFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(browseFilterProvider);
  }

  void _update(ListingFilter next) => setState(() => _draft = next);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ConstrainedBox(
        // Keeps the sheet usable on short screens rather than letting it grow
        // past the viewport and clip the Apply button.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Filters', style: theme.textTheme.titleLarge),
                  ),
                  if (_draft.activeCount > 0)
                    TextButton(
                      onPressed: () => _update(const ListingFilter()),
                      child: Text('Clear ${_draft.activeCount}'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: <Widget>[
                  const _Label('Property type'),
                  _Wrap(
                    children: <Widget>[
                      for (final type in PropertyType.values)
                        ChoiceChip(
                          label: Text(_humanise(type.name)),
                          selected: _draft.propertyType == type,
                          onSelected: (selected) => _update(
                            _draft.copyWith(
                              propertyType: selected ? type : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _Label('Purpose'),
                  _Wrap(
                    children: <Widget>[
                      for (final purpose in ListingPurpose.values)
                        ChoiceChip(
                          label: Text(_humanise(purpose.name)),
                          selected: _draft.listingPurpose == purpose,
                          onSelected: (selected) => _update(
                            _draft.copyWith(
                              listingPurpose: selected ? purpose : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _Label('Price range (NPR)'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _NumberField(
                          label: 'Min',
                          value: _draft.minPriceNpr,
                          onChanged: (value) =>
                              _update(_draft.copyWith(minPriceNpr: value)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NumberField(
                          label: 'Max',
                          value: _draft.maxPriceNpr,
                          onChanged: (value) =>
                              _update(_draft.copyWith(maxPriceNpr: value)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _Label('Area (sqm)'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _NumberField(
                          label: 'Min',
                          value: _draft.minAreaSqm?.round(),
                          onChanged: (value) => _update(
                            _draft.copyWith(minAreaSqm: value?.toDouble()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NumberField(
                          label: 'Max',
                          value: _draft.maxAreaSqm?.round(),
                          onChanged: (value) => _update(
                            _draft.copyWith(maxAreaSqm: value?.toDouble()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _Label('Sort'),
                  _Wrap(
                    children: <Widget>[
                      for (final sort in ListingSort.values)
                        ChoiceChip(
                          label: Text(_sortLabel(sort)),
                          selected: _draft.sort == sort,
                          onSelected: (_) =>
                              _update(_draft.copyWith(sort: sort)),
                        ),
                    ],
                  ),
                  if (widget.districts.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 20),
                    const _Label('District'),
                    _Wrap(
                      children: <Widget>[
                        for (final district in widget.districts)
                          ChoiceChip(
                            label: Text(district),
                            selected: _draft.district == district,
                            onSelected: (selected) => _update(
                              _draft.copyWith(
                                district: selected ? district : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_draft),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `pendingReview` and `post_listing` must never reach a chip label.
  static String _humanise(String value) => value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';

  static String _sortLabel(ListingSort sort) => switch (sort) {
        ListingSort.newest => 'Newest',
        ListingSort.oldest => 'Oldest',
        ListingSort.priceAsc => 'Price: low to high',
        ListingSort.priceDesc => 'Price: high to low',
      };
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

/// Lays chips out in rows that wrap, rather than a horizontally scrolling
/// strip.
class _Wrap extends StatelessWidget {
  const _Wrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value?.toString() ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (text) => widget.onChanged(int.tryParse(text)),
    );
  }
}
