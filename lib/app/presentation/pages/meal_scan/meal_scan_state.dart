import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_entry.dart';

class MealScanState extends Equatable {
  const MealScanState({this.imageBytes, this.entries = const [], this.mealType = .lunch, this.hasScanned = false});

  final Uint8List? imageBytes;
  final List<MealScanEntry> entries;
  final MealType mealType;
  final bool hasScanned;

  List<MealScanEntry> get includedEntries => entries.where((entry) => entry.isIncluded).toList();

  bool get canLog => includedEntries.isNotEmpty && includedEntries.every((entry) => entry.isValid);

  double get totalCalories => includedEntries.fold(0, (sum, entry) => sum + entry.calories);

  MealScanState copyWith({Uint8List? imageBytes, List<MealScanEntry>? entries, MealType? mealType, bool? hasScanned}) => MealScanState(
    imageBytes: imageBytes ?? this.imageBytes,
    entries: entries ?? this.entries,
    mealType: mealType ?? this.mealType,
    hasScanned: hasScanned ?? this.hasScanned,
  );

  @override
  List<Object?> get props => [imageBytes, entries, mealType, hasScanned];
}
