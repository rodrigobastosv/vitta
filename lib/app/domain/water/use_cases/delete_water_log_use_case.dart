import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/water/water_repository.dart';

class DeleteWaterLogUseCase {
  DeleteWaterLogUseCase({required WaterRepository waterRepository}) : _waterRepository = waterRepository;

  final WaterRepository _waterRepository;

  Future<Result<VTError, void>> call({required String logId}) => _waterRepository.deleteWaterLog(logId: logId);
}
