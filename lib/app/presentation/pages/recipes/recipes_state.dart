import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';

class RecipesState extends Equatable {
  const RecipesState({this.recipes = const [], this.isLoaded = true});

  final List<Recipe> recipes;
  final bool isLoaded;

  RecipesState copyWith({List<Recipe>? recipes, bool? isLoaded}) => RecipesState(isLoaded: isLoaded ?? this.isLoaded, recipes: recipes ?? this.recipes);

  @override
  List<Object?> get props => [isLoaded, recipes];
}
