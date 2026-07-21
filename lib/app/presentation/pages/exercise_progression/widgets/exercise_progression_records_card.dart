import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_metric.dart';

class ExerciseProgressionRecordsCard extends StatelessWidget {
  const ExerciseProgressionRecordsCard({required this.progression, required this.color, required this.unitSystem, super.key});

  final ExerciseProgression progression;
  final Color color;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.16), shape: .circle),
                child: Icon(Icons.emoji_events_outlined, color: color, size: 20),
              ),
              const SizedBox(width: VTSpacing.m),
              Text(l10n.workoutProgressionRecordsTitle, style: VTTextStyles.bodyStrong(context)),
            ],
          ),
          const VTGap.m(),
          Row(
            children: [
              Expanded(
                child: WorkoutMetric(
                  icon: Icons.trending_up,
                  label: l10n.workoutProgressionBestE1rmLabel,
                  value: _formatLoad(progression.bestEstimatedOneRepMax),
                  color: color,
                ),
              ),
              Expanded(
                child: WorkoutMetric(icon: Icons.fitness_center, label: l10n.workoutProgressionHeaviestLabel, value: _formatLoad(progression.heaviestWeightKg)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLoad(double kilograms) {
    final value = unitSystem.kilogramsToDisplayLoad(kilograms);
    final rounded = value.round();
    final label = (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
    return '$label ${unitSystem.loadUnitLabel}';
  }
}
