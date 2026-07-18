import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart_point.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';
import 'package:vitta/app/presentation/pages/body_weight/widgets/body_weight_format.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class BodyWeightTrendCard extends StatelessWidget {
  const BodyWeightTrendCard({required this.logs, required this.unitSystem, super.key});

  // Oldest first.
  final List<BodyWeightLog> logs;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final materialLocalizations = context.materialLocalizations;
    final weights = [for (final log in logs) log.weightKg];
    final change = logs.last.weightKg - logs.first.weightKg;
    final average = weights.reduce((sum, value) => sum + value) / weights.length;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.bodyWeightTrendTitle, style: VTTextStyles.title(context)),
          const VTGap.m(),
          VTLineChart(
            points: [
              for (final (index, log) in logs.indexed)
                VTLineChartPoint(
                  value: unitSystem.kilogramsToDisplayLoad(log.weightKg),
                  label: index == 0 || index == logs.length - 1 ? materialLocalizations.formatShortDate(log.loggedDate) : null,
                ),
            ],
          ),
          const VTGap.l(),
          Wrap(
            spacing: VTSpacing.l,
            runSpacing: VTSpacing.m,
            children: [
              _stat(context, l10n.bodyWeightStatChange, _signed(l10n, change)),
              _stat(context, l10n.bodyWeightStatAverage, bodyWeightDisplay(l10n, unitSystem, average)),
              _stat(context, l10n.bodyWeightStatMin, bodyWeightDisplay(l10n, unitSystem, weights.reduce((a, b) => a < b ? a : b))),
              _stat(context, l10n.bodyWeightStatMax, bodyWeightDisplay(l10n, unitSystem, weights.reduce((a, b) => a > b ? a : b))),
            ],
          ),
        ],
      ),
    );
  }

  String _signed(AppLocalizations l10n, double changeKg) {
    final display = bodyWeightDisplay(l10n, unitSystem, changeKg.abs());
    if (changeKg.abs() < 0.05) {
      return display;
    }
    return '${changeKg < 0 ? '−' : '+'}$display';
  }

  Widget _stat(BuildContext context, String label, String value) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label, style: VTTextStyles.overline(context).copyWith(color: colorScheme.onSurfaceVariant)),
        Text(value, style: VTTextStyles.bodyStrong(context)),
      ],
    );
  }
}
