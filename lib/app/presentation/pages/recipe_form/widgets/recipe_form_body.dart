import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_cubit.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_state.dart';
import 'package:vitta/app/presentation/pages/recipe_form/widgets/recipe_ingredient_tile.dart';
import 'package:vitta/app/presentation/pages/recipe_form/widgets/recipe_totals_card.dart';

class RecipeFormBody extends StatefulWidget {
  const RecipeFormBody({required this.state, super.key});

  final RecipeFormState state;

  @override
  State<RecipeFormBody> createState() => _RecipeFormBodyState();
}

class _RecipeFormBodyState extends State<RecipeFormBody> {
  late final _nameController = TextEditingController(text: widget.state.draft.name);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addIngredient() async {
    final cubit = context.read<RecipeFormCubit>();
    final ingredient = await context.pushRoute<RecipeIngredient>(.ingredientPicker, extra: cubit.unitSystem);
    if (ingredient != null) {
      cubit.addIngredient(ingredient);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<RecipeFormCubit>();
    final draft = widget.state.draft;
    return Padding(
      padding: const EdgeInsets.all(VTSpacing.m),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          VTAppearEffect(
            child: Text(
              cubit.isEditing ? l10n.dietEditRecipeTitle : l10n.dietRecipeSubtitle,
              style: cubit.isEditing ? VTTextStyles.title(context) : VTTextStyles.caption(context),
            ),
          ),
          const VTGap.m(),
          VTAppearEffect(
            delay: const Duration(milliseconds: 50),
            child: TextField(
              controller: _nameController,
              onChanged: cubit.nameChanged,
              textCapitalization: .sentences,
              decoration: InputDecoration(labelText: l10n.dietRecipeNameLabel, hintText: l10n.dietRecipeNameHint),
            ),
          ),
          const VTGap.l(),
          VTAppearEffect(
            delay: const Duration(milliseconds: 100),
            child: Text(l10n.dietRecipeIngredientsTitle, style: VTTextStyles.title(context)),
          ),
          const VTGap.m(),
          if (draft.ingredients.isEmpty)
            Text(l10n.dietRecipeNoIngredientsMessage, style: VTTextStyles.caption(context))
          else
            VTCard(
              child: Column(
                children: [
                  for (final (index, ingredient) in draft.ingredients.indexed) ...[
                    RecipeIngredientTile(ingredient: ingredient, onRemove: () => cubit.removeIngredientAt(index)),
                    if (index != draft.ingredients.length - 1) const VTGap.s(),
                  ],
                ],
              ),
            ),
          const VTGap.m(),
          Align(
            alignment: .centerLeft,
            child: TextButton.icon(onPressed: _addIngredient, icon: const Icon(Icons.add), label: Text(l10n.dietRecipeAddIngredientAction)),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: .topCenter,
            child: draft.ingredients.isEmpty
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: VTSpacing.m),
                    child: RecipeTotalsCard(draft: draft),
                  ),
          ),
        ],
      ),
    );
  }
}
