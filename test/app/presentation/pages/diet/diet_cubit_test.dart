import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  blocTest<DietCubit, DietState>(
    'emits a loaded state when loadToday succeeds',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
      return CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase);
    },
    act: (cubit) => cubit.loadToday(),
    expect: () => [isA<DietState>()],
  );

  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'shows then hides loading while loadToday runs',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
      return CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase);
    },
    act: (cubit) => cubit.loadToday(),
    expectPresentation: () => [isA<DietShowLoading>(), isA<DietHideLoading>()],
  );

  test('loadToday keeps the previous state when it fails', () async {
    final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final cubit = CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase);
    final initialState = cubit.state;

    await cubit.loadToday();

    expect(cubit.state, initialState);
  });

  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'emits DietError when loadToday fails',
    build: () {
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase);
    },
    act: (cubit) => cubit.loadToday(),
    expectPresentation: () => [isA<DietShowLoading>(), isA<DietHideLoading>(), isA<DietError>()],
  );

  blocTest<DietCubit, DietState>(
    'reloads today after successfully deleting a log',
    build: () {
      final deleteFoodLogUseCase = MockDeleteFoodLogUseCase();
      final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
      when(() => deleteFoodLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Success(null));
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
      return CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, deleteFoodLogUseCase: deleteFoodLogUseCase);
    },
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expect: () => [isA<DietState>()],
  );

  final getDailyMacrosUseCaseSpy = MockGetDailyMacrosUseCase();
  blocPresentationTest<DietCubit, DietState, DietPresentationEvent>(
    'emits DietError without reloading when deletion fails',
    build: () {
      final deleteFoodLogUseCase = MockDeleteFoodLogUseCase();
      when(() => deleteFoodLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCaseSpy, deleteFoodLogUseCase: deleteFoodLogUseCase);
    },
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expectPresentation: () => [isA<DietError>()],
    verify: (_) => verifyNever(() => getDailyMacrosUseCaseSpy(date: any(named: 'date'))),
  );
}
