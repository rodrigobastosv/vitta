import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/cubit/app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  void changeLocale(Locale locale) => emit(AppState(locale: locale, themeMode: state.themeMode));

  void useSystemLocale() => emit(AppState(themeMode: state.themeMode));

  void changeThemeMode(ThemeMode themeMode) => emit(AppState(locale: state.locale, themeMode: themeMode));
}
