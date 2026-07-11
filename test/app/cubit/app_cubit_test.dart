import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/cubit/app_state.dart';

void main() {
  blocTest<AppCubit, AppState>(
    'emits state with the new locale when changeLocale is called',
    build: AppCubit.new,
    act: (cubit) => cubit.changeLocale(const Locale('pt')),
    expect: () => [const AppState(locale: Locale('pt'))],
  );

  blocTest<AppCubit, AppState>(
    'emits state with a null locale when useSystemLocale is called',
    build: AppCubit.new,
    seed: () => const AppState(locale: Locale('pt')),
    act: (cubit) => cubit.useSystemLocale(),
    expect: () => [const AppState()],
  );

  blocTest<AppCubit, AppState>(
    'emits state with the new theme mode when changeThemeMode is called',
    build: AppCubit.new,
    act: (cubit) => cubit.changeThemeMode(.dark),
    expect: () => [const AppState(themeMode: .dark)],
  );
}
