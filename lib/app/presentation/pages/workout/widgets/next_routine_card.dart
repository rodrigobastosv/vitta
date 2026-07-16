import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';

class NextRoutineCard extends StatelessWidget {
  const NextRoutineCard({required this.routine, required this.onStart, super.key});

  final Routine routine;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.16),
                child: Icon(Icons.repeat, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: VTSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(l10n.workoutNextRoutineLabel, style: VTTextStyles.overline(context)),
                    const VTGap.xs(),
                    Text(routine.name, style: VTTextStyles.title(context)),
                  ],
                ),
              ),
            ],
          ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.s,
            runSpacing: VTSpacing.xs,
            children: [
              VTBadge(label: l10n.workoutRoutineExerciseCount(routine.exercises.length), color: colorScheme.primary),
              for (final region in routine.regions) VTBadge(label: region.getLabel(l10n), color: region.color),
            ],
          ),
          const VTGap.m(),
          Text(l10n.workoutStartRoutineHint, style: VTTextStyles.caption(context)),
          const VTGap.s(),
          Align(
            alignment: .centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.play_arrow, size: 18),
              label: Text(l10n.workoutStartRoutineAction(routine.name)),
              onPressed: onStart,
            ),
          ),
        ],
      ),
    );
  }
}
