import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_filter.dart';

class ReminderState extends Equatable {
  const ReminderState({required this.date, required this.reminders, required this.filter, this.isLoaded = true});

  final DateTime date;
  final List<Reminder> reminders;
  final ReminderFilter filter;
  final bool isLoaded;

  List<Reminder> get visibleReminders => reminders.where(filter.matches).toList();

  int get completedCount => reminders.where((reminder) => reminder.isCompleted).length;

  ReminderState copyWith({DateTime? date, List<Reminder>? reminders, ReminderFilter? filter, bool? isLoaded}) =>
      ReminderState(isLoaded: isLoaded ?? this.isLoaded, date: date ?? this.date, reminders: reminders ?? this.reminders, filter: filter ?? this.filter);

  @override
  List<Object?> get props => [isLoaded, date, reminders, filter];
}
