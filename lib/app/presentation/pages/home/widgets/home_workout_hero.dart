import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class HomeWorkoutHero extends StatelessWidget {
  const HomeWorkoutHero({required this.completedExercises, required this.totalExercises, required this.onTap, super.key});

  final int completedExercises;
  final int totalExercises;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final isFinished = totalExercises > 0 && completedExercises == totalExercises;
    return VTCard(
      onTap: onTap,
      child: Row(
        children: [
          VTMacroRing(
            value: totalExercises <= 0 ? 0 : completedExercises / totalExercises,
            color: isFinished ? VTColors.success : colorScheme.primary,
            size: 104,
            child: Column(
              mainAxisSize: .min,
              children: [
                Text(totalExercises <= 0 ? '—' : '$completedExercises/$totalExercises', style: VTTextStyles.headline(context)),
                Text(l10n.workoutFeatureTitle, style: VTTextStyles.overline(context)),
              ],
            ),
          ),
          const VTGap.l(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(l10n.homeWorkoutHeroTitle, style: VTTextStyles.title(context)),
                const VTGap.xs(),
                Text(
                  totalExercises <= 0 ? l10n.homeNoWorkout : l10n.homeWorkoutProgress(completedExercises, totalExercises),
                  style: VTTextStyles.caption(context).copyWith(color: isFinished ? VTColors.success : colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
