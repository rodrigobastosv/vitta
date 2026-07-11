import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';

class DeleteFoodLogUseCase {
  DeleteFoodLogUseCase({required DietRepository dietRepository}) : _dietRepository = dietRepository;

  final DietRepository _dietRepository;

  Future<Result<VTError, void>> call({required String logId}) => _dietRepository.deleteFoodLog(logId: logId);
}
