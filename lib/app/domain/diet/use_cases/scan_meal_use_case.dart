import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/scanned_meal.dart';

class ScanMealUseCase {
  ScanMealUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, ScannedMeal>> call({required String imagePath}) => _dietRepository.scanMeal(imagePath: imagePath);
}
