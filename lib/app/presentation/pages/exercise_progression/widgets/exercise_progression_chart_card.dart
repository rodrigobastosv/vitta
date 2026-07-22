import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression_point.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class ExerciseProgressionChartCard extends StatelessWidget {
  const ExerciseProgressionChartCard({
    required this.title,
    required this.points,
    required this.valueOf,
    required this.color,
    required this.unitSystem,
    super.key,
  });

  final String title;
  final List<ExerciseProgressionPoint> points;
  final double Function(ExerciseProgressionPoint point) valueOf;
  final Color color;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final latest = points.isEmpty ? 0.0 : valueOf(points.last);
    final recordIndex = _recordIndex();
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: VTTextStyles.bodyStrong(context))),
              VTBadge(label: _formatLoad(latest), color: color),
            ],
          ),
          const VTGap.xs(),
          Text(l10n.workoutProgressionSessionCount(points.length), style: VTTextStyles.caption(context)),
          const VTGap.m(),
          VTBarChart(bars: _bars(context, recordIndex)),
          if (recordIndex != null) ...[
            const VTGap.s(),
            VTLegendDot(label: l10n.workoutProgressionRecordLegend, color: color),
          ],
        ],
      ),
    );
  }

  // The personal record moment: the first session that reached the all-time best,
  // so later sessions that merely match it don't steal the marker.
  int? _recordIndex() {
    if (points.isEmpty) {
      return null;
    }
    var best = valueOf(points.first);
    var bestIndex = 0;
    for (final (index, point) in points.indexed) {
      if (valueOf(point) > best) {
        best = valueOf(point);
        bestIndex = index;
      }
    }
    return best <= 0 ? null : bestIndex;
  }

  List<VTBarChartBar> _bars(BuildContext context, int? recordIndex) {
    final l10n = context.l10n;
    final materialLocalizations = context.materialLocalizations;
    return [
      for (final (index, point) in points.indexed)
        VTBarChartBar(
          // The record bar keeps the full accent; the rest recede to a muted tint so
          // the peak reads as the personal best rather than one bar among equals.
          segments: [
            VTBarChartSegment(
              value: unitSystem.kilogramsToDisplayLoad(valueOf(point)),
              color: index == recordIndex ? color : color.withValues(alpha: 0.35),
            ),
          ],
          tooltip: _tooltipFor(l10n, materialLocalizations.formatShortDate(point.date), valueOf(point), isRecord: index == recordIndex),
        ),
    ];
  }

  String _tooltipFor(AppLocalizations l10n, String date, double valueKg, {required bool isRecord}) {
    final entry = l10n.chartTooltipEntry(date, _formatLoad(valueKg));
    return isRecord ? '$entry · ${l10n.workoutProgressionRecordLegend}' : entry;
  }

  String _formatLoad(double kilograms) {
    final value = unitSystem.kilogramsToDisplayLoad(kilograms);
    final rounded = value.round();
    final label = (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
    return '$label ${unitSystem.loadUnitLabel}';
  }
}
