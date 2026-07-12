import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';

class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({required this.dailyWater, required this.dailyGoalMl, required this.unitSystem, super.key});

  final DailyWater dailyWater;
  final double dailyGoalMl;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final consumedMl = dailyWater.totalMl;
    final progress = dailyGoalMl <= 0 ? 0.0 : (consumedMl / dailyGoalMl).clamp(0, 1).toDouble();
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            l10n.waterProgressLabel(
              unitSystem.millilitersToDisplayVolume(consumedMl).round().toString(),
              unitSystem.millilitersToDisplayVolume(dailyGoalMl).round().toString(),
              unitSystem.volumeUnitLabel,
            ),
            style: VTTextStyles.headline(context),
          ),
          const VTGap.m(),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, minHeight: 8),
          ),
        ],
      ),
    );
  }
}
