import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_extra.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_cubit.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_presentation_event.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_state.dart';
import 'package:vitta/app/presentation/pages/recipes/widgets/recipe_tile.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<RecipesCubit, RecipesState, RecipesPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case RecipesShowLoading():
            context.showLoading();
          case RecipesHideLoading():
            context.hideLoading();
          case RecipesError(:final message):
            context.showErrorToast(message: message, onRetry: context.read<RecipesCubit>().loadRecipes);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.dietRecipesTitle)),
        body: state.recipes.isEmpty
            ? VTEmptyState(icon: Icons.menu_book_outlined, title: l10n.dietRecipesEmptyTitle, message: l10n.dietRecipesEmptyMessage)
            : ListView(
                padding: const EdgeInsets.all(VTSpacing.m),
                children: [
                  Text(l10n.dietRecipeLogHint, style: VTTextStyles.caption(context)),
                  const VTGap.m(),
                  for (final (index, recipe) in state.recipes.indexed) ...[
                    VTAppearEffect(
                      key: ValueKey(recipe.id),
                      delay: Duration(milliseconds: index.clamp(0, 10) * 60),
                      child: RecipeTile(
                        recipe: recipe,
                        onEdit: () => _openForm(context, cubit, recipe: recipe),
                        onDelete: () => cubit.deleteRecipe(recipeId: recipe.id),
                      ),
                    ),
                    const VTGap.m(),
                  ],
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(context, cubit),
          icon: const Icon(Icons.add),
          label: Text(l10n.dietCreateRecipeTitle),
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, RecipesCubit cubit, {Recipe? recipe}) async {
    final saved = await context.pushRoute<bool>(.recipeForm, extra: RecipeFormExtra(recipe: recipe));
    if (saved ?? false) {
      await cubit.loadRecipes();
    }
  }
}
