import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/presentation/general/workout_duration_format.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class WorkoutSetRow extends StatelessWidget {
  const WorkoutSetRow({
    required this.set,
    required this.position,
    required this.unitSystem,
    required this.color,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final WorkoutSet set;

  // Null on a cardio effort: there is only ever one of them, so numbering it "1"
  // would advertise a second (issue #212).
  final int? position;
  final UnitSystem unitSystem;
  final Color color;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final distanceMeters = set.distanceMeters;
    final badgeLabel = set.isCardio
        ? (distanceMeters != null && distanceMeters > 0 ? formatWorkoutDistance(unitSystem, distanceMeters) : null)
        : (set.isBodyweight ? l10n.workoutBodyweightLabel : _load());
    return InkWell(
      onTap: onEdit,
      borderRadius: VTRadius.borderRadiusS,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: VTSpacing.s),
        child: Row(
          children: [
            if (position case final position?) ...[
              Container(
                width: 26,
                height: 26,
                alignment: .center,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: VTRadius.borderRadiusS),
                child: Text(
                  '$position',
                  style: VTTextStyles.caption(context).copyWith(color: color, fontWeight: .w700),
                ),
              ),
              const VTGap.m(),
            ] else ...[
              Icon(Icons.timer_outlined, size: 20, color: color),
              const VTGap.m(),
            ],
            Expanded(child: Text(_primaryLabel(l10n), style: VTTextStyles.bodyStrong(context))),
            if (badgeLabel != null) VTBadge(label: badgeLabel, color: set.isBodyweight ? colorScheme.onSurfaceVariant : color),
            if (onDelete != null) ...[
              const VTGap.xs(),
              InkResponse(
                onTap: onDelete,
                radius: 20,
                child: Tooltip(
                  message: l10n.workoutDeleteSetTooltip,
                  child: Padding(
                    padding: const EdgeInsets.all(VTSpacing.xs),
                    child: Icon(Icons.close_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _primaryLabel(AppLocalizations l10n) =>
      set.isCardio ? formatWorkoutDuration(l10n, set.durationSeconds ?? 0) : l10n.workoutSetSummary(set.reps ?? 0);

  String _load() {
    final value = unitSystem.kilogramsToDisplayLoad(set.weightKg);
    final rounded = value.round();
    final label = (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
    return '$label ${unitSystem.loadUnitLabel}';
  }
}
