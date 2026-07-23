import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class HomeSleepHero extends StatelessWidget {
  const HomeSleepHero({required this.lastNightHours, required this.goalHours, required this.onTap, required this.onLog, super.key});

  final double? lastNightHours;
  final double goalHours;
  final VoidCallback onTap;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final slept = lastNightHours ?? 0;
    final reached = goalHours > 0 && slept >= goalHours;
    return VTCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              VTMacroRing(
                value: goalHours <= 0 ? 0 : slept / goalHours,
                color: lastNightHours == null
                    ? colorScheme.primary
                    : reached
                    ? VTColors.success
                    : VTColors.sleep,
                size: 104,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      switch (lastNightHours) {
                        final hours? => l10n.sleepDurationLabel(hours.floor(), ((hours - hours.floor()) * 60).round()),
                        null => '—',
                      },
                      style: VTTextStyles.title(context),
                    ),
                    Text(l10n.homeSleepLastNight, style: VTTextStyles.overline(context)),
                  ],
                ),
              ),
              const VTGap.l(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(l10n.sleepFeatureTitle, style: VTTextStyles.overline(context)),
                    const VTGap.xs(),
                    Text(l10n.homeSleepGoal(_goalLabel), style: VTTextStyles.title(context)),
                    const VTGap.xs(),
                    Text(
                      lastNightHours == null
                          ? l10n.homeNotTrackedYet
                          : reached
                          ? l10n.sleepGoalReached
                          : l10n.sleepFeatureSubtitle,
                      style: VTTextStyles.caption(context).copyWith(color: reached ? VTColors.success : colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextButton.icon(onPressed: onLog, icon: const Icon(Icons.add), label: Text(l10n.sleepLogAction)),
        ],
      ),
    );
  }

  String get _goalLabel => goalHours == goalHours.roundToDouble() ? goalHours.toStringAsFixed(0) : goalHours.toStringAsFixed(1);
}
