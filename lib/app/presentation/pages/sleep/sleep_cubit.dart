import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/sleep/use_cases/delete_sleep_log_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_recent_sleep_logs_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_goal_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/log_sleep_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/save_sleep_goal_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_presentation_event.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_state.dart';

class SleepCubit extends PresentationCubit<SleepState, SleepPresentationEvent> {
  SleepCubit({
    required this._getRecentSleepLogsUseCase,
    required this._logSleepUseCase,
    required this._deleteSleepLogUseCase,
    required this._getSleepGoalUseCase,
    required this._saveSleepGoalUseCase,
  }) : super(const SleepState(logs: []));

  final GetRecentSleepLogsUseCase _getRecentSleepLogsUseCase;
  final LogSleepUseCase _logSleepUseCase;
  final DeleteSleepLogUseCase _deleteSleepLogUseCase;
  final GetSleepGoalUseCase _getSleepGoalUseCase;
  final SaveSleepGoalUseCase _saveSleepGoalUseCase;

  double get durationGoalHours => _getSleepGoalUseCase();

  Future<void> saveDurationGoalHours(double goalHours) => _saveSleepGoalUseCase(goalHours: goalHours);

  static const _recentDays = 7;

  @override
  void onInit() => loadRecent();

  Future<void> loadRecent() async {
    emitPresentation(SleepShowLoading());
    final recentLogsResult = await _getRecentSleepLogsUseCase(days: _recentDays);
    emitPresentation(SleepHideLoading());
    recentLogsResult.when((error) => emitPresentation(SleepError(message: error.message)), (value) => emit(SleepState(logs: value)));
  }

  Future<void> logSleep({required DateTime bedTime, required DateTime wakeTime, int? qualityRating}) async {
    final loggedResult = await _logSleepUseCase(bedTime: bedTime, wakeTime: wakeTime, qualityRating: qualityRating);
    await loggedResult.when((error) => Future.sync(() => emitPresentation(SleepError(message: error.message))), (_) {
      Log.action('sleep_logged', data: {'quality': qualityRating});
      return loadRecent();
    });
  }

  Future<void> deleteLog({required String logId}) async {
    final previous = state.logs;
    emit(state.copyWith(logs: [for (final log in previous) if (log.id != logId) log]));
    final deletedResult = await _deleteSleepLogUseCase(logId: logId);
    deletedResult.when(
      (error) {
        emit(state.copyWith(logs: previous));
        emitPresentation(SleepError(message: error.message));
      },
      (_) => Log.action('sleep_log_deleted'),
    );
  }
}
