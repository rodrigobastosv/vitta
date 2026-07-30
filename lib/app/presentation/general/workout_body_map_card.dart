import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_highlight.dart';
import 'package:vitta/app/design_system/components/general/vt_body_part.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/workout_muscle_work.dart';
import 'package:vitta/app/presentation/general/muscle_group_body_part.dart';
import 'package:vitta/app/presentation/general/workout_body_map_figure.dart';

class WorkoutBodyMapCard extends StatelessWidget {
  const WorkoutBodyMapCard({
    required this.muscleWork,
    required this.hint,
    this.figure = VTBodyFigure.male,
    this.isCompact = false,
    super.key,
  });

  static const double _figureHeight = 168;
  static const double _compactFigureHeight = 118;

  final WorkoutMuscleWork muscleWork;
  final String hint;
  final VTBodyFigure figure;

  // A surface with a fixed height gives up the legend and the two view captions
  // (the workout page's carousel). The legend is what costs the most: six region
  // names wrap to three runs at 320px, taller than the figures they explain. The
  // accents are the app's fixed bodyRegion* vocabulary and the summary page states
  // them in full; front-versus-back is legible from the drawing itself, and the
  // muscles are named to VoiceOver either way.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final muscles = muscleWork.workedMuscles;
    final regions = muscleWork.workedRegions;
    // workedMuscles is ordered hardest-first, so putIfAbsent takes the harder of
    // the two muscles that can share a shape and paints it in that muscle's region.
    final highlightByPart = <VTBodyPart, VTBodyMapHighlight>{};
    for (final muscle in muscles) {
      highlightByPart.putIfAbsent(
        muscle.bodyPart,
        () => VTBodyMapHighlight(part: muscle.bodyPart, color: muscle.region.color, intensity: muscleWork.intensityOf(muscle)),
      );
    }
    final highlights = highlightByPart.values.toList();
    final figureHeight = isCompact ? _compactFigureHeight : _figureHeight;
    return VTCard(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(l10n.workoutBodyMapTitle, style: VTTextStyles.bodyStrong(context)),
          const VTGap.m(),
          VTSemanticSummary(
            label: muscles.isEmpty
                ? l10n.workoutBodyMapSemanticsEmpty
                : l10n.workoutBodyMapSemantics(muscles.map((muscle) => muscle.getLabel(l10n)).join(', ')),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: WorkoutBodyMapFigure(
                    view: .front,
                    caption: isCompact ? null : l10n.workoutBodyMapFrontView,
                    highlights: highlights,
                    figure: figure,
                    figureHeight: figureHeight,
                  ),
                ),
                Expanded(
                  child: WorkoutBodyMapFigure(
                    view: .back,
                    caption: isCompact ? null : l10n.workoutBodyMapBackView,
                    highlights: highlights,
                    figure: figure,
                    figureHeight: figureHeight,
                  ),
                ),
              ],
            ),
          ),
          if (!isCompact && regions.isNotEmpty) ...[
            const VTGap.m(),
            Wrap(
              spacing: VTSpacing.m,
              runSpacing: VTSpacing.s,
              children: [for (final region in regions) VTLegendDot(label: region.getLabel(l10n), color: region.color)],
            ),
          ],
          const VTGap.s(),
          Text(hint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
