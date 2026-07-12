import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

class DietCubit extends PresentationCubit<DietState, DietPresentationEvent> {
  DietCubit({required GetDailyMacrosUseCase getDailyMacrosUseCase, required DeleteFoodLogUseCase deleteFoodLogUseCase})
    : _getDailyMacrosUseCase = getDailyMacrosUseCase,
      _deleteFoodLogUseCase = deleteFoodLogUseCase,
      super(
        DietLoaded(
          date: _dateOnly(DateTime.now()),
          dailyMacros: const DailyMacros(entries: []),
        ),
      );

  final GetDailyMacrosUseCase _getDailyMacrosUseCase;
  final DeleteFoodLogUseCase _deleteFoodLogUseCase;

  static DateTime _dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

  DateTime get _today => _dateOnly(DateTime.now());

  @override
  void onInit() => loadToday();

  Future<void> loadToday() async {
    emitPresentation(DietShowLoading());
    final dailyMacrosResult = await _getDailyMacrosUseCase(date: _today);
    emitPresentation(DietHideLoading());
    dailyMacrosResult.when(
      (error) => emit(DietError(message: error.message)),
      (value) => emit(DietLoaded(date: _today, dailyMacros: value)),
    );
  }

  Future<void> deleteLog({required String logId}) async {
    final deletedResult = await _deleteFoodLogUseCase(logId: logId);
    await deletedResult.when((error) => Future.sync(() => emit(DietError(message: error.message))), (_) => loadToday());
  }
}
