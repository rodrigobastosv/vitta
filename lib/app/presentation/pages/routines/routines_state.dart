import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';

class RoutinesState extends Equatable {
  const RoutinesState({required this.routines, this.isLoaded = true});

  final List<Routine> routines;
  final bool isLoaded;

  RoutinesState copyWith({List<Routine>? routines, bool? isLoaded}) => RoutinesState(isLoaded: isLoaded ?? this.isLoaded, routines: routines ?? this.routines);

  @override
  List<Object?> get props => [isLoaded, routines];
}
