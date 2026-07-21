import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_search_field.dart';
import 'package:vitta/app/design_system/components/general/vt_segmented_tabs.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_cubit.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_extra.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_mode.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_presentation_event.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_state.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_tab.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/food_details_dialog.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/food_result_list.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/ingredient_quantity_sheet.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/log_food_sheet.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/meal_scan_action.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/recent_foods_list.dart';
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
          case AddFoodError(:final message):
            context.showErrorToast(message: message);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(
          title: Text(_isPicking ? l10n.dietPickIngredientTitle : l10n.dietFoodSearchTitle),
          actions: [
            if (!_isPicking)
              MealScanAction(
                date: loggedDate,
                onLogged: () {
                  context.showToast(title: l10n.mealScanLoggedTitle, message: l10n.mealScanLoggedMessage);
                  Navigator.of(context).pop();
                },
              ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: l10n.dietCustomFoodTitle,
              onPressed: () async {
                final food = await context.pushRoute<Food>(.customFood);
                if (food != null && context.mounted) {
                  await _addFood(context, food);
                }
              },
            ),
          ],
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
    cubit.logFood(food: entry.food, quantityGrams: entry.log.quantityGrams, mealType: initialMealType ?? entry.log.mealType, loggedDate: loggedDate);
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

  Widget _buildRecentTab(BuildContext context, AddFoodCubit cubit, AddFoodState state, AppLocalizations l10n) => Padding(
    key: const ValueKey(AddFoodTab.recent),
    padding: const EdgeInsets.only(top: VTSpacing.m),
    child: RecentFoodsList(
      entries: state.recentFoods,
      onOpenFood: (entry) => _addFood(context, entry.food),
      onQuickAdd: (entry) => _quickAdd(context, cubit, entry),
    ),
  );

  Widget _buildFavoritesTab(BuildContext context, AddFoodCubit cubit, AddFoodState state, AppLocalizations l10n) => Padding(
    key: const ValueKey(AddFoodTab.favorites),
    padding: const EdgeInsets.only(top: VTSpacing.m),
    child: state.favorites.isEmpty
        ? VTEmptyState(icon: Icons.favorite_border, title: l10n.dietFavoritesEmptyTitle, message: l10n.dietFavoritesEmptyMessage)
        : _buildList(context: context, cubit: cubit, state: state, foods: state.favorites, heroPrefix: 'food-favorite'),
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
