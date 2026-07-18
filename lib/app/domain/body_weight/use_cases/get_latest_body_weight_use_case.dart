import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/body_weight/body_weight_repository.dart';
import 'package:vitta/app/domain/body_weight/entities/body_weight_log.dart';

// The most recent weight measurement, or null when nothing has been logged. The
// workout feature uses it to pre-fill the load for bodyweight exercises (issue #101).
class GetLatestBodyWeightUseCase {
  GetLatestBodyWeightUseCase({required this._bodyWeightRepository});

  final BodyWeightRepository _bodyWeightRepository;

  Future<Result<VTError, BodyWeightLog?>> call() => _bodyWeightRepository.getLatest();
}
