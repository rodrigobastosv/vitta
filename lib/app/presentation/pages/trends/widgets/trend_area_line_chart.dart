import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart_point.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_labels.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_visuals.dart';

class TrendAreaLineChart extends StatelessWidget {
  const TrendAreaLineChart({required this.area, required this.trend, required this.unitSystem, super.key});

  final TrendArea area;
  final AreaTrend trend;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final materialLocalizations = context.materialLocalizations;
    final loggedDays = [
      for (final day in trend.days)
        if (trend.valuesByDate.containsKey(day)) day,
    ];
    return VTLineChart(
      height: 108,
      lineColor: trendAreaAccent(area),
      points: [
        for (final (index, day) in loggedDays.indexed)
          VTLineChartPoint(
            value: trendAreaDisplayValue(unitSystem, area, trend.valuesByDate[day]!),
            label: index == 0 || index == loggedDays.length - 1 ? materialLocalizations.formatShortDate(day) : null,
            tooltip: l10n.chartTooltipEntry(materialLocalizations.formatShortDate(day), trendAreaValueLabel(l10n, unitSystem, area, trend.valuesByDate[day]!)),
          ),
      ],
    );
  }
}
