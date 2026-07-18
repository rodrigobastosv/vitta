import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/body_weight/body_weight_repository.dart';

class DeleteBodyWeightLogUseCase {
  DeleteBodyWeightLogUseCase({required this._bodyWeightRepository});

  final BodyWeightRepository _bodyWeightRepository;

  Future<Result<VTError, void>> call({required String logId}) => _bodyWeightRepository.deleteBodyWeightLog(logId: logId);
}
