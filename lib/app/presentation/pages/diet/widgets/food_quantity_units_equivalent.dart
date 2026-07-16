import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/text/quantity_format.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_mode.dart';

class FoodQuantityUnitsEquivalent extends StatelessWidget {
  const FoodQuantityUnitsEquivalent({required this.food, required this.controller, required this.unitSystem, super.key});

  final Food food;
  final TextEditingController controller;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        final units = double.tryParse(value.text.replaceAll(',', '.'));
        final grams = units == null ? null : FoodQuantityMode.units.gramsFor(value: units, food: food, unitSystem: unitSystem);
        if (units == null || units <= 0 || grams == null) {
          return const SizedBox.shrink();
        }
        final weight = '${QuantityFormat.format(unitSystem.gramsToDisplayWeight(grams))} ${unitSystem.weightUnitLabel}';
        return Padding(
          padding: const EdgeInsets.only(top: VTSpacing.xs),
          child: Text(
            l10n.dietQuantityUnitsHint(QuantityFormat.format(units), weight),
            style: VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        );
      },
    );
  }
}
