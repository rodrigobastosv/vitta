import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/body_profile/entities/basal_metabolism.dart';

class BasalMetabolismCard extends StatelessWidget {
  const BasalMetabolismCard({required this.metabolism, super.key});

  final BasalMetabolism metabolism;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final caption = VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant);
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: .center,
                decoration: BoxDecoration(color: colorScheme.primary, shape: .circle),
                child: Icon(Icons.local_fire_department_outlined, size: 20, color: VTColors.inkOn(colorScheme.primary)),
              ),
              const VTGap.s(),
              Expanded(child: Text(l10n.bodyProfileMetabolismTitle, style: VTTextStyles.bodyStrong(context))),
            ],
          ),
          const VTGap.s(),
          Text(l10n.bodyProfileMetabolismBasal(metabolism.basalCalories.round()), style: VTTextStyles.display(context)),
          Text(l10n.bodyProfileMetabolismMaintenance(metabolism.maintenanceCalories.round()), style: VTTextStyles.bodyStrong(context)),
          const VTGap.xs(),
          Text(l10n.bodyProfileMetabolismMethod, style: caption),
          Text(
            metabolism.isFullyKnown ? l10n.bodyProfileMetabolismMeasured : l10n.bodyProfileMetabolismAssumed,
            style: caption,
          ),
        ],
      ),
    );
  }
}
