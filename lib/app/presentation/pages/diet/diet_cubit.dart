import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/presentation/general/loading_presentation_event.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

class DietCubit extends PresentationCubit<DietState> {
  DietCubit({required GetDailyMacrosUseCase getDailyMacrosUseCase, required DeleteFoodLogUseCase deleteFoodLogUseCase})
    : _getDailyMacrosUseCase = getDailyMacrosUseCase,
      _deleteFoodLogUseCase = deleteFoodLogUseCase,
      super(DietLoaded(date: _dateOnly(DateTime.now()), dailyMacros: const DailyMacros(entries: [])));

  final GetDailyMacrosUseCase _getDailyMacrosUseCase;
  final DeleteFoodLogUseCase _deleteFoodLogUseCase;

  static DateTime _dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

  DateTime get _today => _dateOnly(DateTime.now());

  Future<void> loadToday() async {
    emitPresentation(LoadingPresentationEvent.show);
    final dailyMacros = await _getDailyMacrosUseCase(date: _today);
    emitPresentation(LoadingPresentationEvent.hide);
    switch (dailyMacros) {
      case Failure(:final error):
        emit(DietError(message: error.message));
      case Success(:final value):
        emit(DietLoaded(date: _today, dailyMacros: value));
    }
  }

  Future<void> deleteLog({required String logId}) async {
    final deleted = await _deleteFoodLogUseCase(logId: logId);
    switch (deleted) {
      case Failure(:final error):
        emit(DietError(message: error.message));
      case Success():
        await loadToday();
    }
  }
}
