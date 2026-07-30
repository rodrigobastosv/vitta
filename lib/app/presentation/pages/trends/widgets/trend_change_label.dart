import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/trends/entities/trend_direction.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_visuals.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_change_format.dart';

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
    return Row(
      children: [
        Icon(trendDirectionIcon(TrendDirection.forChangeRatio(changeRatio!)), size: 16, color: colorScheme.onSurfaceVariant),
        const VTGap.xs(),
        Expanded(
          child: Text(
            l10n.trendsChangeVsPrevious(signedChangePercent(changeRatio!), days),
            style: VTTextStyles.caption(context),
          ),
        ),
      ],
    );
  }
}
