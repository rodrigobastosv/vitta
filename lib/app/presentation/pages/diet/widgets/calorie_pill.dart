import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class CaloriePill extends StatelessWidget {
  const CaloriePill({required this.calories, required this.color, super.key});

  final int calories;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: VTRadius.borderRadiusFull),
      child: Text(
        l10n.dietMealCalories(calories),
        style: VTTextStyles.caption(context).copyWith(color: color, fontWeight: .w700),
      ),
    );
  }
}
