import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/nutrient_label.dart';

class MicronutrientRow extends StatelessWidget {
  const MicronutrientRow({required this.nutrient, required this.gramsPer100g, super.key});

  final Nutrient nutrient;
  final double gramsPer100g;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(nutrientLabel(l10n, nutrient), style: VTTextStyles.body(context)),
        Text(
          l10n.dietMicronutrientAmount(_formatAmount(nutrient.unit.fromGrams(gramsPer100g)), nutrient.unit.symbol),
          style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  static String _formatAmount(double value) {
    final rounded = double.parse(value.toStringAsFixed(1));
    return rounded == rounded.roundToDouble() ? rounded.toInt().toString() : rounded.toString();
  }
}
