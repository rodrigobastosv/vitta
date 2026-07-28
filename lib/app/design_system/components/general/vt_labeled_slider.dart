import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_adjustable_slider.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTLabeledSlider extends StatelessWidget {
  const VTLabeledSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.color,
    required this.onChanged,
    required this.decreaseTooltip,
    required this.increaseTooltip,
    super.key,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final double step;
  final Color color;
  final ValueChanged<double> onChanged;
  final String decreaseTooltip;
  final String increaseTooltip;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    children: [
      Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: .circle),
          ),
          const VTGap.s(),
          Expanded(
            child: Text(label, style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
          ),
          const VTGap.s(),
          VTBadge(label: valueLabel, color: color),
        ],
      ),
      VTAdjustableSlider(
        value: value,
        min: min,
        max: max,
        step: step,
        color: color,
        onChanged: onChanged,
        decreaseTooltip: decreaseTooltip,
        increaseTooltip: increaseTooltip,
      ),
    ],
  );
}
