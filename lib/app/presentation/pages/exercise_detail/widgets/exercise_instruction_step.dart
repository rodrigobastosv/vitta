import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class ExerciseInstructionStep extends StatelessWidget {
  const ExerciseInstructionStep({required this.position, required this.instruction, super.key});

  final int position;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: VTSpacing.m),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.16),
            child: Text(
              '$position',
              style: VTTextStyles.caption(context).copyWith(color: colorScheme.primary, fontWeight: .w700),
            ),
          ),
          const SizedBox(width: VTSpacing.m),
          Expanded(child: Text(instruction, style: VTTextStyles.body(context))),
        ],
      ),
    );
  }
}
