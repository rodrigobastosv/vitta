import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';

class RecipeFormState extends Equatable {
  const RecipeFormState({this.draft = const RecipeDraft(), this.imageBytes, this.imageExtension = ''});

  final RecipeDraft draft;
  final Uint8List? imageBytes;
  final String imageExtension;

  RecipeFormState copyWith({RecipeDraft? draft, Uint8List? imageBytes, String? imageExtension}) => RecipeFormState(
    draft: draft ?? this.draft,
    imageBytes: imageBytes ?? this.imageBytes,
    imageExtension: imageExtension ?? this.imageExtension,
  );

  @override
  List<Object?> get props => [draft, imageBytes, imageExtension];
}
