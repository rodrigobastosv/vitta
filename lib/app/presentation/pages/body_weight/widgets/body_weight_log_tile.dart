import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';
import 'package:vitta/app/presentation/pages/body_weight/widgets/body_weight_format.dart';

class BodyWeightLogTile extends StatelessWidget {
  const BodyWeightLogTile({required this.log, required this.unitSystem, required this.onDelete, this.previousWeightKg, super.key});

  final BodyWeightLog log;
  final UnitSystem unitSystem;
  final VoidCallback onDelete;

  // The measurement before this one (chronologically), so the row can show the
  // change since then. Null for the earliest entry.
  final double? previousWeightKg;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final previous = previousWeightKg;
    return VTCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(bodyWeightDisplay(l10n, unitSystem, log.weightKg), style: VTTextStyles.bodyStrong(context)),
                Text(
                  context.materialLocalizations.formatShortDate(log.loggedDate),
                  style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (previous != null && (log.weightKg - previous).abs() >= 0.05) _delta(context, log.weightKg - previous),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: context.materialLocalizations.deleteButtonTooltip,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _delta(BuildContext context, double deltaKg) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: VTSpacing.s),
      child: Row(
        mainAxisSize: .min,
        children: [
          Icon(deltaKg < 0 ? Icons.south : Icons.north, size: 14, color: colorScheme.onSurfaceVariant),
          const VTGap.xs(),
          Text(
            bodyWeightDisplay(l10n, unitSystem, deltaKg.abs()),
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
