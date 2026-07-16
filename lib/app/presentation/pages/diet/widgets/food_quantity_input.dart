import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_segmented_tabs.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_mode.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_units_equivalent.dart';

/// The quantity field shared by the log and edit sheets, plus the weight/units
/// switch above it. The switch appears only for a countable food
/// ([Food.isCountable]); for anything measured rather than counted this stays
/// exactly the plain weight field it has always been.
class FoodQuantityInput extends StatelessWidget {
  const FoodQuantityInput({
    required this.food,
    required this.controller,
    required this.mode,
    required this.onModeChanged,
    required this.unitSystem,
    this.autofocus = false,
    super.key,
  });

  final Food food;
  final TextEditingController controller;
  final FoodQuantityMode mode;
  final ValueChanged<FoodQuantityMode> onModeChanged;
  final UnitSystem unitSystem;
  final bool autofocus;

  String get _fieldUnitLabel => switch (mode) {
    .weight => unitSystem.weightUnitLabel,
    .units => 'un',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        if (food.isCountable) ...[
          VTSegmentedTabs<FoodQuantityMode>(
            tabs: [
              VTSegmentedTab(value: .weight, label: l10n.dietQuantityModeWeight, icon: Icons.scale_outlined),
              VTSegmentedTab(value: .units, label: l10n.dietQuantityModeUnits, icon: Icons.tag_outlined),
            ],
            selected: mode,
            onSelected: onModeChanged,
          ),
          const VTGap.m(),
        ],
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.dietQuantityLabel(_fieldUnitLabel)),
        ),
        if (mode == .units) FoodQuantityUnitsEquivalent(food: food, controller: controller, unitSystem: unitSystem),
      ],
    );
  }
}
