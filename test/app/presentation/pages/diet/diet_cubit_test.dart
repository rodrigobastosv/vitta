import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  late MockGetDailyMacrosUseCase getDailyMacrosUseCase;
  late MockDeleteFoodLogUseCase deleteFoodLogUseCase;

  setUp(() {
    getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
    deleteFoodLogUseCase = MockDeleteFoodLogUseCase();
  });

  blocTest<DietCubit, DietState>(
    'emits [DietLoading, DietLoaded] when loadToday succeeds',
    setUp: () {
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    },
    build: () => buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, deleteFoodLogUseCase: deleteFoodLogUseCase),
    act: (cubit) => cubit.loadToday(),
    expect: () => [const DietLoading(), isA<DietLoaded>()],
  );

  blocTest<DietCubit, DietState>(
    'emits [DietLoading, DietError] when loadToday fails',
    setUp: () {
      when(
        () => getDailyMacrosUseCase(date: any(named: 'date')),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    },
    build: () => buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, deleteFoodLogUseCase: deleteFoodLogUseCase),
    act: (cubit) => cubit.loadToday(),
    expect: () => [const DietLoading(), const DietError(message: 'boom')],
  );

  blocTest<DietCubit, DietState>(
    'reloads today after successfully deleting a log',
    setUp: () {
      when(() => deleteFoodLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Success(null));
      when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
    },
    build: () => buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, deleteFoodLogUseCase: deleteFoodLogUseCase),
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expect: () => [const DietLoading(), isA<DietLoaded>()],
  );

  blocTest<DietCubit, DietState>(
    'emits DietError without reloading when deletion fails',
    setUp: () {
      when(() => deleteFoodLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    },
    build: () => buildDietCubit(getDailyMacrosUseCase: getDailyMacrosUseCase, deleteFoodLogUseCase: deleteFoodLogUseCase),
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expect: () => [const DietError(message: 'boom')],
    verify: (_) => verifyNever(() => getDailyMacrosUseCase(date: any(named: 'date'))),
  );
}
