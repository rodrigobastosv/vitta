import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_body_weight_in_range_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/body_weight_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/body_weight_history_state.dart';

class BodyWeightHistoryCubit extends PresentationCubit<BodyWeightHistoryState, BodyWeightHistoryPresentationEvent> {
  BodyWeightHistoryCubit({required this._getBodyWeightInRangeUseCase, required this._getAppSettingsUseCase})
    : super(const BodyWeightHistoryState(isLoaded: false));

  final GetBodyWeightInRangeUseCase _getBodyWeightInRangeUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  @override
  void onInit() => _loadTrend(state.trendRange);

  Future<void> changeTrendRange(TrendRange trendRange) async {
    emit(state.copyWith(trendRange: trendRange));
    await _loadTrend(trendRange);
  }

  Future<void> _loadTrend(TrendRange trendRange) async {
    emitPresentation(BodyWeightHistoryShowLoading());
    final to = _dateOnly(DateTime.now());
    final logsResult = await _getBodyWeightInRangeUseCase(
      from: to.subtract(Duration(days: trendRange.days - 1)),
      to: to,
    );
    emitPresentation(BodyWeightHistoryHideLoading());
    logsResult.when((error) => emitPresentation(BodyWeightHistoryError(message: error.message)), (value) => emit(state.copyWith(isLoaded: true, logs: value)));
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }
}
