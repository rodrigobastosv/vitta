import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/body_weight/use_cases/delete_body_weight_log_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_recent_body_weight_logs_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/log_body_weight_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_presentation_event.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_state.dart';

class BodyWeightCubit extends PresentationCubit<BodyWeightState, BodyWeightPresentationEvent> {
  BodyWeightCubit({
    required this._getRecentBodyWeightLogsUseCase,
    required this._logBodyWeightUseCase,
    required this._deleteBodyWeightLogUseCase,
    required this._getAppSettingsUseCase,
  }) : super(const BodyWeightState(logs: [], isLoaded: false));

  final GetRecentBodyWeightLogsUseCase _getRecentBodyWeightLogsUseCase;
  final LogBodyWeightUseCase _logBodyWeightUseCase;
  final DeleteBodyWeightLogUseCase _deleteBodyWeightLogUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  static const _recentDays = 90;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  @override
  void onInit() => loadRecent();

  Future<void> loadRecent() async {
    emitPresentation(BodyWeightShowLoading());
    final recentLogsResult = await _getRecentBodyWeightLogsUseCase(days: _recentDays);
    emitPresentation(BodyWeightHideLoading());
    recentLogsResult.when((error) => emitPresentation(BodyWeightError(message: error.message)), (value) => emit(BodyWeightState(logs: value)));
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> logWeight({required DateTime loggedDate, required double weightKg}) async {
    final loggedResult = await _logBodyWeightUseCase(loggedDate: loggedDate, weightKg: weightKg);
    await loggedResult.when((error) => Future.sync(() => emitPresentation(BodyWeightError(message: error.message))), (_) {
      Log.action('body_weight_logged', data: {'weight_kg': weightKg});
      emitPresentation(BodyWeightLogged());
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
    final deletedResult = await _deleteBodyWeightLogUseCase(logId: logId);
    deletedResult.when((error) {
      emit(state.copyWith(logs: previous));
      emitPresentation(BodyWeightError(message: error.message));
    }, (_) => Log.action('body_weight_log_deleted'));
  }
}
