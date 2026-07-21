import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/sleep/sleep_repository.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_import.dart';

import '../../../mocks/datasources_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(<SleepImport>[]);
    registerFallbackValue(DateTime(2000));
  });

  test('stamps the last-synced time after a successful import', () async {
    final supabaseSleepDataSource = MockSupabaseSleepDataSource();
    final sleepLocalDataSource = MockSleepLocalDataSource();
    when(() => supabaseSleepDataSource.importSleepLogs(imports: any(named: 'imports'))).thenAnswer((_) async => const Success(2));
    when(() => sleepLocalDataSource.saveLastSyncedAt(any())).thenAnswer((_) async {});
    final repository = SleepRepository(supabaseSleepDataSource: supabaseSleepDataSource, sleepLocalDataSource: sleepLocalDataSource);

    final importedResult = await repository.importSleepLogs(imports: const []);

    expect(importedResult, const Success<VTError, int>(2));
    verify(() => sleepLocalDataSource.saveLastSyncedAt(any())).called(1);
  });

  test('does not stamp the last-synced time when the import fails', () async {
    final supabaseSleepDataSource = MockSupabaseSleepDataSource();
    final sleepLocalDataSource = MockSleepLocalDataSource();
    when(() => supabaseSleepDataSource.importSleepLogs(imports: any(named: 'imports'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final repository = SleepRepository(supabaseSleepDataSource: supabaseSleepDataSource, sleepLocalDataSource: sleepLocalDataSource);

    await repository.importSleepLogs(imports: const []);

    verifyNever(() => sleepLocalDataSource.saveLastSyncedAt(any()));
  });

  test('reads the last-synced time back from local storage', () {
    final sleepLocalDataSource = MockSleepLocalDataSource();
    final syncedAt = DateTime(2026, 7, 21, 14, 30);
    when(sleepLocalDataSource.getLastSyncedAt).thenReturn(syncedAt);
    final repository = SleepRepository(supabaseSleepDataSource: MockSupabaseSleepDataSource(), sleepLocalDataSource: sleepLocalDataSource);

    expect(repository.getLastSyncedAt(), syncedAt);
  });
}
