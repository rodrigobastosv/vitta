import 'package:flutter/material.dart';
import 'package:vitta/app/core/goals/daily_goal_average.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';

class WaterTrendCard extends StatelessWidget {
  const WaterTrendCard({required this.days, required this.waterByDate, required this.dailyGoalMl, super.key});

  final List<DateTime> days;
  final Map<DateTime, DailyWater> waterByDate;
  final double dailyGoalMl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final average = DailyGoalAverage.fromValues([
      for (final day in days)
        if (waterByDate[day] case final water? when water.entries.isNotEmpty) water.totalMl,
    ]);
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.waterTrendTitle, style: VTTextStyles.bodyStrong(context))),
              if (average.hasData) VTBadge(label: l10n.waterTrendAverageLabel(average.average.round()), color: colorScheme.primary),
            ],
          ),
          const VTGap.xs(),
          Text(l10n.dietTrendLoggedDays(average.loggedDayCount, days.length), style: VTTextStyles.caption(context)),
          const VTGap.m(),
          if (!average.hasData)
            Text(l10n.waterTrendEmptyMessage, style: VTTextStyles.caption(context))
          else ...[
            VTBarChart(bars: _bars(colorScheme.primary), referenceValue: dailyGoalMl, referenceColor: colorScheme.onSurfaceVariant),
            const VTGap.s(),
            VTLegendDot(label: l10n.dietGoalLineLabel, color: colorScheme.onSurfaceVariant, isDashed: true),
          ],
        ],
      ),
    );
  }

  List<VTBarChartBar> _bars(Color fallbackColor) => [
    for (final day in days)
      if (waterByDate[day] case final water? when water.entries.isNotEmpty)
        VTBarChartBar(
          segments: [
            VTBarChartSegment(value: water.totalMl, color: dailyGoalMl <= 0 ? fallbackColor : GoalAdherence.forRatio(water.totalMl / dailyGoalMl).color),
          ],
        )
      else
        const VTBarChartBar.empty(),
  ];
}
