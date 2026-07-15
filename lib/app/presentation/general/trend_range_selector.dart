import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';

class TrendRangeSelector extends StatelessWidget {
  const TrendRangeSelector({required this.selected, required this.onSelected, super.key});

  final TrendRange selected;
  final ValueChanged<TrendRange> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<TrendRange>(
      segments: [
        for (final range in TrendRange.values) ButtonSegment(value: range, label: Text(range.getLabel(l10n))),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onSelected(selection.single),
    );
  }
}
