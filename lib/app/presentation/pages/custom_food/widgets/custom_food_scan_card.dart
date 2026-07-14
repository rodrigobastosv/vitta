import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class CustomFoodScanCard extends StatelessWidget {
  const CustomFoodScanCard({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: VTColors.coral.withValues(alpha: 0.16), shape: .circle),
            child: const Icon(Icons.document_scanner_outlined, color: VTColors.coral, size: 22),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(l10n.dietScanLabelAction, style: VTTextStyles.bodyStrong(context)),
                const VTGap.xs(),
                Text(l10n.dietScanLabelHint, style: VTTextStyles.caption(context)),
              ],
            ),
          ),
          const VTGap.s(),
          Icon(Icons.chevron_right, color: context.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
