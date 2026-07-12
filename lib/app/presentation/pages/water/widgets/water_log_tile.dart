import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
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
    return VTCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${unitSystem.millilitersToDisplayVolume(log.amountMl).round()} ${unitSystem.volumeUnitLabel}',
              style: VTTextStyles.bodyStrong(context),
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: l10n.waterDeleteLogTooltip, onPressed: onDelete),
        ],
      ),
    );
  }
}
