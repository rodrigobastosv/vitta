import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutFinishedCard extends StatelessWidget {
  const WorkoutFinishedCard({required this.estimatedCalories, required this.isBodyWeightKnown, this.onViewSummary, super.key});

  static const double _avatarSize = 44;

  final int estimatedCalories;
  final bool isBodyWeightKnown;

  /// Opens the day's summary. Null renders the card without a CTA - the "pass no
  /// callback to disable" convention `MealSectionCard` established.
  ///
  /// This is what a day finished *earlier* offers: finishing the last exercise
  /// pushes the summary itself, but a past day has no such moment to ride on, so
  /// the way back to it has to be on the card.
  final VoidCallback? onViewSummary;

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
          if (onViewSummary case final onViewSummary?) ...[
            const VTGap.s(),
            TextButton.icon(
              onPressed: onViewSummary,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(l10n.workoutSummaryViewAction),
            ),
          ],
        ],
      ),
    );
  }
}
