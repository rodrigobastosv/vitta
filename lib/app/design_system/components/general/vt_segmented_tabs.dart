import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTSegmentedTab<T> {
  const VTSegmentedTab({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class VTSegmentedTabs<T> extends StatelessWidget {
  const VTSegmentedTabs({required this.tabs, required this.selected, required this.onSelected, super.key});

  static const Duration _duration = Duration(milliseconds: 240);
  static const double _indicatorHeight = 3;

  static const double _indicatorTabFraction = 0.5;

  final List<VTSegmentedTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onSelected;

  double get _indicatorWidthFactor => _indicatorTabFraction / tabs.length;

  double get _indicatorAlignmentX {
    final selectedIndex = tabs.indexWhere((tab) => tab.value == selected);
    if (selectedIndex < 0 || tabs.length < 2) {
      return 0;
    }
    return (2 * (selectedIndex + 0.5) / tabs.length - 1) / (1 - _indicatorWidthFactor);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      mainAxisSize: .min,
      children: [
        Row(
          children: [
            for (final tab in tabs)
              Expanded(
                child: _Segment(
                  tab: tab,
                  isSelected: tab.value == selected,
                  onTap: () {
                    if (tab.value != selected) {
                      VTHaptics.selection();
                    }
                    onSelected(tab.value);
                  },
                ),
              ),
          ],
        ),
        SizedBox(
          height: _indicatorHeight,
          child: AnimatedAlign(
            alignment: Alignment(_indicatorAlignmentX, 0),
            duration: _duration,
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: _indicatorWidthFactor,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: colorScheme.primary, borderRadius: VTRadius.borderRadiusFull),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({required this.tab, required this.isSelected, required this.onTap});

  final VTSegmentedTab<T> tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: VTRadius.borderRadiusS,
      child: Padding(
        padding: const EdgeInsets.only(bottom: VTSpacing.s, top: VTSpacing.xs),
        child: AnimatedDefaultTextStyle(
          duration: VTSegmentedTabs._duration,
          style: VTTextStyles.bodyStrong(context).copyWith(color: color, fontWeight: isSelected ? .w700 : .w500),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              if (tab.icon != null) ...[Icon(tab.icon, size: 18, color: color), const VTGap.s()],
              Text(tab.label),
            ],
          ),
        ),
      ),
    );
  }
}
