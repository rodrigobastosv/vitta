import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/general/trend_range.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/body_weight_history_cubit.dart';
import 'package:vitta/app/presentation/pages/body_weight_history/body_weight_history_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/body_weight_log_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

MockGetAppSettingsUseCase _settingsUseCase() {
  final useCase = MockGetAppSettingsUseCase();
  when(useCase.call).thenReturn(const AppSettings());
  return useCase;
}

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  blocTest<BodyWeightHistoryCubit, BodyWeightHistoryState>(
    'loads the logs for the selected trend range',
    build: () {
      final getBodyWeightInRangeUseCase = MockGetBodyWeightInRangeUseCase();
      when(() => getBodyWeightInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => Success([BodyWeightLogFactory.build()]));
      return CubitsFactories.buildBodyWeightHistoryCubit(
        getBodyWeightInRangeUseCase: getBodyWeightInRangeUseCase,
        getAppSettingsUseCase: _settingsUseCase(),
      );
    },
    act: (cubit) => cubit.onInit(),
    expect: () => [isA<BodyWeightHistoryState>().having((state) => state.logs.length, 'logs', 1)],
  );

  blocTest<BodyWeightHistoryCubit, BodyWeightHistoryState>(
    'changeTrendRange updates the range and reloads',
    build: () {
      final getBodyWeightInRangeUseCase = MockGetBodyWeightInRangeUseCase();
      when(() => getBodyWeightInRangeUseCase(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildBodyWeightHistoryCubit(
        getBodyWeightInRangeUseCase: getBodyWeightInRangeUseCase,
        getAppSettingsUseCase: _settingsUseCase(),
      );
    },
    act: (cubit) => cubit.changeTrendRange(TrendRange.week),
    expect: () => [
      isA<BodyWeightHistoryState>().having((state) => state.trendRange, 'trendRange', TrendRange.week),
      isA<BodyWeightHistoryState>().having((state) => state.isLoaded, 'loaded once the range resolves', isTrue),
    ],
  );
}
