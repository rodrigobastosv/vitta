import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:vitta/app/core/storage/hive_local_storage_service.dart';
import 'package:vitta/app/data/settings/settings_local_datasource.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> box;
  late SettingsLocalDataSource dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vitta_test_hive');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('app_test');
    dataSource = SettingsLocalDataSource(localStorageService: HiveLocalStorageService(box: box));
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('getLocale returns null when nothing was saved', () {
    expect(dataSource.getLocale(), isNull);
  });

  test('saveLocale persists and getLocale reads it back', () async {
    await dataSource.saveLocale(const Locale('pt'));

    expect(dataSource.getLocale(), const Locale('pt'));
  });

  test('saveLocale with null clears the persisted locale', () async {
    await dataSource.saveLocale(const Locale('pt'));
    await dataSource.saveLocale(null);

    expect(dataSource.getLocale(), isNull);
  });

  test('getThemeMode defaults to system when nothing was saved', () {
    expect(dataSource.getThemeMode(), ThemeMode.system);
  });

  test('saveThemeMode persists and getThemeMode reads it back', () async {
    await dataSource.saveThemeMode(ThemeMode.dark);

    expect(dataSource.getThemeMode(), ThemeMode.dark);
  });
}
