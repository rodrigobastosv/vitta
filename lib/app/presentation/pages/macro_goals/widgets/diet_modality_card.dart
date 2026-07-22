import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/diet_modality.dart';
import 'package:vitta/app/presentation/pages/macro_goals/widgets/diet_modality_icon.dart';
import 'package:vitta/app/presentation/pages/macro_goals/widgets/diet_modality_label.dart';

class DietModalityCard extends StatelessWidget {
  const DietModalityCard({required this.modality, required this.isSelected, required this.onTap, super.key});

  final DietModality modality;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _width = 152;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.brightness == .dark;
    return SizedBox(
      width: _width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.08) : (isDark ? VTColors.cardDark : VTColors.cardLight),
          borderRadius: VTRadius.borderRadiusL,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.6),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Material(
          type: .transparency,
          borderRadius: VTRadius.borderRadiusL,
          child: InkWell(
            onTap: onTap,
            borderRadius: VTRadius.borderRadiusL,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.m, VTSpacing.m, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.16),
                        child: Icon(dietModalityIcon(modality), color: colorScheme.primary, size: 18),
                      ),
                      const VTGap.s(),
                      Expanded(
                        child: Text(
                          dietModalityLabel(l10n, modality),
                          style: VTTextStyles.caption(context).copyWith(fontWeight: .bold),
                          maxLines: 2,
                          overflow: .ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const VTGap.xs(),
                  VTDistributionBar(
                    segments: [
                      VTBarChartSegment(value: modality.proteinRatio, color: VTColors.macroProtein),
                      VTBarChartSegment(value: modality.carbsRatio, color: VTColors.macroCarbs),
                      VTBarChartSegment(value: modality.fatRatio, color: VTColors.macroFat),
                    ],
                  ),
                  const VTGap.xs(),
                  Row(
                    children: [
                      _percent(context, modality.proteinRatio, VTColors.macroProtein, .start),
                      _percent(context, modality.carbsRatio, VTColors.macroCarbs, .center),
                      _percent(context, modality.fatRatio, VTColors.macroFat, .end),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _percent(BuildContext context, double ratio, Color color, TextAlign align) => Expanded(
    child: Text(
      '${(ratio * 100).round()}%',
      textAlign: align,
      style: VTTextStyles.caption(context).copyWith(color: color, fontWeight: .w600),
    ),
  );
}
