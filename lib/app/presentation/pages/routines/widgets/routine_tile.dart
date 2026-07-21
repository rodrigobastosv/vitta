import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';

class RoutineTile extends StatelessWidget {
  const RoutineTile({required this.routine, required this.onTap, this.onDelete, this.dragHandle, super.key});

  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(routine.name, style: VTTextStyles.bodyStrong(context)),
                const VTGap.xs(),
                Text(l10n.workoutRoutineExerciseCount(routine.exercises.length), style: VTTextStyles.caption(context)),
                if (routine.regions.isNotEmpty) ...[
                  const VTGap.s(),
                  Wrap(
                    spacing: VTSpacing.s,
                    runSpacing: VTSpacing.xs,
                    children: [for (final region in routine.regions) VTBadge(label: region.getLabel(l10n), color: region.color)],
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null) IconButton(icon: const Icon(Icons.delete_outline), tooltip: l10n.workoutRoutineDeleteTooltip, onPressed: onDelete),
          ?dragHandle,
        ],
      ),
    );
  }
}
