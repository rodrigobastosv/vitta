import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_nutrient.dart';

class CustomFoodNutrientField extends StatelessWidget {
  const CustomFoodNutrientField({required this.nutrient, required this.controller, required this.onChanged, super.key});

  final CustomFoodNutrient nutrient;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = nutrient.getColor(context.colorScheme);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: .next,
      decoration: InputDecoration(
        labelText: nutrient.getLabel(l10n),
        suffixText: nutrient.getUnitLabel(l10n),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
          child: Center(
            widthFactor: 1,
            child: Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: .circle)),
          ),
        ),
        focusedBorder: OutlineInputBorder(borderRadius: VTRadius.borderRadiusM, borderSide: BorderSide(color: color, width: 2)),
      ),
    );
  }
}
