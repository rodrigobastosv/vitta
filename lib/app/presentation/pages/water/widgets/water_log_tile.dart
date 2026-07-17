import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';

class WaterLogTile extends StatelessWidget {
  const WaterLogTile({required this.log, required this.unitSystem, required this.onDelete, super.key});

  final WaterLog log;
  final UnitSystem unitSystem;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m, vertical: VTSpacing.s),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: .center,
            decoration: BoxDecoration(color: VTColors.water.withValues(alpha: 0.16), shape: .circle),
            child: const Icon(Icons.water_drop_rounded, color: VTColors.water, size: 20),
          ),
          const VTGap.m(),
          Expanded(
            child: Text(
              '${unitSystem.millilitersToDisplayVolume(log.amountMl).round()} ${unitSystem.volumeUnitLabel}',
              style: VTTextStyles.bodyStrong(context),
            ),
          ),
          InkResponse(
            onTap: onDelete,
            radius: 20,
            child: Tooltip(
              message: l10n.waterDeleteLogTooltip,
              child: Padding(
                padding: const EdgeInsets.all(VTSpacing.xs),
                child: Icon(Icons.close_rounded, size: 18, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
