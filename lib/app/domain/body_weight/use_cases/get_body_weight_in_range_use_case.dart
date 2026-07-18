import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/body_weight/body_weight_repository.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';

class GetBodyWeightInRangeUseCase {
  GetBodyWeightInRangeUseCase({required this._bodyWeightRepository});

  final BodyWeightRepository _bodyWeightRepository;

  Future<Result<VTError, List<BodyWeightLog>>> call({required DateTime from, required DateTime to}) =>
      _bodyWeightRepository.getLogsInRange(from: from, to: to);
}
