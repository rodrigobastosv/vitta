import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';
import 'package:vitta/app/domain/home/entities/home_slot.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_cubit.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(HomeLayout.shipped));

  test('the cubit starts on the saved layout', () {
    final getHomeLayoutUseCase = MockGetHomeLayoutUseCase();
    when(getHomeLayoutUseCase.call).thenReturn(HomeLayout.shipped);

    final cubit = CubitsFactories.buildHomeLayoutCubit(getHomeLayoutUseCase: getHomeLayoutUseCase);

    expect(cubit.state.layout, HomeLayout.shipped);
  });

  final saveHomeLayoutUseCase = MockSaveHomeLayoutUseCase();
  blocTest<HomeLayoutCubit, HomeLayoutState>(
    'changing a slot promotes the feature and persists the layout',
    build: () {
      final getHomeLayoutUseCase = MockGetHomeLayoutUseCase();
      when(getHomeLayoutUseCase.call).thenReturn(HomeLayout.shipped);
      when(() => saveHomeLayoutUseCase(layout: any(named: 'layout'))).thenAnswer((_) async {});
      return CubitsFactories.buildHomeLayoutCubit(getHomeLayoutUseCase: getHomeLayoutUseCase, saveHomeLayoutUseCase: saveHomeLayoutUseCase);
    },
    act: (cubit) => cubit.changeSlot(feature: .workout, slot: .hero),
    expect: () => [HomeLayoutState(layout: HomeLayout.shipped.withSlot(feature: HomeFeature.workout, slot: HomeSlot.hero))],
    verify: (_) => verify(() => saveHomeLayoutUseCase(layout: HomeLayout.shipped.withSlot(feature: HomeFeature.workout, slot: HomeSlot.hero))).called(1),
  );

  blocTest<HomeLayoutCubit, HomeLayoutState>(
    'reordering moves the feature and persists the new order',
    build: () {
      final getHomeLayoutUseCase = MockGetHomeLayoutUseCase();
      when(getHomeLayoutUseCase.call).thenReturn(HomeLayout.shipped);
      final saveHomeLayoutUseCase = MockSaveHomeLayoutUseCase();
      when(() => saveHomeLayoutUseCase(layout: any(named: 'layout'))).thenAnswer((_) async {});
      return CubitsFactories.buildHomeLayoutCubit(getHomeLayoutUseCase: getHomeLayoutUseCase, saveHomeLayoutUseCase: saveHomeLayoutUseCase);
    },
    act: (cubit) => cubit.reorderFeatures(oldIndex: 0, newIndex: 1),
    expect: () => [HomeLayoutState(layout: HomeLayout.shipped.reordered(oldIndex: 0, newIndex: 1))],
  );

  blocTest<HomeLayoutCubit, HomeLayoutState>(
    'resetting restores the shipped hierarchy',
    build: () {
      final getHomeLayoutUseCase = MockGetHomeLayoutUseCase();
      when(getHomeLayoutUseCase.call).thenReturn(HomeLayout.shipped.withSlot(feature: HomeFeature.sleep, slot: HomeSlot.hero));
      final saveHomeLayoutUseCase = MockSaveHomeLayoutUseCase();
      when(() => saveHomeLayoutUseCase(layout: any(named: 'layout'))).thenAnswer((_) async {});
      return CubitsFactories.buildHomeLayoutCubit(getHomeLayoutUseCase: getHomeLayoutUseCase, saveHomeLayoutUseCase: saveHomeLayoutUseCase);
    },
    act: (cubit) => cubit.resetToDefault(),
    expect: () => [const HomeLayoutState(layout: HomeLayout.shipped)],
  );
}
