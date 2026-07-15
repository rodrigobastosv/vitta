import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_metric.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({required this.state, required this.unitSystem, super.key});

  final WorkoutState state;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final regions = {for (final workout in state.workouts) ...workout.regions}.toList();
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(
                child: WorkoutMetric(label: l10n.workoutVolumeLabel, value: _formatLoad(state.volumeKg), isHeadline: true),
              ),
              Expanded(
                child: WorkoutMetric(label: l10n.workoutSetsLabel, value: '${state.totalSets}'),
              ),
              Expanded(
                child: WorkoutMetric(label: l10n.workoutTotalRepsLabel, value: '${state.totalReps}'),
              ),
            ],
          ),
          if (regions.isNotEmpty) ...[
            const VTGap.m(),
            Wrap(
              spacing: VTSpacing.s,
              runSpacing: VTSpacing.s,
              children: [for (final region in regions) VTBadge(label: region.getLabel(l10n), color: region.color)],
            ),
          ],
        ],
      ),
    );
  }

  String _formatLoad(double kilograms) {
    final value = unitSystem.kilogramsToDisplayLoad(kilograms);
    return '${value.round()} ${unitSystem.loadUnitLabel}';
  }
}
