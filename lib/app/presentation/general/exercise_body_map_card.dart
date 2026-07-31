import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_muscle_work.dart';
import 'package:vitta/app/presentation/general/workout_body_map_figure.dart';
import 'package:vitta/app/presentation/general/workout_muscle_work_highlights.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class ExerciseBodyMapCard extends StatelessWidget {
  const ExerciseBodyMapCard({required this.exercise, this.figure = VTBodyFigure.male, super.key});

  final Exercise exercise;
  final VTBodyFigure figure;

  String? _semanticLabel(AppLocalizations l10n) {
    final primaryMuscles = [for (final muscle in exercise.primaryMuscles) muscle.getLabel(l10n)];
    final secondaryMuscles = [for (final muscle in exercise.secondaryMuscles) muscle.getLabel(l10n)];
    if (primaryMuscles.isEmpty) {
      return null;
    }
    return secondaryMuscles.isEmpty
        ? l10n.exerciseBodyMapSemanticsPrimaryOnly(primaryMuscles.join(', '))
        : l10n.exerciseBodyMapSemantics(primaryMuscles.join(', '), secondaryMuscles.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final muscleWork = WorkoutMuscleWork.forExercise(exercise);
    final highlights = muscleWork.bodyMapHighlights;
    final regions = muscleWork.workedRegions;
    return VTCard(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(l10n.exerciseBodyMapTitle, style: VTTextStyles.bodyStrong(context)),
          const VTGap.m(),
          VTSemanticSummary(
            label: _semanticLabel(l10n),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: WorkoutBodyMapFigure(
                    view: .front,
                    caption: l10n.workoutBodyMapFrontView,
                    highlights: highlights,
                    figure: figure,
                  ),
                ),
                Expanded(
                  child: WorkoutBodyMapFigure(view: .back, caption: l10n.workoutBodyMapBackView, highlights: highlights, figure: figure),
                ),
              ],
            ),
          ),
          if (regions.isNotEmpty) ...[
            const VTGap.m(),
            Wrap(
              spacing: VTSpacing.m,
              runSpacing: VTSpacing.s,
              children: [for (final region in regions) VTLegendDot(label: region.getLabel(l10n), color: region.color)],
            ),
          ],
          const VTGap.s(),
          Text(l10n.exerciseBodyMapHint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
