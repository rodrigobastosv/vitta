import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/presentation/pages/exercise_detail/widgets/exercise_instruction_step.dart';
import 'package:vitta/app/presentation/pages/exercise_detail/widgets/exercise_muscle_section.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_extra.dart';

class ExerciseDetailPage extends StatelessWidget {
  const ExerciseDetailPage({required this.exercise, super.key});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final instructions = exercise.instructionsFor(l10n.localeName);
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.nameFor(l10n.localeName)),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: l10n.workoutProgressionTitle,
            onPressed: () => context.pushRoute(.exerciseProgression, extra: ExerciseProgressionExtra(exercise: exercise)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(VTSpacing.m),
        children: [
          if (exercise.imageUrls.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: .horizontal,
                itemCount: exercise.imageUrls.length,
                separatorBuilder: (context, index) => const SizedBox(width: VTSpacing.s),
                itemBuilder: (context, index) => VTRemoteImage(
                  imageUrl: exercise.imageUrls[index],
                  placeholderIcon: Icons.fitness_center_outlined,
                  width: 280,
                  height: 200,
                  borderRadius: VTRadius.borderRadiusM,
                ),
              ),
            ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.s,
            runSpacing: VTSpacing.s,
            children: [
              VTBadge(label: exercise.category.getLabel(l10n), color: context.colorScheme.primary),
              VTBadge(label: exercise.level.getLabel(l10n), color: context.colorScheme.secondary),
              if (exercise.equipment case final equipment?) VTBadge(label: equipment.getLabel(l10n), color: context.colorScheme.tertiary),
            ],
          ),
          const VTGap.l(),
          ExerciseMuscleSection(title: l10n.exerciseDetailPrimaryMusclesTitle, muscles: exercise.primaryMuscles),
          if (exercise.secondaryMuscles.isNotEmpty) ...[
            const VTGap.m(),
            ExerciseMuscleSection(title: l10n.exerciseDetailSecondaryMusclesTitle, muscles: exercise.secondaryMuscles),
          ],
          const VTGap.l(),
          Text(l10n.exerciseDetailInstructionsTitle, style: VTTextStyles.title(context)),
          const VTGap.s(),
          if (instructions.isEmpty)
            Text(l10n.exerciseDetailNoInstructionsMessage, style: VTTextStyles.body(context))
          else
            for (final (index, instruction) in instructions.indexed) ExerciseInstructionStep(position: index + 1, instruction: instruction),
        ],
      ),
    );
  }
}
