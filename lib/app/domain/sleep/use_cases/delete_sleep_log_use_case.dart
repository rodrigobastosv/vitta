import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/sleep/sleep_repository.dart';

class DeleteSleepLogUseCase {
  DeleteSleepLogUseCase({required this._sleepRepository});

  final SleepRepository _sleepRepository;

  Future<Result<VTError, void>> call({required String logId}) => _sleepRepository.deleteSleepLog(logId: logId);
}
