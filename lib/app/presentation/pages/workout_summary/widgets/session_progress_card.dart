import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/session_progress.dart';
import 'package:vitta/app/presentation/pages/workout_summary/widgets/session_progress_row.dart';

class SessionProgressCard extends StatelessWidget {
  const SessionProgressCard({required this.progress, required this.unitSystem, super.key});

  final List<SessionProgress> progress;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final improved = progress.where((exercise) => exercise.direction == .up).length;
    return VTCard(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(l10n.workoutSummaryProgressTitle, style: VTTextStyles.title(context)),
          const VTGap.xs(),
          Text(
            l10n.workoutSummaryImprovedCount(improved),
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const VTGap.m(),
          for (final (index, exercise) in progress.indexed) ...[
            if (index > 0) const VTGap.s(),
            SessionProgressRow(progress: exercise, unitSystem: unitSystem),
          ],
        ],
      ),
    );
  }
}
