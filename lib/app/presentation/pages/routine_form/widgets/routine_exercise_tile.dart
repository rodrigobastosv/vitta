import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';

class RoutineExerciseTile extends StatelessWidget {
  const RoutineExerciseTile({required this.exercise, required this.position, this.onRemove, this.dragHandle, super.key});

  final Exercise exercise;
  final int position;
  final VoidCallback? onRemove;

  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = exercise.primaryMuscles.firstOrNull?.region.color ?? context.colorScheme.primary;
    return VTCard(
      child: Row(
        children: [
          SizedBox(width: 20, child: Text('$position', style: VTTextStyles.caption(context))),
          const SizedBox(width: VTSpacing.s),
          VTRemoteImage(imageUrl: exercise.imageUrl, placeholderIcon: Icons.fitness_center_outlined, size: 44),
          const SizedBox(width: VTSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(exercise.nameFor(l10n.localeName), style: VTTextStyles.body(context)),
                const VTGap.xs(),
                Text(
                  [
                    if (exercise.equipment case final equipment?) equipment.getLabel(l10n),
                    for (final muscle in exercise.primaryMuscles.take(1)) muscle.getLabel(l10n),
                  ].join(' · '),
                  style: VTTextStyles.caption(context).copyWith(color: accent),
                ),
              ],
            ),
          ),
          if (onRemove != null) IconButton(icon: const Icon(Icons.close, size: 18), tooltip: l10n.workoutRoutineRemoveExerciseTooltip, onPressed: onRemove),
          ?dragHandle,
        ],
      ),
    );
  }
}
