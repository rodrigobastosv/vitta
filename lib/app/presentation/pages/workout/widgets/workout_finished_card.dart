import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

/// Shown once every exercise of the day is marked done. It's the payoff for
/// checking things off, so it only appears when the workout is genuinely
/// finished - a day with nothing logged has finished nothing.
class WorkoutFinishedCard extends StatelessWidget {
  const WorkoutFinishedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: VTColors.success.withValues(alpha: 0.16),
            child: const Icon(Icons.emoji_events_outlined, color: VTColors.success, size: 22),
          ),
          const SizedBox(width: VTSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(l10n.workoutFinishedTitle, style: VTTextStyles.bodyStrong(context)),
                const VTGap.xs(),
                Text(l10n.workoutFinishedMessage, style: VTTextStyles.caption(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
