import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/domain/home/entities/home_slot.dart';
import 'package:vitta/app/presentation/general/home_feature_labels.dart';
import 'package:vitta/app/presentation/general/home_slot_labels.dart';

class HomeLayoutFeatureTile extends StatelessWidget {
  const HomeLayoutFeatureTile({required this.feature, required this.slot, required this.dragHandle, required this.onTap, super.key});

  final HomeFeature feature;
  final HomeSlot slot;
  final Widget dragHandle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final isHidden = slot == .hidden;
    return VTCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.s),
      child: Row(
        children: [
          dragHandle,
          const VTGap.xs(),
          Container(
            width: 40,
            height: 40,
            alignment: .center,
            decoration: BoxDecoration(color: isHidden ? colorScheme.surfaceContainerHighest : feature.accent, shape: .circle),
            child: Icon(feature.icon, size: 20, color: isHidden ? colorScheme.onSurfaceVariant : VTColors.inkOn(feature.accent)),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(feature.label(l10n), style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
                Text(slot.label(l10n), style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.expand_more_rounded, size: 20, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
