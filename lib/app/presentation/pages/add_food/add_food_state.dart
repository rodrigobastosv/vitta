import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/recent_meal.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_tab.dart';

class AddFoodState extends Equatable {
  const AddFoodState({
    this.results,
    this.favorites = const [],
    this.myFoods = const [],
    this.myRecipes = const [],
    this.recentSearches = const [],
    this.recentFoods = const [],
    this.recentMeals = const [],
    this.query = '',
    this.tab = AddFoodTab.search,
  });

  final List<Food>? results;

  final List<Food> favorites;

  final List<Food> myFoods;

  final List<Food> myRecipes;

  final List<String> recentSearches;

  final List<FoodLogEntry> recentFoods;

  final List<RecentMeal> recentMeals;

  final String query;

  final AddFoodTab tab;

  Set<String> get favoriteFoodIds => {for (final food in favorites) ?food.id};

  bool isFavorite(Food food) => food.id == null ? favorites.contains(food) : favoriteFoodIds.contains(food.id);

  AddFoodState copyWith({
    List<Food>? results,
    List<Food>? favorites,
    List<Food>? myFoods,
    List<Food>? myRecipes,
    List<String>? recentSearches,
    List<FoodLogEntry>? recentFoods,
    List<RecentMeal>? recentMeals,
    String? query,
    AddFoodTab? tab,
  }) => AddFoodState(
    results: results ?? this.results,
    favorites: favorites ?? this.favorites,
    myFoods: myFoods ?? this.myFoods,
    myRecipes: myRecipes ?? this.myRecipes,
    recentSearches: recentSearches ?? this.recentSearches,
    recentFoods: recentFoods ?? this.recentFoods,
    recentMeals: recentMeals ?? this.recentMeals,
    query: query ?? this.query,
    tab: tab ?? this.tab,
  );

  @override
  List<Object?> get props => [results, favorites, myFoods, myRecipes, recentSearches, recentFoods, recentMeals, query, tab];
}
