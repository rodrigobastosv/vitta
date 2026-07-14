import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';

class CopyFoodLogsUseCase {
  CopyFoodLogsUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, void>> call({required List<FoodLogEntry> entries, required DateTime targetDate}) =>
      _dietRepository.copyFoodLogs(entries: entries, targetDate: targetDate);
}
