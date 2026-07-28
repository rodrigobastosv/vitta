import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/services/cache/wire_cache_service.dart';

import '../../../../fixtures/local_storage_fixture.dart';

void main() {
  test('reads back the rows it was given', () async {
    final service = WireCacheService(localStorageService: await buildTestLocalStorageService());

    await service.write('diet.dailyLog.user-1.2026-07-28', [
      {'id': 'log-1', 'quantity_grams': 120.0},
    ]);

    expect(service.read('diet.dailyLog.user-1.2026-07-28'), [
      {'id': 'log-1', 'quantity_grams': 120.0},
    ]);
  });

  test('a key never written reads as null rather than empty', () async {
    final service = WireCacheService(localStorageService: await buildTestLocalStorageService());

    expect(service.read('diet.dailyLog.user-1.2026-07-28'), isNull);
  });

  test('rewriting a key replaces it rather than appending', () async {
    final service = WireCacheService(localStorageService: await buildTestLocalStorageService());

    await service.write('day', [
      {'id': 'log-1'},
    ]);
    await service.write('day', [
      {'id': 'log-2'},
    ]);

    expect(service.read('day'), [
      {'id': 'log-2'},
    ]);
  });

  test('evicts the least recently written once it is full, so the box cannot grow forever', () async {
    final service = WireCacheService(localStorageService: await buildTestLocalStorageService());

    for (var day = 0; day < 65; day++) {
      await service.write('day-$day', [
        {'id': 'log-$day'},
      ]);
    }

    expect(service.read('day-0'), isNull);
    expect(service.read('day-4'), isNull);
    expect(service.read('day-5'), isNotNull);
    expect(service.read('day-64'), isNotNull);
  });

  test('clearing drops every cached key', () async {
    final service = WireCacheService(localStorageService: await buildTestLocalStorageService());
    await service.write('day', [
      {'id': 'log-1'},
    ]);

    await service.clear();

    expect(service.read('day'), isNull);
  });
}
