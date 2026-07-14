import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class MacroPill extends StatelessWidget {
  const MacroPill({required this.label, required this.grams, required this.color, super.key});

  final String label;
  final double grams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: VTRadius.borderRadiusFull),
      child: Text(
        '$label ${l10n.dietMacroGrams(_formatGrams(grams))}',
        style: VTTextStyles.caption(context).copyWith(color: color, fontWeight: .w700),
      ),
    );
  }

  static String _formatGrams(double value) {
    final rounded = double.parse(value.toStringAsFixed(1));
    return rounded == rounded.roundToDouble() ? rounded.toInt().toString() : rounded.toString();
  }
}
