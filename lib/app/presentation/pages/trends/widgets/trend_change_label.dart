import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/trends/entities/trend_direction.dart';

class TrendChangeLabel extends StatelessWidget {
  const TrendChangeLabel({required this.changeRatio, required this.days, super.key});

  final double? changeRatio;
  final int days;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    if (changeRatio == null) {
      return Text(l10n.trendsNoComparison, style: VTTextStyles.caption(context));
    }
    final direction = TrendDirection.forChangeRatio(changeRatio!);
    final changePercent = ((changeRatio! - 1) * 100).round();
    return Row(
      children: [
        Icon(
          switch (direction) {
            .up => Icons.arrow_upward,
            .down => Icons.arrow_downward,
            .flat => Icons.trending_flat,
          },
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const VTGap.xs(),
        Expanded(
          child: Text(
            l10n.trendsChangeVsPrevious(_signed(changePercent), days),
            style: VTTextStyles.caption(context),
          ),
        ),
      ],
    );
  }

  String _signed(int changePercent) {
    if (changePercent == 0) {
      return '0%';
    }
    return '${changePercent < 0 ? '−' : '+'}${changePercent.abs()}%';
  }
}
