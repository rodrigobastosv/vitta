import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_sets_summary.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_exercise_thumbnail.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_set_actions.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_set_row.dart';

class WorkoutExerciseCard extends StatelessWidget {
  const WorkoutExerciseCard({
    required this.workoutExercise,
    required this.unitSystem,
    this.lastSets,
    this.onAddSet,
    this.onRepeatSet,
    this.onEditSet,
    this.onDeleteSet,
    this.onRemove,
    this.onTap,
    this.onToggleCompleted,
    super.key,
  });

  final WorkoutExercise workoutExercise;
  final UnitSystem unitSystem;

  final List<WorkoutSet>? lastSets;
  final VoidCallback? onAddSet;
  final VoidCallback? onRepeatSet;
  final void Function(WorkoutSet set)? onEditSet;
  final void Function(WorkoutSet set)? onDeleteSet;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final exercise = workoutExercise.exercise;
    final isCompleted = workoutExercise.isCompleted;
    final canComplete = workoutExercise.sets.isNotEmpty;
    final onEditSet = this.onEditSet;
    final onDeleteSet = this.onDeleteSet;
    final accent = exercise.primaryMuscles.firstOrNull?.region.color ?? colorScheme.primary;
    return VTCard(
      color: isCompleted ? Color.alphaBlend(VTColors.success.withValues(alpha: 0.10), colorScheme.surface) : null,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onTap,
                borderRadius: VTRadius.borderRadiusM,
                child: WorkoutExerciseThumbnail(imageUrl: exercise.imageUrl, isCompleted: isCompleted),
              ),
              const SizedBox(width: VTSpacing.m),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        exercise.nameFor(l10n.localeName),
                        style: VTTextStyles.bodyStrong(context).copyWith(
                          color: isCompleted ? colorScheme.onSurfaceVariant : null,
                          decoration: isCompleted ? .lineThrough : null,
                          decorationColor: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const VTGap.xs(),
                      Text(
                        isCompleted
                            ? l10n.workoutCompletedSummary(workoutExercise.totalSets)
                            : [
                                if (exercise.equipment case final equipment?) equipment.getLabel(l10n),
                                for (final muscle in exercise.primaryMuscles.take(2)) muscle.getLabel(l10n),
                              ].join(' · '),
                        style: VTTextStyles.caption(context).copyWith(color: isCompleted ? colorScheme.onSurfaceVariant : accent),
                      ),
                    ],
                  ),
                ),
              ),
              if (onToggleCompleted case final onToggleCompleted?)
                IconButton(
                  icon: Icon(isCompleted ? Icons.check_circle : Icons.check_circle_outline, color: isCompleted ? VTColors.success : null),
                  tooltip: switch ((isCompleted, canComplete)) {
                    (true, _) => l10n.workoutReopenExerciseAction,
                    (false, true) => l10n.workoutCompleteExerciseAction,
                    (false, false) => l10n.workoutCompleteNeedsSetTooltip,
                  },
                  onPressed: canComplete || isCompleted
                      ? () {
                          if (isCompleted) {
                            VTHaptics.selection();
                          } else {
                            VTHaptics.success();
                          }
                          onToggleCompleted(!isCompleted);
                        }
                      : null,
                ),
              if (onRemove != null && !isCompleted)
                IconButton(icon: const Icon(Icons.delete_outline), tooltip: l10n.workoutDeleteExercise, onPressed: onRemove),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: .topCenter,
            child: isCompleted
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: .start,
                    children: [
                      const VTGap.s(),
                      const Divider(height: 1),
                      const VTGap.s(),
                      if (WorkoutSetsSummary.format(sets: lastSets ?? const [], unitSystem: unitSystem, l10n: l10n)
                          case final summary?) ...[
                        Row(
                          children: [
                            Icon(Icons.history, size: 14, color: colorScheme.onSurfaceVariant),
                            const VTGap.xs(),
                            Text(
                              l10n.workoutLastTimeLabel(summary),
                              style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        const VTGap.s(),
                      ],
                      if (workoutExercise.sets.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: VTSpacing.s),
                          child: Text(l10n.workoutNoSetsMessage, style: VTTextStyles.caption(context)),
                        )
                      else
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.035),
                            borderRadius: VTRadius.borderRadiusM,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
                            child: Column(
                              children: [
                                for (final (index, set) in workoutExercise.sets.indexed) ...[
                                  if (index > 0) Divider(height: 1, thickness: 1, color: colorScheme.outline.withValues(alpha: 0.4)),
                                  WorkoutSetRow(
                                    set: set,
                                    position: index + 1,
                                    unitSystem: unitSystem,
                                    color: accent,
                                    onEdit: onEditSet == null ? null : () => onEditSet(set),
                                    onDelete: onDeleteSet == null ? null : () => onDeleteSet(set),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      const VTGap.m(),
                      WorkoutSetActions(
                        accent: accent,
                        onAddSet: onAddSet,
                        onRepeatSet: onRepeatSet != null && workoutExercise.sets.isNotEmpty ? onRepeatSet : null,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
