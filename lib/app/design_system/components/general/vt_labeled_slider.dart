import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTLabeledSlider extends StatelessWidget {
  const VTLabeledSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;

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
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
          ),
          const SizedBox(width: 8),
          VTBadge(label: valueLabel, color: color),
        ],
      ),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: color,
          thumbColor: color,
          overlayColor: color.withValues(alpha: 0.12),
          inactiveTrackColor: color.withValues(alpha: 0.20),
          trackHeight: 4,
        ),
        child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
      ),
    ],
  );
}
