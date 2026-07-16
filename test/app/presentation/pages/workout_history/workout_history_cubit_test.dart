import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/workout/entities/daily_workout.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_cubit.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_state.dart';

import '../../../../factories/entities/workout_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2026)));

  blocTest<WorkoutHistoryCubit, WorkoutHistoryState>(
    'refresh loads the month and the trend range',
    build: () {
      final getDailyWorkoutsInRangeUseCase = MockGetDailyWorkoutsInRangeUseCase();
      final day = DateTime(2026, 7, 15);
      when(() => getDailyWorkoutsInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer(
        (_) async => Success({day: DailyWorkout(date: day, workouts: [WorkoutFactory.build()])}),
      );
      return WorkoutHistoryCubit(getDailyWorkoutsInRangeUseCase: getDailyWorkoutsInRangeUseCase, getAppSettingsUseCase: MockGetAppSettingsUseCase());
    },
    act: (cubit) => cubit.refresh(),
    expect: () => [
      isA<WorkoutHistoryState>().having((state) => state.workoutsInMonth, 'workoutsInMonth', isNotEmpty),
      isA<WorkoutHistoryState>().having((state) => state.workoutsInTrendRange, 'workoutsInTrendRange', isNotEmpty),
    ],
  );

  blocPresentationTest<WorkoutHistoryCubit, WorkoutHistoryState, WorkoutHistoryPresentationEvent>(
    'refresh surfaces a failure as an error event',
    build: () {
      final getDailyWorkoutsInRangeUseCase = MockGetDailyWorkoutsInRangeUseCase();
      when(
        () => getDailyWorkoutsInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')),
      ).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return WorkoutHistoryCubit(getDailyWorkoutsInRangeUseCase: getDailyWorkoutsInRangeUseCase, getAppSettingsUseCase: MockGetAppSettingsUseCase());
    },
    act: (cubit) => cubit.refresh(),
    expectPresentation: () => [
      isA<WorkoutHistoryShowLoading>(),
      isA<WorkoutHistoryError>().having((event) => event.message, 'message', 'offline'),
      isA<WorkoutHistoryError>().having((event) => event.message, 'message', 'offline'),
      isA<WorkoutHistoryHideLoading>(),
    ],
  );
}
