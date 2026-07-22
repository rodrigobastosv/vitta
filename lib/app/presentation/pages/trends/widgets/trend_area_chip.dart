import 'package:flutter/material.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_labels.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_visuals.dart';

class TrendAreaChip extends StatelessWidget {
  const TrendAreaChip({required this.area, required this.adherence, super.key});

  final TrendArea area;
  final GoalAdherence? adherence;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final background = adherence?.color ?? colorScheme.surfaceContainerHighest;
    final ink = adherence == null ? colorScheme.onSurfaceVariant : VTColors.inkOn(background);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: VTRadius.borderRadiusFull),
      child: Row(
        mainAxisSize: .min,
        children: [
          Icon(trendAreaIcon(area), size: 14, color: ink),
          const VTGap.xs(),
          Text(
            trendAreaLabel(context.l10n, area),
            style: VTTextStyles.caption(context).copyWith(color: ink, fontWeight: .w700),
          ),
        ],
      ),
    );
  }
}
