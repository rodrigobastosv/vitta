import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/meal_calorie_split.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/meal_split_row.dart';

class MealSplitCard extends StatelessWidget {
  const MealSplitCard({required this.days, required this.macrosByDate, super.key});

  final List<DateTime> days;
  final Map<DateTime, DailyMacros> macrosByDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final split = MealCalorieSplit.fromLoggedDays([
      for (final day in days) ?macrosByDate[day],
    ]);
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.dietMealSplitTitle, style: VTTextStyles.bodyStrong(context)),
          const VTGap.m(),
          if (!split.hasData)
            Text(l10n.dietTrendEmptyMessage, style: VTTextStyles.caption(context))
          else ...[
            VTDistributionBar(
              segments: [
                for (final mealType in split.presentMealTypes)
                  VTBarChartSegment(value: split.caloriesByMealType[mealType]!, color: mealType.color),
              ],
            ),
            const VTGap.m(),
            for (final mealType in split.presentMealTypes) ...[
              MealSplitRow(mealType: mealType, share: split.shareOf(mealType), dailyAverage: split.dailyAverageOf(mealType)),
              const VTGap.s(),
            ],
          ],
        ],
      ),
    );
  }
}
