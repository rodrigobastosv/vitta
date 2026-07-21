import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/health/health_service.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_import.dart';
import 'package:vitta/app/domain/sleep/use_cases/delete_sleep_log_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_recent_sleep_logs_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/get_sleep_goal_use_case.dart';
import 'package:vitta/app/domain/sleep/use_cases/import_sleep_from_health_use_case.dart';
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
    required this._importSleepFromHealthUseCase,
    required this._healthService,
  }) : super(const SleepState(logs: []));

  final GetRecentSleepLogsUseCase _getRecentSleepLogsUseCase;
  final LogSleepUseCase _logSleepUseCase;
  final DeleteSleepLogUseCase _deleteSleepLogUseCase;
  final GetSleepGoalUseCase _getSleepGoalUseCase;
  final SaveSleepGoalUseCase _saveSleepGoalUseCase;
  final ImportSleepFromHealthUseCase _importSleepFromHealthUseCase;
  final HealthService _healthService;

  double get durationGoalHours => _getSleepGoalUseCase();

  Future<void> saveDurationGoalHours(double goalHours) => _saveSleepGoalUseCase(goalHours: goalHours);

  static const _recentDays = 7;
  static const _importWindowDays = 30;

  @override
  void onInit() => _loadThenSync();

  Future<void> _loadThenSync() async {
    await loadRecent();
    await _autoSyncFromHealth();
  }

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
    emit(
      state.copyWith(
        logs: [
          for (final log in previous)
            if (log.id != logId) log,
        ],
      ),
    );
    final deletedResult = await _deleteSleepLogUseCase(logId: logId);
    deletedResult.when((error) {
      emit(state.copyWith(logs: previous));
      emitPresentation(SleepError(message: error.message));
    }, (_) => Log.action('sleep_log_deleted'));
  }

  Future<void> importFromHealth() async {
    emitPresentation(SleepShowLoading());
    try {
      if (!await _healthService.isAvailable()) {
        emitPresentation(SleepHealthUnavailable());
        return;
      }
      if (!await _healthService.requestSleepAuthorization()) {
        emitPresentation(SleepHealthPermissionDenied());
        return;
      }
      final importedResult = await _readAndImportFromHealth();
      await importedResult.when((error) => Future.sync(() => emitPresentation(SleepError(message: error.message))), (count) {
        Log.action('sleep_imported_from_health', data: {'count': count});
        emitPresentation(SleepImported(count: count));
        return loadRecent();
      });
    } on Exception catch (error) {
      emitPresentation(SleepError(message: error.toString()));
    } finally {
      emitPresentation(SleepHideLoading());
    }
  }

  // Best-effort sync run whenever the page opens, so recorded nights show up
  // without tapping the button. Requests health authorization here — not only
  // when the sync button is tapped (issue #150) — so the OS permission prompt
  // appears the first time the sleep page is opened. Still deliberately quiet
  // otherwise: no loading overlay, and no error toast on an unavailable platform
  // or a denied prompt — the manual button stays the path that surfaces
  // failures. Only a sync that actually pulled in new nights announces itself.
  Future<void> _autoSyncFromHealth() async {
    try {
      if (!await _healthService.isAvailable()) {
        return;
      }
      if (!await _healthService.requestSleepAuthorization()) {
        return;
      }
      final importedResult = await _readAndImportFromHealth();
      await importedResult.when((_) => Future<void>.value(), (count) async {
        if (count == 0) {
          return;
        }
        Log.action('sleep_imported_from_health', data: {'count': count, 'auto': true});
        emitPresentation(SleepImported(count: count));
        await loadRecent();
      });
    } on Exception {
      // An unavailable or unauthorized health platform must never interrupt the
      // page it opened onto — the manual sync button is where failures surface.
    }
  }

  Future<Result<VTError, int>> _readAndImportFromHealth() async {
    final to = DateTime.now();
    final sessions = await _healthService.readSleepSessions(
      from: to.subtract(const Duration(days: _importWindowDays)),
      to: to,
    );
    final imports = [for (final session in sessions) SleepImport(start: session.start, end: session.end, externalId: session.externalId)];
    return _importSleepFromHealthUseCase(imports: imports);
  }

  Future<void> seedSampleSleepForDebug() async {
    final now = DateTime.now();
    final wakeTime = DateTime(now.year, now.month, now.day, 6, 30);
    await _healthService.writeSampleSleep(start: wakeTime.subtract(const Duration(hours: 7, minutes: 45)), end: wakeTime);
  }
}
