import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/body_weight/body_weight_repository.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';

class GetRecentBodyWeightLogsUseCase {
  GetRecentBodyWeightLogsUseCase({required this._bodyWeightRepository});

  final BodyWeightRepository _bodyWeightRepository;

  Future<Result<VTError, List<BodyWeightLog>>> call({required int days}) => _bodyWeightRepository.getRecentLogs(days: days);
}
