import 'package:flutter/material.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_bar_chart.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_labels.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_line_chart.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_visuals.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_change_label.dart';

class TrendAreaCard extends StatelessWidget {
  const TrendAreaCard({required this.area, required this.trend, required this.unitSystem, required this.onOpenHistory, super.key});

  final TrendArea area;
  final AreaTrend trend;
  final UnitSystem unitSystem;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final adherence = trend.adherence;
    return VTCard(
      onTap: onOpenHistory,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              _avatar(),
              const VTGap.m(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(trendAreaLabel(l10n, area), style: VTTextStyles.bodyStrong(context)),
                    Text(trendAreaMetricLabel(l10n, area), style: VTTextStyles.caption(context)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: colorScheme.onSurfaceVariant),
            ],
          ),
          const VTGap.m(),
          if (!trend.hasData)
            Text(l10n.dietTrendEmptyMessage, style: VTTextStyles.caption(context))
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    trendAreaValueLabel(l10n, unitSystem, area, trend.current.average),
                    style: VTTextStyles.headline(context),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                ),
                if (adherence case final adherence?) VTBadge(label: _adherenceLabel(context, adherence), color: adherence.color),
              ],
            ),
            const VTGap.xs(),
            TrendChangeLabel(changeRatio: trend.changeRatio, days: trend.days.length),
            const VTGap.xs(),
            Text(l10n.dietTrendLoggedDays(trend.current.loggedDayCount, trend.days.length), style: VTTextStyles.caption(context)),
            const VTGap.m(),
            switch (area) {
              .bodyWeight => TrendAreaLineChart(area: area, trend: trend, unitSystem: unitSystem),
              _ => TrendAreaBarChart(area: area, trend: trend, unitSystem: unitSystem),
            },
          ],
        ],
      ),
    );
  }

  Widget _avatar() {
    final accent = trendAreaAccent(area);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: accent, shape: .circle),
      child: Icon(trendAreaIcon(area), size: 20, color: VTColors.inkOn(accent)),
    );
  }

  String _adherenceLabel(BuildContext context, GoalAdherence adherence) => switch (adherence) {
    .met => context.l10n.trendsAdherenceMet,
    .close => context.l10n.trendsAdherenceClose,
    .off => context.l10n.trendsAdherenceOff,
  };
}
