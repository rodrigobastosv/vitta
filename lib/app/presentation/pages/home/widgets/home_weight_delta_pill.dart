import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/body_weight/widgets/body_weight_format.dart';

// Direction is stated by sign and arrow, never by colour: weight has no goal, so a
// gain or a loss carries no good/bad valence to paint.
class HomeWeightDeltaPill extends StatelessWidget {
  const HomeWeightDeltaPill({required this.deltaKg, required this.unitSystem, super.key});

  final double deltaKg;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final isFlat = deltaKg.abs() < 0.05;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
      decoration: BoxDecoration(color: colorScheme.onSurface.withValues(alpha: 0.08), borderRadius: VTRadius.borderRadiusFull),
      child: Row(
        mainAxisSize: .min,
        children: [
          Icon(
            isFlat
                ? Icons.trending_flat_rounded
                : deltaKg < 0
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            size: 16,
            color: colorScheme.onSurface,
          ),
          const VTGap.xs(),
          Text(
            bodyWeightSignedDisplay(l10n, unitSystem, deltaKg),
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurface, fontWeight: .w700),
          ),
        ],
      ),
    );
  }
}
