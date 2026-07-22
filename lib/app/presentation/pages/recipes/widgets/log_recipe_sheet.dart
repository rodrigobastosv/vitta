import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_input.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_selection.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_cubit.dart';

Future<void> showLogRecipeSheet({required BuildContext context, required Recipe recipe, required DateTime loggedDate}) => showModalBottomSheet<void>(
  context: context,
  routeSettings: VTBottomSheet.logRecipe.settings,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(value: context.read<RecipesCubit>(), child: _LogRecipeSheet(recipe: recipe, loggedDate: loggedDate)),
);

class _LogRecipeSheet extends StatefulWidget {
  const _LogRecipeSheet({required this.recipe, required this.loggedDate});

  final Recipe recipe;
  final DateTime loggedDate;

  @override
  State<_LogRecipeSheet> createState() => _LogRecipeSheetState();
}

class _LogRecipeSheetState extends State<_LogRecipeSheet> {
  late final UnitSystem _unitSystem = context.read<RecipesCubit>().unitSystem;
  late final double _initialGrams = widget.recipe.totalGrams;
  late FoodQuantitySelection _selection = FoodQuantitySelection(quantityGrams: _initialGrams);
  MealType _mealType = .breakfast;
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _submit() async {
    final l10n = context.l10n;
    final selection = _selection;
    if (!selection.isValid) {
      setState(() => _errorMessage = l10n.dietInvalidQuantity);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final loggedResult = await context.read<RecipesCubit>().logRecipe(
      recipeFood: widget.recipe.food,
      loggedDate: widget.loggedDate,
      mealType: _mealType,
      quantityGrams: selection.quantityGrams!,
    );

    if (!mounted) {
      return;
    }
    loggedResult.when(
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
      padding: EdgeInsets.only(left: VTSpacing.m, right: VTSpacing.m, top: VTSpacing.m, bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(widget.recipe.food.name, style: VTTextStyles.title(context)),
          const VTGap.m(),
          FoodQuantityInput(
            food: widget.recipe.food,
            unitSystem: _unitSystem,
            initialGrams: _initialGrams,
            onChanged: (selection) => _selection = selection,
          ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.s,
            children: [
              for (final mealType in MealType.values)
                ChoiceChip(label: Text(mealType.getLabel(l10n)), selected: _mealType == mealType, onSelected: (_) => setState(() => _mealType = mealType)),
            ],
          ),
          if (_errorMessage case final errorMessage?) ...[const VTGap.s(), Text(errorMessage, style: TextStyle(color: Theme.of(context).colorScheme.error))],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.dietRecipeAddToMealAction, isLoading: _isSaving, onPressed: _submit),
        ],
      ),
    );
  }
}
