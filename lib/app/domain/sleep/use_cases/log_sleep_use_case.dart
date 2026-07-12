import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/sleep/sleep_repository.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

class LogSleepUseCase {
  LogSleepUseCase({required this._sleepRepository});

  final SleepRepository _sleepRepository;

  Future<Result<VTError, SleepLog>> call({required DateTime bedTime, required DateTime wakeTime, int? qualityRating}) =>
      _sleepRepository.logSleep(bedTime: bedTime, wakeTime: wakeTime, qualityRating: qualityRating);
}
