import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/calorie_average.dart';
import 'package:vitta/app/domain/diet/entities/goal_adherence.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class WeekAverageBadge extends StatelessWidget {
  const WeekAverageBadge({required this.average, required this.macroGoals, super.key});

  static const double width = 44;

  final CalorieAverage average;
  final MacroGoals macroGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!average.hasData) {
      return SizedBox(
        width: width,
        child: Center(child: Text('-', style: VTTextStyles.overline(context))),
      );
    }
    final calories = average.averageCalories.round();
    final color = macroGoals.calorieGoal <= 0
        ? context.colorScheme.primary
        : GoalAdherence.forRatio(average.averageCalories / macroGoals.calorieGoal).color;
    return SizedBox(
      width: width,
      child: Tooltip(
        message: l10n.dietWeekAverageTooltip(calories, average.loggedDayCount),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: VTSpacing.xs, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: VTRadius.borderRadiusFull),
          child: Text(
            l10n.dietWeekAverageShort(calories),
            textAlign: .center,
            style: VTTextStyles.overline(context).copyWith(color: color, fontWeight: .w700),
          ),
        ),
      ),
    );
  }
}
