import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/trend_legend_dot.dart';

class MacrosTrendCard extends StatelessWidget {
  const MacrosTrendCard({required this.days, required this.macrosByDate, super.key});

  final List<DateTime> days;
  final Map<DateTime, DailyMacros> macrosByDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasAnyLog = days.any((day) => macrosByDate[day]?.entries.isNotEmpty ?? false);
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.dietMacrosTrendTitle, style: VTTextStyles.bodyStrong(context)),
          const VTGap.m(),
          if (!hasAnyLog)
            Text(l10n.dietTrendEmptyMessage, style: VTTextStyles.caption(context))
          else ...[
            VTBarChart(bars: _bars()),
            const VTGap.s(),
            Wrap(
              spacing: VTSpacing.m,
              runSpacing: VTSpacing.s,
              children: [
                TrendLegendDot(label: l10n.dietProteinLabel, color: VTColors.macroProtein),
                TrendLegendDot(label: l10n.dietCarbsLabel, color: VTColors.macroCarbs),
                TrendLegendDot(label: l10n.dietFatLabel, color: VTColors.macroFat),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<VTBarChartBar> _bars() => [
    for (final day in days)
      if (macrosByDate[day] case final macros? when macros.entries.isNotEmpty)
        VTBarChartBar(
          segments: [
            VTBarChartSegment(value: macros.totalProtein, color: VTColors.macroProtein),
            VTBarChartSegment(value: macros.totalCarbs, color: VTColors.macroCarbs),
            VTBarChartSegment(value: macros.totalFat, color: VTColors.macroFat),
          ],
        )
      else
        const VTBarChartBar.empty(),
  ];
}
