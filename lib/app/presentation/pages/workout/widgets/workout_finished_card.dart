import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutFinishedCard extends StatelessWidget {
  const WorkoutFinishedCard({required this.estimatedCalories, required this.isBodyWeightKnown, super.key});

  static const double _avatarSize = 44;

  final int estimatedCalories;
  final bool isBodyWeightKnown;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: _avatarSize,
                height: _avatarSize,
                alignment: .center,
                decoration: const BoxDecoration(color: VTColors.success, shape: .circle),
                child: Icon(Icons.emoji_events_outlined, color: VTColors.inkOn(VTColors.success), size: 22),
              ),
              const VTGap.m(),
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
          const VTGap.m(),
          const Divider(height: 1),
          const VTGap.m(),
          Text(l10n.workoutFinishedCaloriesLabel, style: VTTextStyles.overline(context)),
          const VTGap.xs(),
          Text(l10n.workoutFinishedCaloriesValue(estimatedCalories), style: VTTextStyles.display(context), textAlign: .center),
          const VTGap.xs(),
          Text(
            isBodyWeightKnown ? l10n.workoutFinishedCaloriesHint : l10n.workoutFinishedCaloriesNoWeightHint,
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: .center,
          ),
        ],
      ),
    );
  }
}
