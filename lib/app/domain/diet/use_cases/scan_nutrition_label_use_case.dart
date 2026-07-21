import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/scanned_nutrition_facts.dart';

class ScanNutritionLabelUseCase {
  ScanNutritionLabelUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, ScannedNutritionFacts>> call({required String imagePath}) => _dietRepository.scanNutritionLabel(imagePath: imagePath);
}
