import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:vitta/app/core/storage/hive_local_storage_service.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> box;
  late HiveLocalStorageService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vitta_test_hive');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('local_storage_test');
    service = HiveLocalStorageService(box: box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('get returns null for a key that was never written', () {
    expect(service.get<String>('missing'), isNull);
  });

  test('put persists a value and get reads it back', () async {
    await service.put('key', 'value');

    expect(service.get<String>('key'), 'value');
  });

  test('delete removes a persisted value', () async {
    await service.put('key', 'value');
    await service.delete('key');

    expect(service.get<String>('key'), isNull);
  });
}
