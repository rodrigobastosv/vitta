import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_highlight.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/workout_region_volume.dart';
import 'package:vitta/app/presentation/general/body_region_body_part.dart';
import 'package:vitta/app/presentation/general/workout_body_map_figure.dart';

class WorkoutBodyMapCard extends StatelessWidget {
  const WorkoutBodyMapCard({required this.regionVolume, super.key});

  final WorkoutRegionVolume regionVolume;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final regions = regionVolume.workedRegions;
    final highlights = [
      for (final region in regions)
        VTBodyMapHighlight(part: region.bodyPart, color: region.color, intensity: regionVolume.intensityOf(region)),
    ];
    return VTCard(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(l10n.workoutBodyMapTitle, style: VTTextStyles.bodyStrong(context)),
          const VTGap.m(),
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(child: WorkoutBodyMapFigure(view: .front, caption: l10n.workoutBodyMapFrontView, highlights: highlights)),
              Expanded(child: WorkoutBodyMapFigure(view: .back, caption: l10n.workoutBodyMapBackView, highlights: highlights)),
            ],
          ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.m,
            runSpacing: VTSpacing.s,
            children: [for (final region in regions) VTLegendDot(label: region.getLabel(l10n), color: region.color)],
          ),
          const VTGap.s(),
          Text(l10n.workoutBodyMapHint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
