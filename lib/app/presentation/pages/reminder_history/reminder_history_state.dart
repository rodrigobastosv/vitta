import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';

class ReminderHistoryState extends Equatable {
  const ReminderHistoryState({required this.month, this.remindersInMonth = const {}});

  final DateTime month;
  final Map<DateTime, List<Reminder>> remindersInMonth;

  ReminderHistoryState copyWith({DateTime? month, Map<DateTime, List<Reminder>>? remindersInMonth}) =>
      ReminderHistoryState(month: month ?? this.month, remindersInMonth: remindersInMonth ?? this.remindersInMonth);

  @override
  List<Object?> get props => [month, remindersInMonth];
}
