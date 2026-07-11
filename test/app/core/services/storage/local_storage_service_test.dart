import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/local_storage_fixture.dart';

void main() {
  test('get returns null for a key that was never written', () async {
    final service = await buildTestLocalStorageService();

    expect(service.get<String>('missing'), isNull);
  });

  test('put persists a value and get reads it back', () async {
    final service = await buildTestLocalStorageService();

    await service.put('key', 'value');

    expect(service.get<String>('key'), 'value');
  });

  test('delete removes a persisted value', () async {
    final service = await buildTestLocalStorageService();

    await service.put('key', 'value');
    await service.delete('key');

    expect(service.get<String>('key'), isNull);
  });
}
