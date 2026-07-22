import 'package:flutter/material.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_labels.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_visuals.dart';

class TrendAreaBarChart extends StatelessWidget {
  const TrendAreaBarChart({required this.area, required this.trend, required this.unitSystem, super.key});

  final TrendArea area;
  final AreaTrend trend;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final materialLocalizations = context.materialLocalizations;
    final goal = trend.goal;
    return VTBarChart(
      height: 108,
      referenceValue: switch (goal) {
        final goal? when goal > 0 => trendAreaDisplayValue(unitSystem, area, goal),
        _ => null,
      },
      referenceColor: context.colorScheme.onSurfaceVariant,
      bars: [
        for (final day in trend.days)
          if (trend.valuesByDate[day] case final value?)
            VTBarChartBar(
              segments: [
                VTBarChartSegment(
                  value: trendAreaDisplayValue(unitSystem, area, value),
                  color: switch (goal) {
                    final goal? when goal > 0 => GoalAdherence.forRatio(value / goal).color,
                    _ => trendAreaAccent(area),
                  },
                ),
              ],
              tooltip: l10n.chartTooltipEntry(materialLocalizations.formatShortDate(day), trendAreaValueLabel(l10n, unitSystem, area, value)),
            )
          else
            const VTBarChartBar.empty(),
      ],
    );
  }
}
