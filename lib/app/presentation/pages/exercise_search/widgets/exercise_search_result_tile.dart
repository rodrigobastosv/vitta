import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';

class ExerciseSearchResultTile extends StatelessWidget {
  const ExerciseSearchResultTile({required this.exercise, required this.onTap, this.onAdd, super.key});

  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = exercise.primaryMuscles.firstOrNull?.region.color ?? context.colorScheme.primary;
    return VTCard(
      onTap: onTap,
      child: Row(
        children: [
          VTRemoteImage(imageUrl: exercise.imageUrl, placeholderIcon: Icons.fitness_center_outlined, size: 56),
          const SizedBox(width: VTSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(exercise.nameFor(l10n.localeName), style: VTTextStyles.bodyStrong(context)),
                const VTGap.xs(),
                Text(
                  [
                    if (exercise.equipment case final equipment?) equipment.getLabel(l10n),
                    for (final muscle in exercise.primaryMuscles.take(2)) muscle.getLabel(l10n),
                  ].join(' · '),
                  style: VTTextStyles.caption(context).copyWith(color: accent),
                ),
              ],
            ),
          ),
          if (onAdd != null)
            IconButton(icon: const Icon(Icons.add_circle_outline), tooltip: l10n.exerciseDetailAddAction, onPressed: onAdd),
        ],
      ),
    );
  }
}
