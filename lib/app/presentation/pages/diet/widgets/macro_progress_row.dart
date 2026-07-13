import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_progress_bar.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class MacroProgressRow extends StatelessWidget {
  const MacroProgressRow({required this.label, required this.consumed, required this.goal, required this.color, super.key});

  final String label;
  final double consumed;
  final double goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Container(
              width: VTSpacing.s,
              height: VTSpacing.s,
              decoration: BoxDecoration(color: color, shape: .circle),
            ),
            const VTGap.s(),
            Expanded(child: Text(label, style: VTTextStyles.bodyStrong(context))),
            Text(
              l10n.progressLabel(consumed.round().toString(), goal.round().toString(), 'g'),
              style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const VTGap.xs(),
        VTProgressBar(value: _getProgress(consumed, goal), minHeight: 6, color: color),
      ],
    );
  }

  double _getProgress(double consumed, double goal) => goal <= 0 ? 0 : consumed / goal;
}
