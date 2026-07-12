import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/data/settings/settings_local_datasource.dart';

import '../../../fixtures/local_storage_fixture.dart';

void main() {
  test('getLocale returns null when nothing was saved', () async {
    final dataSource = SettingsLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getLocale(), isNull);
  });

  test('saveLocale persists and getLocale reads it back', () async {
    final dataSource = SettingsLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.saveLocale(const Locale('pt'));

    expect(dataSource.getLocale(), const Locale('pt'));
  });

  test('saveLocale with null clears the persisted locale', () async {
    final dataSource = SettingsLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.saveLocale(const Locale('pt'));
    await dataSource.saveLocale(null);

    expect(dataSource.getLocale(), isNull);
  });

  test('getThemeMode defaults to system when nothing was saved', () async {
    final dataSource = SettingsLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getThemeMode(), ThemeMode.system);
  });

  test('saveThemeMode persists and getThemeMode reads it back', () async {
    final dataSource = SettingsLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.saveThemeMode(ThemeMode.dark);

    expect(dataSource.getThemeMode(), ThemeMode.dark);
  });

  test('getUnitSystem defaults to metric when nothing was saved', () async {
    final dataSource = SettingsLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getUnitSystem(), UnitSystem.metric);
  });

  test('saveUnitSystem persists and getUnitSystem reads it back', () async {
    final dataSource = SettingsLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.saveUnitSystem(UnitSystem.imperial);

    expect(dataSource.getUnitSystem(), UnitSystem.imperial);
  });
}
