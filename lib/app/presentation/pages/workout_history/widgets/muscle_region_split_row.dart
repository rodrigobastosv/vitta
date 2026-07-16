import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/body_region.dart';

class MuscleRegionSplitRow extends StatelessWidget {
  const MuscleRegionSplitRow({required this.region, required this.share, super.key});

  final BodyRegion region;
  final double share;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Icon(region.icon, size: 18, color: region.color),
        const VTGap.s(),
        Expanded(child: Text(region.getLabel(l10n), style: VTTextStyles.caption(context))),
        VTBadge(label: l10n.dietMacroPercent((share * 100).round()), color: region.color),
      ],
    );
  }
}
