import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/meal_type_label.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> showLogFoodSheet({required BuildContext context, required Food food}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(value: context.read<FoodSearchCubit>(), child: _LogFoodSheet(food: food)),
);

class _LogFoodSheet extends StatefulWidget {
  const _LogFoodSheet({required this.food});

  final Food food;

  @override
  State<_LogFoodSheet> createState() => _LogFoodSheetState();
}

class _LogFoodSheetState extends State<_LogFoodSheet> {
  final _quantityController = TextEditingController(text: '100');
  MealType _mealType = MealType.breakfast;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final quantityGrams = double.tryParse(_quantityController.text.replaceAll(',', '.'));
    final l10n = AppLocalizations.of(context);
    if (quantityGrams == null || quantityGrams <= 0) {
      setState(() => _errorMessage = l10n.dietInvalidQuantity);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final logged = await context.read<FoodSearchCubit>().logFood(
      food: widget.food,
      mealType: _mealType,
      quantityGrams: quantityGrams,
    );

    if (!mounted) {
      return;
    }
    switch (logged) {
      case Failure(:final error):
        setState(() {
          _isSaving = false;
          _errorMessage = error.message;
        });
      case Success():
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Text(widget.food.name, style: VTTextStyles.title(context)),
          const VTGap.m(),
          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.dietQuantityGramsLabel),
          ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.s,
            children: [
              for (final mealType in MealType.values)
                ChoiceChip(
                  label: Text(mealTypeLabel(l10n, mealType)),
                  selected: _mealType == mealType,
                  onSelected: (_) => setState(() => _mealType = mealType),
                ),
            ],
          ),
          if (_errorMessage != null) ...[const VTGap.s(), Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.dietLogFoodAction, isLoading: _isSaving, onPressed: _submit),
        ],
      ),
    );
  }
}
