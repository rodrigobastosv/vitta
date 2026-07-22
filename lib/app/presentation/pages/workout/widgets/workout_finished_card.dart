import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutFinishedCard extends StatelessWidget {
  const WorkoutFinishedCard({this.onViewSummary, super.key});

  /// Opens the day's summary page. Null renders the card without a CTA - the
  /// "pass no callback to disable" convention `MealSectionCard` established.
  ///
  /// This is what a day you finished *earlier* offers: finishing the last
  /// exercise pushes the summary itself, but a past day has no such moment to
  /// ride on, so the way back to it has to be on the card.
  final VoidCallback? onViewSummary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
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
          if (onViewSummary != null) ...[
            const VTGap.s(),
            Align(
              alignment: .centerRight,
              child: TextButton.icon(
                onPressed: onViewSummary,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(l10n.workoutSummaryViewAction),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
