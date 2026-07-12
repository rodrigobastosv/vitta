import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/sleep/sleep_repository.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

class GetRecentSleepLogsUseCase {
  GetRecentSleepLogsUseCase({required this._sleepRepository});

  final SleepRepository _sleepRepository;

  Future<Result<VTError, List<SleepLog>>> call({required int days}) => _sleepRepository.getRecentSleepLogs(days: days);
}
