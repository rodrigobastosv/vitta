import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_celebration.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_water_fill.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class HomeWaterHero extends StatelessWidget {
  const HomeWaterHero({required this.consumedMl, required this.dailyGoalMl, required this.unitSystem, required this.onTap, super.key});

  final double consumedMl;
  final double dailyGoalMl;
  final UnitSystem unitSystem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = dailyGoalMl <= 0 ? 0.0 : (consumedMl / dailyGoalMl).clamp(0, 1).toDouble();
    final reached = progress >= 1;
    final leftMl = (dailyGoalMl - consumedMl).clamp(0, dailyGoalMl).toDouble();
    final accent = reached ? VTColors.success : VTColors.water;
    final unit = unitSystem.volumeUnitLabel;
    return VTCard(
      onTap: onTap,
      child: Row(
        children: [
          VTCelebration(trigger: reached, child: VTWaterFill(value: progress, color: accent, width: 74, height: 118)),
          const VTGap.l(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(l10n.waterFeatureTitle, style: VTTextStyles.overline(context)),
                const VTGap.xs(),
                Text('${unitSystem.millilitersToDisplayVolume(consumedMl).round()}', style: VTTextStyles.display(context)),
                Text(l10n.waterOfGoal(unitSystem.millilitersToDisplayVolume(dailyGoalMl).round().toString(), unit), style: VTTextStyles.caption(context)),
                const VTGap.xs(),
                Text(
                  reached ? l10n.waterGoalReached : l10n.waterLeft(unitSystem.millilitersToDisplayVolume(leftMl).round().toString(), unit),
                  style: VTTextStyles.overline(context).copyWith(color: accent, fontWeight: .w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
