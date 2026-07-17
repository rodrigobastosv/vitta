import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class SleepSummaryCard extends StatelessWidget {
  const SleepSummaryCard({required this.logs, required this.goalHours, this.onEditGoal, super.key});

  final List<SleepLog> logs;
  final double goalHours;
  final VoidCallback? onEditGoal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lastNight = logs.first.duration;
    final goal = Duration(minutes: (goalHours * 60).round());
    final progress = goal.inMinutes <= 0 ? 0.0 : (lastNight.inMinutes / goal.inMinutes).clamp(0, 1).toDouble();
    final reached = progress >= 1;
    final deficit = goal - lastNight;
    final totalMinutes = logs.fold<int>(0, (sum, log) => sum + log.duration.inMinutes);
    final average = Duration(minutes: (totalMinutes / logs.length).round());
    final ringColor = reached ? VTColors.success : VTColors.sleep;

    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.sleepLastNightLabel, style: VTTextStyles.overline(context))),
              if (onEditGoal != null)
                IconButton(
                  visualDensity: .compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(Icons.tune, size: 20),
                  tooltip: l10n.sleepGoalDialogTitle,
                  onPressed: onEditGoal,
                ),
            ],
          ),
          const VTGap.s(),
          Row(
            children: [
              VTMacroRing(
                value: progress,
                color: ringColor,
                size: 120,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text(_format(l10n, lastNight), style: VTTextStyles.headline(context)),
                    Text(l10n.sleepOfGoal(_format(l10n, goal)), style: VTTextStyles.caption(context)),
                    const VTGap.xs(),
                    Text(
                      reached ? l10n.sleepGoalReached : l10n.sleepShort(_format(l10n, deficit)),
                      style: VTTextStyles.overline(context).copyWith(color: ringColor, fontWeight: .w700),
                    ),
                  ],
                ),
              ),
              const VTGap.l(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    _metric(context, icon: Icons.flag_rounded, value: _format(l10n, goal), label: l10n.sleepGoalMetric),
                    const VTGap.m(),
                    _metric(context, icon: Icons.bar_chart_rounded, value: _format(l10n, average), label: l10n.sleepAverageMetric),
                    const VTGap.m(),
                    _metric(context, icon: Icons.bedtime_rounded, value: '${logs.length}', label: l10n.sleepNightsMetric),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(AppLocalizations l10n, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return l10n.sleepDurationLabel(hours, minutes);
    }
    if (hours > 0) {
      return l10n.sleepHoursOnly(hours);
    }
    return l10n.sleepMinutesOnly(minutes);
  }

  Widget _metric(BuildContext context, {required IconData icon, required String value, required String label}) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: VTColors.sleep.withValues(alpha: 0.16), shape: .circle),
        child: Icon(icon, color: VTColors.sleep, size: 16),
      ),
      const VTGap.s(),
      Expanded(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(value, style: VTTextStyles.bodyStrong(context)),
            Text(label, style: VTTextStyles.overline(context)),
          ],
        ),
      ),
    ],
  );
}
