import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/use_cases/add_recent_search_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/clear_recent_searches_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/favorite_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_favorite_foods_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_recent_searches_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/remove_recent_search_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/unfavorite_food_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_state.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_tab.dart';

class FoodSearchCubit extends PresentationCubit<FoodSearchState, FoodSearchPresentationEvent> {
  FoodSearchCubit({
    required this._searchFoodsUseCase,
    required this._logFoodUseCase,
    required this._getAppSettingsUseCase,
    required this._getFavoriteFoodsUseCase,
    required this._favoriteFoodUseCase,
    required this._unfavoriteFoodUseCase,
    required this._getRecentSearchesUseCase,
    required this._addRecentSearchUseCase,
    required this._removeRecentSearchUseCase,
    required this._clearRecentSearchesUseCase,
  }) : super(const FoodSearchState());

  final SearchFoodsUseCase _searchFoodsUseCase;
  final LogFoodUseCase _logFoodUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;
  final GetFavoriteFoodsUseCase _getFavoriteFoodsUseCase;
  final FavoriteFoodUseCase _favoriteFoodUseCase;
  final UnfavoriteFoodUseCase _unfavoriteFoodUseCase;
  final GetRecentSearchesUseCase _getRecentSearchesUseCase;
  final AddRecentSearchUseCase _addRecentSearchUseCase;
  final RemoveRecentSearchUseCase _removeRecentSearchUseCase;
  final ClearRecentSearchesUseCase _clearRecentSearchesUseCase;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  static bool _sameFood(Food a, Food b) => a.id == null || b.id == null ? a == b : a.id == b.id;

  @override
  void onInit() {
    emit(state.copyWith(recentSearches: _getRecentSearchesUseCase()));
    loadFavorites();
  }

  void changeTab(FoodSearchTab tab) => emit(state.copyWith(tab: tab));

  Future<void> loadFavorites() async {
    emitPresentation(FoodSearchShowLoading());
    final favoritesResult = await _getFavoriteFoodsUseCase();
    emitPresentation(FoodSearchHideLoading());
    favoritesResult.when(
      (error) => emitPresentation(FoodSearchError(message: error.message)),
      (favorites) => emit(state.copyWith(favorites: favorites)),
    );
  }

  Future<void> search({required String query}) async {
    if (query.trim().isEmpty) {
      emit(FoodSearchState(favorites: state.favorites, recentSearches: state.recentSearches, tab: state.tab));
      return;
    }
    emitPresentation(FoodSearchShowLoading());
    final foodsResult = await _searchFoodsUseCase(query: query);
    emitPresentation(FoodSearchHideLoading());
    final foods = foodsResult.when((_) => null, (value) => value);
    if (foods == null) {
      emitPresentation(FoodSearchError(message: foodsResult.when((error) => error.message, (_) => '')));
      return;
    }
    emit(state.copyWith(results: foods, query: query));
    if (foods.isEmpty) {
      return;
    }
    emit(state.copyWith(recentSearches: await _addRecentSearchUseCase(query: query)));
  }

  Future<void> removeRecentSearch({required String query}) async =>
      emit(state.copyWith(recentSearches: await _removeRecentSearchUseCase(query: query)));

  Future<void> clearRecentSearches() async => emit(state.copyWith(recentSearches: await _clearRecentSearchesUseCase()));

  Future<void> toggleFavorite({required Food food}) {
    final previousFavorites = state.favorites;
    final wasFavorite = state.isFavorite(food);
    emit(
      state.copyWith(
        favorites: wasFavorite
            ? [
                for (final favorite in previousFavorites)
                  if (!_sameFood(favorite, food)) favorite,
              ]
            : [food, ...previousFavorites],
      ),
    );
    return wasFavorite ? _unfavorite(food, previousFavorites) : _favorite(food, previousFavorites);
  }

  Future<void> _favorite(Food food, List<Food> previousFavorites) async {
    final favoritedResult = await _favoriteFoodUseCase(food: food);
    final savedFood = favoritedResult.when((_) => null, (value) => value);
    if (savedFood == null) {
      _revert(previousFavorites, favoritedResult.when((error) => error.message, (_) => ''));
      return;
    }
    Log.action('food_favorited', data: {'food': savedFood.name});
    if (!state.favorites.any((favorite) => _sameFood(favorite, food))) {
      await _unfavoriteFoodUseCase(foodId: savedFood.id!);
      return;
    }
    emit(
      state.copyWith(
        results: _replaceInResults(food, savedFood),
        favorites: [
          for (final favorite in state.favorites)
            if (_sameFood(favorite, food)) savedFood else favorite,
        ],
      ),
    );
  }

  Future<void> _unfavorite(Food food, List<Food> previousFavorites) async {
    final foodId = food.id;
    if (foodId == null) {
      return;
    }
    final unfavoritedResult = await _unfavoriteFoodUseCase(foodId: foodId);
    final error = unfavoritedResult.when((error) => error, (_) => null);
    if (error != null) {
      _revert(previousFavorites, error.message);
      return;
    }
    Log.action('food_unfavorited', data: {'food': food.name});
  }

  void _revert(List<Food> previousFavorites, String message) {
    emit(state.copyWith(favorites: previousFavorites));
    emitPresentation(FoodSearchError(message: message));
  }

  List<Food>? _replaceInResults(Food food, Food savedFood) {
    final results = state.results;
    if (results == null) {
      return null;
    }
    return [
      for (final result in results)
        if (_sameFood(result, food)) savedFood else result,
    ];
  }

  Future<Result<VTError, FoodLog>> logFood({
    required Food food,
    required DateTime loggedDate,
    required MealType mealType,
    required double quantityGrams,
    double? quantityUnits,
  }) async {
    final loggedResult = await _logFoodUseCase(
      food: food,
      loggedDate: DateTime(loggedDate.year, loggedDate.month, loggedDate.day),
      mealType: mealType,
      quantityGrams: quantityGrams,
      quantityUnits: quantityUnits,
    );
    loggedResult.when((_) {}, (_) {
      Log.action('food_logged', data: {'food': food.name, 'meal': mealType.wireValue});
      emitPresentation(FoodLogged(foodName: food.name, mealType: mealType));
    });
    return loggedResult;
  }
}
