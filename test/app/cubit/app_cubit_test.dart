import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';

import '../../factories/cubits_factories.dart';
import '../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(UnitSystem.metric);
    registerFallbackValue(const AppSettings());
  });

  blocTest<AppCubit, AppSettings>(
    'emits state with the new locale when changeLocale is called',
    build: () {
      final getAppSettingsUseCase = MockGetAppSettingsUseCase();
      when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
      final saveAppSettingsUseCase = MockSaveAppSettingsUseCase();
      when(() => saveAppSettingsUseCase(any())).thenAnswer((_) async {});
      return CubitsFactories.buildAppCubit(getAppSettingsUseCase: getAppSettingsUseCase, saveAppSettingsUseCase: saveAppSettingsUseCase);
    },
    act: (cubit) => cubit.changeLocale(const Locale('pt')),
    expect: () => [const AppSettings(locale: Locale('pt'))],
  );

  blocTest<AppCubit, AppSettings>(
    'emits state with a null locale when useSystemLocale is called',
    build: () {
      final getAppSettingsUseCase = MockGetAppSettingsUseCase();
      when(getAppSettingsUseCase.call).thenReturn(const AppSettings(locale: Locale('pt')));
      final saveAppSettingsUseCase = MockSaveAppSettingsUseCase();
      when(() => saveAppSettingsUseCase(any())).thenAnswer((_) async {});
      return CubitsFactories.buildAppCubit(getAppSettingsUseCase: getAppSettingsUseCase, saveAppSettingsUseCase: saveAppSettingsUseCase);
    },
    act: (cubit) => cubit.useSystemLocale(),
    expect: () => [const AppSettings()],
  );

  blocTest<AppCubit, AppSettings>(
    'emits state with the new theme mode when changeThemeMode is called',
    build: () {
      final getAppSettingsUseCase = MockGetAppSettingsUseCase();
      when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
      final saveAppSettingsUseCase = MockSaveAppSettingsUseCase();
      when(() => saveAppSettingsUseCase(any())).thenAnswer((_) async {});
      return CubitsFactories.buildAppCubit(getAppSettingsUseCase: getAppSettingsUseCase, saveAppSettingsUseCase: saveAppSettingsUseCase);
    },
    act: (cubit) => cubit.changeThemeMode(ThemeMode.dark),
    expect: () => [const AppSettings(themeMode: ThemeMode.dark)],
  );

  blocTest<AppCubit, AppSettings>(
    'emits state with the new unit system when changeUnitSystem is called',
    build: () {
      final getAppSettingsUseCase = MockGetAppSettingsUseCase();
      when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
      final saveAppSettingsUseCase = MockSaveAppSettingsUseCase();
      when(() => saveAppSettingsUseCase(any())).thenAnswer((_) async {});
      return CubitsFactories.buildAppCubit(getAppSettingsUseCase: getAppSettingsUseCase, saveAppSettingsUseCase: saveAppSettingsUseCase);
    },
    act: (cubit) => cubit.changeUnitSystem(UnitSystem.imperial),
    expect: () => [const AppSettings(unitSystem: UnitSystem.imperial)],
  );

  test('loads the persisted settings on construction', () {
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(const AppSettings(locale: Locale('pt'), themeMode: ThemeMode.dark, unitSystem: UnitSystem.imperial));

    final cubit = CubitsFactories.buildAppCubit(getAppSettingsUseCase: getAppSettingsUseCase);

    expect(cubit.state, const AppSettings(locale: Locale('pt'), themeMode: ThemeMode.dark, unitSystem: UnitSystem.imperial));
  });

  test('persists the new settings when changeLocale is called', () {
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
    final saveAppSettingsUseCase = MockSaveAppSettingsUseCase();
    when(() => saveAppSettingsUseCase(any())).thenAnswer((_) async {});

    CubitsFactories.buildAppCubit(
      getAppSettingsUseCase: getAppSettingsUseCase,
      saveAppSettingsUseCase: saveAppSettingsUseCase,
    ).changeLocale(const Locale('pt'));

    verify(() => saveAppSettingsUseCase(const AppSettings(locale: Locale('pt')))).called(1);
  });

  test('persists a null locale when useSystemLocale is called', () {
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(const AppSettings(locale: Locale('pt')));
    final saveAppSettingsUseCase = MockSaveAppSettingsUseCase();
    when(() => saveAppSettingsUseCase(any())).thenAnswer((_) async {});

    CubitsFactories.buildAppCubit(getAppSettingsUseCase: getAppSettingsUseCase, saveAppSettingsUseCase: saveAppSettingsUseCase).useSystemLocale();

    verify(() => saveAppSettingsUseCase(const AppSettings())).called(1);
  });

  test('persists the new settings when changeThemeMode is called', () {
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
    final saveAppSettingsUseCase = MockSaveAppSettingsUseCase();
    when(() => saveAppSettingsUseCase(any())).thenAnswer((_) async {});

    CubitsFactories.buildAppCubit(getAppSettingsUseCase: getAppSettingsUseCase, saveAppSettingsUseCase: saveAppSettingsUseCase).changeThemeMode(ThemeMode.dark);

    verify(() => saveAppSettingsUseCase(const AppSettings(themeMode: ThemeMode.dark))).called(1);
  });

  test('persists the new settings when changeUnitSystem is called', () {
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
    final saveAppSettingsUseCase = MockSaveAppSettingsUseCase();
    when(() => saveAppSettingsUseCase(any())).thenAnswer((_) async {});

    CubitsFactories.buildAppCubit(
      getAppSettingsUseCase: getAppSettingsUseCase,
      saveAppSettingsUseCase: saveAppSettingsUseCase,
    ).changeUnitSystem(UnitSystem.imperial);

    verify(() => saveAppSettingsUseCase(const AppSettings(unitSystem: UnitSystem.imperial))).called(1);
  });
}
