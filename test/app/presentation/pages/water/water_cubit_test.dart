import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/presentation/pages/water/water_cubit.dart';
import 'package:vitta/app/presentation/pages/water/water_presentation_event.dart';
import 'package:vitta/app/presentation/pages/water/water_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/water_log_factory.dart';
import '../../../../mocks/datasources_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  blocTest<WaterCubit, WaterState>(
    'emits WaterLoaded when loadToday succeeds',
    build: () {
      final getDailyWaterUseCase = MockGetDailyWaterUseCase();
      final waterLocalDataSource = MockWaterLocalDataSource();
      when(() => getDailyWaterUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyWater(entries: [])));
      when(waterLocalDataSource.getDailyGoalMl).thenReturn(2000);
      return CubitsFactories.buildWaterCubit(getDailyWaterUseCase: getDailyWaterUseCase, waterLocalDataSource: waterLocalDataSource);
    },
    act: (cubit) => cubit.loadToday(),
    expect: () => [isA<WaterLoaded>()],
  );

  blocPresentationTest<WaterCubit, WaterState, WaterPresentationEvent>(
    'shows then hides loading while loadToday runs',
    build: () {
      final getDailyWaterUseCase = MockGetDailyWaterUseCase();
      final waterLocalDataSource = MockWaterLocalDataSource();
      when(() => getDailyWaterUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyWater(entries: [])));
      when(waterLocalDataSource.getDailyGoalMl).thenReturn(2000);
      return CubitsFactories.buildWaterCubit(getDailyWaterUseCase: getDailyWaterUseCase, waterLocalDataSource: waterLocalDataSource);
    },
    act: (cubit) => cubit.loadToday(),
    expectPresentation: () => [isA<WaterShowLoading>(), isA<WaterHideLoading>()],
  );

  blocTest<WaterCubit, WaterState>(
    'emits WaterError when loadToday fails',
    build: () {
      final getDailyWaterUseCase = MockGetDailyWaterUseCase();
      final waterLocalDataSource = MockWaterLocalDataSource();
      when(() => getDailyWaterUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      when(waterLocalDataSource.getDailyGoalMl).thenReturn(2000);
      return CubitsFactories.buildWaterCubit(getDailyWaterUseCase: getDailyWaterUseCase, waterLocalDataSource: waterLocalDataSource);
    },
    act: (cubit) => cubit.loadToday(),
    expect: () => [const WaterError(message: 'boom')],
  );

  blocTest<WaterCubit, WaterState>(
    'reloads today after successfully adding water',
    build: () {
      final logWaterUseCase = MockLogWaterUseCase();
      final getDailyWaterUseCase = MockGetDailyWaterUseCase();
      final waterLocalDataSource = MockWaterLocalDataSource();
      when(
        () => logWaterUseCase(loggedDate: any(named: 'loggedDate'), amountMl: 250),
      ).thenAnswer((_) async => Success(WaterLogFactory.build()));
      when(() => getDailyWaterUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyWater(entries: [])));
      when(waterLocalDataSource.getDailyGoalMl).thenReturn(2000);
      return CubitsFactories.buildWaterCubit(
        getDailyWaterUseCase: getDailyWaterUseCase,
        logWaterUseCase: logWaterUseCase,
        waterLocalDataSource: waterLocalDataSource,
      );
    },
    act: (cubit) => cubit.addWater(amountMl: 250),
    expect: () => [isA<WaterLoaded>()],
  );

  blocTest<WaterCubit, WaterState>(
    'reloads today after successfully deleting a log',
    build: () {
      final deleteWaterLogUseCase = MockDeleteWaterLogUseCase();
      final getDailyWaterUseCase = MockGetDailyWaterUseCase();
      final waterLocalDataSource = MockWaterLocalDataSource();
      when(() => deleteWaterLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Success(null));
      when(() => getDailyWaterUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyWater(entries: [])));
      when(waterLocalDataSource.getDailyGoalMl).thenReturn(2000);
      return CubitsFactories.buildWaterCubit(
        getDailyWaterUseCase: getDailyWaterUseCase,
        deleteWaterLogUseCase: deleteWaterLogUseCase,
        waterLocalDataSource: waterLocalDataSource,
      );
    },
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expect: () => [isA<WaterLoaded>()],
  );

  final getDailyWaterUseCaseSpy = MockGetDailyWaterUseCase();
  blocTest<WaterCubit, WaterState>(
    'emits WaterError without reloading when deletion fails',
    build: () {
      final deleteWaterLogUseCase = MockDeleteWaterLogUseCase();
      final waterLocalDataSource = MockWaterLocalDataSource();
      when(() => deleteWaterLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildWaterCubit(
        getDailyWaterUseCase: getDailyWaterUseCaseSpy,
        deleteWaterLogUseCase: deleteWaterLogUseCase,
        waterLocalDataSource: waterLocalDataSource,
      );
    },
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expect: () => [const WaterError(message: 'boom')],
    verify: (_) => verifyNever(() => getDailyWaterUseCaseSpy(date: any(named: 'date'))),
  );

  blocTest<WaterCubit, WaterState>(
    'reloads today after changing the daily goal',
    build: () {
      final getDailyWaterUseCase = MockGetDailyWaterUseCase();
      final waterLocalDataSource = MockWaterLocalDataSource();
      when(() => waterLocalDataSource.saveDailyGoalMl(any())).thenAnswer((_) async {});
      when(() => getDailyWaterUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyWater(entries: [])));
      when(waterLocalDataSource.getDailyGoalMl).thenReturn(3000);
      return CubitsFactories.buildWaterCubit(getDailyWaterUseCase: getDailyWaterUseCase, waterLocalDataSource: waterLocalDataSource);
    },
    act: (cubit) => cubit.changeDailyGoal(goalMl: 3000),
    expect: () => [isA<WaterLoaded>()],
  );
}
