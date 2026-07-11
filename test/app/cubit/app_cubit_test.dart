import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/cubit/app_state.dart';

import '../../factories/cubits_factories.dart';
import '../../mocks/datasources_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(UnitSystem.metric);
  });

  blocTest<AppCubit, AppState>(
    'emits state with the new locale when changeLocale is called',
    build: () {
      final settingsLocalDataSource = MockSettingsLocalDataSource();
      when(settingsLocalDataSource.getLocale).thenReturn(null);
      when(settingsLocalDataSource.getThemeMode).thenReturn(ThemeMode.system);
      when(settingsLocalDataSource.getUnitSystem).thenReturn(UnitSystem.metric);
      when(() => settingsLocalDataSource.saveLocale(any())).thenAnswer((_) async {});
      return CubitsFactories.buildAppCubit(settingsLocalDataSource: settingsLocalDataSource);
    },
    act: (cubit) => cubit.changeLocale(const Locale('pt')),
    expect: () => [const AppState(locale: Locale('pt'))],
  );

  blocTest<AppCubit, AppState>(
    'emits state with a null locale when useSystemLocale is called',
    build: () {
      final settingsLocalDataSource = MockSettingsLocalDataSource();
      when(settingsLocalDataSource.getLocale).thenReturn(null);
      when(settingsLocalDataSource.getThemeMode).thenReturn(ThemeMode.system);
      when(settingsLocalDataSource.getUnitSystem).thenReturn(UnitSystem.metric);
      when(() => settingsLocalDataSource.saveLocale(any())).thenAnswer((_) async {});
      return CubitsFactories.buildAppCubit(settingsLocalDataSource: settingsLocalDataSource);
    },
    seed: () => const AppState(locale: Locale('pt')),
    act: (cubit) => cubit.useSystemLocale(),
    expect: () => [const AppState()],
  );

  blocTest<AppCubit, AppState>(
    'emits state with the new theme mode when changeThemeMode is called',
    build: () {
      final settingsLocalDataSource = MockSettingsLocalDataSource();
      when(settingsLocalDataSource.getLocale).thenReturn(null);
      when(settingsLocalDataSource.getThemeMode).thenReturn(ThemeMode.system);
      when(settingsLocalDataSource.getUnitSystem).thenReturn(UnitSystem.metric);
      when(() => settingsLocalDataSource.saveThemeMode(any())).thenAnswer((_) async {});
      return CubitsFactories.buildAppCubit(settingsLocalDataSource: settingsLocalDataSource);
    },
    act: (cubit) => cubit.changeThemeMode(.dark),
    expect: () => [const AppState(themeMode: .dark)],
  );

  blocTest<AppCubit, AppState>(
    'emits state with the new unit system when changeUnitSystem is called',
    build: () {
      final settingsLocalDataSource = MockSettingsLocalDataSource();
      when(settingsLocalDataSource.getLocale).thenReturn(null);
      when(settingsLocalDataSource.getThemeMode).thenReturn(ThemeMode.system);
      when(settingsLocalDataSource.getUnitSystem).thenReturn(UnitSystem.metric);
      when(() => settingsLocalDataSource.saveUnitSystem(any())).thenAnswer((_) async {});
      return CubitsFactories.buildAppCubit(settingsLocalDataSource: settingsLocalDataSource);
    },
    act: (cubit) => cubit.changeUnitSystem(UnitSystem.imperial),
    expect: () => [const AppState(unitSystem: UnitSystem.imperial)],
  );

  test('loads the persisted locale, theme mode and unit system on construction', () {
    final settingsLocalDataSource = MockSettingsLocalDataSource();
    when(settingsLocalDataSource.getLocale).thenReturn(const Locale('pt'));
    when(settingsLocalDataSource.getThemeMode).thenReturn(ThemeMode.dark);
    when(settingsLocalDataSource.getUnitSystem).thenReturn(UnitSystem.imperial);

    final cubit = CubitsFactories.buildAppCubit(settingsLocalDataSource: settingsLocalDataSource);

    expect(cubit.state, const AppState(locale: Locale('pt'), themeMode: ThemeMode.dark, unitSystem: UnitSystem.imperial));
  });

  test('persists the locale when changeLocale is called', () {
    final settingsLocalDataSource = MockSettingsLocalDataSource();
    when(settingsLocalDataSource.getLocale).thenReturn(null);
    when(settingsLocalDataSource.getThemeMode).thenReturn(ThemeMode.system);
    when(settingsLocalDataSource.getUnitSystem).thenReturn(UnitSystem.metric);
    when(() => settingsLocalDataSource.saveLocale(any())).thenAnswer((_) async {});

    CubitsFactories.buildAppCubit(settingsLocalDataSource: settingsLocalDataSource).changeLocale(const Locale('pt'));

    verify(() => settingsLocalDataSource.saveLocale(const Locale('pt'))).called(1);
  });

  test('persists a null locale when useSystemLocale is called', () {
    final settingsLocalDataSource = MockSettingsLocalDataSource();
    when(settingsLocalDataSource.getLocale).thenReturn(const Locale('pt'));
    when(settingsLocalDataSource.getThemeMode).thenReturn(ThemeMode.system);
    when(settingsLocalDataSource.getUnitSystem).thenReturn(UnitSystem.metric);
    when(() => settingsLocalDataSource.saveLocale(any())).thenAnswer((_) async {});

    CubitsFactories.buildAppCubit(settingsLocalDataSource: settingsLocalDataSource).useSystemLocale();

    verify(() => settingsLocalDataSource.saveLocale(null)).called(1);
  });

  test('persists the theme mode when changeThemeMode is called', () {
    final settingsLocalDataSource = MockSettingsLocalDataSource();
    when(settingsLocalDataSource.getLocale).thenReturn(null);
    when(settingsLocalDataSource.getThemeMode).thenReturn(ThemeMode.system);
    when(settingsLocalDataSource.getUnitSystem).thenReturn(UnitSystem.metric);
    when(() => settingsLocalDataSource.saveThemeMode(any())).thenAnswer((_) async {});

    CubitsFactories.buildAppCubit(settingsLocalDataSource: settingsLocalDataSource).changeThemeMode(ThemeMode.dark);

    verify(() => settingsLocalDataSource.saveThemeMode(ThemeMode.dark)).called(1);
  });

  test('persists the unit system when changeUnitSystem is called', () {
    final settingsLocalDataSource = MockSettingsLocalDataSource();
    when(settingsLocalDataSource.getLocale).thenReturn(null);
    when(settingsLocalDataSource.getThemeMode).thenReturn(ThemeMode.system);
    when(settingsLocalDataSource.getUnitSystem).thenReturn(UnitSystem.metric);
    when(() => settingsLocalDataSource.saveUnitSystem(any())).thenAnswer((_) async {});

    CubitsFactories.buildAppCubit(settingsLocalDataSource: settingsLocalDataSource).changeUnitSystem(UnitSystem.imperial);

    verify(() => settingsLocalDataSource.saveUnitSystem(UnitSystem.imperial)).called(1);
  });
}
