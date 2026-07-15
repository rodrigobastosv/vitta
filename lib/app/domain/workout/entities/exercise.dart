import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/equipment.dart';
import 'package:vitta/app/domain/workout/entities/exercise_category.dart';
import 'package:vitta/app/domain/workout/entities/exercise_level.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.names,
    required this.category,
    required this.level,
    this.instructions = const {},
    this.equipment,
    this.primaryMuscles = const [],
    this.secondaryMuscles = const [],
    this.imageUrls = const [],
    this.timesLogged = 0,
  });

  factory Exercise.fromMap(Map<String, dynamic> row) => Exercise(
    id: row['id'] as String,
    names: _namesFromMap(row['names']),
    instructions: _instructionsFromMap(row['instructions']),
    category: ExerciseCategory.fromWireValue(row['category'] as String),
    level: ExerciseLevel.fromWireValue(row['level'] as String),
    equipment: switch (row['equipment']) {
      final String value => Equipment.fromWireValue(value),
      _ => null,
    },
    primaryMuscles: _musclesFromList(row['primary_muscles']),
    secondaryMuscles: _musclesFromList(row['secondary_muscles']),
    imageUrls: switch (row['image_urls']) {
      final List<dynamic> urls => urls.cast<String>(),
      _ => const [],
    },
    timesLogged: (row['times_logged'] as num?)?.toInt() ?? 0,
  );

  static Map<String, String> _namesFromMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return const {};
    }
    return {
      for (final MapEntry(:key, :value) in raw.entries)
        if (value is String) key: value,
    };
  }

  static Map<String, List<String>> _instructionsFromMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return const {};
    }
    return {
      for (final MapEntry(:key, :value) in raw.entries)
        if (value is List<dynamic>) key: value.whereType<String>().toList(),
    };
  }

  static List<MuscleGroup> _musclesFromList(dynamic raw) {
    if (raw is! List<dynamic>) {
      return const [];
    }
    return raw.whereType<String>().map(MuscleGroup.fromWireValue).nonNulls.toList();
  }

  static const fallbackLocale = 'en';

  final String id;
  final Map<String, String> names;
  final Map<String, List<String>> instructions;
  final ExerciseCategory category;
  final ExerciseLevel level;
  final Equipment? equipment;
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;
  final List<String> imageUrls;
  final int timesLogged;

  String nameFor(String localeCode) => names[localeCode] ?? names[fallbackLocale] ?? names.values.firstOrNull ?? '';

  List<String> instructionsFor(String localeCode) => instructions[localeCode] ?? instructions[fallbackLocale] ?? const [];

  String? get imageUrl => imageUrls.firstOrNull;

  @override
  List<Object?> get props => [
    id,
    names,
    instructions,
    category,
    level,
    equipment,
    primaryMuscles,
    secondaryMuscles,
    imageUrls,
    timesLogged,
  ];
}
