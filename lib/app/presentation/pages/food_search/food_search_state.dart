import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

sealed class FoodSearchState extends Equatable {
  const FoodSearchState();

  @override
  List<Object?> get props => [];
}

class FoodSearchIdle extends FoodSearchState {
  const FoodSearchIdle();
}

class FoodSearchLoaded extends FoodSearchState {
  const FoodSearchLoaded({required this.results});

  final List<Food> results;

  @override
  List<Object?> get props => [results];
}

class FoodSearchError extends FoodSearchState {
  const FoodSearchError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
