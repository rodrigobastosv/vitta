import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

class DietCubit extends Cubit<DietState> {
  DietCubit({required GetDailyMacrosUseCase getDailyMacrosUseCase, required DeleteFoodLogUseCase deleteFoodLogUseCase})
    : _getDailyMacrosUseCase = getDailyMacrosUseCase,
      _deleteFoodLogUseCase = deleteFoodLogUseCase,
      super(const DietLoading());

  final GetDailyMacrosUseCase _getDailyMacrosUseCase;
  final DeleteFoodLogUseCase _deleteFoodLogUseCase;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> loadToday() async {
    emit(const DietLoading());
    final dailyMacros = await _getDailyMacrosUseCase(date: _today);
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
