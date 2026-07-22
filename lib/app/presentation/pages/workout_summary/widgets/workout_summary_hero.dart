import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_celebration.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutSummaryHero extends StatelessWidget {
  const WorkoutSummaryHero({required this.date, required this.celebrate, super.key});

  final DateTime date;
  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m, vertical: VTSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: VTRadius.borderRadiusL,
        gradient: LinearGradient(begin: .topCenter, end: .bottomCenter, colors: [VTColors.success.withValues(alpha: 0.18), colorScheme.surface]),
      ),
      child: Column(
        children: [
          VTCelebration(
            trigger: celebrate,
            // A solid disc with the ink that actually contrasts, never the 16%
            // tint - success measures 2.87:1 that way on a light surface.
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: VTColors.success, shape: .circle),
              child: Icon(Icons.emoji_events_rounded, color: VTColors.inkOn(VTColors.success), size: 38),
            ),
          ),
          const VTGap.m(),
          Text(l10n.workoutFinishedTitle, style: VTTextStyles.display(context), textAlign: .center),
          const VTGap.xs(),
          Text(
            context.materialLocalizations.formatFullDate(date),
            style: VTTextStyles.caption(context),
            textAlign: .center,
          ),
          const VTGap.s(),
          Text(l10n.workoutFinishedMessage, style: VTTextStyles.body(context), textAlign: .center),
        ],
      ),
    );
  }
}
