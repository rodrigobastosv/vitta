import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';

class RoutinesState extends Equatable {
  const RoutinesState({required this.routines});

  final List<Routine> routines;

  RoutinesState copyWith({List<Routine>? routines}) => RoutinesState(routines: routines ?? this.routines);

  @override
  List<Object?> get props => [routines];
}
