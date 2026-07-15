import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_set_row.dart';

class WorkoutExerciseCard extends StatelessWidget {
  const WorkoutExerciseCard({
    required this.workoutExercise,
    required this.unitSystem,
    this.onAddSet,
    this.onEditSet,
    this.onDeleteSet,
    this.onRemove,
    this.onTap,
    super.key,
  });

  final WorkoutExercise workoutExercise;
  final UnitSystem unitSystem;
  final VoidCallback? onAddSet;
  final void Function(WorkoutSet set)? onEditSet;
  final void Function(WorkoutSet set)? onDeleteSet;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final exercise = workoutExercise.exercise;
    final accent = exercise.primaryMuscles.firstOrNull?.region.color ?? context.colorScheme.primary;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onTap,
                borderRadius: VTRadius.borderRadiusS,
                child: VTRemoteImage(imageUrl: exercise.imageUrl, placeholderIcon: Icons.fitness_center_outlined, size: 52),
              ),
              const SizedBox(width: VTSpacing.m),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(exercise.nameFor(l10n.localeName), style: VTTextStyles.bodyStrong(context)),
                      const VTGap.xs(),
                      Text(
                        [
                          if (exercise.equipment case final equipment?) equipment.getLabel(l10n),
                          for (final muscle in exercise.primaryMuscles.take(2)) muscle.getLabel(l10n),
                        ].join(' · '),
                        style: VTTextStyles.caption(context).copyWith(color: accent),
                      ),
                    ],
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(icon: const Icon(Icons.delete_outline), tooltip: l10n.workoutDeleteExercise, onPressed: onRemove),
            ],
          ),
          const VTGap.s(),
          const Divider(height: 1),
          if (workoutExercise.sets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: VTSpacing.m),
              child: Text(l10n.workoutNoSetsMessage, style: VTTextStyles.caption(context)),
            )
          else
            for (final (index, set) in workoutExercise.sets.indexed)
              WorkoutSetRow(
                set: set,
                position: index + 1,
                unitSystem: unitSystem,
                onEdit: onEditSet == null ? null : () => onEditSet!(set),
                onDelete: onDeleteSet == null ? null : () => onDeleteSet!(set),
              ),
          if (onAddSet != null)
            Align(
              alignment: .centerLeft,
              child: TextButton.icon(icon: const Icon(Icons.add, size: 18), label: Text(l10n.workoutAddSet), onPressed: onAddSet),
            ),
        ],
      ),
    );
  }
}
