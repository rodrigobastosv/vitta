import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_image_source_sheet.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_cubit.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_nutrient.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_state.dart';
import 'package:vitta/app/presentation/pages/custom_food/widgets/custom_food_energy_split_card.dart';
import 'package:vitta/app/presentation/pages/custom_food/widgets/custom_food_nutrient_field.dart';
import 'package:vitta/app/presentation/pages/custom_food/widgets/custom_food_scan_card.dart';
import 'package:vitta/app/presentation/pages/premium/paywall_extra.dart';

class CustomFoodForm extends StatefulWidget {
  const CustomFoodForm({required this.state, super.key});

  final CustomFoodState state;

  @override
  State<CustomFoodForm> createState() => _CustomFoodFormState();
}

class _CustomFoodFormState extends State<CustomFoodForm> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _gramsPerUnitController = TextEditingController();
  final _nutrientControllers = {for (final nutrient in CustomFoodNutrient.values) nutrient: TextEditingController()};

  @override
  void didUpdateWidget(CustomFoodForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final entry in _nutrientControllers.entries) {
      _syncNutrientController(controller: entry.value, value: widget.state.nutrients[entry.key]);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _gramsPerUnitController.dispose();
    for (final controller in _nutrientControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncNutrientController({required TextEditingController controller, required double? value}) {
    if (double.tryParse(controller.text.replaceAll(',', '.')) == value) {
      return;
    }
    controller.text = value == null ? '' : _formatNutrient(value);
  }

  String _formatNutrient(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();

  Future<void> _scanNutritionLabel() async {
    if (!context.read<PremiumCubit>().state.isPremium) {
      await context.pushRoute(.premium, extra: const PaywallExtra(highlightedFeature: .nutritionLabelScan));
      return;
    }
    final source = await showImageSourceSheet(context: context);
    if (source == null || !mounted) {
      return;
    }
    await context.read<CustomFoodCubit>().scanNutritionLabel(source: source);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<CustomFoodCubit>();
    final state = widget.state;
    return Padding(
      padding: const EdgeInsets.all(VTSpacing.m),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          VTAppearEffect(child: Text(l10n.dietCustomFoodSubtitle, style: VTTextStyles.caption(context))),
          const VTGap.m(),
          VTAppearEffect(
            delay: const Duration(milliseconds: 50),
            child: TextField(
              controller: _nameController,
              onChanged: cubit.nameChanged,
              textInputAction: .next,
              textCapitalization: .sentences,
              decoration: InputDecoration(labelText: l10n.dietFoodNameLabel, hintText: l10n.dietFoodNameHint),
            ),
          ),
          const VTGap.s(),
          VTAppearEffect(
            delay: const Duration(milliseconds: 75),
            child: TextField(
              controller: _brandController,
              onChanged: cubit.brandChanged,
              textInputAction: .next,
              textCapitalization: .words,
              decoration: InputDecoration(labelText: l10n.dietBrandLabel, hintText: l10n.dietBrandHint),
            ),
          ),
          const VTGap.s(),
          VTAppearEffect(
            delay: const Duration(milliseconds: 85),
            child: TextField(
              controller: _gramsPerUnitController,
              onChanged: cubit.gramsPerUnitChanged,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.dietGramsPerUnitLabel, helperText: l10n.dietGramsPerUnitHint, helperMaxLines: 2),
            ),
          ),
          const VTGap.m(),
          VTAppearEffect(
            delay: const Duration(milliseconds: 100),
            child: CustomFoodScanCard(
              onTap: _scanNutritionLabel,
              isLocked: !context.watch<PremiumCubit>().state.isPremium,
            ),
          ),
          const VTGap.l(),
          VTAppearEffect(
            delay: const Duration(milliseconds: 150),
            child: Text(l10n.dietNutritionPer100gTitle, style: VTTextStyles.title(context)),
          ),
          const VTGap.m(),
          for (final (index, nutrient) in CustomFoodNutrient.values.indexed) ...[
            VTAppearEffect(
              delay: Duration(milliseconds: 200 + index * 50),
              child: CustomFoodNutrientField(
                nutrient: nutrient,
                controller: _nutrientControllers[nutrient]!,
                onChanged: (text) => cubit.nutrientChanged(nutrient: nutrient, text: text),
              ),
            ),
            const VTGap.s(),
          ],
          const VTGap.s(),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: .topCenter,
            child: CustomFoodEnergySplitCard.hasSplit(state.nutrients)
                ? CustomFoodEnergySplitCard(nutrients: state.nutrients)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
