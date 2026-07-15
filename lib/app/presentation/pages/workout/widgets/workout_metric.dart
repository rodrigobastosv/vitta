import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutMetric extends StatelessWidget {
  const WorkoutMetric({required this.label, required this.value, this.isHeadline = false, super.key});

  final String label;
  final String value;
  final bool isHeadline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(value, style: isHeadline ? VTTextStyles.headline(context).copyWith(color: colorScheme.primary) : VTTextStyles.title(context)),
        const VTGap.xs(),
        Text(label, style: VTTextStyles.caption(context)),
      ],
    );
  }
}
