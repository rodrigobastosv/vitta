import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/workout/entities/exercise_category.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

class ExerciseFilterChips extends StatelessWidget {
  const ExerciseFilterChips({
    required this.muscleGroup,
    required this.category,
    required this.onMuscleGroupChanged,
    required this.onCategoryChanged,
    required this.onClear,
    super.key,
  });

  final MuscleGroup? muscleGroup;
  final ExerciseCategory? category;
  final ValueChanged<MuscleGroup?> onMuscleGroupChanged;
  final ValueChanged<ExerciseCategory?> onCategoryChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: .horizontal,
        padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
        children: [
          ChoiceChip(
            label: Text(l10n.exerciseSearchAllFilter),
            selected: muscleGroup == null && category == null,
            onSelected: (_) => onClear(),
          ),
          const SizedBox(width: VTSpacing.s),
          // Cardio filters on a different column than the muscle chips beside it,
          // so it carries an icon: "Cardio" is a kind of exercise, not a body part.
          ChoiceChip(
            avatar: Icon(Icons.directions_run, size: 18, color: category == null ? context.colorScheme.onSurfaceVariant : null),
            label: Text(ExerciseCategory.cardio.getLabel(l10n)),
            selected: category == ExerciseCategory.cardio,
            onSelected: (isSelected) => onCategoryChanged(isSelected ? ExerciseCategory.cardio : null),
          ),
          for (final muscleGroup in MuscleGroup.values) ...[
            const SizedBox(width: VTSpacing.s),
            ChoiceChip(
              label: Text(muscleGroup.getLabel(l10n)),
              selected: this.muscleGroup == muscleGroup,
              onSelected: (isSelected) => onMuscleGroupChanged(isSelected ? muscleGroup : null),
            ),
          ],
        ],
      ),
    );
  }
}
