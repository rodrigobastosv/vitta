import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_cubit.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_presentation_event.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/body_weight_log_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

MockGetAppSettingsUseCase _settingsUseCase() {
  final useCase = MockGetAppSettingsUseCase();
  when(useCase.call).thenReturn(const AppSettings());
  return useCase;
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(<String, Object?>{});
  });

  blocTest<BodyWeightCubit, BodyWeightState>(
    'emits the recent logs when loadRecent succeeds',
    build: () {
      final getRecentBodyWeightLogsUseCase = MockGetRecentBodyWeightLogsUseCase();
      when(() => getRecentBodyWeightLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => Success([BodyWeightLogFactory.build()]));
      return CubitsFactories.buildBodyWeightCubit(getRecentBodyWeightLogsUseCase: getRecentBodyWeightLogsUseCase, getAppSettingsUseCase: _settingsUseCase());
    },
    act: (cubit) => cubit.loadRecent(),
    expect: () => [isA<BodyWeightState>().having((state) => state.logs.length, 'logs', 1)],
  );

  blocPresentationTest<BodyWeightCubit, BodyWeightState, BodyWeightPresentationEvent>(
    'shows then hides loading while loadRecent runs',
    build: () {
      final getRecentBodyWeightLogsUseCase = MockGetRecentBodyWeightLogsUseCase();
      when(() => getRecentBodyWeightLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildBodyWeightCubit(getRecentBodyWeightLogsUseCase: getRecentBodyWeightLogsUseCase, getAppSettingsUseCase: _settingsUseCase());
    },
    act: (cubit) => cubit.loadRecent(),
    expectPresentation: () => [isA<BodyWeightShowLoading>(), isA<BodyWeightHideLoading>()],
  );

  blocPresentationTest<BodyWeightCubit, BodyWeightState, BodyWeightPresentationEvent>(
    'emits BodyWeightError when loadRecent fails',
    build: () {
      final getRecentBodyWeightLogsUseCase = MockGetRecentBodyWeightLogsUseCase();
      when(() => getRecentBodyWeightLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return CubitsFactories.buildBodyWeightCubit(getRecentBodyWeightLogsUseCase: getRecentBodyWeightLogsUseCase, getAppSettingsUseCase: _settingsUseCase());
    },
    act: (cubit) => cubit.loadRecent(),
    expectPresentation: () => [isA<BodyWeightShowLoading>(), isA<BodyWeightHideLoading>(), isA<BodyWeightError>()],
  );

  test('logWeight reloads the recent logs and logs an action', () async {
    useMockLog();
    final logBodyWeightUseCase = MockLogBodyWeightUseCase();
    when(
      () => logBodyWeightUseCase(
        loggedDate: any(named: 'loggedDate'),
        weightKg: any(named: 'weightKg'),
      ),
    ).thenAnswer((_) async => Success(BodyWeightLogFactory.build()));
    final getRecentBodyWeightLogsUseCase = MockGetRecentBodyWeightLogsUseCase();
    when(() => getRecentBodyWeightLogsUseCase(days: any(named: 'days'))).thenAnswer((_) async => Success([BodyWeightLogFactory.build()]));
    final cubit = CubitsFactories.buildBodyWeightCubit(
      logBodyWeightUseCase: logBodyWeightUseCase,
      getRecentBodyWeightLogsUseCase: getRecentBodyWeightLogsUseCase,
      getAppSettingsUseCase: _settingsUseCase(),
    );

    await cubit.logWeight(loggedDate: DateTime(2026, 7, 18), weightKg: 74);

    verify(() => getRecentBodyWeightLogsUseCase(days: any(named: 'days'))).called(1);
    expect(cubit.state.logs, isNotEmpty);
  });

  test('deleteLog optimistically removes the log', () async {
    useMockLog();
    final deleteBodyWeightLogUseCase = MockDeleteBodyWeightLogUseCase();
    when(() => deleteBodyWeightLogUseCase(logId: 'bw-old')).thenAnswer((_) async => const Success(null));
    final getRecentBodyWeightLogsUseCase = MockGetRecentBodyWeightLogsUseCase();
    when(
      () => getRecentBodyWeightLogsUseCase(days: any(named: 'days')),
    ).thenAnswer((_) async => Success([BodyWeightLogFactory.build(id: 'bw-old'), BodyWeightLogFactory.build(id: 'bw-2')]));
    final cubit = CubitsFactories.buildBodyWeightCubit(
      deleteBodyWeightLogUseCase: deleteBodyWeightLogUseCase,
      getRecentBodyWeightLogsUseCase: getRecentBodyWeightLogsUseCase,
      getAppSettingsUseCase: _settingsUseCase(),
    );
    await cubit.loadRecent();

    await cubit.deleteLog(logId: 'bw-old');

    expect(cubit.state.logs.map((log) => log.id), ['bw-2']);
  });
}
