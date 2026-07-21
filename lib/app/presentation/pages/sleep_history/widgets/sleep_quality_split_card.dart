import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/sleep/entities/daily_sleep.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_quality_split.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_quality_color.dart';

class SleepQualitySplitCard extends StatelessWidget {
  const SleepQualitySplitCard({required this.days, required this.sleepByDate, super.key});

  final List<DateTime> days;
  final Map<DateTime, DailySleep> sleepByDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final split = SleepQualitySplit.fromDays([for (final day in days) ?sleepByDate[day]]);
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.sleepQualitySplitTitle, style: VTTextStyles.bodyStrong(context)),
          const VTGap.xs(),
          Text(l10n.sleepRatedNights(split.ratedNightCount), style: VTTextStyles.caption(context)),
          const VTGap.m(),
          if (!split.hasData)
            Text(l10n.sleepQualityEmptyMessage, style: VTTextStyles.caption(context))
          else ...[
            VTDistributionBar(
              segments: [
                for (final rating in SleepQualitySplit.ratings)
                  if (split.nightsAt(rating) > 0) VTBarChartSegment(value: split.nightsAt(rating).toDouble(), color: sleepQualityColor(rating)),
              ],
            ),
            const VTGap.m(),
            for (final rating in SleepQualitySplit.ratings)
              if (split.nightsAt(rating) > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: VTLegendDot(label: l10n.sleepQualityStars(rating), color: sleepQualityColor(rating)),
                      ),
                      Text(l10n.dietMacroPercent((split.shareAt(rating) * 100).round()), style: VTTextStyles.caption(context)),
                    ],
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
