import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutMetric extends StatelessWidget {
  const WorkoutMetric({required this.icon, required this.label, required this.value, this.color, super.key});

  final IconData icon;
  final String label;
  final String value;

  /// The accent this metric is tinted with. Null keeps it neutral, which is
  /// what the secondary metrics use so the headline figure stays the only
  /// coloured one of the column.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final accent = color ?? colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.16), shape: .circle),
          child: Icon(icon, color: accent, size: 16),
        ),
        const VTGap.s(),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(value, style: VTTextStyles.bodyStrong(context).copyWith(color: color)),
              Text(label, style: VTTextStyles.overline(context)),
            ],
          ),
        ),
      ],
    );
  }
}
