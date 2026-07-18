import 'package:vitta/app/domain/reminder/use_cases/get_reminders_in_range_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_state.dart';

class ReminderHistoryCubit extends PresentationCubit<ReminderHistoryState, ReminderHistoryPresentationEvent> {
  ReminderHistoryCubit({required this._getRemindersInRangeUseCase}) : super(ReminderHistoryState(month: _monthOf(DateTime.now())));

  final GetRemindersInRangeUseCase _getRemindersInRangeUseCase;

  static DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  @override
  void onInit() => loadMonth(state.month);

  void selectDay(DateTime day) => emit(state.copyWith(selectedDay: day));

  Future<void> goToPreviousMonth() => _changeMonth(-1);

  Future<void> goToNextMonth() => _changeMonth(1);

  Future<void> _changeMonth(int monthDelta) {
    // A fresh state (not copyWith) so the previous month's selected day clears -
    // copyWith can't null a field back out.
    final month = DateTime(state.month.year, state.month.month + monthDelta);
    emit(ReminderHistoryState(month: month));
    return loadMonth(month);
  }

  Future<void> loadMonth(DateTime month) async {
    emitPresentation(ReminderHistoryShowLoading());
    final remindersResult = await _getRemindersInRangeUseCase(from: month, to: DateTime(month.year, month.month + 1, 0));
    emitPresentation(ReminderHistoryHideLoading());
    remindersResult.when(
      (error) => emitPresentation(ReminderHistoryError(message: error.message)),
      (remindersInMonth) => emit(state.copyWith(remindersInMonth: remindersInMonth)),
    );
  }
}
