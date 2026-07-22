import 'package:flutter/material.dart';
import 'package:vitta/app/core/goals/daily_goal_average.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class CaloriesTrendCard extends StatelessWidget {
  const CaloriesTrendCard({required this.days, required this.macrosByDate, required this.macroGoals, super.key});

  final List<DateTime> days;
  final Map<DateTime, DailyMacros> macrosByDate;
  final MacroGoals macroGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final average = DailyGoalAverage.fromValues([
      for (final day in days)
        if (macrosByDate[day] case final macros? when macros.entries.isNotEmpty) macros.totalCalories,
    ]);
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.dietCaloriesTrendTitle, style: VTTextStyles.bodyStrong(context))),
              if (average.hasData) VTBadge(label: l10n.dietTrendAverageLabel(average.average.round()), color: colorScheme.primary),
            ],
          ),
          const VTGap.xs(),
          Text(l10n.dietTrendLoggedDays(average.loggedDayCount, days.length), style: VTTextStyles.caption(context)),
          const VTGap.m(),
          if (!average.hasData)
            Text(l10n.dietTrendEmptyMessage, style: VTTextStyles.caption(context))
          else ...[
            VTBarChart(bars: _bars(context), referenceValue: macroGoals.calorieGoal, referenceColor: colorScheme.onSurfaceVariant),
            const VTGap.s(),
            VTLegendDot(label: l10n.dietGoalLineLabel, color: colorScheme.onSurfaceVariant, isDashed: true),
          ],
        ],
      ),
    );
  }

  List<VTBarChartBar> _bars(BuildContext context) {
    final l10n = context.l10n;
    final materialLocalizations = context.materialLocalizations;
    return [
      for (final day in days)
        if (macrosByDate[day] case final macros? when macros.entries.isNotEmpty)
          VTBarChartBar(
            segments: [VTBarChartSegment(value: macros.totalCalories, color: macros.adherenceTo(macroGoals).color)],
            tooltip: l10n.chartTooltipEntry(materialLocalizations.formatShortDate(day), l10n.dietMealCalories(macros.totalCalories.round())),
          )
        else
          const VTBarChartBar.empty(),
    ];
  }
}
