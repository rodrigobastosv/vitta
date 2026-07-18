import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart_point.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';
import 'package:vitta/app/presentation/pages/body_weight/widgets/body_weight_format.dart';

class BodyWeightSummaryCard extends StatelessWidget {
  const BodyWeightSummaryCard({required this.logs, required this.unitSystem, super.key});

  // Most recent first, as the cubit holds them.
  final List<BodyWeightLog> logs;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final latest = logs.first;
    final oldest = logs.last;
    final deltaKg = latest.weightKg - oldest.weightKg;
    final chronological = logs.reversed.toList();
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.16),
                child: Icon(Icons.monitor_weight_outlined, color: colorScheme.primary, size: 20),
              ),
              const VTGap.m(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(l10n.bodyWeightCurrentTitle, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
                    Text(bodyWeightDisplay(l10n, unitSystem, latest.weightKg), style: VTTextStyles.display(context)),
                  ],
                ),
              ),
              if (logs.length > 1) _deltaPill(context, deltaKg),
            ],
          ),
          if (logs.length > 1) ...[
            const VTGap.m(),
            VTLineChart(
              points: [for (final log in chronological) VTLineChartPoint(value: unitSystem.kilogramsToDisplayLoad(log.weightKg))],
              height: 120,
            ),
          ],
        ],
      ),
    );
  }

  Widget _deltaPill(BuildContext context, double deltaKg) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final isDown = deltaKg < 0;
    final isFlat = deltaKg.abs() < 0.05;
    final icon = isFlat
        ? Icons.trending_flat
        : isDown
        ? Icons.south
        : Icons.north;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
      decoration: BoxDecoration(color: colorScheme.onSurface.withValues(alpha: 0.06), borderRadius: VTRadius.borderRadiusFull),
      child: Row(
        mainAxisSize: .min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const VTGap.xs(),
          Text(
            bodyWeightDisplay(l10n, unitSystem, deltaKg.abs()),
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
