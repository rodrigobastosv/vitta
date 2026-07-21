import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_celebration.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/presentation/pages/water/widgets/water_quick_add_pills.dart';

class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({
    required this.dailyWater,
    required this.dailyGoalMl,
    required this.unitSystem,
    required this.onQuickAdd,
    this.onEditGoal,
    super.key,
  });

  final DailyWater dailyWater;
  final double dailyGoalMl;
  final UnitSystem unitSystem;
  final ValueChanged<double> onQuickAdd;
  final VoidCallback? onEditGoal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final consumedMl = dailyWater.totalMl;
    final progress = dailyGoalMl <= 0 ? 0.0 : (consumedMl / dailyGoalMl).clamp(0, 1).toDouble();
    final reached = progress >= 1;
    final leftMl = (dailyGoalMl - consumedMl).clamp(0, dailyGoalMl).toDouble();
    final ringColor = consumedMl <= 0 ? colorScheme.primary : (reached ? VTColors.success : VTColors.water);
    final unit = unitSystem.volumeUnitLabel;

    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              VTCelebration(
                trigger: reached,
                child: VTMacroRing(
                  value: progress,
                  color: ringColor,
                  size: 120,
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Text('${unitSystem.millilitersToDisplayVolume(consumedMl).round()}', style: VTTextStyles.headline(context)),
                      Text(l10n.waterOfGoal(unitSystem.millilitersToDisplayVolume(dailyGoalMl).round().toString(), unit), style: VTTextStyles.caption(context)),
                      const VTGap.xs(),
                      Text(
                        reached ? l10n.waterGoalReached : l10n.waterLeft(unitSystem.millilitersToDisplayVolume(leftMl).round().toString(), unit),
                        style: VTTextStyles.overline(context).copyWith(color: reached ? VTColors.success : VTColors.water, fontWeight: .w700),
                      ),
                    ],
                  ),
                ),
              ),
              const VTGap.l(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    if (onEditGoal != null)
                      Align(
                        alignment: .centerRight,
                        child: IconButton(
                          visualDensity: .compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: const Icon(Icons.tune, size: 20),
                          tooltip: l10n.waterGoalDialogTitle,
                          onPressed: onEditGoal,
                        ),
                      ),
                    _metric(
                      context,
                      icon: Icons.flag_rounded,
                      value: '${unitSystem.millilitersToDisplayVolume(dailyGoalMl).round()} $unit',
                      label: l10n.waterGoalMetric,
                    ),
                    const VTGap.m(),
                    _metric(context, icon: Icons.local_drink_rounded, value: '${dailyWater.entries.length}', label: l10n.waterLogsMetric),
                  ],
                ),
              ),
            ],
          ),
          const VTGap.m(),
          const Divider(height: 1),
          const VTGap.m(),
          WaterQuickAddPills(unitSystem: unitSystem, onAdd: onQuickAdd),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, {required IconData icon, required String value, required String label}) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: VTColors.water.withValues(alpha: 0.16), shape: .circle),
        child: Icon(icon, color: VTColors.water, size: 16),
      ),
      const VTGap.s(),
      Expanded(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(value, style: VTTextStyles.bodyStrong(context)),
            Text(label, style: VTTextStyles.overline(context)),
          ],
        ),
      ),
    ],
  );
}
