import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_presentation_event.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/sleep_log_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(<String, Object?>{});
  });

  blocTest<SleepCubit, SleepState>(
    'emits a loaded state when loadRecent succeeds',
    build: () {
      final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
      when(() => getRecentSleepLogsUseCase(days: 7)).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildSleepCubit(getRecentSleepLogsUseCase: getRecentSleepLogsUseCase);
    },
    act: (cubit) => cubit.loadRecent(),
    expect: () => [isA<SleepState>()],
  );

  blocPresentationTest<SleepCubit, SleepState, SleepPresentationEvent>(
    'shows then hides loading while loadRecent runs',
    build: () {
      final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
      when(() => getRecentSleepLogsUseCase(days: 7)).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildSleepCubit(getRecentSleepLogsUseCase: getRecentSleepLogsUseCase);
    },
    act: (cubit) => cubit.loadRecent(),
    expectPresentation: () => [isA<SleepShowLoading>(), isA<SleepHideLoading>()],
  );

  blocPresentationTest<SleepCubit, SleepState, SleepPresentationEvent>(
    'emits SleepError when loadRecent fails',
    build: () {
      final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
      when(() => getRecentSleepLogsUseCase(days: 7)).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildSleepCubit(getRecentSleepLogsUseCase: getRecentSleepLogsUseCase);
    },
    act: (cubit) => cubit.loadRecent(),
    expectPresentation: () => [isA<SleepShowLoading>(), isA<SleepHideLoading>(), isA<SleepError>()],
  );

  blocTest<SleepCubit, SleepState>(
    'reloads recent logs after successfully logging sleep',
    build: () {
      final logSleepUseCase = MockLogSleepUseCase();
      final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
      when(
        () => logSleepUseCase(
          bedTime: any(named: 'bedTime'),
          wakeTime: any(named: 'wakeTime'),
          qualityRating: any(named: 'qualityRating'),
        ),
      ).thenAnswer((_) async => Success(SleepLogFactory.build()));
      when(() => getRecentSleepLogsUseCase(days: 7)).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildSleepCubit(logSleepUseCase: logSleepUseCase, getRecentSleepLogsUseCase: getRecentSleepLogsUseCase);
    },
    act: (cubit) => cubit.logSleep(bedTime: DateTime(2026, 7, 10, 22, 30), wakeTime: DateTime(2026, 7, 11, 6, 45)),
    expect: () => [isA<SleepState>()],
  );

  test('logs a sleep_logged user action after logging sleep', () async {
    final loggingService = useMockLog();
    final logSleepUseCase = MockLogSleepUseCase();
    final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
    when(
      () => logSleepUseCase(bedTime: any(named: 'bedTime'), wakeTime: any(named: 'wakeTime'), qualityRating: 4),
    ).thenAnswer((_) async => Success(SleepLogFactory.build()));
    when(() => getRecentSleepLogsUseCase(days: 7)).thenAnswer((_) async => const Success([]));
    final cubit = CubitsFactories.buildSleepCubit(logSleepUseCase: logSleepUseCase, getRecentSleepLogsUseCase: getRecentSleepLogsUseCase);

    await cubit.logSleep(bedTime: DateTime(2026, 7, 10, 22, 30), wakeTime: DateTime(2026, 7, 11, 6, 45), qualityRating: 4);

    final captured = verify(() => loggingService.logAction(captureAny(), data: captureAny(named: 'data'))).captured;
    expect(captured, ['sleep_logged', {'quality': 4}]);
  });

  blocTest<SleepCubit, SleepState>(
    'reloads recent logs after successfully deleting a log',
    build: () {
      final deleteSleepLogUseCase = MockDeleteSleepLogUseCase();
      final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
      when(() => deleteSleepLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Success(null));
      when(() => getRecentSleepLogsUseCase(days: 7)).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildSleepCubit(
        deleteSleepLogUseCase: deleteSleepLogUseCase,
        getRecentSleepLogsUseCase: getRecentSleepLogsUseCase,
      );
    },
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expect: () => [isA<SleepState>()],
  );

  final getRecentSleepLogsUseCaseSpy = MockGetRecentSleepLogsUseCase();
  blocPresentationTest<SleepCubit, SleepState, SleepPresentationEvent>(
    'emits SleepError without reloading when deletion fails',
    build: () {
      final deleteSleepLogUseCase = MockDeleteSleepLogUseCase();
      when(() => deleteSleepLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildSleepCubit(
        deleteSleepLogUseCase: deleteSleepLogUseCase,
        getRecentSleepLogsUseCase: getRecentSleepLogsUseCaseSpy,
      );
    },
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expectPresentation: () => [isA<SleepError>()],
    verify: (_) => verifyNever(() => getRecentSleepLogsUseCaseSpy(days: any(named: 'days'))),
  );
}
