import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/general/food_image.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_input.dart';

Future<void> showEditFoodLogSheet({required BuildContext context, required FoodLogEntry entry}) => showModalBottomSheet<void>(
  context: context,
  routeSettings: VTBottomSheet.editFoodLog.settings,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(
    value: context.read<DietCubit>(),
    child: _EditFoodLogSheet(entry: entry),
  ),
);

class _EditFoodLogSheet extends StatefulWidget {
  const _EditFoodLogSheet({required this.entry});

  final FoodLogEntry entry;

  @override
  State<_EditFoodLogSheet> createState() => _EditFoodLogSheetState();
}

class _EditFoodLogSheetState extends State<_EditFoodLogSheet> {
  late final UnitSystem _unitSystem = context.read<DietCubit>().unitSystem;

  late final LoggedQuantity _initialQuantity = _seedQuantity();
  late LoggedQuantity? _quantity = _initialQuantity;
  late MealType _mealType = widget.entry.log.mealType;

  // The sheet opens in whatever measure the food is read in *now*, which is not
  // always how the log was typed: a food that has since lost its unit weight
  // would otherwise strand the sheet in a mode whose stepper isn't rendered, and
  // one that has since gained a density is better re-stated in mL than in the
  // grams nobody typed. The log's own recorded number is preferred wherever it
  // still applies, so an untouched edit saves back exactly what it showed.
  LoggedQuantity _seedQuantity() {
    final FoodLogEntry(:log, :food) = widget.entry;
    if (log.quantityUnits case final units? when food.isCountable) {
      return LoggedQuantity.units(units: units, grams: log.quantityGrams);
    }
    if (log.quantityMl case final milliliters? when food.isMeasuredByVolume) {
      return LoggedQuantity.volume(milliliters: milliliters, grams: log.quantityGrams);
    }
    return switch (food.densityGPerMl) {
      final density? => LoggedQuantity.volume(milliliters: log.quantityGrams / density, grams: log.quantityGrams),
      null => LoggedQuantity.weight(log.quantityGrams),
    };
  }

  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _submit() async {
    final l10n = context.l10n;
    final quantity = _quantity;
    if (quantity == null) {
      setState(() => _errorMessage = l10n.dietInvalidQuantity);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final updatedResult = await context.read<DietCubit>().updateLog(logId: widget.entry.log.id, mealType: _mealType, quantity: quantity);

    if (!mounted) {
      return;
    }
    updatedResult.when(
      (error) => setState(() {
        _isSaving = false;
        _errorMessage = error.message;
      }),
      (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: VTSpacing.m,
        right: VTSpacing.m,
        top: VTSpacing.m,
        bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              FoodImage(food: widget.entry.food),
              const VTGap.m(),
              Expanded(child: Text(widget.entry.food.name, style: VTTextStyles.title(context))),
            ],
          ),
          const VTGap.m(),
          FoodQuantityInput(
            food: widget.entry.food,
            unitSystem: _unitSystem,
            initialQuantity: _initialQuantity,
            autofocus: true,
            onChanged: (quantity) => _quantity = quantity,
          ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.s,
            children: [
              for (final mealType in MealType.values)
                ChoiceChip(
                  label: Text(mealType.getLabel(l10n)),
                  selected: _mealType == mealType,
                  onSelected: (_) => setState(() => _mealType = mealType),
                ),
            ],
          ),
          if (_errorMessage case final errorMessage?) ...[
            const VTGap.s(),
            Text(errorMessage, style: TextStyle(color: context.colorScheme.error)),
          ],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.saveAction, isLoading: _isSaving, onPressed: _submit),
        ],
      ),
    );
  }
}
