import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/health/health_sleep_session.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_import.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_presentation_event.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/sleep_log_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(<String, Object?>{});
    registerFallbackValue(<SleepImport>[]);
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
      () => logSleepUseCase(
        bedTime: any(named: 'bedTime'),
        wakeTime: any(named: 'wakeTime'),
        qualityRating: 4,
      ),
    ).thenAnswer((_) async => Success(SleepLogFactory.build()));
    when(() => getRecentSleepLogsUseCase(days: 7)).thenAnswer((_) async => const Success([]));
    final cubit = CubitsFactories.buildSleepCubit(logSleepUseCase: logSleepUseCase, getRecentSleepLogsUseCase: getRecentSleepLogsUseCase);

    await cubit.logSleep(bedTime: DateTime(2026, 7, 10, 22, 30), wakeTime: DateTime(2026, 7, 11, 6, 45), qualityRating: 4);

    final captured = verify(() => loggingService.logAction(captureAny(), data: captureAny(named: 'data'))).captured;
    expect(captured, [
      'sleep_logged',
      {'quality': 4},
    ]);
  });

  final deleteReloadSpy = MockGetRecentSleepLogsUseCase();
  blocTest<SleepCubit, SleepState>(
    'optimistically removes a log without reloading',
    build: () {
      final deleteSleepLogUseCase = MockDeleteSleepLogUseCase();
      when(() => deleteSleepLogUseCase(logId: 'log-1')).thenAnswer((_) async => const Success(null));
      return CubitsFactories.buildSleepCubit(deleteSleepLogUseCase: deleteSleepLogUseCase, getRecentSleepLogsUseCase: deleteReloadSpy);
    },
    seed: () => SleepState(logs: [SleepLogFactory.build(id: 'log-1')]),
    act: (cubit) => cubit.deleteLog(logId: 'log-1'),
    expect: () => [isA<SleepState>().having((state) => state.logs, 'logs', isEmpty)],
    verify: (_) => verifyNever(() => deleteReloadSpy(days: any(named: 'days'))),
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

  test('importFromHealth imports the read sessions and reloads the list', () async {
    useMockLog();
    final healthService = MockHealthService();
    when(healthService.isAvailable).thenAnswer((_) async => true);
    when(healthService.requestSleepAuthorization).thenAnswer((_) async => true);
    when(() => healthService.readSleepSessions(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer(
      (_) async => [
        HealthSleepSession(start: DateTime(2026, 7, 10, 23), end: DateTime(2026, 7, 11, 6, 30), externalId: 'ext-1'),
      ],
    );
    final importSleepFromHealthUseCase = MockImportSleepFromHealthUseCase();
    when(() => importSleepFromHealthUseCase(imports: any(named: 'imports'))).thenAnswer((_) async => const Success(1));
    final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
    when(() => getRecentSleepLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => Success([SleepLogFactory.build()]));
    final cubit = CubitsFactories.buildSleepCubit(
      healthService: healthService,
      importSleepFromHealthUseCase: importSleepFromHealthUseCase,
      getRecentSleepLogsUseCase: getRecentSleepLogsUseCase,
    );

    await cubit.importFromHealth();

    final captured = verify(() => importSleepFromHealthUseCase(imports: captureAny(named: 'imports'))).captured.single as List<SleepImport>;
    expect(captured.single.externalId, 'ext-1');
    verify(() => getRecentSleepLogsUseCase(days: any(named: 'days'))).called(1);
    expect(cubit.state.logs, isNotEmpty);
  });

  test('onInit auto-syncs new nights from Health without prompting for permission', () async {
    useMockLog();
    final healthService = MockHealthService();
    when(healthService.isAvailable).thenAnswer((_) async => true);
    when(() => healthService.readSleepSessions(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer(
      (_) async => [
        HealthSleepSession(start: DateTime(2026, 7, 10, 23), end: DateTime(2026, 7, 11, 6, 30), externalId: 'ext-1'),
      ],
    );
    final importSleepFromHealthUseCase = MockImportSleepFromHealthUseCase();
    when(() => importSleepFromHealthUseCase(imports: any(named: 'imports'))).thenAnswer((_) async => const Success(1));
    final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
    when(() => getRecentSleepLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => Success([SleepLogFactory.build()]));
    final cubit = CubitsFactories.buildSleepCubit(
      healthService: healthService,
      importSleepFromHealthUseCase: importSleepFromHealthUseCase,
      getRecentSleepLogsUseCase: getRecentSleepLogsUseCase,
    );
    final events = <SleepPresentationEvent>[];
    final subscription = cubit.presentation.listen(events.add);

    cubit.onInit();
    await pumpEventQueue();
    await subscription.cancel();

    verify(() => importSleepFromHealthUseCase(imports: any(named: 'imports'))).called(1);
    verifyNever(healthService.requestSleepAuthorization);
    expect(events.whereType<SleepImported>(), isNotEmpty);
    expect(cubit.state.logs, isNotEmpty);
  });

  test('onInit auto-sync stays silent when Health has no new nights', () async {
    useMockLog();
    final healthService = MockHealthService();
    when(healthService.isAvailable).thenAnswer((_) async => true);
    when(() => healthService.readSleepSessions(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => []);
    final importSleepFromHealthUseCase = MockImportSleepFromHealthUseCase();
    when(() => importSleepFromHealthUseCase(imports: any(named: 'imports'))).thenAnswer((_) async => const Success(0));
    final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
    when(() => getRecentSleepLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => const Success([]));
    final cubit = CubitsFactories.buildSleepCubit(
      healthService: healthService,
      importSleepFromHealthUseCase: importSleepFromHealthUseCase,
      getRecentSleepLogsUseCase: getRecentSleepLogsUseCase,
    );
    final events = <SleepPresentationEvent>[];
    final subscription = cubit.presentation.listen(events.add);

    cubit.onInit();
    await pumpEventQueue();
    await subscription.cancel();

    expect(events.whereType<SleepImported>(), isEmpty);
    expect(events.whereType<SleepError>(), isEmpty);
  });

  test('onInit auto-sync swallows a Health read failure without an error toast', () async {
    final healthService = MockHealthService();
    when(healthService.isAvailable).thenAnswer((_) async => true);
    when(() => healthService.readSleepSessions(from: any(named: 'from'), to: any(named: 'to'))).thenThrow(Exception('healthkit blew up'));
    final getRecentSleepLogsUseCase = MockGetRecentSleepLogsUseCase();
    when(() => getRecentSleepLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => Success([SleepLogFactory.build()]));
    final cubit = CubitsFactories.buildSleepCubit(healthService: healthService, getRecentSleepLogsUseCase: getRecentSleepLogsUseCase);
    final events = <SleepPresentationEvent>[];
    final subscription = cubit.presentation.listen(events.add);

    cubit.onInit();
    await pumpEventQueue();
    await subscription.cancel();

    expect(events.whereType<SleepError>(), isEmpty);
    expect(cubit.state.logs, isNotEmpty);
  });

  blocPresentationTest<SleepCubit, SleepState, SleepPresentationEvent>(
    'importFromHealth reports when the health platform is unavailable',
    build: () {
      final healthService = MockHealthService();
      when(healthService.isAvailable).thenAnswer((_) async => false);
      return CubitsFactories.buildSleepCubit(healthService: healthService);
    },
    act: (cubit) => cubit.importFromHealth(),
    expectPresentation: () => [isA<SleepShowLoading>(), isA<SleepHealthUnavailable>(), isA<SleepHideLoading>()],
  );

  blocPresentationTest<SleepCubit, SleepState, SleepPresentationEvent>(
    'importFromHealth reports when sleep permission is denied',
    build: () {
      final healthService = MockHealthService();
      when(healthService.isAvailable).thenAnswer((_) async => true);
      when(healthService.requestSleepAuthorization).thenAnswer((_) async => false);
      return CubitsFactories.buildSleepCubit(healthService: healthService);
    },
    act: (cubit) => cubit.importFromHealth(),
    expectPresentation: () => [isA<SleepShowLoading>(), isA<SleepHealthPermissionDenied>(), isA<SleepHideLoading>()],
  );
}
