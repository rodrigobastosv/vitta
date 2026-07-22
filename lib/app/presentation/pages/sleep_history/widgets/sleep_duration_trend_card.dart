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
import 'package:vitta/app/domain/sleep/entities/daily_sleep.dart';

class SleepDurationTrendCard extends StatelessWidget {
  const SleepDurationTrendCard({required this.days, required this.sleepByDate, required this.durationGoalHours, super.key});

  final List<DateTime> days;
  final Map<DateTime, DailySleep> sleepByDate;
  final double durationGoalHours;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final average = DailyGoalAverage.fromValues(_loggedHours());
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.sleepDurationTrendTitle, style: VTTextStyles.bodyStrong(context))),
              if (average.hasData) VTBadge(label: l10n.sleepTrendAverageLabel(average.average.toStringAsFixed(1)), color: colorScheme.primary),
            ],
          ),
          const VTGap.xs(),
          Text(l10n.dietTrendLoggedDays(average.loggedDayCount, days.length), style: VTTextStyles.caption(context)),
          const VTGap.m(),
          if (!average.hasData)
            Text(l10n.sleepTrendEmptyMessage, style: VTTextStyles.caption(context))
          else ...[
            VTBarChart(bars: _bars(context, colorScheme.primary), referenceValue: durationGoalHours, referenceColor: colorScheme.onSurfaceVariant),
            const VTGap.s(),
            VTLegendDot(label: l10n.dietGoalLineLabel, color: colorScheme.onSurfaceVariant, isDashed: true),
          ],
        ],
      ),
    );
  }

  List<double> _loggedHours() => [
    for (final day in days)
      if (sleepByDate[day] case final sleep? when sleep.entries.isNotEmpty) sleep.totalHours,
  ];

  List<VTBarChartBar> _bars(BuildContext context, Color fallbackColor) {
    final l10n = context.l10n;
    final materialLocalizations = context.materialLocalizations;
    return [
      for (final day in days)
        if (sleepByDate[day] case final sleep? when sleep.entries.isNotEmpty)
          VTBarChartBar(
            segments: [
              VTBarChartSegment(
                value: sleep.totalHours,
                color: durationGoalHours <= 0 ? fallbackColor : GoalAdherence.forRatio(sleep.totalHours / durationGoalHours).color,
              ),
            ],
            tooltip: l10n.chartTooltipEntry(materialLocalizations.formatShortDate(day), l10n.sleepHoursShort(sleep.totalHours.toStringAsFixed(1))),
          )
        else
          const VTBarChartBar.empty(),
    ];
  }
}
