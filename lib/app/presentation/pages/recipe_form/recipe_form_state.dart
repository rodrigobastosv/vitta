import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';

class RecipeFormState extends Equatable {
  const RecipeFormState({this.draft = const RecipeDraft()});

  final RecipeDraft draft;

  RecipeFormState copyWith({RecipeDraft? draft}) => RecipeFormState(draft: draft ?? this.draft);

  @override
  List<Object?> get props => [draft];
}
