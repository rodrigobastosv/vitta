import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

// A named block of rows inside a tab that holds more than one of them, collapsed
// to its first few. Without the cap a long first section pushes the second one
// off the screen entirely, so the tab reads as if it only had the one.
class AddFoodListSection extends StatefulWidget {
  const AddFoodListSection({required this.title, required this.rows, this.collapsedCount = defaultCollapsedCount, super.key});

  static const int defaultCollapsedCount = 5;

  final String title;
  final List<Widget> rows;
  final int collapsedCount;

  @override
  State<AddFoodListSection> createState() => _AddFoodListSectionState();
}

class _AddFoodListSectionState extends State<AddFoodListSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final isCollapsible = widget.rows.length > widget.collapsedCount;
    final visibleRows = isCollapsible && !_isExpanded ? widget.rows.take(widget.collapsedCount).toList() : widget.rows;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
          child: Text(widget.title, style: VTTextStyles.overline(context).copyWith(color: colorScheme.onSurfaceVariant)),
        ),
        const VTGap.s(),
        AnimatedSize(
          duration: VTMotion.transition,
          curve: VTMotion.curve,
          alignment: .topCenter,
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              for (final (index, row) in visibleRows.indexed) ...[
                Padding(padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m), child: VTAppearEffect(index: index, child: row)),
                const VTGap.s(),
              ],
            ],
          ),
        ),
        if (isCollapsible)
          Align(
            child: TextButton.icon(
              onPressed: () {
                VTHaptics.selection();
                setState(() => _isExpanded = !_isExpanded);
              },
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              label: Text(_isExpanded ? l10n.showLessAction : l10n.showMoreAction),
            ),
          ),
      ],
    );
  }
}
