import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';
import 'package:search/l10n/output/search_localizations.dart'
    as search_strings;

import '../providers/browse_providers.dart';
import '../utils/search_labels.dart';

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
    final strings = search_strings.AppLocalizations.of(context);

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
                    child: Text(
                      strings.sheetTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (_draft.activeCount > 0)
                    TextButton(
                      onPressed: () => _update(const ListingFilter()),
                      child: Text(strings.sheetClear(_draft.activeCount)),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                children: <Widget>[
                  _Label(strings.labelType),
                  _Wrap(
                    children: <Widget>[
                      for (final type in PropertyType.values)
                        ChoiceChip(
                          label: Text(searchTypeLabel(context, type)),
                          selected: _draft.propertyType == type,
                          onSelected: (selected) => _update(
                            _draft.copyWith(
                              propertyType: selected ? type : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _Label(strings.labelPurpose),
                  _Wrap(
                    children: <Widget>[
                      for (final purpose in ListingPurpose.values)
                        ChoiceChip(
                          label: Text(searchPurposeLabel(context, purpose)),
                          selected: _draft.listingPurpose == purpose,
                          onSelected: (selected) => _update(
                            _draft.copyWith(
                              listingPurpose: selected ? purpose : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _Label(strings.labelPrice),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _NumberField(
                          label: strings.fieldMin,
                          value: _draft.minPriceNpr,
                          onChanged: (value) =>
                              _update(_draft.copyWith(minPriceNpr: value)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NumberField(
                          label: strings.fieldMax,
                          value: _draft.maxPriceNpr,
                          onChanged: (value) =>
                              _update(_draft.copyWith(maxPriceNpr: value)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _Label(strings.labelArea),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _NumberField(
                          label: strings.fieldMin,
                          value: _draft.minAreaSqm?.round(),
                          onChanged: (value) => _update(
                            _draft.copyWith(minAreaSqm: value?.toDouble()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NumberField(
                          label: strings.fieldMax,
                          value: _draft.maxAreaSqm?.round(),
                          onChanged: (value) => _update(
                            _draft.copyWith(maxAreaSqm: value?.toDouble()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _Label(strings.labelSort),
                  _Wrap(
                    children: <Widget>[
                      for (final sort in ListingSort.values)
                        ChoiceChip(
                          label: Text(searchSortLabel(context, sort)),
                          selected: _draft.sort == sort,
                          onSelected: (_) =>
                              _update(_draft.copyWith(sort: sort)),
                        ),
                    ],
                  ),
                  if (widget.districts.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.xl),
                    _Label(strings.labelDistrict),
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
                      child: Text(strings.sheetCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_draft),
                      child: Text(strings.sheetApply),
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

}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: children,
    );
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
