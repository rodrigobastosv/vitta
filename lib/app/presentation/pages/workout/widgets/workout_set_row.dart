import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

class WorkoutSetRow extends StatelessWidget {
  const WorkoutSetRow({required this.set, required this.position, required this.unitSystem, this.onEdit, this.onDelete, super.key});

  final WorkoutSet set;
  final int position;
  final UnitSystem unitSystem;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: VTSpacing.s),
        child: Row(
          children: [
            SizedBox(width: 28, child: Text('$position', style: VTTextStyles.caption(context))),
            const SizedBox(width: VTSpacing.s),
            Expanded(
              child: Text(
                set.isBodyweight ? l10n.workoutSetSummary(set.reps) : l10n.workoutSetSummaryWeighted(set.reps, _load()),
                style: VTTextStyles.body(context),
              ),
            ),
            if (set.isBodyweight)
              Text(l10n.workoutBodyweightLabel, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
            if (onDelete != null)
              IconButton(icon: const Icon(Icons.close, size: 18), tooltip: l10n.workoutDeleteSetTooltip, onPressed: onDelete),
          ],
        ),
      ),
    );
  }

  String _load() {
    final value = unitSystem.kilogramsToDisplayLoad(set.weightKg);
    final rounded = value.round();
    final label = (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
    return '$label ${unitSystem.loadUnitLabel}';
  }
}
