import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';

class ReminderHistoryState extends Equatable {
  const ReminderHistoryState({required this.month, this.remindersInMonth = const {}, this.selectedDay});

  final DateTime month;
  final Map<DateTime, List<Reminder>> remindersInMonth;
  final DateTime? selectedDay;

  bool get hasData => remindersInMonth.isNotEmpty;

  List<Reminder> get selectedReminders => selectedDay == null ? const [] : (remindersInMonth[selectedDay] ?? const []);

  ReminderHistoryState copyWith({DateTime? month, Map<DateTime, List<Reminder>>? remindersInMonth, DateTime? selectedDay}) => ReminderHistoryState(
    month: month ?? this.month,
    remindersInMonth: remindersInMonth ?? this.remindersInMonth,
    selectedDay: selectedDay ?? this.selectedDay,
  );

  @override
  List<Object?> get props => [month, remindersInMonth, selectedDay];
}
