import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart_point.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';
import 'package:vitta/app/presentation/pages/body_weight/widgets/body_weight_format.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_weight_delta_pill.dart';

// Body weight has no daily goal, so its hero is a trend rather than a ring: the
// latest weight, the change across the loaded window, and the line itself.
class HomeBodyWeightHero extends StatelessWidget {
  const HomeBodyWeightHero({
    required this.logs,
    required this.latestWeightKg,
    required this.unitSystem,
    required this.onTap,
    required this.onLog,
    super.key,
  });

  // Most recent first, as the cubit holds them.
  final List<BodyWeightLog> logs;
  final double? latestWeightKg;
  final UnitSystem unitSystem;
  final VoidCallback onTap;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final latest = logs.firstOrNull?.weightKg ?? latestWeightKg;
    final chronological = logs.reversed.toList();
    return VTCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: .center,
                decoration: const BoxDecoration(color: VTColors.success, shape: .circle),
                child: Icon(Icons.monitor_weight_outlined, color: VTColors.inkOn(VTColors.success), size: 22),
              ),
              const VTGap.m(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(l10n.bodyWeightCurrentTitle, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
                    Text(
                      switch (latest) {
                        final weightKg? => bodyWeightDisplay(l10n, unitSystem, weightKg),
                        null => l10n.homeNotTrackedYet,
                      },
                      style: VTTextStyles.display(context),
                    ),
                  ],
                ),
              ),
              if (logs.length > 1) HomeWeightDeltaPill(deltaKg: logs.first.weightKg - logs.last.weightKg, unitSystem: unitSystem),
            ],
          ),
          if (logs.length > 1) ...[
            const VTGap.m(),
            Text(l10n.homeWeightTrendTitle, style: VTTextStyles.overline(context)),
            const VTGap.s(),
            VTLineChart(points: [for (final log in chronological) VTLineChartPoint(value: unitSystem.kilogramsToDisplayLoad(log.weightKg))], height: 120),
          ],
          TextButton.icon(onPressed: onLog, icon: const Icon(Icons.add), label: Text(l10n.bodyWeightLogAction)),
        ],
      ),
    );
  }
}
