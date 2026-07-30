import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_search_field.dart';
import 'package:vitta/app/design_system/components/general/vt_segmented_tabs.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_cubit.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_extra.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_mode.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_presentation_event.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_state.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_tab.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/add_food_action_bar.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/food_details_dialog.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/food_result_list.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/ingredient_quantity_sheet.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/log_food_sheet.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/recent_food_tile.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/recent_meals_list.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/recent_searches_list.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class AddFoodPage extends StatelessWidget {
  const AddFoodPage({required this.extra, super.key});

  final AddFoodExtra extra;

  bool get _isPicking => extra.mode == AddFoodMode.pickIngredient;

  DateTime get loggedDate => extra.loggedDate ?? DateTime.now();
  MealType? get initialMealType => extra.initialMealType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<AddFoodCubit, AddFoodState, AddFoodPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case AddFoodShowLoading():
            context.showLoading();
          case AddFoodHideLoading():
            context.hideLoading();
          case FoodLogged(:final foodName, :final mealType):
            context.showToast(title: foodName, message: l10n.dietFoodLoggedToast(mealType.getLabel(l10n)));
          case MealLogged(:final mealType, :final foodCount):
            context.showToast(title: mealType.getLabel(l10n), message: l10n.dietMealLoggedToast(foodCount, mealType.getLabel(l10n)));
          case AddFoodError():
            context.showErrorToast();
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(_isPicking ? l10n.dietPickIngredientTitle : l10n.dietFoodSearchTitle)),
        // Picking an ingredient for a recipe has no use for any of these: a
        // photographed plate, a suggested meal and a brand-new custom food are
        // all ways to add food to a *day*.
        bottomNavigationBar: _isPicking
            ? null
            : AddFoodActionBar(
                date: loggedDate,
                onLogged: () {
                  context.showToast(title: l10n.mealScanLoggedTitle, message: l10n.mealScanLoggedMessage);
                  Navigator.of(context).pop();
                },
                onFoodCreated: (food) => _addFood(context, food),
              ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.l),
              child: VTSegmentedTabs<AddFoodTab>(
                selected: state.tab,
                onSelected: cubit.changeTab,
                tabs: [for (final tab in AddFoodTab.values) VTSegmentedTab(value: tab, label: tab.getLabel(l10n))],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: VTMotion.transition,
                switchInCurve: VTMotion.curve,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                child: switch (state.tab) {
                  AddFoodTab.search => _buildSearchTab(context, cubit, state, l10n),
                  AddFoodTab.recent => _buildRecentTab(context, cubit, state, l10n),
                  AddFoodTab.favorites => _buildFavoritesTab(context, cubit, state, l10n),
                  AddFoodTab.myFoods => _buildMyFoodsTab(context, cubit, state, l10n),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _quickAdd(BuildContext context, AddFoodCubit cubit, FoodLogEntry entry) {
    if (_isPicking) {
      Navigator.of(context).pop(RecipeIngredient(food: entry.food, quantityGrams: entry.log.quantityGrams));
      return;
    }
    cubit.logFood(
      food: entry.food,
      quantity: LoggedQuantity.fromLog(entry.log),
      mealType: initialMealType ?? entry.log.mealType,
      loggedDate: loggedDate,
    );
  }

  Future<void> _addFood(BuildContext context, Food food) async {
    if (!_isPicking) {
      await showLogFoodSheet(context: context, food: food, loggedDate: loggedDate, initialMealType: initialMealType);
      return;
    }
    final ingredient = await showIngredientQuantitySheet(context: context, food: food, unitSystem: extra.unitSystem!);
    if (ingredient != null && context.mounted) {
      Navigator.of(context).pop(ingredient);
    }
  }

  Widget _buildSearchTab(BuildContext context, AddFoodCubit cubit, AddFoodState state, AppLocalizations l10n) => Column(
    key: const ValueKey(AddFoodTab.search),
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.m, VTSpacing.m, VTSpacing.m),
        child: VTSearchField(
          autofocus: true,
          text: state.query,
          hintText: l10n.dietSearchFieldLabel,
          onChanged: cubit.queryChanged,
          onSubmitted: (query) => cubit.search(query: query),
        ),
      ),
      Expanded(
        child: switch (state.results) {
          null when state.recentSearches.isEmpty => VTEmptyState(icon: Icons.search, message: l10n.dietSearchPrompt),
          null => RecentSearchesList(
            queries: state.recentSearches,
            onSelect: (query) => cubit.search(query: query),
            onRemove: (query) => cubit.removeRecentSearch(query: query),
            onClear: cubit.clearRecentSearches,
          ),
          final results when results.isEmpty => VTEmptyState.noResults(message: l10n.dietSearchNoResults),
          final results => _buildList(context: context, cubit: cubit, state: state, foods: results, heroPrefix: 'food-search'),
        },
      ),
    ],
  );

  // Foods first, then whole meals: a single food is the finer-grained answer and
  // the one most taps are after, while re-logging a whole breakfast is the
  // shortcut worth scrolling to.
  Widget _buildRecentTab(BuildContext context, AddFoodCubit cubit, AddFoodState state, AppLocalizations l10n) => Padding(
    key: const ValueKey(AddFoodTab.recent),
    padding: const EdgeInsets.only(top: VTSpacing.m),
    child: state.recentFoods.isEmpty && (_isPicking || state.recentMeals.isEmpty)
        ? VTEmptyState(icon: Icons.history, title: l10n.dietRecentEmptyTitle, message: l10n.dietRecentEmptyMessage)
        : ListView(
            padding: const EdgeInsets.only(bottom: VTSpacing.xxl),
            children: [
              for (final (index, entry) in state.recentFoods.indexed) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
                  child: VTAppearEffect(
                    index: index,
                    child: RecentFoodTile(entry: entry, onTap: () => _addFood(context, entry.food), onQuickAdd: () => _quickAdd(context, cubit, entry)),
                  ),
                ),
                const VTGap.s(),
              ],
              // A whole meal cannot stand in for one recipe ingredient, so the
              // section is search-and-log only.
              if (!_isPicking && state.recentMeals.isNotEmpty) ...[
                const VTGap.m(),
                RecentMealsList(
                  title: l10n.dietRecentMealsTitle,
                  meals: state.recentMeals,
                  onLogAgain: (meal) => cubit.logMeal(meal: meal, loggedDate: loggedDate),
                ),
              ],
            ],
          ),
  );

  Widget _buildFavoritesTab(BuildContext context, AddFoodCubit cubit, AddFoodState state, AppLocalizations l10n) => Padding(
    key: const ValueKey(AddFoodTab.favorites),
    padding: const EdgeInsets.only(top: VTSpacing.m),
    child: state.favorites.isEmpty
        ? VTEmptyState(icon: Icons.favorite_border, title: l10n.dietFavoritesEmptyTitle, message: l10n.dietFavoritesEmptyMessage)
        : _buildList(context: context, cubit: cubit, state: state, foods: state.favorites, heroPrefix: 'food-favorite'),
  );

  Widget _buildMyFoodsTab(BuildContext context, AddFoodCubit cubit, AddFoodState state, AppLocalizations l10n) => Padding(
    key: const ValueKey(AddFoodTab.myFoods),
    padding: const EdgeInsets.only(top: VTSpacing.m),
    child: state.myFoods.isEmpty
        ? VTEmptyState(
            icon: Icons.inventory_2_outlined,
            title: l10n.dietMyFoodsEmptyTitle,
            message: l10n.dietMyFoodsEmptyMessage,
          )
        : _buildList(context: context, cubit: cubit, state: state, foods: state.myFoods, heroPrefix: 'food-mine'),
  );

  Widget _buildList({
    required BuildContext context,
    required AddFoodCubit cubit,
    required AddFoodState state,
    required List<Food> foods,
    required String heroPrefix,
  }) => FoodResultList(
    foods: foods,
    heroPrefix: heroPrefix,
    isFavorite: state.isFavorite,
    onTapFood: (food, heroTag) => showFoodDetailsDialog(context: context, food: food, heroTag: heroTag),
    onAddFood: (food) => _addFood(context, food),
    onToggleFavorite: (food) => cubit.toggleFavorite(food: food),
  );
}
