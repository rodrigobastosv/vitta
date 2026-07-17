import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/sleep/sleep_repository.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_import.dart';

class ImportSleepFromHealthUseCase {
  ImportSleepFromHealthUseCase({required this._sleepRepository});

  final SleepRepository _sleepRepository;

  Future<Result<VTError, int>> call({required List<SleepImport> imports}) =>
      _sleepRepository.importSleepLogs(imports: imports);
}
