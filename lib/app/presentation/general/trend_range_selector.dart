import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_segmented_tabs.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';

class TrendRangeSelector extends StatelessWidget {
  const TrendRangeSelector({required this.selected, required this.onSelected, super.key});

  final TrendRange selected;
  final ValueChanged<TrendRange> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTSegmentedTabs<TrendRange>(
      selected: selected,
      onSelected: onSelected,
      tabs: [for (final range in TrendRange.values) VTSegmentedTab(value: range, label: range.getLabel(l10n))],
    );
  }
}
