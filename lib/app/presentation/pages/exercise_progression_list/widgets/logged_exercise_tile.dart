import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';

class LoggedExerciseTile extends StatelessWidget {
  const LoggedExerciseTile({required this.exercise, required this.onTap, super.key});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final accent = exercise.primaryMuscles.firstOrNull?.region.color ?? colorScheme.primary;
    return VTCard(
      onTap: onTap,
      padding: const EdgeInsets.all(VTSpacing.s),
      child: Row(
        children: [
          VTRemoteImage(imageUrl: exercise.imageUrl, placeholderIcon: Icons.fitness_center_outlined, size: 56, borderRadius: VTRadius.borderRadiusM),
          const SizedBox(width: VTSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(exercise.nameFor(l10n.localeName), style: VTTextStyles.bodyStrong(context)),
                const VTGap.xs(),
                Text(
                  [for (final muscle in exercise.primaryMuscles.take(2)) muscle.getLabel(l10n)].join(' · '),
                  style: VTTextStyles.caption(context).copyWith(color: accent),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
