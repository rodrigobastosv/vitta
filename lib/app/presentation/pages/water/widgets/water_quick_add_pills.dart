import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

const _quickAddPresetsMl = [200.0, 300.0, 500.0, 750.0, 1000.0];

class WaterQuickAddPills extends StatelessWidget {
  const WaterQuickAddPills({required this.unitSystem, required this.onAdd, super.key});

  final UnitSystem unitSystem;
  final ValueChanged<double> onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(l10n.waterQuickAddLabel, style: VTTextStyles.overline(context)),
        const VTGap.s(),
        Wrap(
          spacing: VTSpacing.s,
          runSpacing: VTSpacing.s,
          children: [
            for (final presetMl in _quickAddPresetsMl)
              Material(
                color: VTColors.water.withValues(alpha: 0.12),
                borderRadius: VTRadius.borderRadiusFull,
                child: InkWell(
                  onTap: () {
                    VTHaptics.selection();
                    onAdd(presetMl);
                  },
                  borderRadius: VTRadius.borderRadiusFull,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m, vertical: VTSpacing.s),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        const Icon(Icons.add_rounded, size: 16, color: VTColors.water),
                        const VTGap.xs(),
                        Text(
                          '${unitSystem.millilitersToDisplayVolume(presetMl).round()} ${unitSystem.volumeUnitLabel}',
                          style: VTTextStyles.caption(context).copyWith(color: VTColors.water, fontWeight: .w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
